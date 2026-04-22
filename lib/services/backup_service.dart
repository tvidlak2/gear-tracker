/// Google Drive cloud backup service.
///
/// Supports:
///   - Google Sign-In with Drive file scope
///   - backup()  – zip DB + photos → upload to Drive
///   - restore() – download latest zip → extract DB + photos
///   - listBackups() – list backup files on Drive
///   - autoBackupIfNeeded() – back up if > 7 days since last backup
///   - Keep last 3 backups on Drive
library;

import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'purchase_service.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _kDriveFolderName  = 'OutdoorGearTracker Backup';
const _kLastBackupKey    = 'last_backup_date';
const _kAutoBackupKey    = 'auto_backup_enabled';
const _kMaxBackups       = 3;
const _kBackupIntervalDays = 7;

// ─── Auth client ──────────────────────────────────────────────────────────────

/// Minimal HTTP client that injects Google OAuth2 headers.
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

// ─── Service ──────────────────────────────────────────────────────────────────

class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  final _progressController = StreamController<String>.broadcast();

  /// Stream emitting progress messages during backup/restore.
  Stream<String> get progressStream => _progressController.stream;

  // On web the google_sign_in_web plugin requires clientId to be set even
  // though we don't actually use Google Sign-In on web (we throw in signIn()).
  // Passing a placeholder satisfies the plugin's assertion without enabling
  // actual web OAuth (which would need a real Google Cloud web client ID).
  final _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? 'web-not-supported' : null,
    scopes: [
      drive.DriveApi.driveFileScope,
      'email',
    ],
  );

  GoogleSignInAccount? _currentUser;

  /// Currently signed-in Google account (null if not signed in).
  GoogleSignInAccount? get currentUser => _currentUser;

  // ── Sign-in / sign-out ────────────────────────────────────────────────────

  /// Attempts silent sign-in first; prompts user if needed.
  ///
  /// Returns the account on success, null if the user cancelled, or throws
  /// a [BackupException] with a human-readable message on failure.
  Future<GoogleSignInAccount?> signIn() async {
    if (kIsWeb) {
      throw const BackupException(
        'Google Drive záloha není na webu podporována. Použij Android aplikaci.',
      );
    }
    try {
      debugPrint('[GoogleSignIn] Starting sign in...');

      // Try silent first to avoid unnecessary OAuth dialog
      _currentUser = await _googleSignIn.signInSilently();
      debugPrint('[GoogleSignIn] Silent result: ${_currentUser?.email ?? 'null'}');

      if (_currentUser == null) {
        debugPrint('[GoogleSignIn] Silent failed, starting interactive...');
        _currentUser = await _googleSignIn.signIn();
        debugPrint('[GoogleSignIn] Interactive result: ${_currentUser?.email ?? 'null (cancelled)'}');
      }

      if (_currentUser != null) {
        final auth = await _currentUser!.authentication;
        debugPrint('[GoogleSignIn] Access token present: ${auth.accessToken != null}');
        debugPrint('[GoogleSignIn] ID token present: ${auth.idToken != null}');
        debugPrint('[GoogleSignIn] Signed in as: ${_currentUser!.email}');
      }

      return _currentUser;
    } on PlatformException catch (e) {
      debugPrint('[GoogleSignIn] PlatformException: code=${e.code}, message=${e.message}');
      debugPrint('[GoogleSignIn] Details: ${e.details}');
      // Rethrow with the actual error code so the UI can show it
      throw BackupException(
        'Google Sign-In chyba ${e.code}: ${e.message ?? e.details ?? 'neznámá chyba'}',
      );
    } catch (e, stack) {
      debugPrint('[GoogleSignIn] Unknown error: $e');
      debugPrint('[GoogleSignIn] Stack: $stack');
      throw BackupException('Přihlášení Google selhalo: $e');
    }
  }

  /// Signs the user out from Google.
  Future<void> signOut() async {
    if (kIsWeb) return;
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
    } catch (e) {
      debugPrint('BackupService.signOut error: $e');
    }
  }

  /// Restores the sign-in state silently on app start.
  Future<void> restoreSignIn() async {
    if (kIsWeb) return;
    try {
      _currentUser = await _googleSignIn.signInSilently();
    } catch (e) {
      debugPrint('BackupService.restoreSignIn error: $e');
    }
  }

  // ── Backup ────────────────────────────────────────────────────────────────

  /// Creates a zip of the SQLite DB + photos directory and uploads to Drive.
  /// Returns the name of the created backup file.
  Future<String> backup() async {
    _emit('Přihlašování...');

    final account = _currentUser ?? await signIn();
    if (account == null) throw BackupException('Přihlášení se nezdařilo.');

    final driveApi = await _driveApi(account);

    _emit('Příprava zálohy...');

    final zipBytes = await _createZip();

    final dateStr  = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final fileName = 'geartracker_backup_$dateStr.zip';

    _emit('Nahrávání na Google Drive...');

    final folderId = await _ensureFolder(driveApi);

    final media = drive.Media(
      Stream.value(zipBytes),
      zipBytes.length,
      contentType: 'application/zip',
    );

    final fileMetadata = drive.File()
      ..name    = fileName
      ..parents = [folderId];

    await driveApi.files.create(
      fileMetadata,
      uploadMedia: media,
    );

    _emit('Čistění starých záloh...');
    await _pruneOldBackups(driveApi, folderId);

    // Persist last backup date
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastBackupKey, DateTime.now().toIso8601String());

    _emit('Záloha dokončena.');
    return fileName;
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  /// Downloads the most recent backup from Drive and restores DB + photos.
  Future<void> restore() async {
    _emit('Přihlašování...');

    final account = _currentUser ?? await signIn();
    if (account == null) throw BackupException('Přihlášení se nezdařilo.');

    final driveApi = await _driveApi(account);

    _emit('Hledání zálohy...');

    final folderId = await _ensureFolder(driveApi);
    final backups  = await _listBackupFiles(driveApi, folderId);

    if (backups.isEmpty) throw BackupException('Žádné zálohy nenalezeny.');

    // Latest backup = last alphabetically (date-based names)
    final latest = backups.last;

    _emit('Stahování ${latest.name}...');

    final response = await driveApi.files.get(
      latest.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = await _collectStream(response.stream);

    _emit('Obnovování dat...');

    await _extractZip(bytes);

    _emit('Obnova dokončena.');
  }

  // ── List backups ──────────────────────────────────────────────────────────

  /// Returns a list of backup file metadata from Drive, sorted by name asc.
  Future<List<drive.File>> listBackups() async {
    final account = _currentUser ?? await signIn();
    if (account == null) return [];

    try {
      final driveApi = await _driveApi(account);
      final folderId = await _ensureFolder(driveApi);
      return _listBackupFiles(driveApi, folderId);
    } catch (e) {
      debugPrint('BackupService.listBackups error: $e');
      return [];
    }
  }

  // ── Auto-backup ───────────────────────────────────────────────────────────

  /// Runs backup if:
  ///  - User is Premium
  ///  - Auto-backup is enabled in SharedPreferences
  ///  - Last backup was > 7 days ago (or never)
  Future<void> autoBackupIfNeeded() async {
    if (kIsWeb) return;

    try {
      final premium = await PurchaseService.instance.isPremium();
      if (!premium) return;

      final prefs      = await SharedPreferences.getInstance();
      final autoEnabled = prefs.getBool(_kAutoBackupKey) ?? false;
      if (!autoEnabled) return;

      final lastStr = prefs.getString(_kLastBackupKey);
      if (lastStr != null) {
        final last = DateTime.tryParse(lastStr);
        if (last != null) {
          final age = DateTime.now().difference(last).inDays;
          if (age < _kBackupIntervalDays) return;
        }
      }

      // Ensure signed in silently (don't show UI in background)
      _currentUser ??= await _googleSignIn.signInSilently();
      if (_currentUser == null) return;

      await backup();
    } catch (e) {
      // Auto-backup is silent — never crash the app
      debugPrint('BackupService.autoBackupIfNeeded error: $e');
    }
  }

  // ── SharedPreferences helpers ─────────────────────────────────────────────

  Future<String?> getLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastBackupKey);
  }

  Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kAutoBackupKey) ?? false;
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoBackupKey, enabled);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _emit(String message) {
    debugPrint('BackupService: $message');
    _progressController.add(message);
  }

  Future<drive.DriveApi> _driveApi(GoogleSignInAccount account) async {
    final headers = await account.authHeaders;
    final client  = GoogleAuthClient(headers);
    return drive.DriveApi(client);
  }

  /// Returns the Drive folder ID for "OutdoorGearTracker Backup", creating it if absent.
  Future<String> _ensureFolder(drive.DriveApi api) async {
    final result = await api.files.list(
      q: "name='$_kDriveFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id,name)',
    );

    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id!;
    }

    // Create the folder
    final folder = drive.File()
      ..name     = _kDriveFolderName
      ..mimeType = 'application/vnd.google-apps.folder';

    final created = await api.files.create(folder);
    return created.id!;
  }

  Future<List<drive.File>> _listBackupFiles(
      drive.DriveApi api, String folderId) async {
    final result = await api.files.list(
      q: "'$folderId' in parents and name contains 'geartracker_backup_' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id,name,createdTime)',
      orderBy: 'name',
    );
    return result.files ?? [];
  }

  /// Deletes oldest backups if there are more than [_kMaxBackups].
  Future<void> _pruneOldBackups(drive.DriveApi api, String folderId) async {
    final files = await _listBackupFiles(api, folderId);
    if (files.length <= _kMaxBackups) return;

    final toDelete = files.sublist(0, files.length - _kMaxBackups);
    for (final f in toDelete) {
      await api.files.delete(f.id!);
      debugPrint('BackupService: deleted old backup ${f.name}');
    }
  }

  /// Creates a zip archive containing the SQLite DB and the photos directory.
  Future<Uint8List> _createZip() async {
    final archive = Archive();

    // Add SQLite database
    final dbPath  = p.join(await getDatabasesPath(), 'gear_tracker.db');
    final dbFile  = File(dbPath);
    if (dbFile.existsSync()) {
      final bytes = await dbFile.readAsBytes();
      archive.addFile(ArchiveFile('gear_tracker.db', bytes.length, bytes));
    }

    // Add photos directory
    final docsDir   = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docsDir.path, 'photos'));
    if (photosDir.existsSync()) {
      final files = photosDir
          .listSync(recursive: true)
          .whereType<File>()
          .toList();
      for (final f in files) {
        final relative = p.relative(f.path, from: docsDir.path);
        final bytes    = await f.readAsBytes();
        archive.addFile(ArchiveFile(relative, bytes.length, bytes));
      }
    }

    final encoder = ZipEncoder();
    final encoded = encoder.encode(archive);
    return Uint8List.fromList(encoded ?? []);
  }

  /// Extracts a zip archive and restores DB + photos.
  Future<void> _extractZip(Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    final docsDir = await getApplicationDocumentsDirectory();
    final dbDir   = await getDatabasesPath();

    for (final file in archive) {
      if (!file.isFile) continue;

      final name = file.name;
      final data = file.content as List<int>;

      if (name == 'gear_tracker.db') {
        final dest = File(p.join(dbDir, 'gear_tracker.db'));
        await dest.writeAsBytes(data, flush: true);
      } else if (name.startsWith('photos/') || name.startsWith('photos\\')) {
        final dest = File(p.join(docsDir.path, name));
        await dest.parent.create(recursive: true);
        await dest.writeAsBytes(data, flush: true);
      }
    }
  }

  /// Collects a byte stream into a single [Uint8List].
  Future<Uint8List> _collectStream(Stream<List<int>> stream) async {
    final chunks = <int>[];
    await for (final chunk in stream) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }
}

// ─── Exception ────────────────────────────────────────────────────────────────

class BackupException implements Exception {
  final String message;
  const BackupException(this.message);
  @override
  String toString() => message;
}

import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../main.dart' show localeNotifier, themeModeNotifier;
import '../models/strava_models.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../services/purchase_service.dart';
import '../services/strava_service.dart';
import '../services/widget_service.dart';
import 'paywall_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _notifSvc  = NotificationService.instance;
  final _stravaSvc = StravaService.instance;
  final _db        = DatabaseHelper.instance;

  bool _notificationsEnabled = false;
  bool _notifLoading = true;

  // App version
  String _appVersion = '';

  // Premium state
  bool _isPremium       = false;
  bool _premiumLoading  = true;

  // Language state
  String _currentLocale = 'cs';

  static const _languages = [
    ('cs', '🇨🇿', 'Čeština'),
    ('sk', '🇸🇰', 'Slovenčina'),
    ('en', '🇬🇧', 'English'),
    ('de', '🇩🇪', 'Deutsch'),
    ('es', '🇪🇸', 'Español'),
    ('fr', '🇫🇷', 'Français'),
    ('it', '🇮🇹', 'Italiano'),
  ];

  // Backup state
  final _backupSvc = BackupService.instance;
  GoogleSignInAccount? _googleAccount;
  bool   _backupLoading    = false;
  bool   _restoreLoading   = false;
  bool   _autoBackup       = false;
  String? _lastBackupDate;
  String? _backupError;
  String  _restoreProgress = '';

  // Strava state
  bool           _stravaConnected = false;
  bool           _stravaLoading   = true;
  StravaAthlete? _stravaAthlete;
  bool           _stravaSyncing   = false;
  int            _syncedCount     = 0;   // total activities synced from Strava
  String?        _stravaLoadError; // non-null → show inline error
  bool           _autoSync        = false;
  DateTime?      _lastSyncDate;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadNotificationState();
    _loadStravaState();
    _loadLocale();
    _loadPremiumState();
    _loadBackupState();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${info.version} (build ${info.buildNumber})';
      });
    }
  }

  Future<void> _loadPremiumState() async {
    final premium = await PurchaseService.instance.isPremium();
    if (mounted) setState(() { _isPremium = premium; _premiumLoading = false; });
  }

  Future<void> _loadBackupState() async {
    final lastDate  = await _backupSvc.getLastBackupDate();
    final autoOn    = await _backupSvc.isAutoBackupEnabled();
    // Try to restore sign-in silently
    await _backupSvc.restoreSignIn();
    if (mounted) {
      setState(() {
        _googleAccount  = _backupSvc.currentUser;
        _lastBackupDate = lastDate;
        _autoBackup     = autoOn;
      });
    }
  }

  Future<void> _signInGoogle() async {
    try {
      final account = await _backupSvc.signIn();
      if (!mounted) return;
      if (account != null) {
        setState(() => _googleAccount = account);
      }
      // null = user cancelled picker — no error needed
    } on BackupException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In chyba: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }

  Future<void> _signOutGoogle() async {
    await _backupSvc.signOut();
    if (mounted) setState(() => _googleAccount = null);
  }

  Future<void> _runBackup() async {
    setState(() { _backupLoading = true; _backupError = null; });
    try {
      await _backupSvc.backup();
      final lastDate = await _backupSvc.getLastBackupDate();
      if (mounted) setState(() { _lastBackupDate = lastDate; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).backupSuccess)),
        );
      }
    } on BackupException catch (e) {
      if (mounted) setState(() => _backupError = e.message);
    } catch (e) {
      if (mounted) setState(() => _backupError = 'Chyba: $e');
    } finally {
      if (mounted) setState(() => _backupLoading = false);
    }
  }

  Future<void> _runRestore() async {
    final l10nRestore = AppLocalizations.of(context);

    // ── Confirmation dialog ────────────────────────────────────────────────
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10nRestore.restoreConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10nRestore.restoreConfirmContent),
            const SizedBox(height: 12),
            Text(
              'Záloha se stáhne z Google Drive a uloží lokálně. '
              'Aplikace se poté ukončí. Při příštím spuštění '
              'se záloha automaticky obnoví před načtením dat.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10nRestore.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10nRestore.restoreButton),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      _restoreLoading = true;
      _backupError = null;
      _restoreProgress = 'Zahajuji stahování zálohy...';
    });

    // Listen to progress messages during download
    final progressSub = _backupSvc.progressStream.listen((msg) {
      if (mounted) setState(() => _restoreProgress = msg);
    });

    try {
      // restore() downloads the ZIP and queues it as a pending restore.
      // The actual DB extraction happens on the next cold app start (main.dart)
      // BEFORE any widget or DB singleton is initialised → no black screen.
      await _backupSvc.restore();

      progressSub.cancel();
      if (!mounted) return;
      setState(() { _restoreLoading = false; _restoreProgress = ''; });

      // Tell the user what happened, then exit the app so it cold-starts clean.
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Záloha stažena'),
          content: const Text(
            'Data zálohy byla úspěšně stažena.\n\n'
            'Aplikace se nyní ukončí. Otevřete ji prosím znovu — '
            'záloha se automaticky obnoví při dalším spuštění.',
          ),
          actions: [
            FilledButton(
              onPressed: () => SystemNavigator.pop(),
              child: const Text('Ukončit aplikaci'),
            ),
          ],
        ),
      );

    } on BackupException catch (e) {
      progressSub.cancel();
      if (mounted) {
        setState(() {
          _restoreLoading = false;
          _restoreProgress = '';
          _backupError = e.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba obnovy: ${e.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } catch (e) {
      progressSub.cancel();
      if (mounted) {
        setState(() {
          _restoreLoading = false;
          _restoreProgress = '';
          _backupError = 'Chyba: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba obnovy: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_locale') ?? 'cs';
    if (mounted) setState(() => _currentLocale = code);
  }

  Future<void> _setLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', code);
    if (mounted) setState(() => _currentLocale = code);
    localeNotifier.value = Locale(code);
  }

  Future<void> _setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light  => 'light',
      ThemeMode.dark   => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString('app_theme_mode', value);
    themeModeNotifier.value = mode;
  }

  void _showThemeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.appearance),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(ctx);
              await _setTheme(ThemeMode.light);
            },
            child: Row(children: [
              const Icon(Icons.light_mode_outlined),
              const SizedBox(width: 12),
              Text(l10n.themeModeLight),
            ]),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(ctx);
              await _setTheme(ThemeMode.dark);
            },
            child: Row(children: [
              const Icon(Icons.dark_mode_outlined),
              const SizedBox(width: 12),
              Text(l10n.themeModeDark),
            ]),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(ctx);
              await _setTheme(ThemeMode.system);
            },
            child: Row(children: [
              const Icon(Icons.brightness_auto_outlined),
              const SizedBox(width: 12),
              Text(l10n.themeModeSystem),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    try {
      final db = await _db.database;

      // ── Delete ONLY user-data tables ───────────────────────────────────────
      // Order matters: child tables before parents to satisfy FK constraints.
      // Do NOT delete:
      //   • categories  – predefined lookup data, not user content
      // Do NOT touch:
      //   • SharedPreferences – holds locale, theme, premium status, Strava/
      //     backup settings; none of these are "user data"
      //   • FlutterSecureStorage – holds Strava OAuth tokens
      //   • Google Sign-In session – user stays logged in
      for (final table in [
        'trip_custom_items', // child of trips
        'trip_gear_items',   // junction: trips ↔ gear_items
        'trips',
        'insurances',
        'maintenance_logs',  // also cascade-deleted via gear_items, but be explicit
        'usage_logs',        // ditto
        'maintenance_rules', // ditto
        'gear_strava_settings', // cascade from gear_items
        'gear_items',        // root table – cascades to logs/rules above
      ]) {
        try { await db.delete(table); } catch (_) {}
      }

      // ── Delete photos, recreate empty directory ──────────────────────────
      if (!kIsWeb) {
        try {
          final docsDir = await getApplicationDocumentsDirectory();
          final photosDir = Directory('${docsDir.path}/photos');
          if (await photosDir.exists()) {
            await photosDir.delete(recursive: true);
          }
          // Recreate empty directory so the app can write new photos immediately
          await photosDir.create(recursive: true);
        } catch (_) {}
      }

      // ── Update home screen widget (will now show zeros) ──────────────────
      try { await WidgetService.instance.updateWidget(); } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).allDataDeleted)),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).deleteDataError(e.toString()))),
        );
      }
    }
  }

  void _showClearDataDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearAllData),
        content: Text(l10n.settingsClearSubtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteAllData();
            },
            child: Text(l10n.clearAllData),
          ),
        ],
      ),
    );
  }

  bool _csvExporting = false;

  /// Escapes a single CSV field value.
  String _csvField(dynamic v) {
    if (v == null) return '';
    final s = v.toString();
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  String _csvRow(List<dynamic> cols) => cols.map(_csvField).join(',');

  Future<void> _exportCsv() async {
    if (_csvExporting || kIsWeb) return;
    setState(() => _csvExporting = true);

    try {
      final db     = await _db.database;
      final tmpDir = await getTemporaryDirectory();
      final date   = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // ── gear_items.csv ───────────────────────────────────────────────────
      final gearRows = await db.rawQuery('''
        SELECT g.id, g.name, c.name AS category, g.brand, g.model,
               g.serial_number, g.purchase_date, g.purchase_price, g.status, g.notes
        FROM gear_items g
        LEFT JOIN categories c ON c.id = g.category_id
        ORDER BY g.name
      ''');
      final gearCsv = StringBuffer(
          'id,název,kategorie,značka,model,sériové číslo,datum nákupu,cena,stav,poznámky\n');
      for (final r in gearRows) {
        gearCsv.writeln(_csvRow([
          r['id'], r['name'], r['category'], r['brand'], r['model'],
          r['serial_number'], r['purchase_date'], r['purchase_price'],
          r['status'], r['notes'],
        ]));
      }

      // ── maintenance_log.csv ──────────────────────────────────────────────
      final logRows = await db.rawQuery('''
        SELECT ml.performed_date, g.name AS gear, mr.name AS task,
               ml.performed_by, ml.cost, ml.notes
        FROM maintenance_logs ml
        JOIN gear_items g ON g.id = ml.gear_item_id
        LEFT JOIN maintenance_rules mr ON mr.id = ml.rule_id
        ORDER BY ml.performed_date DESC
      ''');
      final logCsv = StringBuffer('datum,vybavení,úkon,kdo,cena,poznámky\n');
      for (final r in logRows) {
        logCsv.writeln(_csvRow([
          r['performed_date'], r['gear'], r['task'],
          r['performed_by'], r['cost'], r['notes'],
        ]));
      }

      // ── usage_log.csv ────────────────────────────────────────────────────
      final usageRows = await db.rawQuery('''
        SELECT ul.date, g.name AS gear,
               ROUND(ul.duration_minutes / 60.0, 2) AS hours,
               ul.distance_km, ul.elevation_gain, ul.location, ul.source
        FROM usage_logs ul
        JOIN gear_items g ON g.id = ul.gear_item_id
        ORDER BY ul.date DESC
      ''');
      final usageCsv =
          StringBuffer('datum,vybavení,hodiny,km,nastoupáno (m),lokalita,zdroj\n');
      for (final r in usageRows) {
        usageCsv.writeln(_csvRow([
          r['date'], r['gear'], r['hours'],
          r['distance_km'], r['elevation_gain'], r['location'], r['source'],
        ]));
      }

      // ── Write CSV files to temp dir ──────────────────────────────────────
      final gearFile  = File('${tmpDir.path}/gear_items.csv');
      final logFile   = File('${tmpDir.path}/maintenance_log.csv');
      final usageFile = File('${tmpDir.path}/usage_log.csv');
      await gearFile.writeAsString(gearCsv.toString());
      await logFile.writeAsString(logCsv.toString());
      await usageFile.writeAsString(usageCsv.toString());

      // ── Pack into ZIP ────────────────────────────────────────────────────
      final zipPath = '${tmpDir.path}/outdoor_gear_tracker_export_$date.zip';
      final encoder = ZipFileEncoder();
      encoder.create(zipPath);
      encoder.addFile(gearFile);
      encoder.addFile(logFile);
      encoder.addFile(usageFile);
      encoder.close();

      if (!mounted) return;

      // ── Share ────────────────────────────────────────────────────────────
      await Share.shareXFiles(
        [XFile(zipPath, mimeType: 'application/zip')],
        subject: 'OutdoorGearTracker export $date',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).exportCompleted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).exportError(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _csvExporting = false);
    }
  }

  Future<void> _loadNotificationState() async {
    final enabled = await _notifSvc.isEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
        _notifLoading = false;
      });
    }
  }

  /// Loads Strava connection state with a hard 10-second overall timeout.
  /// Always clears [_stravaLoading] in `finally`, so the spinner can't hang.
  Future<void> _loadStravaState() async {
    if (mounted) setState(() { _stravaLoading = true; _stravaLoadError = null; });

    try {
      final connected = await _stravaSvc.isConnected
          .timeout(const Duration(seconds: 10));

      StravaAthlete? athlete;
      int syncedCount = 0;

      if (connected) {
        // Run athlete fetch + count query + prefs in parallel.
        final results = await Future.wait([
          _stravaSvc
              .getAthlete()
              .timeout(const Duration(seconds: 10), onTimeout: () => null),
          _db
              .getTotalStravaActivityCount()
              .timeout(const Duration(seconds: 5), onTimeout: () => 0),
          _stravaSvc.isAutoSyncEnabled(),
          _stravaSvc.getLastSyncDate(),
        ]);
        athlete          = results[0] as StravaAthlete?;
        syncedCount      = results[1] as int;
        final autoSync   = results[2] as bool;
        final lastSync   = results[3] as DateTime?;
        if (mounted) {
          setState(() {
            _autoSync     = autoSync;
            _lastSyncDate = lastSync;
          });
        }
      }

      if (mounted) {
        setState(() {
          _stravaConnected = connected;
          _stravaAthlete   = athlete;
          _syncedCount     = syncedCount;
        });
      }
    } on TimeoutException {
      if (mounted) {
        setState(() => _stravaLoadError =
            AppLocalizations.of(context).stravaLoadError);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _stravaLoadError = 'Chyba: $e');
      }
    } finally {
      if (mounted) setState(() => _stravaLoading = false);
    }
  }

  Future<void> _connectStrava() async {
    if (!mounted) return;
    setState(() { _stravaLoading = true; _stravaLoadError = null; });

    // connect() returns null on success, Czech error string on failure
    String? connectError;
    try {
      connectError = await _stravaSvc
          .connect(context)
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      connectError = AppLocalizations.of(context).stravaConnectTimeout;
    } catch (e) {
      connectError = AppLocalizations.of(context).stravaConnectError(e.toString());
    }

    if (!mounted) return;

    if (connectError != null) {
      setState(() => _stravaLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(connectError),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    if (kIsWeb) {
      // Web: connect() redirected the browser tab to Strava.
      // The /strava-callback route will handle the result — nothing more to do
      // here (the current page is being replaced).
      return;
    }

    // Android: token is already stored — load athlete profile + count
    await _loadStravaState();
  }

  Future<void> _disconnectStrava() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.stravaDisconnect),
        content: Text(AppLocalizations.of(context).stravaDisconnectHint),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.stravaDisconnect)),
        ],
      ),
    );
    if (confirm != true) return;
    await _stravaSvc.disconnect();
    if (mounted) {
      setState(() {
        _stravaConnected = false;
        _stravaAthlete   = null;
        _syncedCount     = 0;
        _stravaLoadError = null;
      });
    }
  }

  Future<void> _syncAll() async {
    setState(() => _stravaSyncing = true);
    int added;
    try {
      added = await _stravaSvc
          .syncAllActivities()
          .timeout(const Duration(minutes: 5));
    } on TimeoutException {
      if (mounted) {
        setState(() => _stravaSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).syncTimedOut)),
        );
      }
      return;
    } catch (e) {
      if (mounted) {
        setState(() => _stravaSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba syncu: $e'),
              duration: const Duration(seconds: 8)),
        );
      }
      return;
    }

    if (!mounted) return;

    // Refresh count + last sync date after sync
    final newCount = await _db.getTotalStravaActivityCount();
    final lastSync = await _stravaSvc.getLastSyncDate();
    setState(() {
      _stravaSyncing = false;
      _syncedCount   = newCount;
      _lastSyncDate  = lastSync;
    });

    final yearAgo = DateTime.now().subtract(const Duration(days: 365));
    final from    = DateFormat('d. M. yyyy').format(yearAgo);
    final to      = DateFormat('d. M. yyyy').format(DateTime.now());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added > 0
              ? 'Synchronizováno $added aktivit (období: $from – $to)'
              : AppLocalizations.of(context).stravaSyncNoNew,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notifLoading = true);

    // Na Android 13+ požádej o oprávnění při prvním zapnutí
    if (value && _notifSvc.platformSupported) {
      final granted = await _notifSvc.requestPermission();
      if (!granted && mounted) {
        setState(() => _notifLoading = false);
        _showPermissionDeniedSnackbar();
        return;
      }
    }

    await _notifSvc.setEnabled(value: value);

    if (mounted) {
      setState(() {
        _notificationsEnabled = value;
        _notifLoading = false;
      });

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value
              ? l10n.notificationsEnabled
              : l10n.notificationsDisabled),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showPermissionDeniedSnackbar() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.notificationPermissionDenied),
        action: SnackBarAction(
          label: l10n.settingsButton,
          onPressed: () {
            // Uživatel může oprávnění udělit ručně v systémovém nastavení
          },
        ),
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(l10n.languageSection),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2C2C2C)
                    : const Color(0xFFE0E0E0),
                width: 0.5,
              ),
            ),
            child: Column(
              children: _languages.map((lang) {
                final (code, flag, name) = lang;
                final selected = _currentLocale == code;
                final isLast = lang == _languages.last;
                return Column(
                  children: [
                    ListTile(
                      leading: Text(flag, style: const TextStyle(fontSize: 22)),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected ? cs.primary : null,
                        ),
                      ),
                      trailing: selected
                          ? Icon(Icons.check_circle,
                              color: cs.primary, size: 20)
                          : null,
                      onTap: () => _setLocale(code),
                    ),
                    if (!isLast)
                      Divider(
                        height: 0,
                        indent: 56,
                        endIndent: 0,
                        color: isDark
                            ? const Color(0xFF2C2C2C)
                            : const Color(0xFFEEEEEE),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          // ── Premium banner / badge ───────────────────────────────────────
          if (!_premiumLoading)
            _isPremium
                ? const _PremiumBadgeTile()
                : _UpgradeBannerTile(
                    onTap: () async {
                      final unlocked = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => const PaywallScreen(),
                        ),
                      );
                      if (unlocked == true) _loadPremiumState();
                    },
                  ),

          // ── Sekce: Pojistky ─────────────────────────────────────────────
          _SectionHeader(l10n.insuranceSection),
          _SettingsTile(
            icon: Icons.security_outlined,
            title: l10n.insurance,
            subtitle: l10n.insuranceSubtitle,
            onTap: () => context.push('/insurance'),
          ),

          // ── Sekce: Aplikace ─────────────────────────────────────────────
          _SectionHeader(l10n.applicationsSection),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: l10n.appearance,
            subtitle: l10n.appearanceSubtitle,
            onTap: () => _showThemeDialog(context),
          ),

          // ── Sekce: Oznámení ──────────────────────────────────────────────
          _SectionHeader(l10n.notificationsSection),
          _NotificationTile(
            loading: _notifLoading,
            enabled: _notificationsEnabled,
            platformSupported: _notifSvc.platformSupported,
            onChanged: _toggleNotifications,
          ),

          // ── Sekce: Jazyk ─────────────────────────────────────────────────
          _buildLanguageSection(context),

          // ── Sekce: Propojené služby ──────────────────────────────────────
          _SectionHeader(l10n.connectedServices),
          _StravaSection(
            loading:      _stravaLoading,
            connected:    _stravaConnected,
            syncing:      _stravaSyncing,
            athlete:      _stravaAthlete,
            syncedCount:  _syncedCount,
            loadError:    _stravaLoadError,
            autoSync:     _autoSync,
            lastSyncDate: _lastSyncDate,
            onConnect:    _connectStrava,
            onDisconnect: _disconnectStrava,
            onSyncAll:    _syncAll,
            onRetry:      _loadStravaState,
            onAutoSyncChanged: (v) async {
              await _stravaSvc.setAutoSync(enabled: v);
              setState(() => _autoSync = v);
            },
          ),

          // ── Sekce: Záloha a export ──────────────────────────────────────
          _SectionHeader(l10n.settingsBackupSection),
          if (!_premiumLoading)
            _SettingsTile(
              icon: Icons.picture_as_pdf,
              title: l10n.settingsAnnualReport,
              subtitle: l10n.settingsAnnualReportSubtitle,
              showPremiumBadge: !_isPremium,
              onTap: () {
                if (_isPremium) {
                  context.push('/annual-report');
                } else {
                  Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => const PaywallScreen(),
                    ),
                  ).then((unlocked) {
                    if (unlocked == true) _loadPremiumState();
                  });
                }
              },
            ),
          if (!_premiumLoading)
            _BackupSection(
              isPremium:       _isPremium,
              googleAccount:   _googleAccount,
              backupLoading:   _backupLoading,
              restoreLoading:  _restoreLoading,
              restoreProgress: _restoreProgress,
              autoBackup:      _autoBackup,
              lastBackupDate:  _lastBackupDate,
              backupError:     _backupError,
              onSignIn:        _signInGoogle,
              onSignOut:       _signOutGoogle,
              onBackup:        _runBackup,
              onRestore:       _runRestore,
              onAutoBackupChanged: (v) async {
                await _backupSvc.setAutoBackupEnabled(v);
                setState(() => _autoBackup = v);
              },
              onUpgradeTap: () async {
                final unlocked = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const PaywallScreen(),
                  ),
                );
                if (unlocked == true) _loadPremiumState();
              },
              onCsvExport: _exportCsv,
              csvExporting: _csvExporting,
            ),

          // ── Sekce: Data ─────────────────────────────────────────────────
          _SectionHeader(l10n.settingsDataSection),
          _SettingsTile(
            icon: Icons.upload_file_outlined,
            title: l10n.importData,
            subtitle: l10n.settingsImportSubtitle,
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: l10n.clearAllData,
            subtitle: l10n.settingsClearSubtitle,
            titleColor: cs.error,
            onTap: _showClearDataDialog,
          ),

          // ── Sekce: Widget ───────────────────────────────────────────────
          _SectionHeader(l10n.settingsWidgetSection),
          _SettingsTile(
            icon: Icons.widgets_outlined,
            title: l10n.settingsWidgetAdd,
            subtitle: l10n.settingsWidgetAddSubtitle,
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  final dl = AppLocalizations.of(ctx);
                  return AlertDialog(
                    title: Text(dl.widgetHowToAddTitle),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dl.widgetHowToStep1),
                        const SizedBox(height: 8),
                        Text(dl.widgetHowToStep2),
                        const SizedBox(height: 8),
                        Text(dl.widgetHowToStep3),
                        const SizedBox(height: 8),
                        Text(dl.widgetHowToStep4),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(dl.understood),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          _SettingsTile(
            icon: Icons.refresh,
            title: l10n.settingsWidgetRefresh,
            onTap: () async {
              await WidgetService.instance.updateWidget();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).settingsWidgetRefreshed),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),

          // ── Sekce: O aplikaci ───────────────────────────────────────────
          _SectionHeader(l10n.settingsAboutSection),
          _SettingsTile(
            icon: Icons.info_outline,
            title: l10n.settingsVersion,
            subtitle: _appVersion.isEmpty ? '…' : _appVersion,
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.settingsPrivacyPolicy,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ─── Notification tile ────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final bool loading;
  final bool enabled;
  final bool platformSupported;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.loading,
    required this.enabled,
    required this.platformSupported,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    if (!platformSupported) {
      // Web: zobraz informaci místo přepínače
      return ListTile(
        leading: Icon(Icons.notifications_off_outlined, color: cs.outline),
        title: Text(l10n.notifications),
        subtitle: Text(
          l10n.settingsNotificationsWeb,
          style: TextStyle(color: cs.outline),
        ),
        isThreeLine: true,
      );
    }

    return SwitchListTile(
      secondary: loading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.primary,
              ),
            )
          : Icon(
              enabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: enabled ? cs.primary : cs.outline,
            ),
      title: Text(l10n.notifications),
      subtitle: Text(
        enabled
            ? l10n.settingsNotificationsOn
            : l10n.settingsNotificationsOff,
        style: tt.bodySmall,
      ),
      value: enabled,
      onChanged: loading ? null : onChanged,
    );
  }
}

// ─── Sdílené pomocné widgety ──────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Small amber "Premium" badge for settings tiles.
class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Premium',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? titleColor;
  final bool showPremiumBadge;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.titleColor,
    this.showPremiumBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget? trailingWidget;
    if (showPremiumBadge) {
      trailingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PremiumBadge(),
          const SizedBox(width: 8),
          if (onTap != null) const Icon(Icons.chevron_right, size: 20),
        ],
      );
    } else if (onTap != null) {
      trailingWidget = const Icon(Icons.chevron_right, size: 20);
    }

    return ListTile(
      leading: Icon(
        icon,
        color: titleColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: titleColor != null ? TextStyle(color: titleColor) : null,
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailingWidget,
      onTap: onTap,
    );
  }
}

// ─── Strava section ───────────────────────────────────────────────────────────

class _StravaSection extends StatelessWidget {
  final bool            loading;
  final bool            connected;
  final bool            syncing;
  final StravaAthlete?  athlete;
  final int             syncedCount;
  final String?         loadError;
  final bool            autoSync;
  final DateTime?       lastSyncDate;
  final VoidCallback    onConnect;
  final VoidCallback    onDisconnect;
  final VoidCallback    onSyncAll;
  final VoidCallback    onRetry;
  final ValueChanged<bool> onAutoSyncChanged;
  const _StravaSection({
    required this.loading,
    required this.connected,
    required this.syncing,
    required this.athlete,
    required this.syncedCount,
    required this.loadError,
    required this.autoSync,
    required this.lastSyncDate,
    required this.onConnect,
    required this.onDisconnect,
    required this.onSyncAll,
    required this.onRetry,
    required this.onAutoSyncChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const stravaOrange = Color(0xFFFC4C02);

    // ── Loading ────────────────────────────────────────────────────────────
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // ── Load error (timeout / network) ────────────────────────────────────
    if (loadError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 0,
          color: const Color(0xFFFFF3E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFFFCC80)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFE65100), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(loadError!,
                      style:
                          const TextStyle(fontSize: 13, color: Color(0xFF5D4037))),
                ),
                TextButton(
                  onPressed: onRetry,
                  child: Text(AppLocalizations.of(context).retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Not connected ──────────────────────────────────────────────────────
    if (!connected) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_run, color: stravaOrange),
                    const SizedBox(width: 8),
                    const Text('Strava',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).stravaConnectDescription,
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: onConnect,
                  style: FilledButton.styleFrom(
                      backgroundColor: stravaOrange),
                  icon: const Icon(Icons.link, size: 16),
                  label: Text(AppLocalizations.of(context).stravaConnect),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Connected ──────────────────────────────────────────────────────────
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: stravaOrange, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title + "Propojeno" badge ──────────────────────────────
              Row(
                children: [
                  const Icon(Icons.directions_run, color: stravaOrange,
                      size: 20),
                  const SizedBox(width: 8),
                  const Text('Strava',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  const Spacer(),
                  _ConnectedBadge(),
                ],
              ),

              const SizedBox(height: 12),

              // ── Athlete row (photo + name + count) ─────────────────────
              Row(
                children: [
                  // Avatar: network photo if available, else initials
                  _AthleteAvatar(athlete: athlete),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          athlete?.fullName ?? AppLocalizations.of(context).stravaAccount,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          syncedCount > 0
                              ? AppLocalizations.of(context).stravaSyncedCount(syncedCount)
                              : AppLocalizations.of(context).stravaSyncedNone,
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 0),

              // ── Auto-sync toggle ────────────────────────────────────────
              SwitchListTile(
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4),
                title: Text(
                  AppLocalizations.of(context).stravaAutoSync,
                  style: const TextStyle(fontSize: 13),
                ),
                value: autoSync,
                activeColor: stravaOrange,
                onChanged: onAutoSyncChanged,
              ),

              // ── Last sync date ──────────────────────────────────────────
              if (lastSyncDate != null)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 4, right: 4, bottom: 8),
                  child: Text(
                    AppLocalizations.of(context).stravaSyncDateLabel(_formatSyncDate(context, lastSyncDate!)),
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),

              const Divider(height: 0),
              const SizedBox(height: 12),

              // ── Action buttons ──────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: syncing ? null : onSyncAll,
                      style: FilledButton.styleFrom(
                        backgroundColor: stravaOrange,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: syncing
                          ? const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.sync, size: 16),
                      label: Text(syncing
                          ? AppLocalizations.of(context).loading
                          : AppLocalizations.of(context).stravasyncActivities),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onDisconnect,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    child: Text(AppLocalizations.of(context).stravaDisconnect),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatSyncDate(BuildContext context, DateTime dt) {
    final l10n  = AppLocalizations.of(context);
    final now   = DateTime.now();
    final local = dt.toLocal();
    final time  = '${local.hour.toString().padLeft(2, '0')}:'
                  '${local.minute.toString().padLeft(2, '0')}';
    if (local.year == now.year &&
        local.month == now.month &&
        local.day   == now.day) {
      return l10n.syncToday(time);
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (local.year  == yesterday.year &&
        local.month == yesterday.month &&
        local.day   == yesterday.day) {
      return l10n.syncYesterday(time);
    }
    return '${local.day}. ${local.month}. ${local.year} $time';
  }
}

// ─── Athlete avatar ───────────────────────────────────────────────────────────

class _AthleteAvatar extends StatelessWidget {
  final StravaAthlete? athlete;
  const _AthleteAvatar({required this.athlete});

  @override
  Widget build(BuildContext context) {
    const stravaOrange = Color(0xFFFC4C02);
    const size = 40.0;

    final photoUrl = athlete?.profileMedium;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl,
          width: size, height: size,
          fit: BoxFit.cover,
          // On error (e.g. no network) fall back to initials
          errorBuilder: (_, __, ___) =>
              _initialsAvatar(athlete, size, stravaOrange),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              width: size, height: size,
              child: const CircularProgressIndicator(
                  strokeWidth: 2, color: stravaOrange),
            );
          },
        ),
      );
    }

    return _initialsAvatar(athlete, size, stravaOrange);
  }

  static Widget _initialsAvatar(
      StravaAthlete? athlete, double size, Color color) {
    final initials = athlete != null && athlete.firstname.isNotEmpty
        ? athlete.firstname[0].toUpperCase()
        : 'S';
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withAlpha(30),
      child: Text(initials,
          style: TextStyle(
              fontWeight: FontWeight.w700, color: color, fontSize: size * 0.4)),
    );
  }
}

// ─── Connected badge ──────────────────────────────────────────────────────────

class _ConnectedBadge extends StatelessWidget {
  const _ConnectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 13, color: Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context).stravaConnected,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Premium badge tile (shown when user has Premium) ─────────────────────────

class _PremiumBadgeTile extends StatelessWidget {
  const _PremiumBadgeTile();

  static const _kGold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C2500), const Color(0xFF1A1600)]
              : [const Color(0xFFFFF8E1), const Color(0xFFFFF3CD)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kGold.withAlpha(130)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kGold.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👑', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Premium ⭐',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF8B6914),
                  ),
                ),
                Text(
                  AppLocalizations.of(context).premiumAllFeaturesUnlocked,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF8B6914).withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: _kGold),
        ],
      ),
    );
  }
}

// ─── Upgrade banner tile (shown for free users) ───────────────────────────────

class _UpgradeBannerTile extends StatelessWidget {
  final VoidCallback onTap;
  const _UpgradeBannerTile({required this.onTap});

  static const _kGold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2C2500), const Color(0xFF1A1600)]
                : [const Color(0xFFFFF8E1), const Color(0xFFFEECB0)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kGold.withAlpha(150)),
          boxShadow: [
            BoxShadow(
              color: _kGold.withAlpha(30),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _kGold.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👑', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).upgradeToPremium,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF7A5C00),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).premiumBenefits,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF7A5C00).withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _kGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Backup section ───────────────────────────────────────────────────────────

class _BackupSection extends StatelessWidget {
  final bool                  isPremium;
  final GoogleSignInAccount?  googleAccount;
  final bool                  backupLoading;
  final bool                  restoreLoading;
  final String                restoreProgress;
  final bool                  autoBackup;
  final String?               lastBackupDate;
  final String?               backupError;
  final VoidCallback          onSignIn;
  final VoidCallback          onSignOut;
  final VoidCallback          onBackup;
  final VoidCallback          onRestore;
  final ValueChanged<bool>    onAutoBackupChanged;
  final VoidCallback          onUpgradeTap;
  final VoidCallback          onCsvExport;
  final bool                  csvExporting;

  const _BackupSection({
    required this.isPremium,
    required this.googleAccount,
    required this.backupLoading,
    required this.restoreLoading,
    required this.restoreProgress,
    required this.autoBackup,
    required this.lastBackupDate,
    required this.backupError,
    required this.onSignIn,
    required this.onSignOut,
    required this.onBackup,
    required this.onRestore,
    required this.onAutoBackupChanged,
    required this.onUpgradeTap,
    required this.onCsvExport,
    required this.csvExporting,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ── Not premium ────────────────────────────────────────────────────────
    if (!isPremium) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            _LockedFeatureTile(
              icon: Icons.cloud_upload_outlined,
              title: AppLocalizations.of(context).googleDriveBackupTitle,
              onUpgradeTap: onUpgradeTap,
            ),
            // CSV export is always free
            ListTile(
              leading: Icon(Icons.table_chart_outlined, color: cs.onSurfaceVariant),
              title: Text(AppLocalizations.of(context).exportCsvLabel),
              subtitle: Text(AppLocalizations.of(context).exportCsvSubtitle),
              trailing: csvExporting
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.chevron_right, size: 20),
              onTap: csvExporting ? null : onCsvExport,
            ),
          ],
        ),
      );
    }

    // ── Premium: not signed in ─────────────────────────────────────────────
    if (googleAccount == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cloud_outlined, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).googleDriveBackupTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).googleSignInPrompt,
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: onSignIn,
                  icon: const Icon(Icons.login, size: 16),
                  label: Text(AppLocalizations.of(context).signInWithGoogle),
                ),
                const SizedBox(height: 12),
                // CSV export (always available)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.table_chart_outlined,
                      color: cs.onSurfaceVariant),
                  title: Text(AppLocalizations.of(context).exportCsvLabel),
                  trailing: csvExporting
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.chevron_right, size: 20),
                  onTap: csvExporting ? null : onCsvExport,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Premium: signed in ────────────────────────────────────────────────
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.primary, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.cloud_done_outlined, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).googleDriveBackupTitle,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const Spacer(),
                  _ConnectedBadge(),
                ],
              ),
              const SizedBox(height: 12),

              // Account info
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: cs.primaryContainer,
                    backgroundImage: googleAccount!.photoUrl != null
                        ? NetworkImage(googleAccount!.photoUrl!)
                        : null,
                    child: googleAccount!.photoUrl == null
                        ? Text(
                            (googleAccount!.displayName ?? 'G')[0].toUpperCase(),
                            style: TextStyle(
                                color: cs.onPrimaryContainer,
                                fontWeight: FontWeight.w700),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          googleAccount!.displayName ?? AppLocalizations.of(context).googleAccount,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Text(
                          googleAccount!.email,
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (lastBackupDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).lastBackupDate(_formatDate(lastBackupDate!)),
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],

              const SizedBox(height: 14),
              const Divider(height: 0),

              // Auto-backup toggle
              SwitchListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: Text(
                  AppLocalizations.of(context).autoBackupLabel,
                  style: const TextStyle(fontSize: 13),
                ),
                value: autoBackup,
                onChanged: onAutoBackupChanged,
              ),

              const Divider(height: 0),
              const SizedBox(height: 12),

              // Error message
              if (backupError != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    backupError!,
                    style: TextStyle(color: cs.onErrorContainer, fontSize: 13),
                  ),
                ),
              ],

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: (backupLoading || restoreLoading) ? null : onBackup,
                      icon: backupLoading
                          ? const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.cloud_upload_outlined, size: 16),
                      label: Text(backupLoading ? AppLocalizations.of(context).uploading : AppLocalizations.of(context).backupNow),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (backupLoading || restoreLoading) ? null : onRestore,
                      icon: restoreLoading
                          ? SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: cs.primary))
                          : const Icon(Icons.cloud_download_outlined, size: 16),
                      label: Text(restoreLoading ? 'Obnovuji...' : 'Obnovit'),
                    ),
                  ),
                ],
              ),

              // ── Restore progress indicator ─────────────────────────────
              if (restoreLoading && restoreProgress.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(
                      width: 12, height: 12,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        restoreProgress,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 8),
              // CSV export
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.table_chart_outlined,
                    color: cs.onSurfaceVariant),
                title: Text(AppLocalizations.of(context).exportCsvLabel),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).featureComingSoon)),
                  );
                },
              ),

              const Divider(height: 0),
              const SizedBox(height: 8),

              // Sign-out
              TextButton.icon(
                onPressed: onSignOut,
                style: TextButton.styleFrom(foregroundColor: cs.error),
                icon: const Icon(Icons.logout, size: 16),
                label: Text(AppLocalizations.of(context).signOutGoogleAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('d. M. yyyy HH:mm').format(dt);
    } catch (_) {
      return isoDate;
    }
  }
}

// ─── Locked feature tile ──────────────────────────────────────────────────────

class _LockedFeatureTile extends StatelessWidget {
  final IconData     icon;
  final String       title;
  final VoidCallback onUpgradeTap;

  const _LockedFeatureTile({
    required this.icon,
    required this.title,
    required this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: cs.onSurfaceVariant),
      title: Text(title),
      subtitle: Text(AppLocalizations.of(context).availableInPremium),
      trailing: GestureDetector(
        onTap: onUpgradeTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Upgrade',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
      ),
      onTap: onUpgradeTap,
    );
  }
}

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Aplikační logger — píše na konzoli i do rotovaného souboru.
///
/// Cíl: incidenty na zařízeních testerů jsou řešitelné bez ADB / logcatu.
/// Tester si log exportuje přes obrazovku Diagnostika.
///
/// Bezpečnost: logging NIKDY nesmí shodit aplikaci. Selhání zápisu se
/// spolkne, init() při chybě spadne do režimu "jen konzole". Volání před
/// [init] (early bootstrap) jdou jen na konzoli — do souboru se nezapíšou
/// a nefrontí se.
class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  static const int _maxFileBytes = 1024 * 1024; // 1 MB / soubor
  static const int _maxFiles     = 5;           // kolik log souborů držet

  final Logger _console = Logger(
    printer: SimplePrinter(colors: false, printTime: false),
  );

  bool       _initialized = false;
  Directory? _logsDir;
  File?      _currentFile;
  IOSink?    _sink;

  // Cachované hodnoty pro hlavičku — zjišťují se jen jednou v init().
  String _appLine    = 'App: unknown';
  String _deviceLine = 'Device: unknown';
  String _osLine     = 'OS: unknown';

  /// Adresář s logy (po [init]). Null, dokud init neproběhl / selhal.
  Directory? get logsDirectory => _logsDir;

  /// Aktuální log soubory seřazené od nejstaršího po nejnovější.
  /// Prázdné, pokud init neproběhl nebo složka logs/ neexistuje.
  Future<List<File>> logFiles() async {
    final dir = _logsDir;
    if (dir == null || !await dir.exists()) return [];
    try {
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) {
            final n = p.basename(f.path);
            return n.startsWith('app-') && n.endsWith('.log');
          })
          .toList()
        ..sort((a, b) =>
            a.statSync().modified.compareTo(b.statSync().modified));
      return files;
    } catch (_) {
      return [];
    }
  }

  /// Inicializace — vytvoří složku logs/, otevře dnešní soubor, provede
  /// rotaci. Idempotentní. Při jakékoli chybě zůstane v console-only režimu.
  Future<void> init() async {
    if (_initialized) return;
    try {
      await _gatherEnvInfo();
      final docsDir = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docsDir.path, 'logs'));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _logsDir = dir;
      await _openTodaysFile();
      _initialized = true;
      await info('AppLogger initialized — logs at ${dir.path}');
    } catch (e, st) {
      // Logging se nesmí stát příčinou pádu — spadni do console-only.
      _console.e('AppLogger init failed (console-only fallback)',
          error: e, stackTrace: st);
      _initialized = false;
      _sink = null;
    }
  }

  Future<void> info(String msg) => _write('INFO', msg);

  Future<void> warn(String msg) => _write('WARN', msg);

  Future<void> error(Object e, [StackTrace? st]) async {
    _console.e(e, stackTrace: st);
    final buf = StringBuffer('${_stamp()} [ERROR] $e');
    if (st != null) {
      for (final line in st.toString().trimRight().split('\n')) {
        if (line.isNotEmpty) buf.write('\n  $line');
      }
    }
    await _appendToFile(buf.toString());
  }

  // ── Interní ───────────────────────────────────────────────────────────

  Future<void> _write(String level, String msg) async {
    final line = '${_stamp()} [$level] $msg';
    switch (level) {
      case 'WARN':  _console.w(line); break;
      case 'ERROR': _console.e(line); break;
      default:      _console.i(line); break;
    }
    await _appendToFile(line);
  }

  Future<void> _appendToFile(String line) async {
    final sink = _sink;
    if (sink == null) return; // před init() nebo console-only fallback
    try {
      sink.writeln(line);
      await sink.flush(); // flush po každém řádku — log přežije i pád
    } catch (_) {
      // Selhání zápisu se spolkne — logging nesmí shodit aplikaci.
    }
  }

  String _stamp() => '[${DateTime.now().toUtc().toIso8601String()}]';

  String _dateStamp() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Vybere dnešní log soubor. Pokud `app-YYYY-MM-DD.log` přesáhl 1 MB,
  /// přejde na `-2`, `-3` … Po otevření spustí rotaci.
  Future<void> _openTodaysFile() async {
    final stamp = _dateStamp();
    var index = 1;
    var candidate = File(p.join(_logsDir!.path, 'app-$stamp.log'));
    while (await candidate.exists() &&
        await candidate.length() > _maxFileBytes) {
      index++;
      candidate = File(p.join(_logsDir!.path, 'app-$stamp-$index.log'));
    }
    final isNewFile = !await candidate.exists();
    _currentFile = candidate;
    _sink = candidate.openWrite(mode: FileMode.append);
    if (isNewFile) {
      _sink!
        ..writeln('=== Session start: ${DateTime.now().toUtc().toIso8601String()} ===')
        ..writeln(_appLine)
        ..writeln(_deviceLine)
        ..writeln(_osLine)
        ..writeln('============================================');
      await _sink!.flush();
    }
    await _enforceRotation();
  }

  /// Smaže nejstarší log soubory, pokud jich je víc než [_maxFiles].
  Future<void> _enforceRotation() async {
    try {
      final dir = _logsDir;
      if (dir == null) return;
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) {
            final n = p.basename(f.path);
            return n.startsWith('app-') && n.endsWith('.log');
          })
          .where((f) => f.path != _currentFile?.path)
          .toList();
      const keepOthers = _maxFiles - 1; // +1 je aktuální soubor
      if (files.length <= keepOthers) return;
      files.sort(
          (a, b) => a.statSync().modified.compareTo(b.statSync().modified));
      for (final f in files.take(files.length - keepOthers)) {
        try {
          await f.delete();
        } catch (_) {/* ignoruj — rotace nesmí shodit logging */}
      }
    } catch (_) {/* ignoruj */}
  }

  /// Zjistí info o aplikaci a zařízení pro hlavičku log souboru.
  /// Žádná osobní data — jen verze appky, model a verze OS.
  Future<void> _gatherEnvInfo() async {
    try {
      final pkg = await PackageInfo.fromPlatform();
      _appLine = 'App: ${pkg.appName} ${pkg.version}+${pkg.buildNumber}';
    } catch (_) {/* ponech default */}
    try {
      final di = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await di.androidInfo;
        _deviceLine = 'Device: ${a.manufacturer} ${a.model}';
        _osLine =
            'Android: ${a.version.release} (API ${a.version.sdkInt})';
      } else if (Platform.isIOS) {
        final i = await di.iosInfo;
        _deviceLine = 'Device: ${i.model}';
        _osLine = 'iOS: ${i.systemVersion}';
      }
    } catch (_) {/* ponech default */}
  }
}

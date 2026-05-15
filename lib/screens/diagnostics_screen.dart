import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kProfileMode, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../utils/app_logger.dart';

/// Obrazovka Diagnostika — self-service nástroj pro testery.
///
/// Umožní exportovat logy a obnovit data bez ADB / logcatu. Vznikla kvůli
/// incidentu, kdy se na Galaxy S10 nenačítaly kategorie a tester nebyl
/// schopen poskytnout logcat.
class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  final _db = DatabaseHelper.instance;

  bool _loading = true;

  PackageInfo?     _pkg;
  String           _deviceModel    = 'Neznámé';
  String           _osVersion      = '—';
  Map<String, int> _tableCounts    = {};
  List<File>       _logFiles       = [];
  int              _logTotalBytes  = 0;

  static const _buildMode = kReleaseMode
      ? 'release'
      : kProfileMode
          ? 'profile'
          : 'debug';

  @override
  void initState() {
    super.initState();
    AppLogger.instance.info('Diagnostics screen opened');
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    setState(() => _loading = true);

    PackageInfo? pkg;
    try {
      pkg = await PackageInfo.fromPlatform();
    } catch (_) {/* ponech null */}

    var deviceModel = 'Neznámé';
    var osVersion = '—';
    try {
      final di = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await di.androidInfo;
        deviceModel = '${a.manufacturer} ${a.model}';
        osVersion = 'Android ${a.version.release} (API ${a.version.sdkInt})';
      } else if (Platform.isIOS) {
        final i = await di.iosInfo;
        deviceModel = i.model;
        osVersion = 'iOS ${i.systemVersion}';
      }
    } catch (_) {/* ponech default */}

    var counts = <String, int>{};
    try {
      counts = await _db.getTableCounts();
    } catch (e) {
      await AppLogger.instance.error(e);
    }

    final files = await AppLogger.instance.logFiles();
    var totalBytes = 0;
    for (final f in files) {
      try {
        totalBytes += await f.length();
      } catch (_) {/* ignoruj */}
    }

    if (!mounted) return;
    setState(() {
      _pkg           = pkg;
      _deviceModel   = deviceModel;
      _osVersion     = osVersion;
      _tableCounts   = counts;
      _logFiles      = files;
      _logTotalBytes = totalBytes;
      _loading       = false;
    });
  }

  // ── Akce ──────────────────────────────────────────────────────────────

  Future<void> _shareLogs() async {
    final files = await AppLogger.instance.logFiles();
    if (files.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Žádné log soubory k odeslání.')),
        );
      }
      return;
    }

    final counts = _tableCounts.entries
        .map((e) => '${e.key}=${e.value}')
        .join(', ');
    final summary = StringBuffer()
      ..writeln('OutdoorGearTracker — diagnostika')
      ..writeln(
          'Verze: ${_pkg?.version ?? '?'}+${_pkg?.buildNumber ?? '?'} ($_buildMode)')
      ..writeln('Zařízení: $_deviceModel')
      ..writeln('OS: $_osVersion')
      ..writeln('Schéma DB: v${_db.schemaVersion}')
      ..writeln('Záznamy: $counts')
      ..writeln('Log souborů: ${files.length}');

    await Share.shareXFiles(
      files.map((f) => XFile(f.path, mimeType: 'text/plain')).toList(),
      subject: 'OutdoorGearTracker diagnostika',
      text: summary.toString(),
    );
    await AppLogger.instance.info('User shared ${files.length} log files');
  }

  Future<void> _confirmReseed() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Obnovit výchozí kategorie'),
        content: const Text(
            'Opravdu obnovit výchozí kategorie? Vlastní úpravy kategorií '
            'budou ztraceny.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Zrušit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Obnovit'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await AppLogger.instance.info('User triggered reseed from Diagnostics');
    final result = await _db.reseedCategories(force: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Obnoveno ${result.inserted} kategorií')),
    );
    await _loadDiagnostics();
  }

  Future<void> _confirmResetDatabase() async {
    // Krok 1 — varování.
    final step1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Smazat databázi'),
        content: const Text(
            'Toto smaže VŠECHNA data — kategorie, vybavení, záznamy o '
            'údržbě, fotky položek. Akce je nevratná. Pokračovat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Zrušit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Pokračovat'),
          ),
        ],
      ),
    );
    if (step1 != true || !mounted) return;

    // Krok 2 — opis potvrzovacího slova.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return StatefulBuilder(
          builder: (ctx, setD) => AlertDialog(
            title: const Text('Potvrzení'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pro potvrzení napiš velkými písmeny: SMAZAT'),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setD(() {}),
                  decoration: const InputDecoration(
                    hintText: 'SMAZAT',
                    isDense: true,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Zrušit'),
              ),
              FilledButton(
                onPressed: ctrl.text == 'SMAZAT'
                    ? () => Navigator.pop(ctx, true)
                    : null,
                style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error),
                child: const Text('Smazat'),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed != true) return;

    await AppLogger.instance
        .warn('Database reset confirmed by user from Diagnostics');
    await _db.resetDatabase();
    SystemNavigator.pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────

  /// Vytáhne datum z názvu log souboru `app-YYYY-MM-DD[-N].log`.
  String? _logDate(File f) {
    final m = RegExp(r'app-(\d{4}-\d{2}-\d{2})').firstMatch(f.path);
    return m?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostika'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Obnovit',
            onPressed: _loading ? null : _loadDiagnostics,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _section('Aplikace', [
                  _kv('Verze',
                      '${_pkg?.version ?? '?'}+${_pkg?.buildNumber ?? '?'}'),
                  _kv('Build mode', _buildMode),
                ]),
                _section('Zařízení', [
                  _kv('Model', _deviceModel),
                  _kv('Systém', _osVersion),
                ]),
                _section('Databáze', [
                  _kv('Schéma', 'v${_db.schemaVersion}'),
                  _kv('Soubor', _db.databaseFileName),
                  if (_tableCounts.isEmpty)
                    _kv('Záznamy', '—')
                  else
                    ..._tableCounts.entries
                        .map((e) => _kv(e.key, '${e.value}')),
                ]),
                _section('Logy', _buildLogRows()),
                const SizedBox(height: 8),
                _buildActions(),
              ],
            ),
    );
  }

  List<Widget> _buildLogRows() {
    if (_logFiles.isEmpty) {
      return [_kv('Soubory', 'žádné')];
    }
    final kb = (_logTotalBytes / 1024).toStringAsFixed(1);
    return [
      _kv('Počet souborů', '${_logFiles.length}'),
      _kv('Celková velikost', '$kb kB'),
      _kv('Nejstarší', _logDate(_logFiles.first) ?? '—'),
      _kv('Nejnovější', _logDate(_logFiles.last) ?? '—'),
    ];
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _shareLogs,
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const Text('Sdílet logy'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _confirmReseed,
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('Obnovit výchozí kategorie'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _confirmResetDatabase,
            icon: Icon(Icons.delete_forever_outlined,
                size: 18, color: context.dangerColor),
            label: Text(
              'Smazat databázi',
              style: TextStyle(color: context.dangerColor),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.dangerColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: context.isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.cardBorderColor, width: 0.5),
            ),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              key,
              style: TextStyle(fontSize: 13, color: context.subtitleColor),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

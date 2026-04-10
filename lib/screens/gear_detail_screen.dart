import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/category.dart';
import '../models/gear_item.dart';
import '../models/maintenance_log.dart';
import '../models/maintenance_rule.dart';
import '../models/strava_models.dart';
import '../models/usage_log.dart';
import '../services/igc_parser.dart';
import '../services/maintenance_service.dart';
import '../services/strava_service.dart';
import '../theme/app_theme.dart';
import '../widgets/maintenance_badge.dart';

class GearDetailScreen extends StatefulWidget {
  final int gearItemId;
  const GearDetailScreen({super.key, required this.gearItemId});

  @override
  State<GearDetailScreen> createState() => _GearDetailScreenState();
}

class _GearDetailScreenState extends State<GearDetailScreen> {
  final _db        = DatabaseHelper.instance;
  final _svc       = MaintenanceService();
  final _stravaSvc = StravaService.instance;

  GearItem?                     _item;
  Category?                     _category;
  List<MaintenanceStatusResult> _maintenanceResults = [];
  List<MaintenanceLog>          _maintenanceLogs    = [];
  List<UsageLog>                _usageLogs          = [];
  int    _totalMinutes = 0;
  double _totalKm      = 0;
  int    _usageCount   = 0;

  // Strava
  GearStravaSettings? _stravaSettings;
  bool _stravaConnected = false;
  bool _stravaSyncing   = false;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData(initial: true);
    // Reload when the global Strava sync (triggered from HomeScreen) finishes
    StravaService.isSyncing.addListener(_onGlobalSyncChanged);
  }

  @override
  void dispose() {
    StravaService.isSyncing.removeListener(_onGlobalSyncChanged);
    super.dispose();
  }

  /// Called when [StravaService.isSyncing] changes.
  /// Reloads usage data silently once the sync finishes.
  void _onGlobalSyncChanged() {
    if (!StravaService.isSyncing.value && mounted) {
      _loadData();
    }
  }

  /// Full data reload.
  ///
  /// [initial] = true  → shows the full-screen spinner (first open).
  /// [initial] = false → refreshes in-place; the existing UI stays visible.
  ///   Used for pull-to-refresh, post-sync reloads, etc.
  Future<void> _loadData({bool initial = false}) async {
    if (initial) setState(() => _loading = true);

    final item = await _db.getGearItemById(widget.gearItemId);
    if (item == null) { if (mounted) context.pop(); return; }

    final category     = await _db.getCategoryById(item.categoryId);
    final results      = await _svc.getStatusForItem(item.id!);
    final logs         = await _db.getMaintenanceLogs(gearItemId: item.id!);
    final usageLogs    = await _db.getUsageLogs(gearItemId: item.id!);
    final totalMinutes = await _db.getTotalDurationMinutes(item.id!);
    final totalKm      = await _db.getTotalDistanceKm(item.id!);
    final usageCount   = await _db.getUsageCount(item.id!);

    final stravaSettings  = await _db.getGearStravaSettings(widget.gearItemId);
    final stravaConnected = await _stravaSvc.isConnected;

    if (mounted) {
      setState(() {
        _item = item;                  _category = category;
        _maintenanceResults = results; _maintenanceLogs = logs;
        _usageLogs = usageLogs;        _totalMinutes = totalMinutes;
        _totalKm = totalKm;            _usageCount = usageCount;
        _stravaSettings  = stravaSettings;
        _stravaConnected = stravaConnected;
        _loading = false;
      });
    }
  }

  // ── Strava helpers ─────────────────────────────────────────────────────────

  Future<void> _saveStravaSettings(GearStravaSettings s) async {
    await _db.upsertGearStravaSettings(s);
    setState(() => _stravaSettings = s);
  }

  Future<void> _syncStrava() async {
    setState(() => _stravaSyncing = true);
    final result = await _stravaSvc.syncGear(widget.gearItemId);
    await _loadData();
    if (!mounted) return;
    setState(() => _stravaSyncing = false);

    final l10n = AppLocalizations.of(context);
    final String message;
    if (result.hasError) {
      message = l10n.stravaSyncError(result.error ?? '');
    } else if (result.added > 0) {
      final newestStr = result.newestActivityDate != null
          ? DateFormat('d. M. yyyy').format(result.newestActivityDate!)
          : '';
      message = l10n.stravaSyncSuccess(result.added, newestStr);
    } else {
      message = l10n.stravaSyncNoNew;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final item = _item!;

    // Most pressing date-based rule
    final dateResults = _maintenanceResults
        .where((r) => r.rule.triggerType == TriggerType.date);
    final nextServiceResult = dateResults.isEmpty
        ? null
        : dateResults.reduce((a, b) => a.remaining < b.remaining ? a : b);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
          // ── Coloured header ──────────────────────────────────────────────
          _buildHeader(item, context),

          // ── 3 stat cards ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _StatCardsRow(
                totalMinutes: _totalMinutes,
                item: item,
                nextServiceResult: nextServiceResult,
              ),
            ),
          ),

          // ── Maintenance plan ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _MaintenancePlanSection(
              results: _maintenanceResults,
              maintenanceLogs: _maintenanceLogs,
              onLogService: (_) => context
                  .push('/gear/${item.id}/maintenance/add')
                  .then((_) => _loadData()),
              onAddRule: () => context
                  .push('/gear/${item.id}/rules/add')
                  .then((_) => _loadData()),
            ),
          ),

          // ── Activity history ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ActivityHistorySection(
              logs: _usageLogs,
              onAdd: () => context
                  .push('/gear/${item.id}/usage/add')
                  .then((_) => _loadData()),
              onImportIgc: _importIgc,
            ),
          ),

          // ── Strava sync ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _StravaGearSection(
              connected:    _stravaConnected,
              settings:     _stravaSettings,
              syncing:      _stravaSyncing,
              categoryIcon: _category?.icon,
              onSave:       _saveStravaSettings,
              onSync:       _syncStrava,
              gearItemId:   item.id!,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
        ),
      ),
      bottomNavigationBar: _BottomActions(
        onAddActivity: () => context
            .push('/gear/${item.id}/usage/add')
            .then((_) => _loadData()),
        onLogService: () => context
            .push('/gear/${item.id}/maintenance/add')
            .then((_) => _loadData()),
        onEdit: () => context
            .push('/gear/${item.id}/edit')
            .then((_) => _loadData()),
      ),
    );
  }

  // ── Header sliver ──────────────────────────────────────────────────────────

  SliverAppBar _buildHeader(GearItem item, BuildContext context) {
    final headerColor = _headerColor(_category?.icon);

    return SliverAppBar(
      expandedHeight: 176,
      pinned: true,
      backgroundColor: headerColor,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () =>
              context.push('/gear/${item.id}/edit').then((_) => _loadData()),
        ),
        PopupMenuButton<String>(
          iconColor: Colors.white,
          itemBuilder: (ctx) {
            final l = AppLocalizations.of(ctx);
            return [
              PopupMenuItem(value: 'status', child: Text(l.gearStatus)),
              PopupMenuItem(
                value: 'delete',
                child: Text(l.delete, style: const TextStyle(color: AppColors.danger)),
              ),
            ];
          },
          onSelected: (v) {
            if (v == 'status') _showStatusDialog();
            if (v == 'delete') _confirmDelete();
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          color: headerColor,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          alignment: Alignment.bottomLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // kategorie · sport
              if (_category != null)
                Text(
                  '${_category!.name} · ${_category!.sport}'.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              const SizedBox(height: 6),
              // název vybavení
              Text(
                item.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // datum koupě · sériové číslo
              if (_buildMeta(item).isNotEmpty)
                Text(
                  _buildMeta(item),
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildMeta(GearItem item) {
    final parts = <String>[];
    if (item.purchaseDate != null) {
      parts.add(DateFormat('d. M. yyyy').format(item.purchaseDate!));
    }
    if (item.serialNumber != null) parts.add('SN: ${item.serialNumber}');
    return parts.join(' · ');
  }

  // icon name → header background color (deeper, richer than card tint)
  static Color _headerColor(String? icon) => switch (icon) {
    'rope'       => const Color(0xFFB85C00),
    'bike'       => const Color(0xFF1565C0),
    'harness'    => const Color(0xFF4527A0),
    'skis'       => const Color(0xFF4527A0),
    'paraglider' => const Color(0xFF1D9E75),
    _            => const Color(0xFF424242),
  };

  // ── IGC import ────────────────────────────────────────────────────────────

  Future<void> _importIgc() async {
    // 1. Pick file
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['igc'],
        withData: true,
      );
    } catch (_) {
      // File picker cancelled or platform error
      return;
    }

    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.first.bytes;
    if (bytes == null || !mounted) return;

    // 2. Parse
    final content = utf8.decode(bytes, allowMalformed: true);
    final flight  = IgcParser.parse(content);

    if (flight == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nepodařilo se načíst IGC soubor. Zkontroluj formát.'),
          ),
        );
      }
      return;
    }

    // 3. Preview dialog
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _IgcPreviewDialog(flight: flight),
    );

    if (confirmed != true || !mounted) return;

    // 4. Save to UsageLog
    await _db.insertUsageLog(UsageLog(
      gearItemId: widget.gearItemId,
      date: flight.flightDate,
      durationMinutes: flight.durationMinutes,
      source: UsageSource.igc,
    ));

    // 5. Reload
    await _loadData();

    // 6. Toast
    if (mounted) {
      final h = flight.durationMinutes ~/ 60;
      final m = flight.durationMinutes % 60;
      final dur = h > 0 ? '$h h $m min' : '$m min';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Let přidán: $dur, max výška ${flight.maxAltitudeM} m'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showStatusDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(l10n.gearStatus),
        children: GearStatus.values
            .map((s) => SimpleDialogOption(
                  child: Text(s.label),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _db.updateGearItem(_item!.copyWith(status: s));
                    _loadData();
                  },
                ))
            .toList(),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteGearConfirm(_item!.name)),
        content: Text(l10n.deleteGearWarning),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await _db.deleteGearItem(_item!.id!);
      context.pop();
    }
  }
}

// ─── 3 stat cards ─────────────────────────────────────────────────────────────

class _StatCardsRow extends StatelessWidget {
  final int                      totalMinutes;
  final GearItem                 item;
  final MaintenanceStatusResult? nextServiceResult;

  const _StatCardsRow({
    required this.totalMinutes,
    required this.item,
    required this.nextServiceResult,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hours = totalMinutes >= 60
        ? '${(totalMinutes / 60).toStringAsFixed(0)} h'
        : '$totalMinutes min';

    final age = item.purchaseDate != null
        ? _ageString(DateTime.now().difference(item.purchaseDate!))
        : '–';

    // Service days: negative = overdue
    String serviceVal = '–';
    Color? serviceColor;
    if (nextServiceResult != null) {
      final days = nextServiceResult!.remaining.toInt();
      serviceVal = days < 0 ? '${(-days)}d' : '${days}d';
      serviceColor = days < 0
          ? context.dangerColor
          : days <= 30
              ? context.warningColor
              : context.successColor;
    }

    return Row(
      children: [
        _StatCard(
          icon: Icons.timer_outlined,
          value: hours,
          label: l10n.hours,
        ),
        const SizedBox(width: 8),
        _StatCard(
          icon: Icons.calendar_today_outlined,
          value: age,
          label: l10n.gearAge,
        ),
        const SizedBox(width: 8),
        _StatCard(
          icon: Icons.build_outlined,
          value: serviceVal,
          label: nextServiceResult != null && nextServiceResult!.remaining < 0
              ? l10n.statusOverdue
              : l10n.nextService,
          valueColor: serviceColor,
          iconColor: serviceColor,
        ),
      ],
    );
  }

  static String _ageString(Duration d) {
    final months = d.inDays ~/ 30;
    if (months < 1)  return '< 1 měs.';
    if (months < 12) return '$months měs.';
    final years = months ~/ 12;
    final rem   = months % 12;
    return rem > 0 ? '${years}r ${rem}m' : '${years} r.';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String   value;
  final String   label;
  final Color?   valueColor;
  final Color?   iconColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: context.isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.cardBorderColor, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: valueColor ??
                    (context.isDark ? Colors.white : const Color(0xFF1A1A1A)),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: context.subtitleColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Maintenance plan section ─────────────────────────────────────────────────

class _MaintenancePlanSection extends StatelessWidget {
  final List<MaintenanceStatusResult> results;
  final List<MaintenanceLog>          maintenanceLogs;
  final void Function(int? ruleId)    onLogService;
  final VoidCallback                  onAddRule;

  const _MaintenancePlanSection({
    required this.results,
    required this.maintenanceLogs,
    required this.onLogService,
    required this.onAddRule,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: l10n.maintenancePlan,
            onAdd: onAddRule,
            addLabel: l10n.addMaintenanceRule,
          ),
          if (results.isEmpty)
            _EmptyHint(l10n.noMaintenanceRules)
          else
            ...results.map((r) {
              final logsForRule = maintenanceLogs
                  .where((l) => l.ruleId == r.rule.id)
                  .toList()
                ..sort((a, b) => b.performedDate.compareTo(a.performedDate));
              final lastDate =
                  logsForRule.isEmpty ? null : logsForRule.first.performedDate;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MaintenanceRuleCard(
                  result: r,
                  lastPerformed: lastDate,
                  onLogService: () => onLogService(r.rule.id),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _MaintenanceRuleCard extends StatelessWidget {
  final MaintenanceStatusResult result;
  final DateTime?               lastPerformed;
  final VoidCallback            onLogService;

  static final _dateFmt = DateFormat('d. M. yyyy');

  const _MaintenanceRuleCard({
    required this.result,
    required this.lastPerformed,
    required this.onLogService,
  });

  @override
  Widget build(BuildContext context) {
    final r         = result;
    final isOverdue = r.status == MaintenanceStatus.overdue;
    final isWarning = r.status == MaintenanceStatus.warning;
    final barColor  = isOverdue
        ? context.dangerColor
        : isWarning
            ? context.warningColor
            : context.successColor;

    final progress = r.rule.triggerValue > 0
        ? ((r.rule.triggerValue - r.remaining) / r.rule.triggerValue)
            .clamp(0.0, 1.0)
        : 1.0;

    final lastText = lastPerformed != null
        ? 'Naposledy: ${_dateFmt.format(lastPerformed!)}'
        : 'Dosud neprovedeno';

    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorderColor, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Název + štít + badge
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.rule.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (r.rule.isSafetyCritical)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(Icons.shield_outlined,
                            size: 14, color: context.subtitleColor),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MaintenanceBadge(status: r.status),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: context.isDark
                  ? AppColors.darkBorder
                  : const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 8),
          // Naposledy · interval
          Row(
            children: [
              Expanded(
                child: Text(
                  lastText,
                  style:
                      TextStyle(fontSize: 11, color: context.subtitleColor),
                ),
              ),
              Text(
                _intervalText(r.rule),
                style: TextStyle(fontSize: 11, color: context.subtitleColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Zapsat servis
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLogService,
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: Text(AppLocalizations.of(context).logService,
                  style: const TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _intervalText(MaintenanceRule rule) => switch (rule.triggerType) {
    TriggerType.date          => 'každých ${rule.triggerValue.toInt()} dní',
    TriggerType.usageHours    =>
        'každých ${rule.triggerValue.toStringAsFixed(0)} h',
    TriggerType.usageDistance =>
        'každých ${rule.triggerValue.toStringAsFixed(0)} km',
    TriggerType.usageCount    => 'každých ${rule.triggerValue.toInt()}×',
  };
}

// ─── Activity history section ─────────────────────────────────────────────────

class _ActivityHistorySection extends StatefulWidget {
  final List<UsageLog> logs;
  final VoidCallback   onAdd;
  final VoidCallback   onImportIgc;

  const _ActivityHistorySection({
    required this.logs,
    required this.onAdd,
    required this.onImportIgc,
  });

  @override
  State<_ActivityHistorySection> createState() => _ActivityHistorySectionState();
}

class _ActivityHistorySectionState extends State<_ActivityHistorySection> {
  static const _previewCount = 5;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final logs        = widget.logs;
    final hasMore     = logs.length > _previewCount;
    final visibleLogs = (_showAll || !hasMore)
        ? logs
        : logs.take(_previewCount).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row with IGC + Add buttons ───────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.activityHistory,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.onImportIgc,
                  icon: const Icon(Icons.flight_outlined, size: 15),
                  label: Text(l10n.importIgc, style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: widget.onAdd,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(l10n.add, style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),

          // ── Log rows ─────────────────────────────────────────────────────
          if (logs.isEmpty)
            _EmptyHint(l10n.noActivities)
          else ...[
            ...visibleLogs.map((l) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ActivityRow(log: l),
                )),

            // ── "Zobrazit vše" / "Skrýt" button ─────────────────────────
            if (hasMore)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => setState(() => _showAll = !_showAll),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      _showAll
                          ? l10n.hide
                          : l10n.showAll(logs.length),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final UsageLog log;
  static final _dateFmt = DateFormat('d. M. yyyy');

  const _ActivityRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (log.durationMinutes != null)
        '${(log.durationMinutes! / 60).toStringAsFixed(1)} h',
      if (log.distanceKm != null) '${log.distanceKm!.round()} km',
      if (log.location != null) log.location!,
    ];

    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorderColor, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.directions_run,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateFmt.format(log.date),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                if (parts.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    parts.join(' · '),
                    style: TextStyle(
                        fontSize: 12, color: context.subtitleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _SourceBadge(source: log.source),
        ],
      ),
    );
  }
}

// ─── Source badge ─────────────────────────────────────────────────────────────

class _SourceBadge extends StatelessWidget {
  final UsageSource source;
  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = switch (source) {
      UsageSource.manual => (l10n.sourceManual, AppColors.subtitleGray),
      UsageSource.strava => (l10n.sourceStrava, const Color(0xFFFC4C02)),
      UsageSource.garmin => (l10n.sourceGarmin, const Color(0xFF006EBF)),
      UsageSource.gpx    => (l10n.sourceGpx,    const Color(0xFF5C6BC0)),
      UsageSource.igc    => (l10n.sourceIgc,    const Color(0xFF00897B)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

// ─── Bottom action buttons ────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final VoidCallback onAddActivity;
  final VoidCallback onLogService;
  final VoidCallback onEdit;

  const _BottomActions({
    required this.onAddActivity,
    required this.onLogService,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : Colors.white,
        border: Border(
          top: BorderSide(color: context.cardBorderColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAddActivity,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(l10n.addActivity,
                      style: const TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onLogService,
                  icon: const Icon(Icons.build_outlined, size: 16),
                  label: Text(l10n.logService,
                      style: const TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(l10n.edit,
                      style: const TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.isDark
                        ? Colors.white
                        : const Color(0xFF1A1A1A),
                    side: BorderSide(color: context.cardBorderColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── IGC preview dialog ───────────────────────────────────────────────────────

class _IgcPreviewDialog extends StatelessWidget {
  final IgcFlight flight;
  static final _dateFmt = DateFormat('d. M. yyyy');

  const _IgcPreviewDialog({required this.flight});

  @override
  Widget build(BuildContext context) {
    final h   = flight.durationMinutes ~/ 60;
    final m   = flight.durationMinutes % 60;
    final dur = h > 0 ? '$h h $m min' : '$m min';

    final start =
        '${flight.startHour.toString().padLeft(2, '0')}:'
        '${flight.startMinute.toString().padLeft(2, '0')}';
    final end =
        '${flight.endHour.toString().padLeft(2, '0')}:'
        '${flight.endMinute.toString().padLeft(2, '0')}';

    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.flight_outlined,
                color: Color(0xFF00897B), size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Náhled letu', style: TextStyle(fontSize: 17)),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PreviewRow(Icons.calendar_today_outlined,
              'Datum', _dateFmt.format(flight.flightDate)),
          _PreviewRow(Icons.schedule_outlined,
              'Start', start),
          _PreviewRow(Icons.schedule_outlined,
              'Přistání', end),
          _PreviewRow(Icons.timer_outlined,
              'Délka letu', dur),
          _PreviewRow(Icons.height_rounded,
              'Max výška', '${flight.maxAltitudeM} m'),
          _PreviewRow(Icons.location_on_outlined,
              'GPS start',
              '${flight.startLat.toStringAsFixed(4)}°, '
              '${flight.startLon.toStringAsFixed(4)}°'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary),
          child: Text(AppLocalizations.of(context).add),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;

  const _PreviewRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 15, color: context.subtitleColor),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, color: context.subtitleColor)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String       title;
  final VoidCallback onAdd;
  final String       addLabel;

  const _SectionHeader(
      {required this.title, required this.onAdd, required this.addLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(addLabel,
                style: const TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text,
          style: TextStyle(color: context.subtitleColor, fontSize: 13)),
    );
  }
}

// ─── Strava gear section ──────────────────────────────────────────────────────

class _StravaGearSection extends StatefulWidget {
  final bool                               connected;
  final GearStravaSettings?                settings;
  final bool                               syncing;
  final String?                            categoryIcon;
  final Future<void> Function(GearStravaSettings) onSave;
  final VoidCallback                       onSync;
  final int                                gearItemId;

  const _StravaGearSection({
    required this.connected,
    required this.settings,
    required this.syncing,
    required this.categoryIcon,
    required this.onSave,
    required this.onSync,
    required this.gearItemId,
  });

  @override
  State<_StravaGearSection> createState() => _StravaGearSectionState();
}

class _StravaGearSectionState extends State<_StravaGearSection> {
  late List<String> _selectedTypes;
  late bool         _syncEnabled;
  DateTime?         _syncFrom;

  static const _stravaOrange = Color(0xFFFC4C02);

  @override
  void initState() {
    super.initState();
    _initFromSettings();
  }

  @override
  void didUpdateWidget(_StravaGearSection old) {
    super.didUpdateWidget(old);
    if (old.settings != widget.settings) _initFromSettings();
  }

  void _initFromSettings() {
    final s = widget.settings;
    _selectedTypes = List<String>.from(s?.activityTypes ?? []);
    _syncEnabled   = s?.syncEnabled ?? false;
    _syncFrom      = s?.syncFrom;

    // Auto-suggest types from category if empty
    if (_selectedTypes.isEmpty && widget.categoryIcon != null) {
      _selectedTypes =
          List<String>.from(StravaActivityTypes.forIcon(widget.categoryIcon!));
    }
  }

  Future<void> _save() async {
    await widget.onSave(GearStravaSettings(
      gearItemId:    widget.gearItemId,
      activityTypes: _selectedTypes,
      syncEnabled:   _syncEnabled,
      syncFrom:      _syncFrom,
    ));
  }

  Future<void> _pickSyncFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _syncFrom ?? DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      helpText: 'Synchronizovat aktivity od',
    );
    if (picked != null) {
      setState(() => _syncFrom = picked);
      _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              const Icon(Icons.directions_run, size: 16, color: _stravaOrange),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context).stravaSync,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (!widget.connected)
            // Not connected → prompt
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorderColor, width: 0.5),
              ),
              child: Text(
                'Strava není připojena. Přejdi do Nastavení → Propojené služby.',
                style: TextStyle(
                    fontSize: 13, color: context.subtitleColor),
              ),
            )
          else ...[
            // Sync enable switch
            Container(
              decoration: BoxDecoration(
                color: context.isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorderColor, width: 0.5),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      AppLocalizations.of(context).stravaAutoSync,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Importuj aktivity ze Stravy jako záznamy použití',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _syncEnabled,
                    activeColor: _stravaOrange,
                    onChanged: (v) {
                      setState(() => _syncEnabled = v);
                      _save();
                    },
                  ),

                  if (_syncEnabled) ...[
                    const Divider(height: 0),

                    // Sync from date
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.calendar_today_outlined,
                          size: 18, color: _stravaOrange),
                      title: Text(AppLocalizations.of(context).stravaSyncFrom,
                          style: const TextStyle(fontSize: 13)),
                      trailing: Text(
                        _syncFrom != null
                            ? DateFormat('d. M. yyyy').format(_syncFrom!)
                            : 'Vybrat datum',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _stravaOrange,
                        ),
                      ),
                      onTap: _pickSyncFrom,
                    ),

                    const Divider(height: 0),

                    // Activity type chips
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).stravaSyncTypes,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: StravaActivityTypes.all.map((type) {
                              final selected = _selectedTypes.contains(type);
                              return FilterChip(
                                label: Text(
                                  StravaActivityTypes.label(type),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                selected: selected,
                                selectedColor:
                                    _stravaOrange.withOpacity(0.15),
                                checkmarkColor: _stravaOrange,
                                side: BorderSide(
                                  color: selected
                                      ? _stravaOrange
                                      : context.cardBorderColor,
                                ),
                                showCheckmark: true,
                                onSelected: (v) {
                                  setState(() {
                                    if (v) {
                                      _selectedTypes.add(type);
                                    } else {
                                      _selectedTypes.remove(type);
                                    }
                                  });
                                  _save();
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Manual sync button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (_syncEnabled && !widget.syncing)
                    ? widget.onSync
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _stravaOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: widget.syncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync, size: 18),
                label: Text(
                  widget.syncing
                      ? AppLocalizations.of(context).loading
                      : AppLocalizations.of(context).stravasyncActivities,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

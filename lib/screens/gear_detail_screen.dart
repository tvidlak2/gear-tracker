import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/category.dart';
import '../models/gear_item.dart';
import '../models/maintenance_log.dart';
import '../models/maintenance_rule.dart';
import '../models/usage_log.dart';
import '../services/maintenance_service.dart';
import '../theme/app_theme.dart';
import '../widgets/maintenance_badge.dart';

class GearDetailScreen extends StatefulWidget {
  final int gearItemId;
  const GearDetailScreen({super.key, required this.gearItemId});

  @override
  State<GearDetailScreen> createState() => _GearDetailScreenState();
}

class _GearDetailScreenState extends State<GearDetailScreen> {
  final _db  = DatabaseHelper.instance;
  final _svc = MaintenanceService();

  GearItem?                     _item;
  Category?                     _category;
  List<MaintenanceStatusResult> _maintenanceResults = [];
  List<MaintenanceLog>          _maintenanceLogs    = [];
  List<UsageLog>                _usageLogs          = [];
  int    _totalMinutes = 0;
  double _totalKm      = 0;
  int    _usageCount   = 0;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final item = await _db.getGearItemById(widget.gearItemId);
    if (item == null) { if (mounted) context.pop(); return; }

    final category     = await _db.getCategoryById(item.categoryId);
    final results      = await _svc.getStatusForItem(item.id!);
    final logs         = await _db.getMaintenanceLogs(gearItemId: item.id!);
    final usageLogs    = await _db.getUsageLogs(gearItemId: item.id!);
    final totalMinutes = await _db.getTotalDurationMinutes(item.id!);
    final totalKm      = await _db.getTotalDistanceKm(item.id!);
    final usageCount   = await _db.getUsageCount(item.id!);

    if (mounted) {
      setState(() {
        _item = item;              _category = category;
        _maintenanceResults = results; _maintenanceLogs = logs;
        _usageLogs = usageLogs;    _totalMinutes = totalMinutes;
        _totalKm = totalKm;        _usageCount = usageCount;
        _loading = false;
      });
    }
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
      body: CustomScrollView(
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
              logs: _usageLogs.take(5).toList(),
              onAdd: () => context
                  .push('/gear/${item.id}/usage/add')
                  .then((_) => _loadData()),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
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
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'status', child: Text('Změnit stav')),
            PopupMenuItem(
              value: 'delete',
              child: Text('Smazat', style: TextStyle(color: AppColors.danger)),
            ),
          ],
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

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Stav vybavení'),
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Smazat vybavení?'),
        content: Text(
            'Opravdu chceš smazat "${_item!.name}"? Tato akce je nevratná.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Zrušit')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Smazat'),
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
          label: 'Hodiny',
        ),
        const SizedBox(width: 8),
        _StatCard(
          icon: Icons.calendar_today_outlined,
          value: age,
          label: 'Stáří',
        ),
        const SizedBox(width: 8),
        _StatCard(
          icon: Icons.build_outlined,
          value: serviceVal,
          label: nextServiceResult != null && nextServiceResult!.remaining < 0
              ? 'Po termínu'
              : 'Do servisu',
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Plán údržby',
            onAdd: onAddRule,
            addLabel: 'Přidat pravidlo',
          ),
          if (results.isEmpty)
            _EmptyHint('Žádná pravidla údržby.')
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
              label: const Text('Zapsat servis',
                  style: TextStyle(fontSize: 13)),
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

class _ActivityHistorySection extends StatelessWidget {
  final List<UsageLog> logs;
  final VoidCallback   onAdd;

  const _ActivityHistorySection({required this.logs, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Historie aktivit',
            onAdd: onAdd,
            addLabel: 'Přidat',
          ),
          if (logs.isEmpty)
            _EmptyHint('Žádné záznamy o použití.')
          else
            ...logs.map((l) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ActivityRow(log: l),
                )),
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
    final (label, color) = switch (source) {
      UsageSource.manual => ('Ručně',  AppColors.subtitleGray),
      UsageSource.strava => ('Strava', const Color(0xFFFC4C02)),
      UsageSource.garmin => ('Garmin', const Color(0xFF006EBF)),
      UsageSource.gpx    => ('GPX',    const Color(0xFF5C6BC0)),
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
                  label: const Text('Aktivita',
                      style: TextStyle(fontSize: 12)),
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
                  label: const Text('Zapsat servis',
                      style: TextStyle(fontSize: 12)),
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
                  label: const Text('Upravit',
                      style: TextStyle(fontSize: 12)),
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

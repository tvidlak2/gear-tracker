import 'dart:io';

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

class _GearDetailScreenState extends State<GearDetailScreen>
    with SingleTickerProviderStateMixin {
  final _db  = DatabaseHelper.instance;
  final _svc = MaintenanceService();

  GearItem?                    _item;
  Category?                    _category;
  List<MaintenanceStatusResult> _maintenanceResults = [];
  List<MaintenanceLog>          _maintenanceLogs    = [];
  List<UsageLog>                _usageLogs          = [];
  int    _totalMinutes = 0;
  double _totalKm      = 0;
  int    _usageCount   = 0;

  late TabController _tabController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final item = await _db.getGearItemById(widget.gearItemId);
    if (item == null) { if (mounted) context.pop(); return; }

    final category    = await _db.getCategoryById(item.categoryId);
    final results     = await _svc.getStatusForItem(item.id!);
    final logs        = await _db.getMaintenanceLogs(gearItemId: item.id!);
    final usageLogs   = await _db.getUsageLogs(gearItemId: item.id!);
    final totalMinutes = await _db.getTotalDurationMinutes(item.id!);
    final totalKm     = await _db.getTotalDistanceKm(item.id!);
    final usageCount  = await _db.getUsageCount(item.id!);

    if (mounted) {
      setState(() {
        _item = item; _category = category;
        _maintenanceResults = results; _maintenanceLogs = logs;
        _usageLogs = usageLogs; _totalMinutes = totalMinutes;
        _totalKm = totalKm; _usageCount = usageCount;
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

    // Nejbližší servis (jen date-based pravidla s kladným remaining)
    final nextServiceDays = _maintenanceResults
        .where((r) => r.rule.triggerType == TriggerType.date && r.remaining >= 0)
        .map((r) => r.remaining.toInt())
        .fold<int?>(null, (min, v) => min == null || v < min ? v : min);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          _GreenHeader(
            item: item,
            category: _category,
            tabController: _tabController,
            onEdit: () => context.push('/gear/${item.id}/edit').then((_) => _loadData()),
            onStatusChange: _showStatusDialog,
            onDelete: _confirmDelete,
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(
              item: item,
              category: _category,
              maintenanceResults: _maintenanceResults,
              totalMinutes: _totalMinutes,
              totalKm: _totalKm,
              usageCount: _usageCount,
              nextServiceDays: nextServiceDays,
            ),
            _MaintenanceTab(
              results: _maintenanceResults,
              logs: _maintenanceLogs,
              onAddLog: () => context
                  .push('/gear/${item.id}/maintenance/add')
                  .then((_) => _loadData()),
              onAddRule: () => context
                  .push('/gear/${item.id}/rules/add')
                  .then((_) => _loadData()),
            ),
            _UsageTab(
              logs: _usageLogs,
              onAdd: () => context
                  .push('/gear/${item.id}/usage/add')
                  .then((_) => _loadData()),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Stav vybavení'),
        children: GearStatus.values.map((s) => SimpleDialogOption(
          child: Text(s.label),
          onPressed: () async {
            Navigator.pop(context);
            await _db.updateGearItem(_item!.copyWith(status: s));
            _loadData();
          },
        )).toList(),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Smazat vybavení?'),
        content: Text('Opravdu chceš smazat "${_item!.name}"? Tato akce je nevratná.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Zrušit')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
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

// ─── Zelený header ────────────────────────────────────────────────────────────

class _GreenHeader extends StatelessWidget {
  final GearItem      item;
  final Category?     category;
  final TabController tabController;
  final VoidCallback  onEdit;
  final VoidCallback  onStatusChange;
  final VoidCallback  onDelete;

  const _GreenHeader({
    required this.item,
    required this.category,
    required this.tabController,
    required this.onEdit,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = item.photoPath != null;

    return SliverAppBar(
      expandedHeight: hasPhoto ? 240 : 140,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: onEdit,
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
            if (v == 'status') onStatusChange();
            if (v == 'delete') onDelete();
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Pozadí – foto nebo plná zelená
            if (hasPhoto)
              Image.file(File(item.photoPath!), fit: BoxFit.cover)
            else
              Container(color: AppColors.primary),
            // Gradient overlay pro čitelnost textu
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withOpacity(hasPhoto ? 0.85 : 1.0),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            // Text info
            Positioned(
              left: 16,
              right: 16,
              bottom: 56, // nad TabBar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (category != null)
                    Text(
                      category!.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.serialNumber != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'SN: ${item.serialNumber}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: TabBar(
        controller: tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 2,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Přehled'),
          Tab(text: 'Údržba'),
          Tab(text: 'Použití'),
        ],
      ),
    );
  }
}

// ─── Overview tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final GearItem                  item;
  final Category?                 category;
  final List<MaintenanceStatusResult> maintenanceResults;
  final int    totalMinutes;
  final double totalKm;
  final int    usageCount;
  final int?   nextServiceDays;

  static final _dateFmt = DateFormat('d. M. yyyy');

  const _OverviewTab({
    required this.item,
    required this.category,
    required this.maintenanceResults,
    required this.totalMinutes,
    required this.totalKm,
    required this.usageCount,
    required this.nextServiceDays,
  });

  @override
  Widget build(BuildContext context) {
    // Stáří vybavení
    final ageText = item.purchaseDate != null
        ? _ageString(DateTime.now().difference(item.purchaseDate!))
        : '–';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // ── 3 stat karty ──────────────────────────────────────────────────
        _StatCardsRow(
          cells: [
            _StatCell(
              icon: Icons.timer_outlined,
              value: totalMinutes >= 60
                  ? '${(totalMinutes / 60).toStringAsFixed(0)} h'
                  : '$totalMinutes min',
              label: 'Hodiny',
            ),
            _StatCell(
              icon: Icons.calendar_today_outlined,
              value: ageText,
              label: 'Stáří',
            ),
            _StatCell(
              icon: Icons.build_outlined,
              value: nextServiceDays != null ? '${nextServiceDays}d' : '–',
              label: 'Do servisu',
              valueColor: nextServiceDays != null && nextServiceDays! <= 30
                  ? context.warningColor
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Info o vybavení ───────────────────────────────────────────────
        _FlatCard(
          children: [
            if (category != null) _InfoRow('Kategorie', category!.name),
            if (item.brand != null) _InfoRow('Značka', item.brand!),
            if (item.model != null) _InfoRow('Model', item.model!),
            if (item.serialNumber != null) _InfoRow('Sériové číslo', item.serialNumber!),
            if (item.manufacturedDate != null)
              _InfoRow('Rok výroby', _dateFmt.format(item.manufacturedDate!)),
            if (item.purchaseDate != null)
              _InfoRow('Datum koupě', _dateFmt.format(item.purchaseDate!)),
            _InfoRow('Stav', item.status.label),
          ],
        ),
        const SizedBox(height: 12),

        // ── Statistiky ────────────────────────────────────────────────────
        _FlatCard(
          title: 'Statistiky použití',
          children: [
            _InfoRow('Počet aktivit', '$usageCount×'),
            _InfoRow('Celkem hodin', '${(totalMinutes / 60).toStringAsFixed(1)} h'),
            _InfoRow('Celkem km', '${totalKm.toStringAsFixed(1)} km'),
          ],
        ),

        // ── Maintenance pravidla s progress barem ─────────────────────────
        if (maintenanceResults.isNotEmpty) ...[
          const SizedBox(height: 12),
          _FlatCard(
            title: 'Stav údržby',
            children: maintenanceResults
                .map((r) => _MaintenanceProgressRow(result: r))
                .toList(),
          ),
        ],

        // ── Poznámky ──────────────────────────────────────────────────────
        if (item.notes != null && item.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _FlatCard(
            title: 'Poznámky',
            children: [Text(item.notes!, style: const TextStyle(fontSize: 13))],
          ),
        ],
      ],
    );
  }

  String _ageString(Duration d) {
    final months = d.inDays ~/ 30;
    if (months < 12) return '$months měs.';
    final years = months ~/ 12;
    final rem   = months % 12;
    return rem > 0 ? '${years}r ${rem}m' : '${years} r.';
  }
}

// ─── Stat cards row ───────────────────────────────────────────────────────────

class _StatCardsRow extends StatelessWidget {
  final List<_StatCell> cells;
  const _StatCardsRow({required this.cells});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: cells.map((c) {
        final isLast = cells.indexOf(c) == cells.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                color: context.isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorderColor, width: 0.5),
              ),
              child: Column(
                children: [
                  Icon(c.icon, size: 18,
                      color: c.valueColor ?? AppColors.primary),
                  const SizedBox(height: 6),
                  Text(
                    c.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: c.valueColor ??
                          (context.isDark ? Colors.white : const Color(0xFF1A1A1A)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.label,
                    style: TextStyle(fontSize: 11, color: context.subtitleColor),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatCell {
  final IconData icon;
  final String   value;
  final String   label;
  final Color?   valueColor;

  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });
}

// ─── Maintenance progress row ─────────────────────────────────────────────────

class _MaintenanceProgressRow extends StatelessWidget {
  final MaintenanceStatusResult result;
  const _MaintenanceProgressRow({required this.result});

  @override
  Widget build(BuildContext context) {
    final r         = result;
    final isOverdue = r.status == MaintenanceStatus.overdue;
    final isWarning = r.status == MaintenanceStatus.warning;

    final barColor = isOverdue
        ? context.dangerColor
        : isWarning
            ? context.warningColor
            : context.successColor;

    // progress = použito / celkový interval (0.0 – 1.0)
    final progress = r.rule.triggerValue > 0
        ? ((r.rule.triggerValue - r.remaining) / r.rule.triggerValue).clamp(0.0, 1.0)
        : 1.0;

    final subtitle = _subtitleText(r);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.rule.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              if (r.rule.isSafetyCritical)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(Icons.shield_outlined, size: 13,
                      color: context.subtitleColor),
                ),
              MaintenanceBadge(status: r.status),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  context.isDark ? AppColors.darkBorder : const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: context.subtitleColor),
          ),
        ],
      ),
    );
  }

  String _subtitleText(MaintenanceStatusResult r) {
    final val  = r.remaining.abs();
    final past = r.remaining < 0;
    return switch (r.rule.triggerType) {
      TriggerType.date =>
        past ? 'Překročeno o ${val.toInt()} dní' : 'Za ${val.toInt()} dní',
      TriggerType.usageHours =>
        past ? 'Překročeno o ${val.toStringAsFixed(1)} h'
             : 'Zbývá ${val.toStringAsFixed(1)} h',
      TriggerType.usageDistance =>
        past ? 'Překročeno o ${val.toStringAsFixed(1)} km'
             : 'Zbývá ${val.toStringAsFixed(1)} km',
      TriggerType.usageCount =>
        past ? 'Překročeno o ${val.toInt()}×' : 'Zbývá ${val.toInt()}×',
    };
  }
}

// ─── Flat card ────────────────────────────────────────────────────────────────

class _FlatCard extends StatelessWidget {
  final String?       title;
  final List<Widget>  children;

  const _FlatCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorderColor, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const Divider(height: 16),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(fontSize: 13, color: context.subtitleColor)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ─── Maintenance tab ──────────────────────────────────────────────────────────

class _MaintenanceTab extends StatelessWidget {
  final List<MaintenanceStatusResult> results;
  final List<MaintenanceLog>          logs;
  final VoidCallback onAddLog;
  final VoidCallback onAddRule;

  static final _dateFmt = DateFormat('d. M. yyyy');

  const _MaintenanceTab({
    required this.results, required this.logs,
    required this.onAddLog, required this.onAddRule,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _TabSectionHeader('Pravidla', onAdd: onAddRule, addLabel: 'Přidat pravidlo'),
        if (results.isEmpty)
          _EmptyHint('Žádná pravidla údržby.')
        else
          ...results.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _FlatCard(children: [_MaintenanceProgressRow(result: r)]),
          )),

        const SizedBox(height: 8),
        _TabSectionHeader('Historie', onAdd: onAddLog, addLabel: 'Zaznamenat'),
        if (logs.isEmpty)
          _EmptyHint('Žádné záznamy o údržbě.')
        else
          ...logs.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: context.isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorderColor, width: 0.5),
              ),
              child: ListTile(
                leading: Icon(Icons.build_outlined, color: AppColors.primary, size: 20),
                title: Text(_dateFmt.format(l.performedDate),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: l.notes != null ? Text(l.notes!, style: const TextStyle(fontSize: 12)) : null,
                trailing: l.cost != null
                    ? Text('${l.cost!.toStringAsFixed(0)} Kč',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))
                    : null,
              ),
            ),
          )),
      ],
    );
  }
}

// ─── Usage tab ────────────────────────────────────────────────────────────────

class _UsageTab extends StatelessWidget {
  final List<UsageLog> logs;
  final VoidCallback   onAdd;

  static final _dateFmt = DateFormat('d. M. yyyy');

  const _UsageTab({required this.logs, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _TabSectionHeader('Aktivity', onAdd: onAdd, addLabel: 'Přidat'),
        if (logs.isEmpty)
          _EmptyHint('Žádné záznamy o použití.')
        else
          ...logs.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: context.isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorderColor, width: 0.5),
              ),
              child: ListTile(
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.directions_run,
                      color: AppColors.primary, size: 18),
                ),
                title: Text(_dateFmt.format(l.date),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text(
                  [
                    if (l.durationMinutes != null)
                      '${(l.durationMinutes! / 60).toStringAsFixed(1)} h',
                    if (l.distanceKm != null)
                      '${l.distanceKm!.toStringAsFixed(1)} km',
                    if (l.location != null) l.location!,
                  ].join(' · '),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: _SourceBadge(source: l.source),
              ),
            ),
          )),
      ],
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
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _TabSectionHeader extends StatelessWidget {
  final String       title;
  final VoidCallback onAdd;
  final String       addLabel;

  const _TabSectionHeader(this.title, {required this.onAdd, required this.addLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: Text(addLabel, style: const TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      child: Text(text, style: TextStyle(color: context.subtitleColor, fontSize: 13)),
    );
  }
}

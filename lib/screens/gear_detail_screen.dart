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
import '../widgets/maintenance_badge.dart';

class GearDetailScreen extends StatefulWidget {
  final int gearItemId;

  const GearDetailScreen({super.key, required this.gearItemId});

  @override
  State<GearDetailScreen> createState() => _GearDetailScreenState();
}

class _GearDetailScreenState extends State<GearDetailScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseHelper.instance;
  final _maintenanceService = MaintenanceService();

  GearItem? _item;
  Category? _category;
  List<MaintenanceStatusResult> _maintenanceResults = [];
  List<MaintenanceLog> _maintenanceLogs = [];
  List<UsageLog> _usageLogs = [];
  int _totalMinutes = 0;
  double _totalKm = 0;
  int _usageCount = 0;

  late TabController _tabController;
  bool _loading = true;

  static final _dateFormat = DateFormat('d. M. yyyy');

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
    if (item == null) {
      if (mounted) context.pop();
      return;
    }
    final category = await _db.getCategoryById(item.categoryId);
    final results = await _maintenanceService.getStatusForItem(item.id!);
    final logs = await _db.getMaintenanceLogs(gearItemId: item.id!);
    final usageLogs = await _db.getUsageLogs(gearItemId: item.id!);
    final totalMinutes = await _db.getTotalDurationMinutes(item.id!);
    final totalKm = await _db.getTotalDistanceKm(item.id!);
    final usageCount = await _db.getUsageCount(item.id!);

    if (mounted) {
      setState(() {
        _item = item;
        _category = category;
        _maintenanceResults = results;
        _maintenanceLogs = logs;
        _usageLogs = usageLogs;
        _totalMinutes = totalMinutes;
        _totalKm = totalKm;
        _usageCount = usageCount;
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

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: item.photoPath != null ? 220 : 0,
            pinned: true,
            title: Text(item.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.push('/gear/${item.id}/edit').then((_) => _loadData()),
              ),
              PopupMenuButton(
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'status',
                    child: Text('Změnit stav'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Smazat', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (v) {
                  if (v == 'status') _showStatusDialog();
                  if (v == 'delete') _confirmDelete();
                },
              ),
            ],
            flexibleSpace: item.photoPath != null
                ? FlexibleSpaceBar(
                    background: Image.file(
                      File(item.photoPath!),
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Přehled'),
                Tab(text: 'Údržba'),
                Tab(text: 'Použití'),
              ],
            ),
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
            ),
            _MaintenanceTab(
              results: _maintenanceResults,
              logs: _maintenanceLogs,
              onAddLog: _showAddMaintenanceDialog,
              onAddRule: () =>
                  context.push('/gear/${item.id}/rules/add').then((_) => _loadData()),
            ),
            _UsageTab(
              logs: _usageLogs,
              onAdd: () =>
                  context.push('/gear/${item.id}/usage/add').then((_) => _loadData()),
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
        children: GearStatus.values.map((s) {
          return SimpleDialogOption(
            child: Text(s.label),
            onPressed: () async {
              Navigator.pop(context);
              final updated = _item!.copyWith(status: s);
              await _db.updateGearItem(updated);
              _loadData();
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Smazat vybavení?'),
        content: Text('Opravdu chceš smazat "${_item!.name}"? Tato akce je nevratná.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Smazat'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _db.deleteGearItem(_item!.id!);
      context.pop();
    }
  }

  void _showAddMaintenanceDialog() {
    context
        .push('/gear/${_item!.id}/maintenance/add')
        .then((_) => _loadData());
  }
}

// ─────────────────────────────── TABS ────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final GearItem item;
  final Category? category;
  final List<MaintenanceStatusResult> maintenanceResults;
  final int totalMinutes;
  final double totalKm;
  final int usageCount;

  static final _dateFormat = DateFormat('d. M. yyyy');

  const _OverviewTab({
    required this.item,
    required this.category,
    required this.maintenanceResults,
    required this.totalMinutes,
    required this.totalKm,
    required this.usageCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(children: [
          _row('Kategorie', category?.name ?? '–'),
          if (item.brand != null) _row('Značka', item.brand!),
          if (item.model != null) _row('Model', item.model!),
          if (item.serialNumber != null)
            _row('Sériové číslo', item.serialNumber!),
          if (item.manufacturedDate != null)
            _row('Rok výroby', _dateFormat.format(item.manufacturedDate!)),
          if (item.purchaseDate != null)
            _row('Datum koupě', _dateFormat.format(item.purchaseDate!)),
          _row('Stav', item.status.label),
        ]),
        const SizedBox(height: 12),
        _InfoCard(title: 'Statistiky použití', children: [
          _row('Počet aktivit', '$usageCount×'),
          _row('Celkem hodin',
              '${(totalMinutes / 60).toStringAsFixed(1)} h'),
          _row('Celkem km', '${totalKm.toStringAsFixed(1)} km'),
        ]),
        if (maintenanceResults.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoCard(title: 'Údržba', children: [
            ...maintenanceResults.map(
              (r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    MaintenanceBadge(status: r.status, compact: true),
                    const SizedBox(width: 8),
                    Expanded(child: Text(r.rule.name)),
                  ],
                ),
              ),
            ),
          ]),
        ],
        if (item.notes != null && item.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoCard(title: 'Poznámky', children: [
            Text(item.notes!),
          ]),
        ],
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _InfoCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!,
                  style: Theme.of(context).textTheme.titleSmall),
              const Divider(),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

class _MaintenanceTab extends StatelessWidget {
  final List<MaintenanceStatusResult> results;
  final List<MaintenanceLog> logs;
  final VoidCallback onAddLog;
  final VoidCallback onAddRule;

  const _MaintenanceTab({
    required this.results,
    required this.logs,
    required this.onAddLog,
    required this.onAddRule,
  });

  static final _dateFormat = DateFormat('d. M. yyyy');

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pravidla', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: onAddRule,
              icon: const Icon(Icons.add),
              label: const Text('Přidat pravidlo'),
            ),
          ],
        ),
        if (results.isEmpty)
          const Text('Žádná pravidla údržby.')
        else
          ...results.map((r) => _MaintenanceRuleCard(result: r)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Historie', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: onAddLog,
              icon: const Icon(Icons.add),
              label: const Text('Zaznamenat'),
            ),
          ],
        ),
        if (logs.isEmpty)
          const Text('Žádné záznamy o údržbě.')
        else
          ...logs.map(
            (l) => ListTile(
              leading: const Icon(Icons.build_outlined),
              title: Text(_dateFormat.format(l.performedDate)),
              subtitle: l.notes != null ? Text(l.notes!) : null,
              trailing: l.cost != null
                  ? Text('${l.cost!.toStringAsFixed(0)} Kč')
                  : null,
            ),
          ),
      ],
    );
  }
}

class _MaintenanceRuleCard extends StatelessWidget {
  final MaintenanceStatusResult result;

  const _MaintenanceRuleCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: MaintenanceBadge(status: result.status),
        title: Text(result.rule.name),
        subtitle: Text(_subtitle()),
        trailing: result.rule.isSafetyCritical
            ? const Icon(Icons.warning, color: Colors.red)
            : null,
      ),
    );
  }

  String _subtitle() {
    final r = result.remaining;
    switch (result.rule.triggerType.value) {
      case 'date':
        if (r < 0) return 'Překročeno o ${r.abs().toInt()} dní';
        return 'Za ${r.toInt()} dní';
      case 'usageHours':
        if (r < 0) return 'Překročeno o ${r.abs().toStringAsFixed(1)} h';
        return 'Zbývá ${r.toStringAsFixed(1)} h';
      case 'usageDistance':
        if (r < 0) return 'Překročeno o ${r.abs().toStringAsFixed(1)} km';
        return 'Zbývá ${r.toStringAsFixed(1)} km';
      case 'usageCount':
        if (r < 0) return 'Překročeno o ${r.abs().toInt()}×';
        return 'Zbývá ${r.toInt()}×';
      default:
        return '';
    }
  }
}

class _UsageTab extends StatelessWidget {
  final List<UsageLog> logs;
  final VoidCallback onAdd;

  const _UsageTab({required this.logs, required this.onAdd});

  static final _dateFormat = DateFormat('d. M. yyyy');

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Aktivity', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Přidat'),
            ),
          ],
        ),
        if (logs.isEmpty)
          const Text('Žádné záznamy o použití.')
        else
          ...logs.map(
            (l) => ListTile(
              leading: const Icon(Icons.directions_run),
              title: Text(_dateFormat.format(l.date)),
              subtitle: Text([
                if (l.durationMinutes != null)
                  '${(l.durationMinutes! / 60).toStringAsFixed(1)} h',
                if (l.distanceKm != null)
                  '${l.distanceKm!.toStringAsFixed(1)} km',
                if (l.location != null) l.location!,
              ].join(' · ')),
              trailing: Text(
                l.source.label,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
      ],
    );
  }
}

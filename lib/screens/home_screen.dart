import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../database/database_helper.dart';
import '../models/category.dart';
import '../models/gear_item.dart';
import '../models/maintenance_rule.dart';
import '../services/maintenance_service.dart';
import '../services/strava_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gear_card.dart';
import '../widgets/maintenance_badge.dart';

// ─── View model ───────────────────────────────────────────────────────────────

class _GearWithStats {
  final GearItem item;
  final Category? category;
  final MaintenanceStatus status;
  final List<MaintenanceStatusResult> results;
  final int totalMinutes;
  final double totalKm;

  const _GearWithStats({
    required this.item,
    required this.category,
    required this.status,
    required this.results,
    required this.totalMinutes,
    required this.totalKm,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db  = DatabaseHelper.instance;
  final _svc = MaintenanceService();

  List<_GearWithStats> _gear          = [];
  bool                 _loading       = true;
  bool                 _stravaSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    StravaService.isSyncing.addListener(_onSyncStateChanged);
    _maybeAutoSync();
  }

  @override
  void dispose() {
    StravaService.isSyncing.removeListener(_onSyncStateChanged);
    super.dispose();
  }

  void _onSyncStateChanged() {
    if (mounted) {
      final wasSyncing = _stravaSyncing;
      setState(() => _stravaSyncing = StravaService.isSyncing.value);
      // Reload gear data after sync finishes to pick up new usage logs
      if (wasSyncing && !_stravaSyncing) _loadData();
    }
  }

  Future<void> _maybeAutoSync() async {
    final svc = StravaService.instance;
    if (!await svc.isConnected) return;
    if (!await svc.isAutoSyncEnabled()) return;
    // Fire-and-forget; isSyncing notifier drives the progress bar
    unawaited(svc.syncAll());
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final items      = await _db.getGearItems();
    final categories = await _db.getCategories();
    final catMap     = {for (final c in categories) c.id!: c};

    final gear = <_GearWithStats>[];
    for (final item in items) {
      final results = await _svc.getStatusForItem(item.id!);
      final worst   = _worstOf(results);
      final minutes = await _db.getTotalDurationMinutes(item.id!);
      final km      = await _db.getTotalDistanceKm(item.id!);
      gear.add(_GearWithStats(
        item: item, category: catMap[item.categoryId],
        status: worst, results: results, totalMinutes: minutes, totalKm: km,
      ));
    }

    gear.sort((a, b) {
      final si = b.status.index.compareTo(a.status.index);
      return si != 0 ? si : a.item.name.compareTo(b.item.name);
    });

    if (mounted) setState(() { _gear = gear; _loading = false; });
  }

  static MaintenanceStatus _worstOf(List<MaintenanceStatusResult> r) {
    if (r.any((x) => x.status == MaintenanceStatus.overdue)) return MaintenanceStatus.overdue;
    if (r.any((x) => x.status == MaintenanceStatus.warning)) return MaintenanceStatus.warning;
    return MaintenanceStatus.ok;
  }

  List<_GearWithStats> get _attentionItems =>
      _gear.where((g) => g.status != MaintenanceStatus.ok).toList();

  int get _attentionCount => _attentionItems
      .expand((g) => g.results)
      .where((r) => r.status != MaintenanceStatus.ok)
      .length;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Strava sync progress indicator – shown when background sync runs
          if (_stravaSyncing)
            LinearProgressIndicator(
              backgroundColor: const Color(0xFFFC4C02).withAlpha(30),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFC4C02)),
              minHeight: 3,
            ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadData,
              child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              // Sekce "Vyžaduje pozornost"
              if (_attentionItems.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Vyžaduje pozornost',
                  count: _attentionCount,
                  countColor: context.dangerColor,
                  countBgColor: context.dangerBgColor,
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  sliver: SliverList.builder(
                    itemCount: _attentionItems.length,
                    itemBuilder: (_, i) => _AttentionRow(
                      gear: _attentionItems[i],
                      onTap: () => context
                          .push('/gear/${_attentionItems[i].item.id}')
                          .then((_) => _loadData()),
                    ),
                  ),
                ),
              ],

              // Sekce "Vše vybavení"
              _SectionHeader(title: 'Vše vybavení', count: _gear.length),
              if (_gear.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyState(
                    onAdd: () => context.push('/gear/add').then((_) => _loadData()),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList.builder(
                    itemCount: _gear.length,
                    itemBuilder: (_, i) {
                      final g = _gear[i];
                      return GearCard(
                        item: g.item,
                        category: g.category,
                        maintenanceStatus: g.status,
                        totalMinutes: g.totalMinutes,
                        totalKm: g.totalKm,
                        isAlternate: i.isOdd,
                        onTap: () => context
                            .push('/gear/${g.item.id}')
                            .then((_) => _loadData()),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
          ),
        ),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      toolbarHeight: 64,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Moje vybavení',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          if (!_loading)
            Text(
              _attentionCount > 0
                  ? '$_attentionCount upozornění'
                  : 'Vše v pořádku',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: _gear.any((g) => g.status == MaintenanceStatus.overdue)
                    ? AppColors.danger
                    : _gear.any((g) => g.status == MaintenanceStatus.warning)
                        ? AppColors.warning
                        : AppColors.subtitleGray,
              ),
            ),
        ],
      ),
      actions: [
        // FAB-style tlačítko + v AppBaru
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilledButton.icon(
            onPressed: () => context.push('/gear/add').then((_) => _loadData()),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Přidat',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int    count;
  final Color? countColor;
  final Color? countBgColor;

  const _SectionHeader({
    required this.title,
    required this.count,
    this.countColor,
    this.countBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: countBgColor ??
                    Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: countColor ??
                      Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Attention row ────────────────────────────────────────────────────────────

class _AttentionRow extends StatelessWidget {
  final _GearWithStats gear;
  final VoidCallback   onTap;

  const _AttentionRow({required this.gear, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Vezmi nejhorší pravidlo pro tento řádek
    final worstResults = gear.results
        .where((r) => r.status != MaintenanceStatus.ok)
        .toList()
      ..sort((a, b) => b.status.index.compareTo(a.status.index));

    // Nejhorší stav celé karty → accent border vlevo
    final cardIsOverdue = worstResults.any((r) => r.status == MaintenanceStatus.overdue);
    final accentBorderColor = cardIsOverdue ? AppColors.danger : AppColors.warning;
    final cardBg = context.isDark
        ? (cardIsOverdue ? AppColors.dangerBgDark : AppColors.warningBgDark)
        : (cardIsOverdue ? const Color(0xFFFCEBEB) : const Color(0xFFFAEEDA));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.cardBorderColor, width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent border
                  Container(width: 3, color: accentBorderColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Column(
                        children: worstResults.map((r) {
                          final isOverdue = r.status == MaintenanceStatus.overdue;
                          final accentColor =
                              isOverdue ? context.dangerColor : context.warningColor;

                          return Padding(
                            padding: worstResults.indexOf(r) > 0
                                ? const EdgeInsets.only(top: 8)
                                : EdgeInsets.zero,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              gear.item.name,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: accentColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (r.rule.isSafetyCritical)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 4),
                                              child: Icon(
                                                Icons.shield_outlined,
                                                size: 13,
                                                color: accentColor,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${r.rule.name} – ${_statusText(r)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.subtitleColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: context.subtitleColor,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _statusText(MaintenanceStatusResult r) {
    final val  = r.remaining.abs();
    final past = r.remaining < 0;
    return switch (r.rule.triggerType) {
      TriggerType.date          => past
          ? '${val.toInt()} dní po termínu'
          : 'za ${val.toInt()} dní',
      TriggerType.usageHours    => past
          ? '${val.toStringAsFixed(1)} h po limitu'
          : 'zbývá ${val.toStringAsFixed(1)} h',
      TriggerType.usageDistance => past
          ? '${val.toStringAsFixed(0)} km po limitu'
          : 'zbývá ${val.toStringAsFixed(0)} km',
      TriggerType.usageCount    => past
          ? '${val.toInt()}× po limitu'
          : 'zbývá ${val.toInt()}×',
    };
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.backpack_outlined, size: 72, color: context.subtitleColor),
          const SizedBox(height: 16),
          const Text(
            'Zatím žádné vybavení',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Přidej své první vybavení a začni\nsledovat jeho stav a údržbu.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.subtitleColor),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Přidat vybavení'),
          ),
        ],
      ),
    );
  }
}

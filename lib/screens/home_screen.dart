import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../database/database_helper.dart';
import '../models/category.dart';
import '../models/gear_item.dart';
import '../models/maintenance_rule.dart';
import '../services/maintenance_service.dart';
import '../widgets/gear_card.dart';

// ─────────────────────────────── Data Models ──────────────────────────────

class _GearWithStats {
  final GearItem item;
  final Category? category;
  final MaintenanceStatus status;
  final List<MaintenanceStatusResult> results;
  final int totalMinutes;

  const _GearWithStats({
    required this.item,
    required this.category,
    required this.status,
    required this.results,
    required this.totalMinutes,
  });
}

// ──────────────────────────────── Screen ──────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper.instance;
  final _svc = MaintenanceService();

  List<_GearWithStats> _gear = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final items = await _db.getGearItems();
    final categories = await _db.getCategories();
    final catMap = {for (final c in categories) c.id!: c};

    final gear = <_GearWithStats>[];
    for (final item in items) {
      final results = await _svc.getStatusForItem(item.id!);
      final worst = _worstOf(results);
      final minutes = await _db.getTotalDurationMinutes(item.id!);
      gear.add(_GearWithStats(
        item: item,
        category: catMap[item.categoryId],
        status: worst,
        results: results,
        totalMinutes: minutes,
      ));
    }

    // Řazení: overdue → warning → ok; uvnitř skupiny abecedně
    gear.sort((a, b) {
      final si = b.status.index.compareTo(a.status.index);
      if (si != 0) return si;
      return a.item.name.compareTo(b.item.name);
    });

    if (mounted) setState(() { _gear = gear; _loading = false; });
  }

  static MaintenanceStatus _worstOf(List<MaintenanceStatusResult> results) {
    if (results.any((r) => r.status == MaintenanceStatus.overdue)) {
      return MaintenanceStatus.overdue;
    }
    if (results.any((r) => r.status == MaintenanceStatus.warning)) {
      return MaintenanceStatus.warning;
    }
    return MaintenanceStatus.ok;
  }

  List<_GearWithStats> get _attentionItems => _gear
      .where((g) => g.status != MaintenanceStatus.ok)
      .toList();

  int get _totalMinutes =>
      _gear.fold(0, (sum, g) => sum + g.totalMinutes);

  int get _overdueCount =>
      _gear.where((g) => g.status == MaintenanceStatus.overdue).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              SliverToBoxAdapter(child: _StatsStrip(
                gearCount: _gear.length,
                totalMinutes: _totalMinutes,
                overdueCount: _overdueCount,
              )),
              if (_attentionItems.isNotEmpty) ...[
                _buildSectionHeader('Vyžaduje pozornost', _attentionItems.length),
                SliverToBoxAdapter(
                  child: _AttentionScroll(items: _attentionItems),
                ),
              ],
              _buildSectionHeader('Vše vybavení', _gear.length),
              if (_gear.isEmpty)
                SliverToBoxAdapter(child: _EmptyState(
                  onAdd: () => context.push('/gear/add').then((_) => _loadData()),
                ))
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/gear/add').then((_) => _loadData()),
        tooltip: 'Přidat vybavení',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      title: const Text(
        'Moje vybavení',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
      ),
      pinned: true,
      floating: true,
      snap: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.backpack_outlined),
          tooltip: 'Vše vybavení',
          onPressed: () => context.push('/gear').then((_) => _loadData()),
        ),
        IconButton(
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Přidat vybavení',
          onPressed: () => context.push('/gear/add').then((_) => _loadData()),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title, int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            _CountBadge(count: count),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Stats Strip ──────────────────────────────────

class _StatsStrip extends StatelessWidget {
  final int gearCount;
  final int totalMinutes;
  final int overdueCount;

  const _StatsStrip({
    required this.gearCount,
    required this.totalMinutes,
    required this.overdueCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hours = (totalMinutes / 60.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _StatCell(
            icon: Icons.backpack_outlined,
            value: '$gearCount',
            label: 'položek',
          ),
          _VerticalDivider(),
          _StatCell(
            icon: Icons.timer_outlined,
            value: hours >= 100
                ? '${hours.toStringAsFixed(0)} h'
                : '${hours.toStringAsFixed(1)} h',
            label: 'celkem',
          ),
          _VerticalDivider(),
          _StatCell(
            icon: Icons.warning_amber_rounded,
            value: '$overdueCount',
            label: 'po termínu',
            valueColor: overdueCount > 0 ? Colors.red : null,
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: valueColor ?? cs.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor ?? cs.onPrimaryContainer,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: cs.onPrimaryContainer.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 1,
      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.15),
    );
  }
}

// ─────────────────────── Attention horizontal scroll ─────────────────────

class _AttentionScroll extends StatelessWidget {
  final List<_GearWithStats> items;
  const _AttentionScroll({required this.items});

  @override
  Widget build(BuildContext context) {
    // Rozbal pravidla – každé overdue/warning pravidlo dostane vlastní kartu
    final cards = <_AttentionCard>[];
    for (final g in items) {
      for (final r in g.results) {
        if (r.status != MaintenanceStatus.ok) {
          cards.add(_AttentionCard(gear: g, result: r));
        }
      }
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => cards[i],
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  final _GearWithStats gear;
  final MaintenanceStatusResult result;

  const _AttentionCard({required this.gear, required this.result});

  @override
  Widget build(BuildContext context) {
    final isOverdue = result.status == MaintenanceStatus.overdue;
    final accentColor = isOverdue ? const Color(0xFFD32F2F) : const Color(0xFFE65100);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push('/gear/${gear.item.id}'),
      child: Container(
        width: 218,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: accentColor, width: 4),
            top: BorderSide(color: cs.outlineVariant, width: 0.8),
            right: BorderSide(color: cs.outlineVariant, width: 0.8),
            bottom: BorderSide(color: cs.outlineVariant, width: 0.8),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    gear.item.name,
                    style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  isOverdue ? Icons.warning_rounded : Icons.info_rounded,
                  color: accentColor,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              result.rule.name,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _statusText(result),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
                if (result.rule.isSafetyCritical)
                  Tooltip(
                    message: 'Bezpečnostně kritické',
                    child: Icon(Icons.shield_outlined, size: 14, color: accentColor),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusText(MaintenanceStatusResult r) {
    final val = r.remaining.abs();
    final past = r.remaining < 0;

    switch (r.rule.triggerType.value) {
      case 'date':
        final days = val.toInt();
        return past
            ? '$days dní po termínu'
            : 'Za $days dní';
      case 'usageHours':
        final h = val.toStringAsFixed(1);
        return past ? '${h} h po limitu' : 'Zbývá ${h} h';
      case 'usageDistance':
        final km = val.toStringAsFixed(0);
        return past ? '$km km po limitu' : 'Zbývá $km km';
      case 'usageCount':
        final n = val.toInt();
        return past ? '$n× po limitu' : 'Zbývá $n×';
      default:
        return '';
    }
  }
}

// ──────────────────────────── Helpers ─────────────────────────────────────

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: cs.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.backpack_outlined, size: 72, color: cs.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'Zatím žádné vybavení',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Přidej své první vybavení a začni\nsledovat jeho stav a údržbu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
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

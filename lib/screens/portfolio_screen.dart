import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/portfolio_service.dart';
import '../services/purchase_service.dart';
import '../theme/app_theme.dart';
import 'paywall_screen.dart';

const _kMonthAbbr = [
  'led', 'úno', 'bře', 'dub', 'kvě', 'čvn',
  'čvc', 'srp', 'zář', 'říj', 'lis', 'pro',
];

const _kCategoryColors = [
  Color(0xFF1D9E75),
  Color(0xFF42A5F5),
  Color(0xFFFF7043),
  Color(0xFFAB47BC),
  Color(0xFF26A69A),
  Color(0xFFFFCA28),
  Color(0xFF78909C),
  Color(0xFFEF5350),
];

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  PortfolioStats? _stats;
  bool _loading = true;
  bool _isPremium = false;

  final _czk = NumberFormat.currency(
      locale: 'cs_CZ', symbol: 'Kč', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final stats = await PortfolioService.instance.getStats();
      final premium = await PurchaseService.instance.isPremium();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isPremium = premium;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text(
          'Portfolio',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadData,
              child: _stats == null
                  ? const Center(child: Text('Nepodařilo se načíst data.'))
                  : ListView(
                      padding:
                          const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      children: [
                        _buildSummaryCards(_stats!, isDark),
                        const SizedBox(height: 16),
                        if (_stats!.valueByCategory.isNotEmpty) ...[
                          _buildPieChartSection(_stats!, isDark),
                          const SizedBox(height: 16),
                        ],
                        _buildBarChartSection(_stats!, isDark),
                        const SizedBox(height: 16),
                        _buildGearValueList(_stats!, isDark),
                        const SizedBox(height: 16),
                        _buildExportButton(isDark),
                      ],
                    ),
            ),
    );
  }

  // ── Summary cards ───────────────────────────────────────────────────────────

  Widget _buildSummaryCards(PortfolioStats stats, bool isDark) {
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.cardBorder;

    final deprPct = stats.totalPurchaseValue > 0
        ? (stats.totalDepreciation / stats.totalPurchaseValue * 100)
            .round()
        : 0;

    final cards = [
      _SummaryCard(
        label: 'Pořizovací hodnota',
        value: _czk.format(stats.totalPurchaseValue),
        icon: Icons.shopping_cart_outlined,
        color: const Color(0xFF1565C0),
      ),
      _SummaryCard(
        label: 'Aktuální hodnota',
        value: _czk.format(stats.totalCurrentValue),
        subtitle: '–$deprPct% odepsáno',
        icon: Icons.trending_down_rounded,
        color: AppColors.primary,
      ),
      _SummaryCard(
        label: 'Roční pojistné',
        value: _czk.format(stats.totalInsuranceCost),
        icon: Icons.security_outlined,
        color: AppColors.warning,
      ),
      _SummaryCard(
        label: 'Náklady na údržbu',
        value: _czk.format(stats.totalMaintenanceCost),
        icon: Icons.build_outlined,
        color: AppColors.danger,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: cards.map((c) => _buildSummaryCardWidget(c, cardBg, borderColor)).toList(),
    );
  }

  Widget _buildSummaryCardWidget(
      _SummaryCard card, Color cardBg, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: card.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(card.icon, size: 16, color: card.color),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.label,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                card.value,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
              if (card.subtitle != null)
                Text(
                  card.subtitle!,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.subtitleGray),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Pie chart ────────────────────────────────────────────────────────────────

  Widget _buildPieChartSection(PortfolioStats stats, bool isDark) {
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.cardBorder;

    final categories = stats.valueByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sections = categories.asMap().entries.map((e) {
      final colorIdx = e.key % _kCategoryColors.length;
      return PieChartSectionData(
        value: e.value.value,
        color: _kCategoryColors[colorIdx],
        title: '',
        radius: 60,
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hodnota podle kategorie',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: categories.asMap().entries.map((e) {
                    final colorIdx = e.key % _kCategoryColors.length;
                    final totalCurrent = stats.totalCurrentValue;
                    final pct = totalCurrent > 0
                        ? (e.value.value / totalCurrent * 100).round()
                        : 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _kCategoryColors[colorIdx],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${e.value.key} ($pct%)',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bar chart ────────────────────────────────────────────────────────────────

  Widget _buildBarChartSection(PortfolioStats stats, bool isDark) {
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.cardBorder;

    // Build last 12 months
    final now = DateTime.now();
    final months = List.generate(12, (i) {
      final d = DateTime(now.year, now.month - 11 + i, 1);
      return '${d.year}-${d.month.toString().padLeft(2, '0')}';
    });

    final hasData =
        months.any((m) => (stats.maintenanceCostByMonth[m] ?? 0) > 0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Náklady na údržbu po měsících',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (!hasData)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Žádné záznamy o nákladech',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: months
                          .map((m) => stats.maintenanceCostByMonth[m] ?? 0)
                          .fold<double>(0, (a, b) => a > b ? a : b) *
                      1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= months.length) {
                            return const SizedBox.shrink();
                          }
                          final parts = months[idx].split('-');
                          final month = int.tryParse(parts[1]) ?? 1;
                          return Text(
                            _kMonthAbbr[month - 1],
                            style: const TextStyle(fontSize: 9),
                          );
                        },
                        reservedSize: 20,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: months.asMap().entries.map((e) {
                    final cost =
                        stats.maintenanceCostByMonth[e.value] ?? 0;
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: cost,
                          color: AppColors.primary,
                          width: 8,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Gear value list ──────────────────────────────────────────────────────────

  Widget _buildGearValueList(PortfolioStats stats, bool isDark) {
    if (stats.gearByValue.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Žádné vybavení s pořizovací cenou.\nPřidejte cenu v detailu vybavení.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              'Vybavení podle hodnoty',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          ...stats.gearByValue.asMap().entries.map((e) {
            final entry = e.value;
            final isLast = e.key == stats.gearByValue.length - 1;

            Color deprColor;
            if (entry.depreciationPercent < 20) {
              deprColor = AppColors.success;
            } else if (entry.depreciationPercent < 50) {
              deprColor = AppColors.warning;
            } else {
              deprColor = AppColors.danger;
            }

            return Column(
              children: [
                if (e.key > 0) const Divider(height: 1, indent: 16),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, 12, 16, isLast ? 16 : 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.gearName,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              entry.sport,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                _czk.format(entry.purchasePrice),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward,
                                size: 12,
                                color: AppColors.subtitleGray,
                              ),
                              Text(
                                _czk.format(entry.currentValue),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '–${entry.depreciationPercent.round()}% odepsáno',
                            style: TextStyle(
                              fontSize: 10,
                              color: deprColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Export button ────────────────────────────────────────────────────────────

  Widget _buildExportButton(bool isDark) {
    return FilledButton.icon(
      onPressed: () {
        if (_isPremium) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export PDF bude dostupný v příští verzi'),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => const PaywallScreen(
                contextMessage:
                    'Export portfolia pro pojišťovnu je prémiová funkce.',
              ),
            ),
          );
        }
      },
      style: FilledButton.styleFrom(
        backgroundColor:
            _isPremium ? AppColors.primary : AppColors.subtitleGray,
        minimumSize: const Size(double.infinity, 50),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(
        _isPremium ? Icons.picture_as_pdf_outlined : Icons.lock_outlined,
        size: 20,
      ),
      label: const Text(
        'Exportovat pro pojišťovnu',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SummaryCard {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });
}

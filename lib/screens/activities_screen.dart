import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/category.dart';
import '../models/gear_item.dart';
import '../models/maintenance_log.dart';
import '../models/usage_log.dart';
import '../theme/app_theme.dart';

// ─── Time filter ──────────────────────────────────────────────────────────────

enum _TimeFilter { m3, m6, y1, y2, all }

extension _TimeFilterX on _TimeFilter {
  String get label => switch (this) {
        _TimeFilter.m3  => '3M',
        _TimeFilter.m6  => '6M',
        _TimeFilter.y1  => '1R',
        _TimeFilter.y2  => '2R',
        _TimeFilter.all => 'Vše',
      };

  /// Returns the start of the filtered period, or null for "all time".
  DateTime? cutoff(DateTime now) => switch (this) {
        _TimeFilter.m3  => DateTime(now.year, now.month - 3,  now.day),
        _TimeFilter.m6  => DateTime(now.year, now.month - 6,  now.day),
        _TimeFilter.y1  => DateTime(now.year - 1, now.month,  now.day),
        _TimeFilter.y2  => DateTime(now.year - 2, now.month,  now.day),
        _TimeFilter.all => null,
      };

  /// 3M and 6M use per-week bars; longer periods use per-month bars.
  bool get useWeeks => this == _TimeFilter.m3 || this == _TimeFilter.m6;
}

// ─── Sport colour / icon / label ──────────────────────────────────────────────

Color _sportColor(String sport) => switch (sport) {
      'lezení'        => const Color(0xFFFF7043),
      'skialpinismus' => const Color(0xFF42A5F5),
      'cyklistika'    => const Color(0xFF26A69A),
      'paragliding'   => const Color(0xFFAB47BC),
      'obecné'        => const Color(0xFF9E9E9E),
      _               => const Color(0xFF78909C),
    };

IconData _sportIcon(String sport) => switch (sport) {
      'lezení'        => Icons.terrain,
      'skialpinismus' => Icons.downhill_skiing,
      'cyklistika'    => Icons.directions_bike_outlined,
      'paragliding'   => Icons.air,
      'obecné'        => Icons.backpack_outlined,
      _               => Icons.sports,
    };

String _sportLabel(String sport) => switch (sport) {
      'lezení'        => 'Lezení',
      'skialpinismus' => 'Skialpinismus',
      'cyklistika'    => 'Cyklistika',
      'paragliding'   => 'Paragliding',
      'obecné'        => 'Obecné',
      _               => sport,
    };

const _kSportOrder = [
  'lezení', 'skialpinismus', 'cyklistika', 'paragliding', 'obecné',
];

const _kMonthAbbr = [
  'led', 'úno', 'bře', 'dub', 'kvě', 'čvn',
  'čvc', 'srp', 'zář', 'říj', 'lis', 'pro',
];

// ─── Data containers ─────────────────────────────────────────────────────────

class _GearStat {
  final GearItem item;
  final String   sport;
  final double   totalHours;
  final double   totalKm;
  final int      count;
  const _GearStat({
    required this.item,
    required this.sport,
    required this.totalHours,
    required this.totalKm,
    required this.count,
  });
}

/// One time bucket (week or month) of usage data, broken down by sport.
class _ChartBar {
  final DateTime           start;        // first day of the bucket
  final String             label;        // x-axis label (empty = hide)
  final Map<String,double> hoursBySport;
  final Map<String,double> kmBySport;
  _ChartBar(this.start, this.label) : hoursBySport = {}, kmBySport = {};
  double get totalHours => hoursBySport.values.fold(0.0, (a, b) => a + b);
  double get totalKm    => kmBySport.values.fold(0.0, (a, b) => a + b);
}

class _ActivityEntry {
  final UsageLog  log;
  final GearItem? gear;
  final String    sport;
  const _ActivityEntry({
    required this.log,
    required this.gear,
    required this.sport,
  });
}

// ─── Main screen ─────────────────────────────────────────────────────────────

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final _db = DatabaseHelper.instance;
  bool _loading = true;

  // ── Raw data (loaded once from DB) ───────────────────────────────────────
  List<UsageLog>       _allLogs      = [];
  List<GearItem>       _allGear      = [];
  List<Category>       _allCats      = [];
  List<MaintenanceLog> _allMaintLogs = [];

  // ── Filter state ─────────────────────────────────────────────────────────
  _TimeFilter _filter = _TimeFilter.y1;   // default: last 12 months

  // ── Derived stats (rebuilt on filter change) ──────────────────────────────
  double _totalHours        = 0;
  double _totalKm           = 0;
  double _totalElevM        = 0;
  int    _activityCount     = 0;
  int    _gearCount         = 0;
  int    _maintenanceCount  = 0;

  List<_ChartBar>      _chartBars    = [];
  bool                 _useWeeks     = false;
  double               _barWidth     = 14;
  List<String>         _activeSports = [];
  List<_GearStat>      _gearStats    = [];
  List<_ActivityEntry> _entries      = [];

  // ── Helpers ───────────────────────────────────────────────────────────────

  static DateTime _weekStart(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - 1));

  // ── Load & compute ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final results = await Future.wait([
      _db.getUsageLogs(),
      _db.getGearItems(),
      _db.getCategories(),
      _db.getMaintenanceLogs(),
    ]);

    _allLogs      = results[0] as List<UsageLog>;
    _allGear      = results[1] as List<GearItem>;
    _allCats      = results[2] as List<Category>;
    _allMaintLogs = results[3] as List<MaintenanceLog>;

    _loading = false;
    _rebuildStats();  // calls setState
  }

  /// Recomputes all derived stats from raw data + current filter.
  /// Called on initial load and every time the filter changes.
  void _rebuildStats() {
    final now    = DateTime.now();
    final cutoff = _filter.cutoff(now);

    // Filter logs by date
    final logs = cutoff == null
        ? _allLogs
        : _allLogs.where((l) => !l.date.isBefore(cutoff)).toList();

    // Lookup maps
    final catMap  = {for (final c in _allCats) c.id!: c};
    final gearMap = {for (final g in _allGear) g.id!: g};

    String gearSport(int id) {
      final g = gearMap[id];
      if (g == null) return 'obecné';
      return catMap[g.categoryId]?.sport ?? 'obecné';
    }

    // ── Summary ────────────────────────────────────────────────────────────
    final totalMin  = logs.fold<int>(0,    (s, l) => s + (l.durationMinutes ?? 0));
    final totalKm   = logs.fold<double>(0, (s, l) => s + (l.distanceKm      ?? 0.0));
    final totalElev = logs.fold<double>(0, (s, l) => s + (l.elevationGainM  ?? 0.0));

    // Gear count = distinct gear items used in period
    final activeGearIds = logs.map((l) => l.gearItemId).toSet();

    // Maintenance count = logs in period (by performedDate)
    final maintCount = cutoff == null
        ? _allMaintLogs.length
        : _allMaintLogs
            .where((m) => !m.performedDate.isBefore(cutoff))
            .length;

    // ── Activity entries ───────────────────────────────────────────────────
    final entries = logs
        .map((l) => _ActivityEntry(
              log:   l,
              gear:  gearMap[l.gearItemId],
              sport: gearSport(l.gearItemId),
            ))
        .toList()
      ..sort((a, b) => b.log.date.compareTo(a.log.date));

    // ── Per-gear stats ─────────────────────────────────────────────────────
    final gearMins  = <int, int>{};
    final gearKmMap = <int, double>{};
    final gearCnt   = <int, int>{};
    for (final l in logs) {
      final id = l.gearItemId;
      gearMins[id]  = (gearMins[id]  ?? 0) + (l.durationMinutes ?? 0);
      gearKmMap[id] = (gearKmMap[id] ?? 0) + (l.distanceKm ?? 0.0);
      gearCnt[id]   = (gearCnt[id]   ?? 0) + 1;
    }
    final gearStats = _allGear
        .where((g) => (gearCnt[g.id] ?? 0) > 0)
        .map((g) => _GearStat(
              item:       g,
              sport:      gearSport(g.id!),
              totalHours: (gearMins[g.id] ?? 0) / 60.0,
              totalKm:    gearKmMap[g.id]  ?? 0.0,
              count:      gearCnt[g.id]    ?? 0,
            ))
        .toList()
      ..sort((a, b) => b.totalHours.compareTo(a.totalHours));

    // ── Chart bars ─────────────────────────────────────────────────────────
    final List<_ChartBar> chartBars;
    if (_filter.useWeeks) {
      chartBars = _buildWeeklyBars(logs, gearSport, cutoff!);
    } else {
      chartBars = _buildMonthlyBars(logs, gearSport);
    }
    final barWidth = _computeBarWidth(chartBars.length);

    // ── Active sports (ordered) ────────────────────────────────────────────
    final sportsSet = {for (final l in logs) gearSport(l.gearItemId)};
    final orderedSports = [
      ..._kSportOrder.where(sportsSet.contains),
      ...sportsSet.where((s) => !_kSportOrder.contains(s)),
    ];

    setState(() {
      _totalHours       = totalMin / 60.0;
      _totalKm          = totalKm;
      _totalElevM       = totalElev;
      _activityCount    = logs.length;
      _gearCount        = activeGearIds.length;
      _maintenanceCount = maintCount;
      _chartBars        = chartBars;
      _useWeeks         = _filter.useWeeks;
      _barWidth         = barWidth;
      _activeSports     = orderedSports;
      _gearStats        = gearStats;
      _entries          = entries;
    });
  }

  // ── Chart bar builders ────────────────────────────────────────────────────

  /// Weekly bars from [cutoff] to today.
  List<_ChartBar> _buildWeeklyBars(
    List<UsageLog> logs,
    String Function(int) gearSport,
    DateTime cutoff,
  ) {
    final now       = DateTime.now();
    var   week      = _weekStart(cutoff);
    final thisWeek  = _weekStart(now);

    final bars       = <_ChartBar>[];
    String? lastAbbr;

    while (!week.isAfter(thisWeek)) {
      final abbr  = _kMonthAbbr[(week.month - 1) % 12];
      // Show month abbreviation only on the first week of each new month
      final label = abbr != lastAbbr ? abbr : '';
      if (abbr != lastAbbr) lastAbbr = abbr;
      bars.add(_ChartBar(week, label));
      week = week.add(const Duration(days: 7));
    }

    for (final l in logs) {
      final ws  = _weekStart(l.date);
      final idx = bars.indexWhere((b) => b.start == ws);
      if (idx < 0) continue;
      final sp = gearSport(l.gearItemId);
      bars[idx].hoursBySport[sp] =
          (bars[idx].hoursBySport[sp] ?? 0) + (l.durationMinutes ?? 0) / 60.0;
      bars[idx].kmBySport[sp] =
          (bars[idx].kmBySport[sp] ?? 0) + (l.distanceKm ?? 0.0);
    }
    return bars;
  }

  /// Monthly bars for the selected period.
  List<_ChartBar> _buildMonthlyBars(
    List<UsageLog> logs,
    String Function(int) gearSport,
  ) {
    final now          = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    // Determine start month
    final DateTime startMonth;
    switch (_filter) {
      case _TimeFilter.y1:
        startMonth = DateTime(now.year, now.month - 11);
      case _TimeFilter.y2:
        startMonth = DateTime(now.year, now.month - 23);
      case _TimeFilter.all:
        if (_allLogs.isEmpty) {
          startMonth = DateTime(now.year, now.month - 11);
        } else {
          final earliest = _allLogs.fold<DateTime>(
            _allLogs.first.date,
            (m, l) => l.date.isBefore(m) ? l.date : m,
          );
          startMonth = DateTime(earliest.year, earliest.month);
        }
      default:
        startMonth = DateTime(now.year, now.month - 11);
    }

    final bars = <_ChartBar>[];
    var m = startMonth;
    while (!m.isAfter(currentMonth)) {
      bars.add(_ChartBar(m, _kMonthAbbr[(m.month - 1) % 12]));
      m = DateTime(m.year, m.month + 1);
    }

    for (final l in logs) {
      final ms  = DateTime(l.date.year, l.date.month);
      final idx = bars.indexWhere((b) => b.start == ms);
      if (idx < 0) continue;
      final sp = gearSport(l.gearItemId);
      bars[idx].hoursBySport[sp] =
          (bars[idx].hoursBySport[sp] ?? 0) + (l.durationMinutes ?? 0) / 60.0;
      bars[idx].kmBySport[sp] =
          (bars[idx].kmBySport[sp] ?? 0) + (l.distanceKm ?? 0.0);
    }
    return bars;
  }

  static double _computeBarWidth(int count) {
    if (count <= 13) return 13.0;
    if (count <= 24) return 9.0;
    if (count <= 36) return 7.0;
    if (count <= 52) return 5.0;
    return 4.0;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiky')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // ── 6 summary cards ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _SummaryGrid(
                        totalHours:       _totalHours,
                        totalKm:          _totalKm,
                        totalElevM:       _totalElevM,
                        activityCount:    _activityCount,
                        gearCount:        _gearCount,
                        maintenanceCount: _maintenanceCount,
                      ),
                    ),
                  ),

                  // ── Time filter bar ────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: _TimeFilterBar(
                        selected:  _filter,
                        onChanged: (f) {
                          _filter = f;
                          _rebuildStats();
                        },
                      ),
                    ),
                  ),

                  // ── Bar chart ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _ChartSection(
                      chartBars:    _chartBars,
                      activeSports: _activeSports,
                      useWeeks:     _useWeeks,
                      barWidth:     _barWidth,
                    ),
                  ),

                  // ── Gear ranking ───────────────────────────────────────
                  if (_gearStats.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _GearRankingSection(gearStats: _gearStats),
                    ),

                  // ── Records ────────────────────────────────────────────
                  if (_entries.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _RecordsSection(
                        entries:   _entries,
                        gearStats: _gearStats,
                      ),
                    ),

                  // ── Recent activities ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: _RecentSection(
                      entries:      _entries,
                      activeSports: _activeSports,
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 88)),
                ],
              ),
            ),
    );
  }
}

// ─── Time filter bar ──────────────────────────────────────────────────────────

class _TimeFilterBar extends StatelessWidget {
  final _TimeFilter             selected;
  final ValueChanged<_TimeFilter> onChanged;
  const _TimeFilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_TimeFilter>(
      style: SegmentedButton.styleFrom(
        backgroundColor:         context.isDark
            ? AppColors.darkCard
            : Colors.white,
        selectedBackgroundColor: AppColors.primary,
        selectedForegroundColor: Colors.white,
        foregroundColor:         context.subtitleColor,
        side: BorderSide(color: context.cardBorderColor, width: 0.5),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      segments: _TimeFilter.values
          .map((f) => ButtonSegment<_TimeFilter>(
                value: f,
                label: Text(f.label),
              ))
          .toList(),
      selected:          {selected},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon:   false,
    );
  }
}

// ─── Summary 2×3 grid ─────────────────────────────────────────────────────────

class _SummaryGrid extends StatelessWidget {
  final double totalHours;
  final double totalKm;
  final double totalElevM;
  final int    activityCount;
  final int    gearCount;
  final int    maintenanceCount;

  const _SummaryGrid({
    required this.totalHours,
    required this.totalKm,
    required this.totalElevM,
    required this.activityCount,
    required this.gearCount,
    required this.maintenanceCount,
  });

  static String _fmtH(double h) =>
      h < 100 ? '${h.toStringAsFixed(1)} h' : '${h.round()} h';

  static String _fmtKm(double km) => km < 10000
      ? '${km.toStringAsFixed(0)} km'
      : '${(km / 1000).toStringAsFixed(1)} tis. km';

  static String _fmtElev(double m) => m < 1000
      ? '${m.round()} m'
      : '${(m / 1000).toStringAsFixed(1)} tis. m';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Row3(cards: [
          _StatCard(
            icon:      Icons.schedule_rounded,
            iconColor: AppColors.primary,
            value:     _fmtH(totalHours),
            label:     'Celkem hodin',
          ),
          _StatCard(
            icon:      Icons.route_rounded,
            iconColor: const Color(0xFF42A5F5),
            value:     _fmtKm(totalKm),
            label:     'Celkem km',
          ),
          _StatCard(
            icon:      Icons.trending_up_rounded,
            iconColor: const Color(0xFFFF7043),
            value:     _fmtElev(totalElevM),
            label:     'Nastoupáno',
          ),
        ]),
        const SizedBox(height: 10),
        _Row3(cards: [
          _StatCard(
            icon:      Icons.directions_run_rounded,
            iconColor: const Color(0xFF26A69A),
            value:     '$activityCount',
            label:     'Aktivit',
          ),
          _StatCard(
            icon:      Icons.inventory_2_outlined,
            iconColor: const Color(0xFFAB47BC),
            value:     '$gearCount',
            label:     'Vybavení',
          ),
          _StatCard(
            icon:      Icons.build_outlined,
            iconColor: AppColors.warning,
            value:     '$maintenanceCount',
            label:     'Servisy',
          ),
        ]),
      ],
    );
  }
}

class _Row3 extends StatelessWidget {
  final List<_StatCard> cards;
  const _Row3({required this.cards});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: cards[i]),
          ],
        ],
      );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   value;
  final String   label;
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color:        context.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: context.cardBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color:        iconColor.withAlpha(26),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, height: 1.1),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: context.subtitleColor),
          ),
        ],
      ),
    );
  }
}

// ─── Monthly / weekly bar chart ───────────────────────────────────────────────

class _ChartSection extends StatefulWidget {
  final List<_ChartBar> chartBars;
  final List<String>    activeSports;
  final bool            useWeeks;
  final double          barWidth;
  const _ChartSection({
    required this.chartBars,
    required this.activeSports,
    required this.useWeeks,
    required this.barWidth,
  });

  @override
  State<_ChartSection> createState() => _ChartSectionState();
}

class _ChartSectionState extends State<_ChartSection> {
  bool _showHours = true;

  double _niceMax(double value) {
    if (value <= 0) return 10;
    final target = value * 1.25;
    for (final nice in [2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000]) {
      if (target <= nice) return nice.toDouble();
    }
    return (target / 1000).ceil() * 1000.0;
  }

  List<BarChartGroupData> _buildGroups(bool showHours) {
    final bars   = widget.chartBars;
    final sports = widget.activeSports.isEmpty ? _kSportOrder : widget.activeSports;
    final emptyColor = context.isDark ? AppColors.darkBorder : const Color(0xFFEEEEEE);

    return List.generate(bars.length, (i) {
      final bar    = bars[i];
      final values = showHours ? bar.hoursBySport : bar.kmBySport;

      final rodStackItems = <BarChartRodStackItem>[];
      double bottom = 0;
      for (final sport in sports) {
        final v = values[sport] ?? 0;
        if (v > 0.001) {
          rodStackItems.add(
              BarChartRodStackItem(bottom, bottom + v, _sportColor(sport)));
          bottom += v;
        }
      }

      if (rodStackItems.isEmpty) {
        return BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY:          0.15,
            width:        widget.barWidth,
            color:        emptyColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ]);
      }

      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY:           bottom,
          width:         widget.barWidth,
          color:         Colors.transparent,
          borderRadius:  const BorderRadius.vertical(top: Radius.circular(2)),
          rodStackItems: rodStackItems,
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = context.isDark;
    final showHours   = _showHours;
    final bars        = widget.chartBars;
    final sports      = widget.activeSports;

    final maxVal = bars.fold(
        0.0, (m, b) => max(m, showHours ? b.totalHours : b.totalKm));
    final maxY      = _niceMax(maxVal);
    final interval  = maxY / 4;
    final gridColor = isDark ? AppColors.darkBorder : const Color(0xFFF0F0F0);
    final lblStyle  = TextStyle(fontSize: 9, color: context.subtitleColor);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 16, 8, 16),
        decoration: BoxDecoration(
          color:        isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: context.cardBorderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header + toggle ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Aktivita v čase',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _TogglePill(
                    options:  const ['Hodiny', 'Km'],
                    selected: showHours ? 0 : 1,
                    onChanged: (i) =>
                        setState(() => _showHours = i == 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Chart ───────────────────────────────────────────────────
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  maxY:      maxY,
                  minY:      0,
                  barGroups: _buildGroups(showHours),
                  gridData: FlGridData(
                    show:               true,
                    drawVerticalLine:   false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color:       gridColor,
                      strokeWidth: 0.5,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.black87,
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      getTooltipItem: (group, _, rod, __) {
                        if (group.x >= bars.length) return null;
                        final bar = bars[group.x];
                        final val = showHours ? bar.totalHours : bar.totalKm;
                        if (val <= 0) return null;
                        final unit   = showHours ? 'h' : 'km';
                        final valStr = showHours
                            ? val.toStringAsFixed(1)
                            : val.toStringAsFixed(0);
                        // Date label: week range or month
                        final dateLbl = widget.useWeeks
                            ? '${DateFormat('d. M.').format(bar.start)} – '
                              '${DateFormat('d. M.').format(bar.start.add(const Duration(days: 6)))}'
                            : DateFormat('MMM yyyy').format(bar.start);
                        return BarTooltipItem(
                          '$valStr $unit\n$dateLbl',
                          const TextStyle(
                              fontSize:   12,
                              color:      Colors.white,
                              fontWeight: FontWeight.w600,
                              height:     1.4),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles:   true,
                        reservedSize: 34,
                        interval:     interval,
                        getTitlesWidget: (v, _) {
                          if (v <= 0) return const SizedBox.shrink();
                          final s = (v == v.roundToDouble())
                              ? v.round().toString()
                              : v.toStringAsFixed(1);
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(s,
                                style:     lblStyle,
                                textAlign: TextAlign.right),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles:   true,
                        reservedSize: 18,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i < 0 || i >= bars.length) {
                            return const SizedBox.shrink();
                          }
                          final lbl = bars[i].label;
                          if (lbl.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(lbl, style: lblStyle),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Legend ──────────────────────────────────────────────────
            if (sports.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing:    16,
                runSpacing: 6,
                children: sports
                    .map((s) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(
                                color:        _sportColor(s),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(_sportLabel(s),
                                style: TextStyle(
                                    fontSize: 11,
                                    color:    context.subtitleColor)),
                          ],
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  final List<String>      options;
  final int               selected;
  final ValueChanged<int> onChanged;
  const _TogglePill({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color:        isDark ? AppColors.darkSurface : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final active = selected == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color:        active ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                options[i],
                style: TextStyle(
                  fontSize:   12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color:      active ? Colors.white : context.subtitleColor,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Gear ranking ─────────────────────────────────────────────────────────────

class _GearRankingSection extends StatelessWidget {
  final List<_GearStat> gearStats;
  const _GearRankingSection({required this.gearStats});

  @override
  Widget build(BuildContext context) {
    final maxHours =
        gearStats.first.totalHours.clamp(0.001, double.infinity);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Podle vybavení'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color:        context.isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(
                  color: context.cardBorderColor, width: 0.5),
            ),
            child: Column(
              children: [
                for (int i = 0; i < gearStats.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, color: context.cardBorderColor),
                  _GearStatRow(
                    stat:     gearStats[i],
                    maxHours: maxHours,
                    rank:     i + 1,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GearStatRow extends StatelessWidget {
  final _GearStat stat;
  final double    maxHours;
  final int       rank;
  const _GearStatRow({
    required this.stat,
    required this.maxHours,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (stat.totalHours / maxHours).clamp(0.0, 1.0);
    final color = _sportColor(stat.sport);
    final hStr  = stat.totalHours < 10
        ? '${stat.totalHours.toStringAsFixed(1)} h'
        : '${stat.totalHours.round()} h';
    final kmStr = stat.totalKm > 0
        ? ' · ${stat.totalKm.toStringAsFixed(0)} km'
        : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  '$rank',
                  style: TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.w700,
                      color:      context.subtitleColor),
                ),
              ),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color:        color.withAlpha(26),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(_sportIcon(stat.sport), color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.item.name,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${stat.count} aktivit',
                      style: TextStyle(
                          fontSize: 11, color: context.subtitleColor),
                    ),
                  ],
                ),
              ),
              Text(
                '$hStr$kmStr',
                style: TextStyle(
                    fontSize: 12, color: context.subtitleColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value:          ratio,
              minHeight:      4,
              backgroundColor: context.isDark
                  ? AppColors.darkSurface
                  : const Color(0xFFF0F0F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Records ─────────────────────────────────────────────────────────────────

class _RecordsSection extends StatelessWidget {
  final List<_ActivityEntry> entries;
  final List<_GearStat>      gearStats;
  const _RecordsSection({required this.entries, required this.gearStats});

  static const _czMonths = [
    'leden', 'únor', 'březen', 'duben', 'květen', 'červen',
    'červenec', 'srpen', 'září', 'říjen', 'listopad', 'prosinec',
  ];

  String _fmtDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m min';
    return m > 0 ? '$h h $m min' : '$h h';
  }

  @override
  Widget build(BuildContext context) {
    final byDur = entries
        .where((e) => e.log.durationMinutes != null)
        .toList()
      ..sort((a, b) =>
          (b.log.durationMinutes ?? 0).compareTo(a.log.durationMinutes ?? 0));

    final byKm = entries
        .where((e) => e.log.distanceKm != null)
        .toList()
      ..sort((a, b) =>
          (b.log.distanceKm ?? 0).compareTo(a.log.distanceKm ?? 0));

    final monthCount = <String, int>{};
    for (final e in entries) {
      final key = DateFormat('yyyy-MM').format(e.log.date);
      monthCount[key] = (monthCount[key] ?? 0) + 1;
    }
    String? bestMonthKey;
    int bestMonthCount = 0;
    monthCount.forEach((k, v) {
      if (v > bestMonthCount) {
        bestMonthCount = v;
        bestMonthKey   = k;
      }
    });

    final topGear = gearStats.isNotEmpty ? gearStats.first : null;

    String fmtMonth(String key) {
      final dt = DateTime.parse('$key-01');
      return '${_czMonths[dt.month - 1]} ${dt.year}';
    }

    Widget card(IconData icon, Color color, String label, String value,
            String? subtitle) =>
        _RecordCard(
          icon:      icon,
          iconColor: color,
          label:     label,
          value:     value,
          subtitle:  subtitle,
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Rekordy'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: card(
                Icons.timer_outlined, AppColors.primary,
                'Nejdelší aktivita',
                byDur.isNotEmpty
                    ? _fmtDuration(byDur.first.log.durationMinutes!)
                    : '–',
                byDur.isNotEmpty ? byDur.first.gear?.name : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: card(
                Icons.route_rounded, const Color(0xFF42A5F5),
                'Nejdelší vzdálenost',
                byKm.isNotEmpty
                    ? '${byKm.first.log.distanceKm!.toStringAsFixed(1)} km'
                    : '–',
                byKm.isNotEmpty ? byKm.first.gear?.name : null,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: card(
                Icons.calendar_month_outlined, const Color(0xFF26A69A),
                'Nejaktivnější měsíc',
                bestMonthKey != null ? '$bestMonthCount aktivit' : '–',
                bestMonthKey != null ? fmtMonth(bestMonthKey!) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: card(
                Icons.star_outline_rounded, AppColors.warning,
                'Nejpoužívanější',
                topGear != null
                    ? '${topGear.totalHours.toStringAsFixed(0)} h'
                    : '–',
                topGear?.item.name,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   label;
  final String   value;
  final String?  subtitle;
  const _RecordCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        context.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: context.cardBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
                fontSize: 11, color: context.subtitleColor, height: 1.2),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, height: 1),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 11, color: context.subtitleColor),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Recent activities ────────────────────────────────────────────────────────

class _RecentSection extends StatefulWidget {
  final List<_ActivityEntry> entries;
  final List<String>         activeSports;
  const _RecentSection({required this.entries, required this.activeSports});

  @override
  State<_RecentSection> createState() => _RecentSectionState();
}

class _RecentSectionState extends State<_RecentSection> {
  String? _filterSport;
  int     _visibleCount = 20;

  @override
  void didUpdateWidget(_RecentSection old) {
    super.didUpdateWidget(old);
    // Reset pagination/filter when parent data changes (time filter changed)
    if (old.entries != widget.entries) {
      _filterSport  = null;
      _visibleCount = 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterSport == null
        ? widget.entries
        : widget.entries.where((e) => e.sport == _filterSport).toList();
    final visible = filtered.take(_visibleCount).toList();
    final isDark  = context.isDark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Nedávné aktivity'),
          const SizedBox(height: 10),

          // ── Sport filter chips ──────────────────────────────────────
          if (widget.activeSports.length > 1) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SportFilterChip(
                    label:    'Vše',
                    selected: _filterSport == null,
                    onTap:    () => setState(() {
                      _filterSport  = null;
                      _visibleCount = 20;
                    }),
                  ),
                  ...widget.activeSports.map((s) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _SportFilterChip(
                          label:    _sportLabel(s),
                          color:    _sportColor(s),
                          selected: _filterSport == s,
                          onTap:    () => setState(() {
                            _filterSport  = s;
                            _visibleCount = 20;
                          }),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── List ────────────────────────────────────────────────────
          if (filtered.isEmpty)
            Container(
              padding:   const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:        isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(
                    color: context.cardBorderColor, width: 0.5),
              ),
              child: Text('Žádné aktivity.',
                  style: TextStyle(color: context.subtitleColor)),
            )
          else
            Container(
              decoration: BoxDecoration(
                color:        isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(
                    color: context.cardBorderColor, width: 0.5),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < visible.length; i++) ...[
                    if (i > 0)
                      Divider(height: 1, color: context.cardBorderColor),
                    _RecentRow(entry: visible[i]),
                  ],
                  if (filtered.length > _visibleCount) ...[
                    Divider(height: 1, color: context.cardBorderColor),
                    TextButton(
                      onPressed: () =>
                          setState(() => _visibleCount += 20),
                      style: TextButton.styleFrom(
                        minimumSize:     const Size(double.infinity, 48),
                        foregroundColor: AppColors.primary,
                      ),
                      child: Text(
                        'Načíst více '
                        '(${filtered.length - _visibleCount} zbývá)',
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  final _ActivityEntry entry;
  static final _dateFmt = DateFormat('d. M.');
  const _RecentRow({required this.entry});

  static (String, Color) _sourceBadge(UsageSource source) =>
      switch (source) {
        UsageSource.strava => ('Strava', const Color(0xFFFC4C02)),
        UsageSource.igc    => ('IGC',    const Color(0xFF1976D2)),
        UsageSource.garmin => ('Garmin', AppColors.primary),
        UsageSource.gpx    => ('GPX',    AppColors.primary),
        _                  => ('Ručně',  AppColors.subtitleGray),
      };

  @override
  Widget build(BuildContext context) {
    final l     = entry.log;
    final color = _sportColor(entry.sport);

    String? durLabel;
    if (l.durationMinutes != null) {
      final h = l.durationMinutes! ~/ 60;
      final m = l.durationMinutes! % 60;
      durLabel = h > 0 ? (m > 0 ? '$h h $m min' : '$h h') : '$m min';
    }

    final parts = <String>[
      if (durLabel != null) durLabel,
      if (l.distanceKm != null) '${l.distanceKm!.toStringAsFixed(1)} km',
      if (l.elevationGainM != null && l.elevationGainM! > 0)
        '↑ ${l.elevationGainM!.round()} m',
      if (l.location != null && l.location!.isNotEmpty) l.location!,
    ];

    final badge = _sourceBadge(l.source);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color:        color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_sportIcon(entry.sport), color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.gear?.name ?? 'Neznámé vybavení',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:        badge.$2.withAlpha(26),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge.$1,
                        style: TextStyle(
                            fontSize:   10,
                            color:      badge.$2,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                if (parts.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    parts.join(' · '),
                    style: TextStyle(
                        fontSize: 12, color: context.subtitleColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _dateFmt.format(l.date),
            style: TextStyle(fontSize: 11, color: context.subtitleColor),
          ),
        ],
      ),
    );
  }
}

class _SportFilterChip extends StatelessWidget {
  final String       label;
  final Color?       color;
  final bool         selected;
  final VoidCallback onTap;
  const _SportFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c    = color ?? AppColors.primary;
    final dark = context.isDark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? c : (dark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(
            color: selected ? c : context.cardBorderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize:   13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? Colors.white
                : (dark ? Colors.white : const Color(0xFF1A1A1A)),
          ),
        ),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      );
}

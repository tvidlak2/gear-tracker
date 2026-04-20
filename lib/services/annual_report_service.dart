import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/gear_item.dart';
import '../models/insurance.dart';
import '../models/maintenance_log.dart';
import 'insurance_service.dart';
import 'portfolio_service.dart';

// ─── Data models ───────────────────────────────────────────────────────────────

class MonthlyStats {
  final int month; // 1–12
  final double totalHours;
  final double totalKm;
  final double totalElevation;
  final int activityCount;

  const MonthlyStats({
    required this.month,
    required this.totalHours,
    required this.totalKm,
    required this.totalElevation,
    required this.activityCount,
  });
}

class GearYearStats {
  final GearItem gear;
  final String categoryName;
  final double hoursInYear;
  final double kmInYear;
  final double elevationInYear;
  final int serviceCount;
  final double maintenanceCost;
  final bool hasInsurance;
  final bool warrantyValid;

  const GearYearStats({
    required this.gear,
    required this.categoryName,
    required this.hoursInYear,
    required this.kmInYear,
    required this.elevationInYear,
    required this.serviceCount,
    required this.maintenanceCost,
    required this.hasInsurance,
    required this.warrantyValid,
  });
}

class AnnualReportData {
  final int year;
  final String userName;
  final DateTime generatedAt;

  // Section 1 — Year overview
  final double totalHours;
  final double totalKm;
  final double totalElevation;
  final int totalActivities;
  final int totalServices;
  final double totalMaintenanceCost;

  // Section 2 — Gear
  final List<GearYearStats> gearStats;

  // Section 3 — Monthly breakdown
  final List<MonthlyStats> monthlyStats;

  // Section 4 — Service history
  final List<MaintenanceLog> serviceHistory;
  final Map<int, String> gearNameById; // gearId -> name

  // Section 5 — Insurance & portfolio
  final List<Insurance> insurances;
  final double totalPortfolioCurrentValue;
  final double totalPortfolioPurchaseValue;
  final double totalInsuranceCost;

  // Section 6 — Next year plan
  final List<Map<String, dynamic>> upcomingServices;
  final List<GearItem> agingGear;

  const AnnualReportData({
    required this.year,
    required this.userName,
    required this.generatedAt,
    required this.totalHours,
    required this.totalKm,
    required this.totalElevation,
    required this.totalActivities,
    required this.totalServices,
    required this.totalMaintenanceCost,
    required this.gearStats,
    required this.monthlyStats,
    required this.serviceHistory,
    required this.gearNameById,
    required this.insurances,
    required this.totalPortfolioCurrentValue,
    required this.totalPortfolioPurchaseValue,
    required this.totalInsuranceCost,
    required this.upcomingServices,
    required this.agingGear,
  });
}

// ─── Service ───────────────────────────────────────────────────────────────────

class AnnualReportService {
  AnnualReportService._();
  static final AnnualReportService instance = AnnualReportService._();

  // ── Data collection ──────────────────────────────────────────────────────────

  Future<AnnualReportData> collectData(int year) async {
    final db = await DatabaseHelper.instance.database;
    final yearStr = year.toString();

    // User name
    String userName = 'OutdoorGearTracker uživatel';
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('user_name');
      if (stored != null && stored.isNotEmpty) userName = stored;
    } catch (_) {}

    // All gear items with category sport
    final gearRows = await db.rawQuery('''
      SELECT gi.*, c.sport AS category_sport, c.name AS category_name
      FROM gear_items gi
      LEFT JOIN categories c ON c.id = gi.category_id
    ''');

    final allGear = <GearItem>[];
    final gearCategoryName = <int, String>{};
    final gearCategorySport = <int, String>{};

    for (final row in gearRows) {
      final g = GearItem.fromMap(row);
      if (g.id != null) {
        allGear.add(g);
        gearCategoryName[g.id!] = (row['category_name'] as String?) ?? '';
        gearCategorySport[g.id!] = (row['category_sport'] as String?) ?? '';
      }
    }

    // Map gearId -> name for history section
    final gearNameById = <int, String>{
      for (final g in allGear) if (g.id != null) g.id!: g.name,
    };

    // Usage logs for the year
    final usageRows = await db.rawQuery(
      "SELECT * FROM usage_logs WHERE strftime('%Y', date) = ?",
      [yearStr],
    );

    // Aggregate usage by gear and by month
    final gearUsageHours = <int, double>{};
    final gearUsageKm    = <int, double>{};
    final gearUsageElev  = <int, double>{};
    final monthlyMap     = <int, _MonthAgg>{};

    for (var m = 1; m <= 12; m++) {
      monthlyMap[m] = _MonthAgg();
    }

    for (final row in usageRows) {
      final gid = row['gear_item_id'] as int?;
      final dateStr = row['date'] as String?;
      final mins    = (row['duration_minutes'] as num?)?.toDouble() ?? 0.0;
      final km      = (row['distance_km'] as num?)?.toDouble() ?? 0.0;
      final elev    = (row['elevation_gain'] as num?)?.toDouble() ?? 0.0;

      if (gid != null) {
        gearUsageHours[gid] = (gearUsageHours[gid] ?? 0) + mins / 60.0;
        gearUsageKm[gid]    = (gearUsageKm[gid] ?? 0) + km;
        gearUsageElev[gid]  = (gearUsageElev[gid] ?? 0) + elev;
      }

      if (dateStr != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          final agg = monthlyMap[date.month]!;
          agg.hours     += mins / 60.0;
          agg.km        += km;
          agg.elevation += elev;
          agg.count     += 1;
        }
      }
    }

    // Maintenance logs for the year
    final maintRows = await db.rawQuery(
      "SELECT * FROM maintenance_logs WHERE strftime('%Y', performed_date) = ? ORDER BY performed_date DESC",
      [yearStr],
    );

    final serviceHistory = maintRows.map(MaintenanceLog.fromMap).toList();
    final gearServiceCount = <int, int>{};
    final gearServiceCost  = <int, double>{};

    for (final log in serviceHistory) {
      gearServiceCount[log.gearItemId] =
          (gearServiceCount[log.gearItemId] ?? 0) + 1;
      gearServiceCost[log.gearItemId] =
          (gearServiceCost[log.gearItemId] ?? 0) + (log.cost ?? 0.0);
    }

    // Insurance data
    final insurances = await InsuranceService.instance.getAllInsurances();
    final gearInsuranceIds = <int, bool>{};
    for (final ins in insurances) {
      for (final gidStr in ins.gearItemIds) {
        final gid = int.tryParse(gidStr);
        if (gid != null) gearInsuranceIds[gid] = true;
      }
    }

    // Portfolio stats
    double totalPurchaseValue = 0;
    double totalCurrentValue  = 0;
    try {
      final ps = await PortfolioService.instance.getStats();
      totalPurchaseValue = ps.totalPurchaseValue;
      totalCurrentValue  = ps.totalCurrentValue;
    } catch (_) {}

    double totalInsuranceCost = 0;
    for (final ins in insurances) {
      totalInsuranceCost += ins.annualPremium ?? 0.0;
    }

    // Build gear stats
    final now = DateTime.now();
    final gearStats = <GearYearStats>[];
    for (final g in allGear) {
      if (g.id == null) continue;
      final warrantyValid = g.warrantyExpiryDate != null &&
          g.warrantyExpiryDate!.isAfter(now);
      gearStats.add(GearYearStats(
        gear:            g,
        categoryName:    gearCategoryName[g.id] ?? '',
        hoursInYear:     gearUsageHours[g.id] ?? 0.0,
        kmInYear:        gearUsageKm[g.id] ?? 0.0,
        elevationInYear: gearUsageElev[g.id] ?? 0.0,
        serviceCount:    gearServiceCount[g.id] ?? 0,
        maintenanceCost: gearServiceCost[g.id] ?? 0.0,
        hasInsurance:    gearInsuranceIds[g.id] == true,
        warrantyValid:   warrantyValid,
      ));
    }

    // Monthly stats list
    final monthlyStats = List.generate(12, (i) {
      final m   = i + 1;
      final agg = monthlyMap[m]!;
      return MonthlyStats(
        month:          m,
        totalHours:     agg.hours,
        totalKm:        agg.km,
        totalElevation: agg.elevation,
        activityCount:  agg.count,
      );
    });

    // Totals
    final totalHours      = gearUsageHours.values.fold(0.0, (a, b) => a + b);
    final totalKm         = gearUsageKm.values.fold(0.0, (a, b) => a + b);
    final totalElev       = gearUsageElev.values.fold(0.0, (a, b) => a + b);
    final totalActivities = usageRows.length;
    final totalServices   = serviceHistory.length;
    final totalMaintCost  = gearServiceCost.values.fold(0.0, (a, b) => a + b);

    // Upcoming services (next_due_date in next 12 months, ordered)
    final nextYear = DateTime(now.year + 1, now.month, now.day);
    final allFutureLogs = await db.rawQuery(
      "SELECT * FROM maintenance_logs WHERE next_due_date IS NOT NULL AND next_due_date > ? ORDER BY next_due_date ASC",
      [now.toIso8601String()],
    );

    final upcomingServices = <Map<String, dynamic>>[];
    final seenGearRule = <String>{};
    for (final row in allFutureLogs) {
      final dueDateStr = row['next_due_date'] as String?;
      if (dueDateStr == null) continue;
      final dueDate = DateTime.tryParse(dueDateStr);
      if (dueDate == null || dueDate.isAfter(nextYear)) continue;

      final gid  = row['gear_item_id'] as int?;
      final rid  = row['rule_id'] as int?;
      final key  = '$gid-$rid';
      if (seenGearRule.contains(key)) continue;
      seenGearRule.add(key);

      // Get rule name
      String task = (row['notes'] as String?) ?? 'Servis';
      if (rid != null) {
        try {
          final ruleRows = await db.query(
            'maintenance_rules',
            where: 'id = ?',
            whereArgs: [rid],
          );
          if (ruleRows.isNotEmpty) {
            task = ruleRows.first['name'] as String? ?? task;
          }
        } catch (_) {}
      }

      final gearName = gid != null ? (gearNameById[gid] ?? 'Vybavení') : 'Vybavení';
      upcomingServices.add({
        'gearName': gearName,
        'task':     task,
        'dueDate':  dueDate,
      });
    }

    // Aging gear (5+ years since purchase, or depreciation > 60%)
    final agingGear = <GearItem>[];
    for (final g in allGear) {
      if (g.status == GearStatus.retired) continue;
      bool isAging = false;
      if (g.purchaseDate != null) {
        final ageYears = now.difference(g.purchaseDate!).inDays / 365.0;
        if (ageYears >= 5) isAging = true;
      }
      if (!isAging && g.purchasePrice != null && g.purchasePrice! > 0 && g.purchaseDate != null) {
        final sport = gearCategorySport[g.id] ?? '';
        final depreciationRate = _depreciationRate(sport);
        final years = now.difference(g.purchaseDate!).inDays / 365.0;
        final deprecPct = (depreciationRate * years * 100).clamp(0.0, 100.0);
        if (deprecPct >= 60) isAging = true;
      }
      if (isAging) agingGear.add(g);
    }

    return AnnualReportData(
      year:                    year,
      userName:                userName,
      generatedAt:             now,
      totalHours:              totalHours,
      totalKm:                 totalKm,
      totalElevation:          totalElev,
      totalActivities:         totalActivities,
      totalServices:           totalServices,
      totalMaintenanceCost:    totalMaintCost,
      gearStats:               gearStats,
      monthlyStats:            monthlyStats,
      serviceHistory:          serviceHistory,
      gearNameById:            gearNameById,
      insurances:              insurances,
      totalPortfolioCurrentValue:  totalCurrentValue,
      totalPortfolioPurchaseValue: totalPurchaseValue,
      totalInsuranceCost:      totalInsuranceCost,
      upcomingServices:        upcomingServices,
      agingGear:               agingGear,
    );
  }

  double _depreciationRate(String sport) {
    final lower = sport.toLowerCase();
    if (lower.contains('paraglid') || lower.contains('kříd') || lower.contains('wing')) return 0.15;
    if (lower.contains('kol') || lower.contains('bike') || lower.contains('cykl')) return 0.10;
    if (lower.contains('lan') || lower.contains('rope') || lower.contains('horolezec')) return 0.20;
    return 0.10;
  }

  // ── PDF generation ───────────────────────────────────────────────────────────

  Future<Uint8List> generatePdf(AnnualReportData data) async {
    final doc = pw.Document();

    // Colors
    const primaryColor   = PdfColor.fromInt(0xFF1D9E75);
    const lightGreen     = PdfColor.fromInt(0xFFE8F5F0);
    const darkGrey       = PdfColor.fromInt(0xFF333333);
    const lightGrey      = PdfColor.fromInt(0xFFF5F5F5);
    const warningOrange  = PdfColor.fromInt(0xFFFF8F00);
    const white          = PdfColors.white;
    const tableHeaderBg  = PdfColor.fromInt(0xFF1D9E75);

    final czechMonths = [
      'Leden','Únor','Březen','Duben','Květen','Červen',
      'Červenec','Srpen','Září','Říjen','Listopad','Prosinec',
    ];

    final numFmt   = NumberFormat('#,##0.0', 'cs_CZ');
    final intFmt   = NumberFormat('#,##0', 'cs_CZ');
    final dateFmt  = DateFormat('d. M. yyyy', 'cs_CZ');
    final monFmt   = NumberFormat('#,##0 Kč', 'cs_CZ');

    String fmtH(double h)  => '${numFmt.format(h)} h';
    String fmtKm(double k) => '${numFmt.format(k)} km';
    String fmtEl(double e) => '${intFmt.format(e)} m';

    // ── Cover page ──────────────────────────────────────────────────────────────
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => pw.Container(
          width:  double.infinity,
          height: double.infinity,
          color:  primaryColor,
          child: pw.Stack(
            children: [
              // Decorative circle top-right
              pw.Positioned(
                top:   -60,
                right: -60,
                child: pw.Container(
                  width:  220,
                  height: 220,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    color: PdfColor.fromInt(0xFF17845F),
                  ),
                ),
              ),
              // Decorative circle bottom-left
              pw.Positioned(
                bottom: -80,
                left:   -80,
                child: pw.Container(
                  width:  260,
                  height: 260,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    color: PdfColor.fromInt(0xFF17845F),
                  ),
                ),
              ),
              // Main content
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 50, vertical: 60),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Spacer(),
                    pw.Text(
                      'ROČNÍ REPORT',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xCCFFFFFF),
                        letterSpacing: 4,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      data.year.toString(),
                      style: pw.TextStyle(
                        fontSize: 80,
                        fontWeight: pw.FontWeight.bold,
                        color: white,
                      ),
                    ),
                    pw.SizedBox(height: 24),
                    pw.Container(
                      width: 60,
                      height: 3,
                      color: PdfColor.fromInt(0xAAFFFFFF),
                    ),
                    pw.SizedBox(height: 24),
                    pw.Text(
                      'OutdoorGearTracker',
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                        color: white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      data.userName,
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColor.fromInt(0xDDFFFFFF),
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      'Vygenerováno: ${dateFmt.format(data.generatedAt)}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColor.fromInt(0xAAFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // ── Helper: section header ──────────────────────────────────────────────────
    pw.Widget sectionTitle(String title) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 16),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: primaryColor,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(height: 2, color: primaryColor),
        pw.SizedBox(height: 10),
      ],
    );

    // ── Helper: stat box ────────────────────────────────────────────────────────
    pw.Widget statBox(String label, String value) => pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.all(4),
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: pw.BoxDecoration(
          color: lightGreen,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF666666)),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );

    // ── Helper: page header ─────────────────────────────────────────────────────
    pw.Widget pageHeader(pw.Context ctx) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(color: primaryColor),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'OutdoorGearTracker | Roční Report ${data.year}',
            style: pw.TextStyle(fontSize: 9, color: white),
          ),
          pw.Text(
            'Strana ${ctx.pageNumber}',
            style: pw.TextStyle(fontSize: 9, color: white),
          ),
        ],
      ),
    );

    // ── Helper: page footer ─────────────────────────────────────────────────────
    pw.Widget pageFooter() => pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(
        'Vygenerováno aplikací OutdoorGearTracker | ${dateFmt.format(data.generatedAt)}',
        style: pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF999999)),
      ),
    );

    // ── Helper: table header row ────────────────────────────────────────────────
    pw.TableRow tableHeaderRow(List<String> cols) => pw.TableRow(
      decoration: pw.BoxDecoration(color: tableHeaderBg),
      children: cols.map((c) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(
          c,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: white,
          ),
        ),
      )).toList(),
    );

    // ── Content pages ───────────────────────────────────────────────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 20, 36, 36),
        header: pageHeader,
        footer: (ctx) => pageFooter(),
        build: (context) => [

          // ── SECTION 1: Přehled roku ───────────────────────────────────────
          sectionTitle('1. Přehled roku ${data.year}'),
          pw.Row(children: [
            statBox('Hodiny', fmtH(data.totalHours)),
            statBox('Kilometry', fmtKm(data.totalKm)),
            statBox('Nastoupáno', fmtEl(data.totalElevation)),
          ]),
          pw.Row(children: [
            statBox('Aktivity', intFmt.format(data.totalActivities)),
            statBox('Servisy', intFmt.format(data.totalServices)),
            statBox('Servisní náklady', monFmt.format(data.totalMaintenanceCost)),
          ]),

          // ── SECTION 2: Vybavení ───────────────────────────────────────────
          sectionTitle('2. Vybavení'),
          if (data.gearStats.isEmpty)
            pw.Text('Žádné vybavení v databázi.',
                style: pw.TextStyle(fontSize: 10, color: darkGrey))
          else
            ...data.gearStats.asMap().entries.map((entry) {
              final idx  = entry.key;
              final gs   = entry.value;
              final bgColor = idx.isEven ? white : lightGrey;

              // Try to load gear photo
              pw.Widget? photo;
              if (!kIsWeb && gs.gear.photoPath != null) {
                try {
                  final f = File(gs.gear.photoPath!);
                  if (f.existsSync()) {
                    final bytes = f.readAsBytesSync();
                    photo = pw.Image(
                      pw.MemoryImage(bytes),
                      width: 48,
                      height: 48,
                      fit: pw.BoxFit.cover,
                    );
                  }
                } catch (_) {}
              }

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 2),
                decoration: pw.BoxDecoration(
                  color: bgColor,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (photo != null) ...[
                            pw.ClipRRect(
                              horizontalRadius: 4,
                              verticalRadius: 4,
                              child: photo,
                            ),
                            pw.SizedBox(width: 10),
                          ],
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(children: [
                                  pw.Text(
                                    gs.gear.name,
                                    style: pw.TextStyle(
                                      fontSize: 11,
                                      fontWeight: pw.FontWeight.bold,
                                      color: darkGrey,
                                    ),
                                  ),
                                  pw.SizedBox(width: 6),
                                  pw.Text(
                                    gs.categoryName,
                                    style: pw.TextStyle(
                                      fontSize: 9,
                                      color: PdfColor.fromInt(0xFF888888),
                                    ),
                                  ),
                                  if (gs.warrantyValid) ...[
                                    pw.SizedBox(width: 6),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: pw.BoxDecoration(
                                        color: lightGreen,
                                        borderRadius: pw.BorderRadius.circular(4),
                                      ),
                                      child: pw.Text('Záruka', style: pw.TextStyle(fontSize: 8, color: primaryColor)),
                                    ),
                                  ],
                                  if (gs.hasInsurance) ...[
                                    pw.SizedBox(width: 4),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: pw.BoxDecoration(
                                        color: PdfColor.fromInt(0xFFE3F2FD),
                                        borderRadius: pw.BorderRadius.circular(4),
                                      ),
                                      child: pw.Text('Pojistka', style: pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF1565C0))),
                                    ),
                                  ],
                                ]),
                                if (gs.gear.brand != null || gs.gear.model != null)
                                  pw.Text(
                                    [gs.gear.brand, gs.gear.model].where((v) => v != null).join(' '),
                                    style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF666666)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(children: [
                        _miniStat('Hodiny', fmtH(gs.hoursInYear), primaryColor, lightGreen),
                        pw.SizedBox(width: 6),
                        _miniStat('Km', fmtKm(gs.kmInYear), primaryColor, lightGreen),
                        pw.SizedBox(width: 6),
                        _miniStat('Servisy', gs.serviceCount.toString(), primaryColor, lightGreen),
                        pw.SizedBox(width: 6),
                        _miniStat('Náklady', monFmt.format(gs.maintenanceCost), primaryColor, lightGreen),
                      ]),
                    ],
                  ),
                ),
              );
            }),

          // ── SECTION 3: Měsíční přehled ────────────────────────────────────
          sectionTitle('3. Aktivity podle měsíce'),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFE0E0E0), width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(1.5),
              2: pw.FlexColumnWidth(1.5),
              3: pw.FlexColumnWidth(2),
              4: pw.FlexColumnWidth(1.2),
            },
            children: [
              tableHeaderRow(['Měsíc', 'Hodiny', 'Km', 'Nastoupáno', 'Aktivity']),
              ...data.monthlyStats.asMap().entries.map((entry) {
                final ms     = entry.value;
                final isHigh = ms.activityCount > 0 &&
                    data.monthlyStats
                        .every((m) => m.activityCount <= ms.activityCount) &&
                    data.monthlyStats
                        .where((m) => m.activityCount == ms.activityCount)
                        .length == 1;
                final rowBg = isHigh ? lightGreen : null;

                return pw.TableRow(
                  decoration: rowBg != null
                      ? pw.BoxDecoration(color: rowBg)
                      : null,
                  children: [
                    _tCell(czechMonths[ms.month - 1], bold: isHigh),
                    _tCell(fmtH(ms.totalHours)),
                    _tCell(fmtKm(ms.totalKm)),
                    _tCell(fmtEl(ms.totalElevation)),
                    _tCell(ms.activityCount.toString()),
                  ],
                );
              }),
            ],
          ),

          // ── SECTION 4: Servisní historie ──────────────────────────────────
          sectionTitle('4. Servisní historie'),
          if (data.serviceHistory.isEmpty)
            pw.Text(
              'Žádné servisní záznamy v roce ${data.year}.',
              style: pw.TextStyle(fontSize: 10, color: darkGrey),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFE0E0E0), width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(1.8),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(3),
                3: pw.FlexColumnWidth(1.8),
                4: pw.FlexColumnWidth(1.8),
              },
              children: [
                tableHeaderRow(['Datum', 'Vybavení', 'Popis', 'Technik', 'Cena']),
                ...data.serviceHistory.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final log = entry.value;
                  final bgColor = idx.isEven ? null : lightGrey;
                  final gName = data.gearNameById[log.gearItemId] ?? 'ID ${log.gearItemId}';
                  return pw.TableRow(
                    decoration: bgColor != null ? pw.BoxDecoration(color: bgColor) : null,
                    children: [
                      _tCell(dateFmt.format(log.performedDate)),
                      _tCell(gName),
                      _tCell(log.notes ?? '-'),
                      _tCell(log.performedBy ?? '-'),
                      _tCell(log.cost != null ? monFmt.format(log.cost) : '-'),
                    ],
                  );
                }),
              ],
            ),

          // ── SECTION 5: Pojistky a portfolio ───────────────────────────────
          sectionTitle('5. Pojistky a hodnota portfolia'),
          pw.Row(children: [
            statBox('Pořizovací hodnota', monFmt.format(data.totalPortfolioPurchaseValue)),
            statBox('Aktuální hodnota',   monFmt.format(data.totalPortfolioCurrentValue)),
            statBox('Roční pojistné',     monFmt.format(data.totalInsuranceCost)),
          ]),
          pw.SizedBox(height: 10),
          if (data.insurances.isEmpty)
            pw.Text('Žádné pojistky.', style: pw.TextStyle(fontSize: 10, color: darkGrey))
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFE0E0E0), width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(2.5),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(2),
                3: pw.FlexColumnWidth(2),
                4: pw.FlexColumnWidth(1.8),
              },
              children: [
                tableHeaderRow(['Název', 'Pojišťovna', 'Číslo smlouvy', 'Platí do', 'Roční pojistné']),
                ...data.insurances.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final ins = entry.value;
                  final bgColor = idx.isEven ? null : lightGrey;
                  return pw.TableRow(
                    decoration: bgColor != null ? pw.BoxDecoration(color: bgColor) : null,
                    children: [
                      _tCell(ins.name),
                      _tCell(ins.insuranceCompany),
                      _tCell(ins.policyNumber),
                      _tCell(dateFmt.format(ins.expiryDate)),
                      _tCell(ins.annualPremium != null ? monFmt.format(ins.annualPremium) : '-'),
                    ],
                  );
                }),
              ],
            ),

          // ── SECTION 6: Plán na příští rok ─────────────────────────────────
          sectionTitle('6. Plán na příští rok'),
          if (data.upcomingServices.isEmpty && data.agingGear.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: lightGreen,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'Vše v pořádku! Žádné plánované servisní termíny.',
                style: pw.TextStyle(fontSize: 10, color: primaryColor),
              ),
            )
          else ...[
            if (data.upcomingServices.isNotEmpty) ...[
              pw.Text('Nadcházející servisy (příštích 12 měsíců):',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkGrey)),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFE0E0E0), width: 0.5),
                columnWidths: const {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(2.5),
                  2: pw.FlexColumnWidth(3),
                },
                children: [
                  tableHeaderRow(['Datum', 'Vybavení', 'Úkon']),
                  ...data.upcomingServices.asMap().entries.map((entry) {
                    final idx     = entry.key;
                    final svc     = entry.value;
                    final bgColor = idx.isEven ? null : lightGrey;
                    final due     = svc['dueDate'] as DateTime;
                    return pw.TableRow(
                      decoration: bgColor != null ? pw.BoxDecoration(color: bgColor) : null,
                      children: [
                        _tCell(dateFmt.format(due)),
                        _tCell(svc['gearName'] as String),
                        _tCell(svc['task'] as String),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 12),
            ],
            if (data.agingGear.isNotEmpty) ...[
              pw.Text('Stárnoucí vybavení (5+ let nebo vysoká amortizace):',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: warningOrange)),
              pw.SizedBox(height: 6),
              ...data.agingGear.asMap().entries.map((entry) {
                final idx = entry.key;
                final g   = entry.value;
                final bgColor = idx.isEven ? white : lightGrey;
                String ageText = '';
                if (g.purchaseDate != null) {
                  final years = DateTime.now().difference(g.purchaseDate!).inDays ~/ 365;
                  ageText = '$years let';
                }
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 3),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: bgColor,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          g.name,
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkGrey),
                        ),
                      ),
                      if (ageText.isNotEmpty)
                        pw.Text(
                          ageText,
                          style: pw.TextStyle(fontSize: 9, color: warningOrange),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ],
      ),
    );

    return doc.save();
  }

  // ── Small helpers ─────────────────────────────────────────────────────────────

  static pw.Widget _miniStat(String label, String value, PdfColor textColor, PdfColor bgColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.RichText(
        text: pw.TextSpan(children: [
          pw.TextSpan(
            text: '$label: ',
            style: pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF666666)),
          ),
          pw.TextSpan(
            text: value,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textColor),
          ),
        ]),
      ),
    );
  }

  static pw.Widget _tCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}

// ── Internal aggregation helper ────────────────────────────────────────────────

class _MonthAgg {
  double hours     = 0;
  double km        = 0;
  double elevation = 0;
  int    count     = 0;
}

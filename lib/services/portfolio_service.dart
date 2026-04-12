import '../database/database_helper.dart';
import '../services/insurance_service.dart';

class PortfolioStats {
  final double totalPurchaseValue;
  final double totalCurrentValue;
  final double totalDepreciation;
  final double totalInsuranceCost;
  final double totalMaintenanceCost;
  final Map<String, double> valueByCategory;
  final Map<String, double> purchaseValueByCategory;
  final List<GearValueEntry> gearByValue;
  final Map<String, double> maintenanceCostByMonth;

  const PortfolioStats({
    required this.totalPurchaseValue,
    required this.totalCurrentValue,
    required this.totalDepreciation,
    required this.totalInsuranceCost,
    required this.totalMaintenanceCost,
    required this.valueByCategory,
    required this.purchaseValueByCategory,
    required this.gearByValue,
    required this.maintenanceCostByMonth,
  });
}

class GearValueEntry {
  final String gearId;
  final String gearName;
  final String sport;
  final double purchasePrice;
  final double currentValue;
  final double depreciationPercent;
  final DateTime? purchaseDate;

  const GearValueEntry({
    required this.gearId,
    required this.gearName,
    required this.sport,
    required this.purchasePrice,
    required this.currentValue,
    required this.depreciationPercent,
    this.purchaseDate,
  });
}

class PortfolioService {
  PortfolioService._();
  static final PortfolioService instance = PortfolioService._();

  /// Annual depreciation rate by sport/category keyword
  double _depreciationRate(String sport) {
    final lower = sport.toLowerCase();
    if (lower.contains('paraglid') ||
        lower.contains('kříd') ||
        lower.contains('wing')) return 0.15;
    if (lower.contains('kol') ||
        lower.contains('bike') ||
        lower.contains('cykl')) return 0.10;
    if (lower.contains('lan') ||
        lower.contains('rope') ||
        lower.contains('horolezec')) return 0.20;
    return 0.10; // default
  }

  double _currentValue(
    double purchasePrice,
    DateTime? purchaseDate,
    String sport,
  ) {
    if (purchaseDate == null) return purchasePrice;
    final years = DateTime.now().difference(purchaseDate).inDays / 365.0;
    final rate = _depreciationRate(sport);
    final factor = (1.0 - rate * years).clamp(0.1, 1.0);
    return purchasePrice * factor;
  }

  Future<PortfolioStats> getStats() async {
    final db = await DatabaseHelper.instance.database;

    // Load all gear items with their category sport name via JOIN
    final gearRows = await db.rawQuery('''
      SELECT gi.*, c.sport AS category_sport
      FROM gear_items gi
      LEFT JOIN categories c ON c.id = gi.category_id
      WHERE gi.status != 'retired'
    ''');

    double totalPurchase = 0;
    double totalCurrent = 0;
    final valueByCategory = <String, double>{};
    final purchaseByCategory = <String, double>{};
    final gearByValue = <GearValueEntry>[];

    for (final row in gearRows) {
      final price = (row['purchase_price'] as num?)?.toDouble();
      if (price == null || price <= 0) continue;

      final purchaseDateStr = row['purchase_date'] as String?;
      final purchaseDate =
          purchaseDateStr != null ? DateTime.tryParse(purchaseDateStr) : null;

      final sport = (row['category_sport'] as String?) ?? 'Ostatní';
      final name = row['name'] as String? ?? '';
      final id = row['id']?.toString() ?? '';

      final current = _currentValue(price, purchaseDate, sport);
      final deprecPct =
          ((price - current) / price * 100).clamp(0.0, 100.0);

      totalPurchase += price;
      totalCurrent += current;
      valueByCategory[sport] = (valueByCategory[sport] ?? 0) + current;
      purchaseByCategory[sport] =
          (purchaseByCategory[sport] ?? 0) + price;

      gearByValue.add(GearValueEntry(
        gearId: id,
        gearName: name,
        sport: sport,
        purchasePrice: price,
        currentValue: current,
        depreciationPercent: deprecPct,
        purchaseDate: purchaseDate,
      ));
    }

    gearByValue.sort((a, b) => b.currentValue.compareTo(a.currentValue));

    // Insurance cost
    double insuranceCost = 0;
    try {
      final insurances = await InsuranceService.instance.getAllInsurances();
      for (final ins in insurances) {
        if (ins.annualPremium != null) insuranceCost += ins.annualPremium!;
      }
    } catch (_) {}

    // Maintenance costs by month from maintenance_logs
    double totalMaintenance = 0;
    final maintenanceByMonth = <String, double>{};
    try {
      final logs = await db.query('maintenance_logs', orderBy: 'performed_date DESC');
      for (final log in logs) {
        final cost = (log['cost'] as num?)?.toDouble() ?? 0.0;
        final dateStr = log['performed_date'] as String?;
        if (cost > 0 && dateStr != null) {
          final date = DateTime.tryParse(dateStr);
          if (date != null) {
            final key =
                '${date.year}-${date.month.toString().padLeft(2, '0')}';
            maintenanceByMonth[key] =
                (maintenanceByMonth[key] ?? 0) + cost;
            totalMaintenance += cost;
          }
        }
      }
    } catch (_) {}

    return PortfolioStats(
      totalPurchaseValue: totalPurchase,
      totalCurrentValue: totalCurrent,
      totalDepreciation: totalPurchase - totalCurrent,
      totalInsuranceCost: insuranceCost,
      totalMaintenanceCost: totalMaintenance,
      valueByCategory: valueByCategory,
      purchaseValueByCategory: purchaseByCategory,
      gearByValue: gearByValue,
      maintenanceCostByMonth: maintenanceByMonth,
    );
  }
}

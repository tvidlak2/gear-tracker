import 'package:outdoor_gear_tracker/models/gear_item.dart';
import 'package:outdoor_gear_tracker/models/maintenance_rule.dart';
import 'package:outdoor_gear_tracker/models/usage_log.dart';

/// Factory for a minimal GearItem used in tests.
GearItem createTestGearItem({
  int id = 1,
  String name = 'Test Gear',
  int categoryId = 1,
  DateTime? purchaseDate,
  double? purchasePrice,
  GearStatus status = GearStatus.active,
}) {
  return GearItem(
    id: id,
    name: name,
    categoryId: categoryId,
    purchaseDate: purchaseDate,
    purchasePrice: purchasePrice,
    status: status,
  );
}

/// Factory for a date-based MaintenanceRule used in tests.
MaintenanceRule createTestMaintenanceRule({
  int id = 1,
  int gearItemId = 1,
  String name = 'Test Rule',
  TriggerType triggerType = TriggerType.date,
  double triggerValue = 365,
  double warningBefore = 14,
  bool isSafetyCritical = false,
}) {
  return MaintenanceRule(
    id: id,
    gearItemId: gearItemId,
    name: name,
    triggerType: triggerType,
    triggerValue: triggerValue,
    warningBefore: warningBefore,
    isSafetyCritical: isSafetyCritical,
  );
}

/// Factory for a UsageLog used in tests.
UsageLog createTestUsageLog({
  int id = 1,
  int gearItemId = 1,
  DateTime? date,
  int? durationMinutes,
  double? distanceKm,
}) {
  return UsageLog(
    id: id,
    gearItemId: gearItemId,
    date: date ?? DateTime(2024, 1, 1),
    durationMinutes: durationMinutes,
    distanceKm: distanceKm,
  );
}

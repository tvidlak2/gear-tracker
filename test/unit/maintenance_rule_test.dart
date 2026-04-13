// Unit tests for MaintenanceRule next_due_date calculation and status classification.
//
// The actual logic lives in MaintenanceService._evaluateDateRule():
//   baseDate = lastLog?.performedDate ?? now.subtract(Duration(days: triggerValue))
//   nextDue  = baseDate.add(Duration(days: triggerValue))
//   daysRemaining = nextDue.difference(now).inDays
//
// Status is resolved by _resolveStatus(daysRemaining, warningBefore):
//   <= 0            → overdue
//   <= warningBefore → warning
//   otherwise       → ok

import 'package:test/test.dart';
import 'package:gear_tracker/models/maintenance_rule.dart';
import 'package:gear_tracker/services/maintenance_service.dart';

// ---------------------------------------------------------------------------
// Pure helper that mirrors _evaluateDateRule without any DB calls.
// ---------------------------------------------------------------------------

({DateTime nextDueDate, double daysRemaining}) evaluateDateRule({
  required MaintenanceRule rule,
  DateTime? lastServiceDate,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final baseDate =
      lastServiceDate ?? effectiveNow.subtract(Duration(days: rule.triggerValue.toInt()));
  final nextDue = baseDate.add(Duration(days: rule.triggerValue.toInt()));
  final daysRemaining = nextDue.difference(effectiveNow).inDays.toDouble();
  return (nextDueDate: nextDue, daysRemaining: daysRemaining);
}

MaintenanceStatus resolveStatus(double remaining, double warningBefore) {
  if (remaining <= 0) return MaintenanceStatus.overdue;
  if (remaining <= warningBefore) return MaintenanceStatus.warning;
  return MaintenanceStatus.ok;
}

// ---------------------------------------------------------------------------

void main() {
  group('next_due_date – date-based rule', () {
    test('last service 6 months ago with 365-day interval → next due in ~6 months (future)', () {
      final now = DateTime(2025, 6, 15);
      final lastService = DateTime(2024, 12, 15); // 6 months ago
      final rule = MaintenanceRule(
        id: 1,
        gearItemId: 1,
        name: 'Annual check',
        triggerType: TriggerType.date,
        triggerValue: 365,
        warningBefore: 14,
      );

      final result = evaluateDateRule(rule: rule, lastServiceDate: lastService, now: now);

      // nextDue = 2024-12-15 + 365 days = 2025-12-15
      expect(result.nextDueDate, DateTime(2025, 12, 15));
      // daysRemaining ≈ 183 days – should be positive (future)
      expect(result.daysRemaining, greaterThan(0));
      expect(resolveStatus(result.daysRemaining, rule.warningBefore), MaintenanceStatus.ok);
    });

    test('last service 45 days ago with 30-day interval → next due is 15 days ago (overdue)', () {
      final now = DateTime(2025, 6, 15);
      final lastService = DateTime(2025, 5, 1); // 45 days ago
      final rule = MaintenanceRule(
        id: 2,
        gearItemId: 1,
        name: 'Monthly check',
        triggerType: TriggerType.date,
        triggerValue: 30,
        warningBefore: 7,
      );

      final result = evaluateDateRule(rule: rule, lastServiceDate: lastService, now: now);

      // nextDue = 2025-05-01 + 30 days = 2025-05-31 (15 days before now)
      expect(result.nextDueDate, DateTime(2025, 5, 31));
      expect(result.daysRemaining, lessThan(0));
      expect(resolveStatus(result.daysRemaining, rule.warningBefore), MaintenanceStatus.overdue);
    });

    test('no last service → baseDate = now - intervalDays, nextDue = now → overdue immediately', () {
      final now = DateTime(2025, 6, 15);
      final rule = MaintenanceRule(
        id: 3,
        gearItemId: 1,
        name: 'First check',
        triggerType: TriggerType.date,
        triggerValue: 180,
        warningBefore: 14,
      );

      final result = evaluateDateRule(rule: rule, lastServiceDate: null, now: now);

      // baseDate = now - 180 days; nextDue = baseDate + 180 days = now
      // daysRemaining = now.difference(now).inDays = 0 → overdue (remaining <= 0)
      expect(result.daysRemaining, equals(0));
      expect(resolveStatus(result.daysRemaining, rule.warningBefore), MaintenanceStatus.overdue);
    });
  });

  group('MaintenanceStatus classification', () {
    test('next due more than 14 days from now → ok', () {
      const warningBefore = 14.0;
      // 30 days remaining
      expect(resolveStatus(30, warningBefore), MaintenanceStatus.ok);
    });

    test('next due within warning window (14 days) but not yet overdue → warning', () {
      const warningBefore = 14.0;
      // 7 days remaining – inside warning window
      expect(resolveStatus(7, warningBefore), MaintenanceStatus.warning);
      // Exactly at the warning threshold
      expect(resolveStatus(14, warningBefore), MaintenanceStatus.warning);
    });

    test('next due date is today (0 days remaining) → overdue', () {
      expect(resolveStatus(0, 14), MaintenanceStatus.overdue);
    });

    test('next due date is in the past (negative remaining) → overdue', () {
      expect(resolveStatus(-5, 14), MaintenanceStatus.overdue);
    });

    test('warningBefore = 0 means no warning zone, only ok and overdue', () {
      expect(resolveStatus(1, 0), MaintenanceStatus.ok);
      expect(resolveStatus(0, 0), MaintenanceStatus.overdue);
    });
  });

  group('MaintenanceRule model', () {
    test('stores all fields correctly', () {
      const rule = MaintenanceRule(
        id: 10,
        gearItemId: 5,
        name: 'Safety check',
        triggerType: TriggerType.date,
        triggerValue: 90,
        warningBefore: 7,
        isSafetyCritical: true,
      );

      expect(rule.id, 10);
      expect(rule.gearItemId, 5);
      expect(rule.name, 'Safety check');
      expect(rule.triggerType, TriggerType.date);
      expect(rule.triggerValue, 90);
      expect(rule.warningBefore, 7);
      expect(rule.isSafetyCritical, true);
    });

    test('fromMap round-trips through toMap', () {
      const rule = MaintenanceRule(
        id: 7,
        gearItemId: 3,
        name: 'Annual inspection',
        triggerType: TriggerType.date,
        triggerValue: 365,
        warningBefore: 30,
        isSafetyCritical: false,
      );

      final map = rule.toMap();
      final restored = MaintenanceRule.fromMap(map);

      expect(restored.id, rule.id);
      expect(restored.gearItemId, rule.gearItemId);
      expect(restored.name, rule.name);
      expect(restored.triggerType, rule.triggerType);
      expect(restored.triggerValue, rule.triggerValue);
      expect(restored.warningBefore, rule.warningBefore);
      expect(restored.isSafetyCritical, rule.isSafetyCritical);
    });

    test('copyWith creates a new rule with updated fields', () {
      const original = MaintenanceRule(
        id: 1,
        gearItemId: 1,
        name: 'Original',
        triggerType: TriggerType.date,
        triggerValue: 100,
        warningBefore: 10,
      );

      final updated = original.copyWith(name: 'Updated', triggerValue: 200);

      expect(updated.name, 'Updated');
      expect(updated.triggerValue, 200);
      // Unchanged fields preserved
      expect(updated.id, original.id);
      expect(updated.warningBefore, original.warningBefore);
    });
  });
}

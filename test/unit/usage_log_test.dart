// Unit tests for UsageLog model and aggregation helpers.
//
// The DB aggregates are SQL (SUM / COUNT) so we test:
//   1. The UsageLog model itself – field storage and serialisation.
//   2. In-Dart aggregation helpers that mirror what the DB does.

import 'package:test/test.dart';
import 'package:outdoor_gear_tracker/models/usage_log.dart';

// ---------------------------------------------------------------------------
// Pure helpers that mirror DB aggregations (no DB required).
// ---------------------------------------------------------------------------

double sumHours(List<UsageLog> logs) =>
    logs.fold(0.0, (sum, l) => sum + (l.durationMinutes ?? 0) / 60.0);

double sumKm(List<UsageLog> logs) =>
    logs.fold(0.0, (sum, l) => sum + (l.distanceKm ?? 0.0));

// ---------------------------------------------------------------------------

void main() {
  group('UsageLog model', () {
    test('stores all fields correctly', () {
      final date = DateTime(2024, 5, 20);
      final log = UsageLog(
        id: 42,
        gearItemId: 7,
        date: date,
        durationMinutes: 90,
        distanceKm: 15.5,
        elevationGainM: 300,
        location: 'Alpy',
        source: UsageSource.manual,
      );

      expect(log.id, 42);
      expect(log.gearItemId, 7);
      expect(log.date, date);
      expect(log.durationMinutes, 90);
      expect(log.distanceKm, 15.5);
      expect(log.elevationGainM, 300);
      expect(log.location, 'Alpy');
      expect(log.source, UsageSource.manual);
    });

    test('fromMap round-trips through toMap', () {
      final date = DateTime(2024, 3, 10, 12, 0, 0);
      final log = UsageLog(
        id: 1,
        gearItemId: 2,
        date: date,
        durationMinutes: 120,
        distanceKm: 25.0,
        source: UsageSource.strava,
        stravaActivityId: 'abc123',
      );

      final map = log.toMap();
      final restored = UsageLog.fromMap(map);

      expect(restored.id, log.id);
      expect(restored.gearItemId, log.gearItemId);
      expect(restored.durationMinutes, log.durationMinutes);
      expect(restored.distanceKm, log.distanceKm);
      expect(restored.source, log.source);
      expect(restored.stravaActivityId, log.stravaActivityId);
    });

    test('copyWith preserves unchanged fields and updates specified ones', () {
      final original = UsageLog(
        id: 5,
        gearItemId: 3,
        date: DateTime(2024, 1, 1),
        durationMinutes: 60,
        distanceKm: 10.0,
      );

      final updated = original.copyWith(durationMinutes: 90, distanceKm: 20.0);

      expect(updated.durationMinutes, 90);
      expect(updated.distanceKm, 20.0);
      expect(updated.id, original.id);
      expect(updated.gearItemId, original.gearItemId);
    });

    test('null durationMinutes and distanceKm are handled gracefully', () {
      final log = UsageLog(
        id: 1,
        gearItemId: 1,
        date: DateTime(2024, 1, 1),
      );

      expect(log.durationMinutes, isNull);
      expect(log.distanceKm, isNull);
    });
  });

  group('UsageLog aggregation – sumHours', () {
    test('empty list → 0 hours', () {
      expect(sumHours([]), equals(0.0));
    });

    test('single entry with 150 minutes → 2.5 hours', () {
      final logs = [
        UsageLog(id: 1, gearItemId: 1, date: DateTime(2024, 1, 1), durationMinutes: 150),
      ];
      expect(sumHours(logs), closeTo(2.5, 0.001));
    });

    test('multiple entries: 60 + 150 + 180 min → 6.5 hours', () {
      final logs = [
        UsageLog(id: 1, gearItemId: 1, date: DateTime(2024, 1, 1), durationMinutes: 60),
        UsageLog(id: 2, gearItemId: 1, date: DateTime(2024, 1, 2), durationMinutes: 150),
        UsageLog(id: 3, gearItemId: 1, date: DateTime(2024, 1, 3), durationMinutes: 180),
      ];
      expect(sumHours(logs), closeTo(6.5, 0.001));
    });

    test('entries with null durationMinutes contribute 0', () {
      final logs = [
        UsageLog(id: 1, gearItemId: 1, date: DateTime(2024, 1, 1), durationMinutes: null),
        UsageLog(id: 2, gearItemId: 1, date: DateTime(2024, 1, 2), durationMinutes: 60),
      ];
      expect(sumHours(logs), closeTo(1.0, 0.001));
    });
  });

  group('UsageLog aggregation – sumKm', () {
    test('empty list → 0 km', () {
      expect(sumKm([]), equals(0.0));
    });

    test('single entry with 12.5 km → 12.5 km', () {
      final logs = [
        UsageLog(id: 1, gearItemId: 1, date: DateTime(2024, 1, 1), distanceKm: 12.5),
      ];
      expect(sumKm(logs), closeTo(12.5, 0.001));
    });

    test('multiple entries: 10.0 + 5.5 + 8.0 km → 23.5 km', () {
      final logs = [
        UsageLog(id: 1, gearItemId: 1, date: DateTime(2024, 1, 1), distanceKm: 10.0),
        UsageLog(id: 2, gearItemId: 1, date: DateTime(2024, 1, 2), distanceKm: 5.5),
        UsageLog(id: 3, gearItemId: 1, date: DateTime(2024, 1, 3), distanceKm: 8.0),
      ];
      expect(sumKm(logs), closeTo(23.5, 0.001));
    });

    test('entries with null distanceKm contribute 0', () {
      final logs = [
        UsageLog(id: 1, gearItemId: 1, date: DateTime(2024, 1, 1), distanceKm: null),
        UsageLog(id: 2, gearItemId: 1, date: DateTime(2024, 1, 2), distanceKm: 7.0),
      ];
      expect(sumKm(logs), closeTo(7.0, 0.001));
    });
  });

  group('UsageSource enum', () {
    test('fromString returns correct source', () {
      expect(UsageSourceExtension.fromString('manual'), UsageSource.manual);
      expect(UsageSourceExtension.fromString('strava'), UsageSource.strava);
      expect(UsageSourceExtension.fromString('igc'), UsageSource.igc);
      expect(UsageSourceExtension.fromString('gpx'), UsageSource.gpx);
    });

    test('fromString falls back to manual for unknown value', () {
      expect(UsageSourceExtension.fromString('unknown'), UsageSource.manual);
    });

    test('value returns the enum name', () {
      expect(UsageSource.strava.value, 'strava');
      expect(UsageSource.manual.value, 'manual');
    });
  });
}

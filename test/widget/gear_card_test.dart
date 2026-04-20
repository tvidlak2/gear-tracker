// Widget tests for GearCard.
// GearCard is a pure presentational widget (no DB, no router needed).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outdoor_gear_tracker/models/gear_item.dart';
import 'package:outdoor_gear_tracker/services/maintenance_service.dart';
import 'package:outdoor_gear_tracker/widgets/gear_card.dart';

Widget wrapCard(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  final testItem = GearItem(
    id: 1,
    name: 'Test Rope',
    categoryId: 1,
    brand: 'Mammut',
    model: 'Infinity',
    status: GearStatus.active,
  );

  group('GearCard rendering', () {
    testWidgets('displays gear item name', (tester) async {
      await tester.pumpWidget(
        wrapCard(
          GearCard(
            item: testItem,
            maintenanceStatus: MaintenanceStatus.ok,
          ),
        ),
      );

      expect(find.text('Test Rope'), findsOneWidget);
    });

    testWidgets('displays brand and model in subtitle', (tester) async {
      await tester.pumpWidget(
        wrapCard(
          GearCard(
            item: testItem,
            maintenanceStatus: MaintenanceStatus.ok,
          ),
        ),
      );

      // Subtitle is formatted as "brand · model" or just brand/model
      expect(find.textContaining('Mammut'), findsWidgets);
    });

    testWidgets('pumps without errors for all maintenance statuses', (tester) async {
      for (final status in MaintenanceStatus.values) {
        await tester.pumpWidget(
          wrapCard(
            GearCard(
              item: testItem,
              maintenanceStatus: status,
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: 'Failed for status $status');
      }
    });

    testWidgets('shows chevron_right icon', (tester) async {
      await tester.pumpWidget(
        wrapCard(
          GearCard(
            item: testItem,
            maintenanceStatus: MaintenanceStatus.ok,
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });
  });

  group('GearCard interaction', () {
    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        wrapCard(
          GearCard(
            item: testItem,
            maintenanceStatus: MaintenanceStatus.ok,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not crash if onTap is null', (tester) async {
      await tester.pumpWidget(
        wrapCard(
          GearCard(
            item: testItem,
            maintenanceStatus: MaintenanceStatus.ok,
            // onTap is null
          ),
        ),
      );

      // Tapping without a callback should not crash
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('GearCard status pill for non-active gear', () {
    testWidgets('shows status label for retired gear', (tester) async {
      final retiredItem = testItem.copyWith(status: GearStatus.retired);

      await tester.pumpWidget(
        wrapCard(
          GearCard(
            item: retiredItem,
            maintenanceStatus: MaintenanceStatus.ok,
          ),
        ),
      );

      // GearStatus.retired.label == 'Vyřazeno'
      expect(find.text('Vyřazeno'), findsOneWidget);
    });

    testWidgets('does not show status pill for active gear', (tester) async {
      await tester.pumpWidget(
        wrapCard(
          GearCard(
            item: testItem, // status: active
            maintenanceStatus: MaintenanceStatus.ok,
          ),
        ),
      );

      // 'Aktivní' label should not appear (no pill for active)
      expect(find.text('Aktivní'), findsNothing);
    });
  });

  group('GearCard usage display', () {
    testWidgets('displays usage hours when totalMinutes provided', (tester) async {
      await tester.pumpWidget(
        wrapCard(
          GearCard(
            item: testItem,
            maintenanceStatus: MaintenanceStatus.ok,
            totalMinutes: 120, // 2 hours
          ),
        ),
      );

      expect(find.textContaining('2 h'), findsOneWidget);
    });

    testWidgets('displays km when totalKm provided', (tester) async {
      await tester.pumpWidget(
        wrapCard(
          GearCard(
            item: testItem,
            maintenanceStatus: MaintenanceStatus.ok,
            totalMinutes: 0,
            totalKm: 50.0,
          ),
        ),
      );

      expect(find.textContaining('km'), findsWidgets);
    });
  });
}

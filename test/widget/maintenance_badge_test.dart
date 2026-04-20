// Widget tests for MaintenanceBadge – a pure, stateless widget with no DB dependencies.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outdoor_gear_tracker/services/maintenance_service.dart';
import 'package:outdoor_gear_tracker/widgets/maintenance_badge.dart';

Widget wrapBadge(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

void main() {
  group('MaintenanceBadge – pill variant (compact: false)', () {
    testWidgets('shows "OK" text for ok status', (tester) async {
      await tester.pumpWidget(
        wrapBadge(const MaintenanceBadge(status: MaintenanceStatus.ok)),
      );
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('shows "Brzy" text for warning status', (tester) async {
      await tester.pumpWidget(
        wrapBadge(const MaintenanceBadge(status: MaintenanceStatus.warning)),
      );
      expect(find.text('Brzy'), findsOneWidget);
    });

    testWidgets('shows "Po termínu" text for overdue status', (tester) async {
      await tester.pumpWidget(
        wrapBadge(const MaintenanceBadge(status: MaintenanceStatus.overdue)),
      );
      expect(find.text('Po termínu'), findsOneWidget);
    });

    testWidgets('renders without throwing for all statuses', (tester) async {
      for (final status in MaintenanceStatus.values) {
        await tester.pumpWidget(
          wrapBadge(MaintenanceBadge(status: status)),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('MaintenanceBadge – compact dot variant', () {
    testWidgets('renders a small Container (dot) instead of text', (tester) async {
      await tester.pumpWidget(
        wrapBadge(
          const MaintenanceBadge(status: MaintenanceStatus.overdue, compact: true),
        ),
      );
      // No text should be present in compact mode
      expect(find.text('Po termínu'), findsNothing);
      expect(find.text('OK'), findsNothing);
    });

    testWidgets('compact widget pumps without error', (tester) async {
      await tester.pumpWidget(
        wrapBadge(
          const MaintenanceBadge(status: MaintenanceStatus.warning, compact: true),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}

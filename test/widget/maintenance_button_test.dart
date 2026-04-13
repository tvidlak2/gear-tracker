// Widget tests for the _ItemCard in MaintenanceOverviewScreen.
//
// _ItemCard is a private class but its logic (the "Zapsat servis" button calling
// onLogMaintenance) can be tested by building an equivalent inline widget.
// We replicate the essential structure to test the callback contract.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gear_tracker/models/gear_item.dart';
import 'package:gear_tracker/models/maintenance_rule.dart';
import 'package:gear_tracker/services/maintenance_service.dart';
import 'package:gear_tracker/widgets/maintenance_badge.dart';

// ---------------------------------------------------------------------------
// Minimal replica of _ItemCard that is public and testable.
// Mirrors the structure from maintenance_screen.dart.
// ---------------------------------------------------------------------------

class TestableItemCard extends StatelessWidget {
  final GearItem item;
  final List<({MaintenanceRule rule, MaintenanceStatus status})> ruleStatuses;
  final VoidCallback onTap;
  final void Function(GearItem item, int ruleId) onLogMaintenance;

  const TestableItemCard({
    super.key,
    required this.item,
    required this.ruleStatuses,
    required this.onTap,
    required this.onLogMaintenance,
  });

  @override
  Widget build(BuildContext context) {
    final hasOverdue = ruleStatuses.any((r) => r.status == MaintenanceStatus.overdue);
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    hasOverdue ? Icons.warning : Icons.info_outline,
                    color: hasOverdue ? Colors.red : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.name,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 8),
              ...ruleStatuses
                  .where((r) => r.status != MaintenanceStatus.ok)
                  .map(
                    (r) => Row(
                      children: [
                        MaintenanceBadge(status: r.status, compact: true),
                        const SizedBox(width: 8),
                        Expanded(child: Text(r.rule.name)),
                        if (r.rule.id != null)
                          TextButton(
                            onPressed: () => onLogMaintenance(item, r.rule.id!),
                            child: const Text('Zapsat servis'),
                          ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

void main() {
  final testItem = GearItem(
    id: 1,
    name: 'Mammut Lano',
    categoryId: 1,
    status: GearStatus.active,
  );

  const overdueRule = MaintenanceRule(
    id: 42,
    gearItemId: 1,
    name: 'Roční kontrola',
    triggerType: TriggerType.date,
    triggerValue: 365,
    warningBefore: 14,
  );

  const warningRule = MaintenanceRule(
    id: 7,
    gearItemId: 1,
    name: 'Měsíční mazání',
    triggerType: TriggerType.date,
    triggerValue: 30,
    warningBefore: 7,
  );

  Widget wrapCard(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('TestableItemCard – rendering', () {
    testWidgets('shows gear item name', (tester) async {
      await tester.pumpWidget(wrapCard(
        TestableItemCard(
          item: testItem,
          ruleStatuses: [
            (rule: overdueRule, status: MaintenanceStatus.overdue),
          ],
          onTap: () {},
          onLogMaintenance: (_, __) {},
        ),
      ));

      expect(find.text('Mammut Lano'), findsOneWidget);
    });

    testWidgets('shows "Zapsat servis" button for each non-ok rule with an id', (tester) async {
      await tester.pumpWidget(wrapCard(
        TestableItemCard(
          item: testItem,
          ruleStatuses: [
            (rule: overdueRule, status: MaintenanceStatus.overdue),
            (rule: warningRule, status: MaintenanceStatus.warning),
          ],
          onTap: () {},
          onLogMaintenance: (_, __) {},
        ),
      ));

      expect(find.text('Zapsat servis'), findsNWidgets(2));
    });

    testWidgets('does not show "Zapsat servis" for ok-status rules', (tester) async {
      const okRule = MaintenanceRule(
        id: 99,
        gearItemId: 1,
        name: 'Fine rule',
        triggerType: TriggerType.date,
        triggerValue: 365,
        warningBefore: 14,
      );

      await tester.pumpWidget(wrapCard(
        TestableItemCard(
          item: testItem,
          ruleStatuses: [
            (rule: okRule, status: MaintenanceStatus.ok),
          ],
          onTap: () {},
          onLogMaintenance: (_, __) {},
        ),
      ));

      expect(find.text('Zapsat servis'), findsNothing);
    });

    testWidgets('shows warning icon for overdue item', (tester) async {
      await tester.pumpWidget(wrapCard(
        TestableItemCard(
          item: testItem,
          ruleStatuses: [
            (rule: overdueRule, status: MaintenanceStatus.overdue),
          ],
          onTap: () {},
          onLogMaintenance: (_, __) {},
        ),
      ));

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('shows info icon for warning-only item', (tester) async {
      await tester.pumpWidget(wrapCard(
        TestableItemCard(
          item: testItem,
          ruleStatuses: [
            (rule: warningRule, status: MaintenanceStatus.warning),
          ],
          onTap: () {},
          onLogMaintenance: (_, __) {},
        ),
      ));

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });

  group('TestableItemCard – callbacks', () {
    testWidgets('"Zapsat servis" button calls onLogMaintenance with correct gearItem and ruleId', (tester) async {
      GearItem? capturedItem;
      int? capturedRuleId;

      await tester.pumpWidget(wrapCard(
        TestableItemCard(
          item: testItem,
          ruleStatuses: [
            (rule: overdueRule, status: MaintenanceStatus.overdue),
          ],
          onTap: () {},
          onLogMaintenance: (item, ruleId) {
            capturedItem = item;
            capturedRuleId = ruleId;
          },
        ),
      ));

      await tester.tap(find.text('Zapsat servis'));
      await tester.pump();

      expect(capturedItem, isNotNull);
      expect(capturedItem!.id, 1);
      expect(capturedRuleId, 42); // overdueRule.id
    });

    testWidgets('onTap is called when card body is tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(wrapCard(
        TestableItemCard(
          item: testItem,
          ruleStatuses: [
            (rule: overdueRule, status: MaintenanceStatus.overdue),
          ],
          onTap: () => tapped = true,
          onLogMaintenance: (_, __) {},
        ),
      ));

      // Tap the gear name (within the InkWell)
      await tester.tap(find.text('Mammut Lano'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('tapping "Zapsat servis" does NOT trigger onTap of the card', (tester) async {
      bool cardTapped = false;

      await tester.pumpWidget(wrapCard(
        TestableItemCard(
          item: testItem,
          ruleStatuses: [
            (rule: overdueRule, status: MaintenanceStatus.overdue),
          ],
          onTap: () => cardTapped = true,
          onLogMaintenance: (_, __) {},
        ),
      ));

      await tester.tap(find.text('Zapsat servis'));
      await tester.pump();

      // The TextButton absorbs the tap; the card's InkWell should NOT fire
      expect(cardTapped, isFalse);
    });
  });
}

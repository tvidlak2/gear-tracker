/// Service for updating the Android home screen widget.
library;

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../database/database_helper.dart';
import '../models/gear_item.dart';
import 'maintenance_service.dart';

const _kAppGroupId = 'com.geartracker.widget';

class WidgetService {
  WidgetService._();
  static final WidgetService instance = WidgetService._();

  /// Call once on app start.
  Future<void> init() async {
    if (kIsWeb) return;
    await HomeWidget.setAppGroupId(_kAppGroupId);
    await HomeWidget.registerInteractivityCallback(backgroundCallback);
  }

  /// Update widget data from DB and request redraw.
  Future<void> updateWidget() async {
    if (kIsWeb) return;
    try {
      final stats = await _getMaintenanceStats();

      await HomeWidget.saveWidgetData<int>('overdue_count', stats.overdueCount);
      await HomeWidget.saveWidgetData<int>('upcoming_count', stats.upcomingCount);
      await HomeWidget.saveWidgetData<String>('urgent_items_json', stats.urgentItemsJson);
      await HomeWidget.saveWidgetData<String>(
          'last_updated', DateTime.now().toIso8601String());

      await HomeWidget.updateWidget(androidName: 'GearWidgetSmallProvider');
      await HomeWidget.updateWidget(androidName: 'GearWidgetMediumProvider');
    } catch (e) {
      debugPrint('WidgetService.updateWidget error: $e');
    }
  }

  Future<_WidgetStats> _getMaintenanceStats() async {
    int overdueCount = 0;
    int upcomingCount = 0;
    final urgentItems = <Map<String, String>>[];

    try {
      final svc = MaintenanceService(db: DatabaseHelper.instance);

      // Only active gear items
      final gearItems = await DatabaseHelper.instance
          .getGearItems(status: GearStatus.active);

      for (final gear in gearItems) {
        final gearId = gear.id!;
        final gearName = gear.name;

        final results = await svc.getStatusForItem(gearId);

        for (final result in results) {
          if (result.status == MaintenanceStatus.overdue) {
            overdueCount++;
            if (urgentItems.length < 3) {
              urgentItems.add({
                'gear': gearName,
                'task': result.rule.name,
                'status': 'overdue',
              });
            }
          } else if (result.status == MaintenanceStatus.warning) {
            upcomingCount++;
            if (urgentItems.length < 3) {
              urgentItems.add({
                'gear': gearName,
                'task': result.rule.name,
                'status': 'upcoming',
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('WidgetService._getMaintenanceStats error: $e');
    }

    final buffer = StringBuffer('[');
    for (int i = 0; i < urgentItems.length; i++) {
      final item = urgentItems[i];
      if (i > 0) buffer.write(',');
      buffer.write(
          '{"gear":"${_escJson(item['gear']!)}","task":"${_escJson(item['task']!)}","status":"${item['status']}"}');
    }
    buffer.write(']');

    return _WidgetStats(
      overdueCount: overdueCount,
      upcomingCount: upcomingCount,
      urgentItemsJson: buffer.toString(),
    );
  }

  static String _escJson(String s) =>
      s.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', ' ');
}

class _WidgetStats {
  final int overdueCount;
  final int upcomingCount;
  final String urgentItemsJson;

  const _WidgetStats({
    required this.overdueCount,
    required this.upcomingCount,
    required this.urgentItemsJson,
  });
}

/// Top-level callback for background widget interactions (required by home_widget).
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  // Widget tap is handled via PendingIntent on Android (HomeWidgetLaunchIntent).
}

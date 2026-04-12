/// Native implementace notifikací (Android / iOS / Desktop).
/// Používá flutter_local_notifications + timezone pro přesné plánování.
library;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../database/database_helper.dart';
import '../models/maintenance_rule.dart';
import '../models/trip.dart';
import 'maintenance_service.dart';

// ─── Konstanty ──────────────────────────────────────────────────────────────

const _kEnabledKey = 'notifications_enabled';

const _kChannelId = 'gear_maintenance';
const _kChannelName = 'Připomínky údržby';
const _kChannelDesc = 'Upozornění na termíny servisu a péče o vybavení';

// ─── Service ─────────────────────────────────────────────────────────────────

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get platformSupported => true;

  // ── Inicializace ───────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    // Nastav lokální timezone pro zonedSchedule
    tz_data.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    // flutter_timezone 5.x returns a TimezoneInfo object; .identifier holds
    // the IANA string (e.g. "Europe/Prague") that tz.getLocation() expects.
    tz.setLocalLocation(tz.getLocation(localTz.identifier));

    // Inicializuj plugin pro každou platformu
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
    );

    // Vytvoř notifikační kanál (Android 8+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _kChannelId,
            _kChannelName,
            description: _kChannelDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );

    _initialized = true;
  }

  // ── Oprávnění ──────────────────────────────────────────────────────────────

  /// Vyžádá POST_NOTIFICATIONS oprávnění (Android 13+ / iOS).
  /// Vrátí true pokud bylo uděleno nebo není potřeba.
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? granted = await android?.requestNotificationsPermission();
    if (granted != null) return granted;

    // iOS / macOS
    final darwin = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    final bool? iosGranted = await darwin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return iosGranted ?? true;
  }

  // ── Uložení stavu ──────────────────────────────────────────────────────────

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabledKey) ?? true; // výchozí: zapnuto
  }

  Future<void> setEnabled({required bool value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabledKey, value);
    if (value) {
      await scheduleAll();
    } else {
      await cancelAll();
    }
  }

  // ── Naplánování všech notifikací ──────────────────────────────────────────

  /// Projde všechna pravidla údržby v DB a naplánuje / zobrazí notifikace.
  ///
  /// Logika pro pravidla s trigger_type = 'date':
  ///   - next_due_date v minulosti            → okamžitá notifikace "po termínu"
  ///   - today >= next_due_date – warning_before → okamžitá notifikace "blíží se"
  ///   - next_due_date – warning_before v budoucnu → naplánuj na ten den
  ///
  /// Logika pro usage-based pravidla (hodiny / km / počet):
  ///   - stav overdue / warning               → okamžitá notifikace
  ///   - stav ok                              → žádná notifikace (nelze plánovat)
  Future<void> scheduleAll() async {
    try {
      await _scheduleAllInternal();
    } catch (e) {
      debugPrint('NotificationService.scheduleAll failed (non-fatal): $e');
    }
  }

  Future<void> _scheduleAllInternal() async {
    if (!await isEnabled()) return;
    if (!_initialized) await init();

    // Zruš staré notifikace, aby nedošlo k duplicitám
    await _plugin.cancelAll();

    final db = DatabaseHelper.instance;
    final svc = MaintenanceService();
    final gearItems = await db.getGearItems();
    final now = DateTime.now();

    for (final item in gearItems) {
      if (item.id == null) continue;

      final results = await svc.getStatusForItem(item.id!);

      for (final result in results) {
        final rule = result.rule;
        if (rule.id == null) continue;

        final notifId = rule.id!; // SQLite autoincrement → unikátní int
        final gearName = item.name;
        final ruleName = rule.name;
        final critical = rule.isSafetyCritical;

        if (rule.triggerType == TriggerType.date) {
          // Vypočti next_due_date stejně jako MaintenanceService
          final lastLog = await db.getLastMaintenanceLog(item.id!, rule.id!);
          final baseDate = lastLog?.performedDate ??
              now.subtract(Duration(days: rule.triggerValue.toInt()));
          final nextDue =
              baseDate.add(Duration(days: rule.triggerValue.toInt()));
          final warningDate =
              nextDue.subtract(Duration(days: rule.warningBefore.toInt()));

          if (nextDue.isBefore(now)) {
            // Overdue → okamžitá notifikace
            final overdueDays = now.difference(nextDue).inDays;
            await _showNow(
              id: notifId,
              title: '🔴 Servis po termínu: $gearName',
              body: '$ruleName – $overdueDays ${_days(overdueDays)} po termínu',
              critical: critical,
            );
          } else if (!warningDate.isAfter(now)) {
            // V okně varování → okamžitá notifikace
            final daysLeft = nextDue.difference(now).inDays;
            await _showNow(
              id: notifId,
              title: '🟡 Blíží se servis: $gearName',
              body: '$ruleName – za $daysLeft ${_days(daysLeft)}',
              critical: critical,
            );
          } else if (rule.warningBefore > 0) {
            // Ještě daleko → naplánuj na den varování
            await _scheduleAt(
              id: notifId,
              title: '🟡 Blíží se servis: $gearName',
              body: '$ruleName – za ${rule.warningBefore.toInt()} ${_days(rule.warningBefore.toInt())}',
              scheduledDate: warningDate,
              critical: critical,
            );
          }
        } else {
          // Usage-based: okamžitá notifikace pokud overdue nebo warning
          switch (result.status) {
            case MaintenanceStatus.overdue:
              await _showNow(
                id: notifId,
                title: '🔴 Servis po termínu: $gearName',
                body: '$ruleName – limit byl překročen',
                critical: critical,
              );
            case MaintenanceStatus.warning:
              await _showNow(
                id: notifId,
                title: '🟡 Blíží se servis: $gearName',
                body: ruleName,
                critical: critical,
              );
            case MaintenanceStatus.ok:
              break;
          }
        }
      }
    }
  }

  /// Zruší všechny naplánované i zobrazené notifikace.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── Trip reminders ────────────────────────────────────────────────────────

  /// Schedule a notification 3 days before trip departure.
  Future<void> scheduleTripReminder(Trip trip) async {
    if (trip.departureDate == null) return;
    try {
      if (!_initialized) await init();
      final reminderDate =
          trip.departureDate!.subtract(const Duration(days: 3));
      if (reminderDate.isBefore(DateTime.now())) return;

      final scheduledDateTime = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        9,
        0,
      );

      await _scheduleAt(
        id: trip.id.hashCode.abs() % 100000 + 900000,
        title: 'Připomínka výletu: ${trip.name}',
        body: 'Za 3 dny odjíždíš! Nezapomeň zkontrolovat vybavení.',
        scheduledDate: scheduledDateTime,
      );
    } catch (e) {
      debugPrint('scheduleTripReminder failed (non-fatal): $e');
    }
  }

  /// Cancel a trip reminder by trip id.
  Future<void> cancelTripReminder(String tripId) async {
    try {
      final notifId = tripId.hashCode.abs() % 100000 + 900000;
      await _plugin.cancel(notifId);
    } catch (e) {
      debugPrint('cancelTripReminder failed (non-fatal): $e');
    }
  }

  // ── Privátní pomocné metody ───────────────────────────────────────────────

  Future<void> _showNow({
    required int id,
    required String title,
    required String body,
    bool critical = false,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      _details(critical: critical),
    );
  }

  Future<void> _scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool critical = false,
  }) async {
    // Pokud je datum v minulosti (např. kvůli časové zóně), přeskoč
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final details = _details(critical: critical);

    try {
      // Prefer exact scheduling for reliability
      await _plugin.zonedSchedule(
        id, title, body, tzDate, details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException catch (e) {
      // Android 12+ may throw if SCHEDULE_EXACT_ALARM is not granted by user.
      // Fall back to inexact alarm – still fires, just not at the precise time.
      if (e.code == 'exact_alarms_not_permitted' ||
          (e.message ?? '').contains('exact')) {
        debugPrint(
            'Exact alarms not permitted, falling back to inexact for id=$id');
        try {
          await _plugin.zonedSchedule(
            id, title, body, tzDate, details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (e2) {
          debugPrint('Inexact schedule also failed for id=$id: $e2');
        }
      } else {
        debugPrint('zonedSchedule failed for id=$id: $e');
      }
    }
  }

  NotificationDetails _details({bool critical = false}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _kChannelId,
        _kChannelName,
        channelDescription: _kChannelDesc,
        importance: critical ? Importance.max : Importance.high,
        priority: critical ? Priority.max : Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: const DefaultStyleInformation(true, true),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: critical
            ? InterruptionLevel.critical
            : InterruptionLevel.active,
      ),
    );
  }

  /// Správná česká koncovka pro "den / dny / dní".
  static String _days(int n) {
    if (n == 1) return 'den';
    if (n >= 2 && n <= 4) return 'dny';
    return 'dní';
  }
}

/// Web stub – flutter_local_notifications nepodporuje web.
/// Veškerá logika notifikací je zde no-op; toggle se ukládá do SharedPreferences
/// (localStorage na webu) pro konzistentní UX v nastavení.
library;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/trip.dart';

const _kEnabledKey = 'notifications_enabled';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// Na webu notifikace nejsou podporovány – vždy vrací false.
  bool get platformSupported => false;

  Future<void> init() async {
    // no-op
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabledKey) ?? false;
  }

  Future<void> setEnabled({required bool value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabledKey, value);
    // Na webu nemůžeme nic naplánovat, ale stav uložíme.
  }

  /// Vrátí false – na webu nejde žádat o oprávnění přes flutter_local_notifications.
  Future<bool> requestPermission() async => false;

  Future<void> scheduleAll() async {
    // no-op
  }

  Future<void> cancelAll() async {
    // no-op
  }

  Future<void> scheduleTripReminder(Trip trip) async {
    // no-op on web
  }

  Future<void> cancelTripReminder(String tripId) async {
    // no-op on web
  }
}

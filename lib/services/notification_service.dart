/// Conditional-import dispatcher pro platformní inicializaci notifikací.
///
/// Dart vybere v compile-time:
///   - web (dart.library.html)  → notification_service_web.dart  (no-op stub)
///   - Android / iOS / Desktop  → notification_service_native.dart
///
/// Oba soubory exportují stejnou třídu [NotificationService].
export 'notification_service_native.dart'
    if (dart.library.html) 'notification_service_web.dart';

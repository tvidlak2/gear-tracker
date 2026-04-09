/// Dispatcher pro platformně specifickou inicializaci SQLite.
///
/// Dart conditional imports vyberou správnou implementaci v compile time:
///   - web  → db_factory_web.dart    (sqflite_common_ffi_web)
///   - I/O  → db_factory_native.dart (standardní sqflite, není třeba nic dělat)
export 'db_factory_native.dart'
    if (dart.library.html) 'db_factory_web.dart';

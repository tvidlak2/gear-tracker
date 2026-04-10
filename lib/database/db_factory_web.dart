import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

/// Inicializuje sqflite pro web pomocí WASM SQLite3.
/// Volat jednou před prvním otevřením databáze.
Future<void> initDatabaseFactory() async {
  databaseFactory = databaseFactoryFfiWeb;
}

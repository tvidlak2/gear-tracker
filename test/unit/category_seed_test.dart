// Testy resilientního seedu kategorií (DatabaseHelper).
//
// DatabaseHelper potřebuje skutečnou SQLite — na host VM (flutter test)
// ji poskytuje sqflite_common_ffi. Každý test startuje na čisté DB.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:outdoor_gear_tracker/database/database_helper.dart';
import 'package:outdoor_gear_tracker/models/category.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Čistá DB pro každý test — resetDatabase smaže soubor a re-triggeruje
    // onCreate (schéma + seed 12 výchozích kategorií).
    await DatabaseHelper.instance.resetDatabase();
  });

  group('reseedCategories', () {
    test('force: true vymaže existující a nahraje výchozí kategorie', () async {
      final db = DatabaseHelper.instance;
      await db.insertCategory(
          const Category(name: 'Vlastní X', icon: 'star', sport: 'test'));
      expect((await db.getCategories()).length, 13);

      final result = await db.reseedCategories(force: true);
      expect(result.inserted, 12);
      expect(result.failed, 0);

      final after = await db.getCategories();
      expect(after.length, 12);
      expect(after.any((c) => c.name == 'Vlastní X'), isFalse);
    });

    test('force: false je no-op když kategorie existují', () async {
      final db = DatabaseHelper.instance;
      final result = await db.reseedCategories(force: false);
      expect(result.inserted, 0);
      expect(result.failed, 0);
      expect((await db.getCategories()).length, 12);
    });
  });

  group('ensureCategoriesSeeded', () {
    test('po prázdné DB doplní výchozí kategorie', () async {
      final db = DatabaseHelper.instance;
      final raw = await db.database;
      await raw.delete('categories');
      expect((await db.getCategories()).length, 0);

      final result = await db.ensureCategoriesSeeded();
      expect(result.inserted, 12);

      expect((await db.getCategories()).length, 12);
    });

    test('je no-op když kategorie už existují', () async {
      final db = DatabaseHelper.instance;
      final result = await db.ensureCategoriesSeeded();
      expect(result.inserted, 0);
      expect((await db.getCategories()).length, 12);
    });
  });
}

import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/category.dart';
import '../models/gear_item.dart';
import '../models/maintenance_log.dart';
import '../models/maintenance_rule.dart';
import '../models/strava_models.dart';
import '../models/usage_log.dart';

class DatabaseHelper {
  static const _databaseName = 'gear_tracker.db';
  static const _databaseVersion = 3;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add strava_activity_id to usage_logs
      await db.execute(
        'ALTER TABLE usage_logs ADD COLUMN strava_activity_id TEXT',
      );
      // Create gear_strava_settings table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS gear_strava_settings (
          gear_item_id   INTEGER PRIMARY KEY REFERENCES gear_items(id) ON DELETE CASCADE,
          activity_types TEXT    NOT NULL DEFAULT '[]',
          sync_enabled   INTEGER NOT NULL DEFAULT 0,
          sync_from      TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      // Add elevation_gain column to usage_logs (metres, nullable)
      await db.execute(
        'ALTER TABLE usage_logs ADD COLUMN elevation_gain REAL',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT NOT NULL,
        icon     TEXT NOT NULL,
        sport    TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE gear_items (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        name              TEXT    NOT NULL,
        category_id       INTEGER NOT NULL REFERENCES categories(id),
        brand             TEXT,
        model             TEXT,
        serial_number     TEXT,
        manufactured_date TEXT,
        purchase_date     TEXT,
        status            TEXT    NOT NULL DEFAULT 'active',
        notes             TEXT,
        photo_path        TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_rules (
        id                 INTEGER PRIMARY KEY AUTOINCREMENT,
        gear_item_id       INTEGER NOT NULL REFERENCES gear_items(id) ON DELETE CASCADE,
        name               TEXT    NOT NULL,
        trigger_type       TEXT    NOT NULL,
        trigger_value      REAL    NOT NULL,
        warning_before     REAL    NOT NULL DEFAULT 0,
        is_safety_critical INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_logs (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        gear_item_id   INTEGER NOT NULL REFERENCES gear_items(id) ON DELETE CASCADE,
        rule_id        INTEGER REFERENCES maintenance_rules(id) ON DELETE SET NULL,
        performed_date TEXT    NOT NULL,
        performed_by   TEXT,
        cost           REAL,
        notes          TEXT,
        next_due_date  TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE usage_logs (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        gear_item_id        INTEGER NOT NULL REFERENCES gear_items(id) ON DELETE CASCADE,
        date                TEXT    NOT NULL,
        duration_minutes    INTEGER,
        distance_km         REAL,
        elevation_gain      REAL,
        location            TEXT,
        source              TEXT    NOT NULL DEFAULT 'manual',
        strava_activity_id  TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE gear_strava_settings (
        gear_item_id   INTEGER PRIMARY KEY REFERENCES gear_items(id) ON DELETE CASCADE,
        activity_types TEXT    NOT NULL DEFAULT '[]',
        sync_enabled   INTEGER NOT NULL DEFAULT 0,
        sync_from      TEXT
      )
    ''');

    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaults = [
      {'name': 'Lano', 'icon': 'rope', 'sport': 'lezení'},
      {'name': 'Úvazek', 'icon': 'harness', 'sport': 'lezení'},
      {'name': 'Přilba', 'icon': 'helmet', 'sport': 'lezení'},
      {'name': 'Jistítko', 'icon': 'belay', 'sport': 'lezení'},
      {'name': 'Karabina', 'icon': 'carabiner', 'sport': 'lezení'},
      {'name': 'Cepín', 'icon': 'ice_axe', 'sport': 'skialpinismus'},
      {'name': 'Mačky', 'icon': 'crampons', 'sport': 'skialpinismus'},
      {'name': 'Lyže', 'icon': 'skis', 'sport': 'skialpinismus'},
      {'name': 'Batoh', 'icon': 'backpack', 'sport': 'obecné'},
      {'name': 'Stan', 'icon': 'tent', 'sport': 'obecné'},
      {'name': 'Spacák', 'icon': 'sleeping_bag', 'sport': 'obecné'},
      {'name': 'Kolo', 'icon': 'bike', 'sport': 'cyklistika'},
    ];
    for (final cat in defaults) {
      await db.insert('categories', cat);
    }
  }

  // ───────────────────────────── CATEGORIES ──────────────────────────────

  Future<List<Category>> getCategories() async {
    final db = await database;
    final rows = await db.query('categories', orderBy: 'sport, name');
    return rows.map(Category.fromMap).toList();
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final rows = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Category.fromMap(rows.first);
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return db.insert('categories', category.toMap());
  }

  // ───────────────────────────── GEAR ITEMS ──────────────────────────────

  Future<List<GearItem>> getGearItems({int? categoryId, GearStatus? status}) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (categoryId != null) {
      conditions.add('category_id = ?');
      args.add(categoryId);
    }
    if (status != null) {
      conditions.add('status = ?');
      args.add(status.value);
    }

    final rows = await db.query(
      'gear_items',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'name',
    );
    return rows.map(GearItem.fromMap).toList();
  }

  Future<GearItem?> getGearItemById(int id) async {
    final db = await database;
    final rows = await db.query('gear_items', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return GearItem.fromMap(rows.first);
  }

  Future<int> insertGearItem(GearItem item) async {
    final db = await database;
    return db.insert('gear_items', item.toMap());
  }

  Future<int> updateGearItem(GearItem item) async {
    final db = await database;
    return db.update(
      'gear_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteGearItem(int id) async {
    final db = await database;
    return db.delete('gear_items', where: 'id = ?', whereArgs: [id]);
  }

  // ────────────────────────── MAINTENANCE RULES ──────────────────────────

  Future<List<MaintenanceRule>> getRulesForItem(int gearItemId) async {
    final db = await database;
    final rows = await db.query(
      'maintenance_rules',
      where: 'gear_item_id = ?',
      whereArgs: [gearItemId],
    );
    return rows.map(MaintenanceRule.fromMap).toList();
  }

  Future<int> insertMaintenanceRule(MaintenanceRule rule) async {
    final db = await database;
    return db.insert('maintenance_rules', rule.toMap());
  }

  Future<int> updateMaintenanceRule(MaintenanceRule rule) async {
    final db = await database;
    return db.update(
      'maintenance_rules',
      rule.toMap(),
      where: 'id = ?',
      whereArgs: [rule.id],
    );
  }

  Future<int> deleteMaintenanceRule(int id) async {
    final db = await database;
    return db.delete('maintenance_rules', where: 'id = ?', whereArgs: [id]);
  }

  // ────────────────────────── MAINTENANCE LOGS ───────────────────────────

  Future<List<MaintenanceLog>> getMaintenanceLogs({
    int? gearItemId,
    int? ruleId,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (gearItemId != null) {
      conditions.add('gear_item_id = ?');
      args.add(gearItemId);
    }
    if (ruleId != null) {
      conditions.add('rule_id = ?');
      args.add(ruleId);
    }

    final rows = await db.query(
      'maintenance_logs',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'performed_date DESC',
    );
    return rows.map(MaintenanceLog.fromMap).toList();
  }

  Future<MaintenanceLog?> getLastMaintenanceLog(int gearItemId, int ruleId) async {
    final db = await database;
    final rows = await db.query(
      'maintenance_logs',
      where: 'gear_item_id = ? AND rule_id = ?',
      whereArgs: [gearItemId, ruleId],
      orderBy: 'performed_date DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MaintenanceLog.fromMap(rows.first);
  }

  Future<int> insertMaintenanceLog(MaintenanceLog log) async {
    final db = await database;
    return db.insert('maintenance_logs', log.toMap());
  }

  Future<int> updateMaintenanceLog(MaintenanceLog log) async {
    final db = await database;
    return db.update(
      'maintenance_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<int> deleteMaintenanceLog(int id) async {
    final db = await database;
    return db.delete('maintenance_logs', where: 'id = ?', whereArgs: [id]);
  }

  // ────────────────────────────── USAGE LOGS ─────────────────────────────

  Future<List<UsageLog>> getUsageLogs({int? gearItemId}) async {
    final db = await database;
    final rows = await db.query(
      'usage_logs',
      where: gearItemId != null ? 'gear_item_id = ?' : null,
      whereArgs: gearItemId != null ? [gearItemId] : null,
      orderBy: 'date DESC',
    );
    return rows.map(UsageLog.fromMap).toList();
  }

  /// Součet minut používání pro daný gear item
  Future<int> getTotalDurationMinutes(int gearItemId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(duration_minutes), 0) AS total FROM usage_logs WHERE gear_item_id = ?',
      [gearItemId],
    );
    return (result.first['total'] as num).toInt();
  }

  /// Součet kilometrů pro daný gear item
  Future<double> getTotalDistanceKm(int gearItemId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(distance_km), 0) AS total FROM usage_logs WHERE gear_item_id = ?',
      [gearItemId],
    );
    return (result.first['total'] as num).toDouble();
  }

  /// Počet použití pro daný gear item
  Future<int> getUsageCount(int gearItemId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM usage_logs WHERE gear_item_id = ?',
      [gearItemId],
    );
    return (result.first['cnt'] as num).toInt();
  }

  Future<int> insertUsageLog(UsageLog log) async {
    final db = await database;
    return db.insert('usage_logs', log.toMap());
  }

  Future<int> updateUsageLog(UsageLog log) async {
    final db = await database;
    return db.update(
      'usage_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<int> deleteUsageLog(int id) async {
    final db = await database;
    return db.delete('usage_logs', where: 'id = ?', whereArgs: [id]);
  }

  /// Total number of usage logs that came from Strava (across all gear items).
  Future<int> getTotalStravaActivityCount() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) AS cnt FROM usage_logs WHERE source = 'strava'",
    );
    return (result.first['cnt'] as num).toInt();
  }

  // ────────────────────────── STRAVA SETTINGS ────────────────────────────────

  Future<GearStravaSettings?> getGearStravaSettings(int gearItemId) async {
    final db = await database;
    final rows = await db.query(
      'gear_strava_settings',
      where: 'gear_item_id = ?',
      whereArgs: [gearItemId],
    );
    if (rows.isEmpty) return null;
    return _stravaSettingsFromRow(rows.first);
  }

  Future<void> upsertGearStravaSettings(GearStravaSettings settings) async {
    final db = await database;
    await db.insert(
      'gear_strava_settings',
      {
        'gear_item_id':   settings.gearItemId,
        'activity_types': jsonEncode(settings.activityTypes),
        'sync_enabled':   settings.syncEnabled ? 1 : 0,
        'sync_from':      settings.syncFrom?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns the set of strava_activity_id values already stored for this gear.
  Future<Set<String>> getStravaActivityIds(int gearItemId) async {
    final db = await database;
    final rows = await db.query(
      'usage_logs',
      columns: ['strava_activity_id'],
      where: 'gear_item_id = ? AND strava_activity_id IS NOT NULL',
      whereArgs: [gearItemId],
    );
    return rows
        .map((r) => r['strava_activity_id'] as String)
        .toSet();
  }

  /// Returns gear items that have Strava sync enabled.
  Future<List<GearItem>> getGearItemsWithStravaSync() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT gi.* FROM gear_items gi
      INNER JOIN gear_strava_settings gss ON gss.gear_item_id = gi.id
      WHERE gss.sync_enabled = 1
    ''');
    return rows.map(GearItem.fromMap).toList();
  }

  static GearStravaSettings _stravaSettingsFromRow(Map<String, dynamic> row) {
    final typesJson = row['activity_types'] as String? ?? '[]';
    final typesList = (jsonDecode(typesJson) as List<dynamic>)
        .map((e) => e as String)
        .toList();
    return GearStravaSettings(
      gearItemId:    row['gear_item_id'] as int,
      activityTypes: typesList,
      syncEnabled:   (row['sync_enabled'] as int) == 1,
      syncFrom:      row['sync_from'] != null
          ? DateTime.tryParse(row['sync_from'] as String)
          : null,
    );
  }
}

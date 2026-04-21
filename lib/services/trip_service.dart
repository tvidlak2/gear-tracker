import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../database/database_helper.dart';
import '../models/trip.dart';

class TripService {
  TripService._();
  static final TripService instance = TripService._();

  Future<List<Trip>> getAllTrips() async {
    final db = await DatabaseHelper.instance.database;
    final trips = await db.query('trips', orderBy: 'departure_date ASC');
    final result = <Trip>[];
    for (final t in trips) {
      final gearRows = await db.query(
        'trip_gear_items',
        where: 'trip_id = ?',
        whereArgs: [t['id']],
      );
      result.add(Trip.fromMap(
        t,
        gearItems: gearRows.map(TripGearItem.fromMap).toList(),
      ));
    }
    return result;
  }

  Future<Trip?> getTripById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('trips', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final gearRows = await db.query(
      'trip_gear_items',
      where: 'trip_id = ?',
      whereArgs: [id],
    );
    return Trip.fromMap(
      rows.first,
      gearItems: gearRows.map(TripGearItem.fromMap).toList(),
    );
  }

  Future<void> saveTrip(Trip trip) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'trips',
      trip.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.delete(
      'trip_gear_items',
      where: 'trip_id = ?',
      whereArgs: [trip.id],
    );
    for (final g in trip.gearItems) {
      await db.insert('trip_gear_items', {'trip_id': trip.id, ...g.toMap()});
    }
  }

  Future<void> deleteTrip(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('trips', where: 'id = ?', whereArgs: [id]);
    await db.delete(
      'trip_gear_items',
      where: 'trip_id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateGearPackedState(
    String tripId,
    String gearItemId,
    bool isPacked,
  ) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'trip_gear_items',
      {'is_packed': isPacked ? 1 : 0},
      where: 'trip_id = ? AND gear_item_id = ?',
      whereArgs: [tripId, gearItemId],
    );
  }

  // ── Custom items ─────────────────────────────────────────────────────────────

  Future<List<TripCustomItem>> getCustomItems(String tripId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'trip_custom_items',
      where: 'trip_id = ?',
      whereArgs: [tripId],
    );
    return rows.map(TripCustomItem.fromMap).toList();
  }

  Future<TripCustomItem> addCustomItem(String tripId, String name) async {
    final db = await DatabaseHelper.instance.database;
    final item = TripCustomItem(
      id: const Uuid().v4(),
      tripId: tripId,
      name: name,
    );
    await db.insert('trip_custom_items', item.toMap());
    return item;
  }

  Future<void> deleteCustomItem(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('trip_custom_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateCustomItemPacked(String id, bool isPacked) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'trip_custom_items',
      {'is_packed': isPacked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

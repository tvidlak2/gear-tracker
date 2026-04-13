import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/insurance.dart';

class InsuranceService {
  InsuranceService._();
  static final InsuranceService instance = InsuranceService._();

  Future<List<Insurance>> getAllInsurances() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query('insurances', orderBy: 'expiry_date ASC');
      return maps.map(Insurance.fromMap).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Insurance> saveInsurance(Insurance insurance) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'insurances',
      insurance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return insurance;
  }

  Future<void> deleteInsurance(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('insurances', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Insurance>> getInsurancesForGear(String gearId) async {
    final all = await getAllInsurances();
    return all.where((ins) => ins.gearItemIds.contains(gearId)).toList();
  }

  /// Returns insurances expiring within [days] days (not yet expired).
  Future<List<Insurance>> getExpiringInsurances({int days = 60}) async {
    final all = await getAllInsurances();
    final now = DateTime.now();
    final cutoff = now.add(Duration(days: days));
    return all
        .where(
          (ins) =>
              ins.expiryDate.isAfter(now) && ins.expiryDate.isBefore(cutoff),
        )
        .toList();
  }
}

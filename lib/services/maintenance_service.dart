import '../database/database_helper.dart';
import '../models/maintenance_rule.dart';
import '../models/maintenance_log.dart';

enum MaintenanceStatus { ok, warning, overdue }

class MaintenanceStatusResult {
  final MaintenanceRule rule;
  final MaintenanceStatus status;
  /// Jak daleko jsme od triggeru (záporné = překročeno)
  final double remaining;
  final DateTime? nextDueDate;

  const MaintenanceStatusResult({
    required this.rule,
    required this.status,
    required this.remaining,
    this.nextDueDate,
  });
}

class MaintenanceService {
  final DatabaseHelper _db;

  MaintenanceService({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  /// Vrátí stav údržby pro všechna pravidla daného vybavení.
  Future<List<MaintenanceStatusResult>> getStatusForItem(int gearItemId) async {
    final rules = await _db.getRulesForItem(gearItemId);
    final results = <MaintenanceStatusResult>[];

    for (final rule in rules) {
      final result = await _evaluateRule(gearItemId, rule);
      results.add(result);
    }

    // Bezpečnostně kritická pravidla na začátek, pak podle stavu
    results.sort((a, b) {
      if (a.rule.isSafetyCritical != b.rule.isSafetyCritical) {
        return a.rule.isSafetyCritical ? -1 : 1;
      }
      return a.status.index.compareTo(b.status.index);
    });

    return results;
  }

  /// Vrátí nejhorší stav ze všech pravidel (pro badge na kartičce).
  Future<MaintenanceStatus> getWorstStatusForItem(int gearItemId) async {
    final results = await getStatusForItem(gearItemId);
    if (results.isEmpty) return MaintenanceStatus.ok;

    if (results.any((r) => r.status == MaintenanceStatus.overdue)) {
      return MaintenanceStatus.overdue;
    }
    if (results.any((r) => r.status == MaintenanceStatus.warning)) {
      return MaintenanceStatus.warning;
    }
    return MaintenanceStatus.ok;
  }

  Future<MaintenanceStatusResult> _evaluateRule(
    int gearItemId,
    MaintenanceRule rule,
  ) async {
    final lastLog = await _db.getLastMaintenanceLog(gearItemId, rule.id!);

    switch (rule.triggerType) {
      case TriggerType.date:
        return _evaluateDateRule(rule, lastLog);
      case TriggerType.usageHours:
        return _evaluateUsageHoursRule(gearItemId, rule, lastLog);
      case TriggerType.usageDistance:
        return _evaluateUsageDistanceRule(gearItemId, rule, lastLog);
      case TriggerType.usageCount:
        return _evaluateUsageCountRule(gearItemId, rule, lastLog);
    }
  }

  MaintenanceStatusResult _evaluateDateRule(
    MaintenanceRule rule,
    MaintenanceLog? lastLog,
  ) {
    final now = DateTime.now();
    final baseDate = lastLog?.performedDate ?? now.subtract(Duration(days: rule.triggerValue.toInt()));
    final nextDue = baseDate.add(Duration(days: rule.triggerValue.toInt()));
    final daysRemaining = nextDue.difference(now).inDays.toDouble();

    return MaintenanceStatusResult(
      rule: rule,
      status: _resolveStatus(daysRemaining, rule.warningBefore),
      remaining: daysRemaining,
      nextDueDate: nextDue,
    );
  }

  Future<MaintenanceStatusResult> _evaluateUsageHoursRule(
    int gearItemId,
    MaintenanceRule rule,
    MaintenanceLog? lastLog,
  ) async {
    final totalMinutes = await _db.getTotalDurationMinutes(gearItemId);
    final usedSinceLastService = lastLog != null
        ? await _usedMinutesSince(gearItemId, lastLog.performedDate)
        : totalMinutes.toDouble();
    final usedHours = usedSinceLastService / 60.0;
    final remaining = rule.triggerValue - usedHours;

    return MaintenanceStatusResult(
      rule: rule,
      status: _resolveStatus(remaining, rule.warningBefore),
      remaining: remaining,
    );
  }

  Future<MaintenanceStatusResult> _evaluateUsageDistanceRule(
    int gearItemId,
    MaintenanceRule rule,
    MaintenanceLog? lastLog,
  ) async {
    final usedSince = lastLog != null
        ? await _usedDistanceSince(gearItemId, lastLog.performedDate)
        : await _db.getTotalDistanceKm(gearItemId);
    final remaining = rule.triggerValue - usedSince;

    return MaintenanceStatusResult(
      rule: rule,
      status: _resolveStatus(remaining, rule.warningBefore),
      remaining: remaining,
    );
  }

  Future<MaintenanceStatusResult> _evaluateUsageCountRule(
    int gearItemId,
    MaintenanceRule rule,
    MaintenanceLog? lastLog,
  ) async {
    final usedSince = lastLog != null
        ? await _usageCountSince(gearItemId, lastLog.performedDate)
        : await _db.getUsageCount(gearItemId);
    final remaining = rule.triggerValue - usedSince;

    return MaintenanceStatusResult(
      rule: rule,
      status: _resolveStatus(remaining, rule.warningBefore),
      remaining: remaining,
    );
  }

  MaintenanceStatus _resolveStatus(double remaining, double warningBefore) {
    if (remaining <= 0) return MaintenanceStatus.overdue;
    if (remaining <= warningBefore) return MaintenanceStatus.warning;
    return MaintenanceStatus.ok;
  }

  Future<double> _usedMinutesSince(int gearItemId, DateTime since) async {
    final logs = await _db.getUsageLogs(gearItemId: gearItemId);
    return logs
        .where((l) => l.date.isAfter(since))
        .fold<double>(0.0, (sum, l) => sum + (l.durationMinutes?.toDouble() ?? 0.0));
  }

  Future<double> _usedDistanceSince(int gearItemId, DateTime since) async {
    final logs = await _db.getUsageLogs(gearItemId: gearItemId);
    return logs
        .where((l) => l.date.isAfter(since))
        .fold<double>(0.0, (sum, l) => sum + (l.distanceKm ?? 0.0));
  }

  Future<double> _usageCountSince(int gearItemId, DateTime since) async {
    final logs = await _db.getUsageLogs(gearItemId: gearItemId);
    return logs.where((l) => l.date.isAfter(since)).length.toDouble();
  }

  /// Zaznamená provedení údržby a spočítá next_due_date pro pravidla na datum.
  Future<MaintenanceLog> logMaintenance({
    required int gearItemId,
    int? ruleId,
    required DateTime performedDate,
    String? performedBy,
    double? cost,
    String? notes,
  }) async {
    DateTime? nextDueDate;

    if (ruleId != null) {
      final rules = await _db.getRulesForItem(gearItemId);
      final rule = rules.where((r) => r.id == ruleId).firstOrNull;
      if (rule != null && rule.triggerType == TriggerType.date) {
        nextDueDate = performedDate.add(
          Duration(days: rule.triggerValue.toInt()),
        );
      }
    }

    final log = MaintenanceLog(
      gearItemId: gearItemId,
      ruleId: ruleId,
      performedDate: performedDate,
      performedBy: performedBy,
      cost: cost,
      notes: notes,
      nextDueDate: nextDueDate,
    );

    final id = await _db.insertMaintenanceLog(log);
    return log.copyWith(id: id);
  }
}

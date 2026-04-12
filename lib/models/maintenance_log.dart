class MaintenanceLog {
  final int? id;
  final int gearItemId;
  final int? ruleId;
  final DateTime performedDate;
  final String? performedBy;
  final double? cost;
  final String? notes;
  final DateTime? nextDueDate;
  final String? photoPath;

  const MaintenanceLog({
    this.id,
    required this.gearItemId,
    this.ruleId,
    required this.performedDate,
    this.performedBy,
    this.cost,
    this.notes,
    this.nextDueDate,
    this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'gear_item_id': gearItemId,
      'rule_id': ruleId,
      'performed_date': performedDate.toIso8601String(),
      'performed_by': performedBy,
      'cost': cost,
      'notes': notes,
      'next_due_date': nextDueDate?.toIso8601String(),
      'photo_path': photoPath,
    };
  }

  factory MaintenanceLog.fromMap(Map<String, dynamic> map) {
    return MaintenanceLog(
      id: map['id'] as int?,
      gearItemId: map['gear_item_id'] as int,
      ruleId: map['rule_id'] as int?,
      performedDate: DateTime.parse(map['performed_date'] as String),
      performedBy: map['performed_by'] as String?,
      cost: map['cost'] != null ? (map['cost'] as num).toDouble() : null,
      notes: map['notes'] as String?,
      nextDueDate: map['next_due_date'] != null
          ? DateTime.parse(map['next_due_date'] as String)
          : null,
      photoPath: map['photo_path'] as String?,
    );
  }

  MaintenanceLog copyWith({
    int? id,
    int? gearItemId,
    int? ruleId,
    DateTime? performedDate,
    String? performedBy,
    double? cost,
    String? notes,
    DateTime? nextDueDate,
    String? photoPath,
  }) {
    return MaintenanceLog(
      id: id ?? this.id,
      gearItemId: gearItemId ?? this.gearItemId,
      ruleId: ruleId ?? this.ruleId,
      performedDate: performedDate ?? this.performedDate,
      performedBy: performedBy ?? this.performedBy,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  @override
  String toString() =>
      'MaintenanceLog(id: $id, gearItemId: $gearItemId, date: $performedDate)';
}

enum TriggerType { date, usageHours, usageDistance, usageCount }

extension TriggerTypeExtension on TriggerType {
  String get label {
    switch (this) {
      case TriggerType.date:
        return 'Datum';
      case TriggerType.usageHours:
        return 'Hodiny používání';
      case TriggerType.usageDistance:
        return 'Vzdálenost (km)';
      case TriggerType.usageCount:
        return 'Počet použití';
    }
  }

  String get value => name;

  static TriggerType fromString(String value) {
    return TriggerType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TriggerType.date,
    );
  }
}

class MaintenanceRule {
  final int? id;
  final int gearItemId;
  final String name;
  final TriggerType triggerType;
  /// Hodnota triggeru: počet dní (date), hodin (usageHours), km (usageDistance), počet (usageCount)
  final double triggerValue;
  /// Varování X dní / hodin / km před dosažením limitu
  final double warningBefore;
  final bool isSafetyCritical;

  const MaintenanceRule({
    this.id,
    required this.gearItemId,
    required this.name,
    required this.triggerType,
    required this.triggerValue,
    this.warningBefore = 0,
    this.isSafetyCritical = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'gear_item_id': gearItemId,
      'name': name,
      'trigger_type': triggerType.value,
      'trigger_value': triggerValue,
      'warning_before': warningBefore,
      'is_safety_critical': isSafetyCritical ? 1 : 0,
    };
  }

  factory MaintenanceRule.fromMap(Map<String, dynamic> map) {
    return MaintenanceRule(
      id: map['id'] as int?,
      gearItemId: map['gear_item_id'] as int,
      name: map['name'] as String,
      triggerType: TriggerTypeExtension.fromString(
        map['trigger_type'] as String,
      ),
      triggerValue: (map['trigger_value'] as num).toDouble(),
      warningBefore: (map['warning_before'] as num).toDouble(),
      isSafetyCritical: (map['is_safety_critical'] as int) == 1,
    );
  }

  MaintenanceRule copyWith({
    int? id,
    int? gearItemId,
    String? name,
    TriggerType? triggerType,
    double? triggerValue,
    double? warningBefore,
    bool? isSafetyCritical,
  }) {
    return MaintenanceRule(
      id: id ?? this.id,
      gearItemId: gearItemId ?? this.gearItemId,
      name: name ?? this.name,
      triggerType: triggerType ?? this.triggerType,
      triggerValue: triggerValue ?? this.triggerValue,
      warningBefore: warningBefore ?? this.warningBefore,
      isSafetyCritical: isSafetyCritical ?? this.isSafetyCritical,
    );
  }

  @override
  String toString() =>
      'MaintenanceRule(id: $id, name: $name, trigger: ${triggerType.value})';
}

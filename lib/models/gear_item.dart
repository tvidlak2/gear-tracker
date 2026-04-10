enum GearStatus { active, retired, lent, service }

extension GearStatusExtension on GearStatus {
  String get label {
    switch (this) {
      case GearStatus.active:
        return 'Aktivní';
      case GearStatus.retired:
        return 'Vyřazeno';
      case GearStatus.lent:
        return 'Půjčeno';
      case GearStatus.service:
        return 'V servisu';
    }
  }

  String get value => name;

  static GearStatus fromString(String value) {
    return GearStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GearStatus.active,
    );
  }
}

class GearItem {
  final int? id;
  final String name;
  final int categoryId;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final DateTime? manufacturedDate;
  final DateTime? purchaseDate;
  final GearStatus status;
  final String? notes;
  final String? photoPath;

  const GearItem({
    this.id,
    required this.name,
    required this.categoryId,
    this.brand,
    this.model,
    this.serialNumber,
    this.manufacturedDate,
    this.purchaseDate,
    this.status = GearStatus.active,
    this.notes,
    this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category_id': categoryId,
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'manufactured_date': manufacturedDate?.toIso8601String(),
      'purchase_date': purchaseDate?.toIso8601String(),
      'status': status.value,
      'notes': notes,
      'photo_path': photoPath,
    };
  }

  factory GearItem.fromMap(Map<String, dynamic> map) {
    return GearItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      categoryId: map['category_id'] as int,
      brand: map['brand'] as String?,
      model: map['model'] as String?,
      serialNumber: map['serial_number'] as String?,
      manufacturedDate: map['manufactured_date'] != null
          ? DateTime.parse(map['manufactured_date'] as String)
          : null,
      purchaseDate: map['purchase_date'] != null
          ? DateTime.parse(map['purchase_date'] as String)
          : null,
      status: GearStatusExtension.fromString(
        map['status'] as String? ?? 'active',
      ),
      notes: map['notes'] as String?,
      photoPath: map['photo_path'] as String?,
    );
  }

  GearItem copyWith({
    int? id,
    String? name,
    int? categoryId,
    String? brand,
    String? model,
    String? serialNumber,
    DateTime? manufacturedDate,
    DateTime? purchaseDate,
    GearStatus? status,
    String? notes,
    String? photoPath,
  }) {
    return GearItem(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      manufacturedDate: manufacturedDate ?? this.manufacturedDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  @override
  String toString() => 'GearItem(id: $id, name: $name, status: ${status.value})';
}

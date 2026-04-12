import 'package:uuid/uuid.dart';

enum InsuranceType {
  gearInsurance,
  liability,
  accident,
  travel,
  other;

  String get label => switch (this) {
    InsuranceType.gearInsurance => 'Pojištění vybavení',
    InsuranceType.liability     => 'Odpovědnost',
    InsuranceType.accident      => 'Úrazová',
    InsuranceType.travel        => 'Cestovní',
    InsuranceType.other         => 'Jiná',
  };

  String get emoji => switch (this) {
    InsuranceType.gearInsurance => '🎒',
    InsuranceType.liability     => '🛡️',
    InsuranceType.accident      => '🏥',
    InsuranceType.travel        => '✈️',
    InsuranceType.other         => '📄',
  };
}

class Insurance {
  final String id;
  final String name;
  final InsuranceType type;
  final String insuranceCompany;
  final String policyNumber;
  final DateTime startDate;
  final DateTime expiryDate;
  final double? annualPremium;
  final double? coverageAmount;
  final String? notes;
  final String? photoPath;
  final List<String> gearItemIds;

  const Insurance({
    required this.id,
    required this.name,
    required this.type,
    required this.insuranceCompany,
    required this.policyNumber,
    required this.startDate,
    required this.expiryDate,
    this.annualPremium,
    this.coverageAmount,
    this.notes,
    this.photoPath,
    this.gearItemIds = const [],
  });

  factory Insurance.create({
    required String name,
    required InsuranceType type,
    required String insuranceCompany,
    required String policyNumber,
    required DateTime startDate,
    required DateTime expiryDate,
    double? annualPremium,
    double? coverageAmount,
    String? notes,
    String? photoPath,
    List<String>? gearItemIds,
  }) {
    return Insurance(
      id: const Uuid().v4(),
      name: name,
      type: type,
      insuranceCompany: insuranceCompany,
      policyNumber: policyNumber,
      startDate: startDate,
      expiryDate: expiryDate,
      annualPremium: annualPremium,
      coverageAmount: coverageAmount,
      notes: notes,
      photoPath: photoPath,
      gearItemIds: gearItemIds ?? [],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type.name,
    'insurance_company': insuranceCompany,
    'policy_number': policyNumber,
    'start_date': startDate.toIso8601String(),
    'expiry_date': expiryDate.toIso8601String(),
    'annual_premium': annualPremium,
    'coverage_amount': coverageAmount,
    'notes': notes,
    'photo_path': photoPath,
    'gear_item_ids': gearItemIds.join(','),
  };

  factory Insurance.fromMap(Map<String, dynamic> map) => Insurance(
    id: map['id'] as String,
    name: map['name'] as String,
    type: InsuranceType.values.firstWhere(
      (t) => t.name == map['type'],
      orElse: () => InsuranceType.other,
    ),
    insuranceCompany: map['insurance_company'] as String? ?? '',
    policyNumber: map['policy_number'] as String? ?? '',
    startDate: DateTime.parse(map['start_date'] as String),
    expiryDate: DateTime.parse(map['expiry_date'] as String),
    annualPremium: (map['annual_premium'] as num?)?.toDouble(),
    coverageAmount: (map['coverage_amount'] as num?)?.toDouble(),
    notes: map['notes'] as String?,
    photoPath: map['photo_path'] as String?,
    gearItemIds: (map['gear_item_ids'] as String?)
            ?.split(',')
            .where((s) => s.isNotEmpty)
            .toList() ??
        [],
  );

  Insurance copyWith({
    String? name,
    InsuranceType? type,
    String? insuranceCompany,
    String? policyNumber,
    DateTime? startDate,
    DateTime? expiryDate,
    double? annualPremium,
    double? coverageAmount,
    String? notes,
    String? photoPath,
    List<String>? gearItemIds,
  }) =>
      Insurance(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        insuranceCompany: insuranceCompany ?? this.insuranceCompany,
        policyNumber: policyNumber ?? this.policyNumber,
        startDate: startDate ?? this.startDate,
        expiryDate: expiryDate ?? this.expiryDate,
        annualPremium: annualPremium ?? this.annualPremium,
        coverageAmount: coverageAmount ?? this.coverageAmount,
        notes: notes ?? this.notes,
        photoPath: photoPath ?? this.photoPath,
        gearItemIds: gearItemIds ?? this.gearItemIds,
      );
}

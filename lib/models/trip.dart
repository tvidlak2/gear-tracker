import 'package:uuid/uuid.dart';

enum TripStatus {
  planning,
  packing,
  onTrip,
  completed;

  String get label => switch (this) {
        TripStatus.planning  => 'Plánování',
        TripStatus.packing   => 'Balení',
        TripStatus.onTrip    => 'Na výletě',
        TripStatus.completed => 'Dokončeno',
      };

  String get emoji => switch (this) {
        TripStatus.planning  => '📋',
        TripStatus.packing   => '🎒',
        TripStatus.onTrip    => '🚀',
        TripStatus.completed => '✅',
      };
}

class TripGearItem {
  final String gearItemId;
  final bool isPacked;

  const TripGearItem({required this.gearItemId, this.isPacked = false});

  TripGearItem copyWith({bool? isPacked}) =>
      TripGearItem(gearItemId: gearItemId, isPacked: isPacked ?? this.isPacked);

  Map<String, dynamic> toMap() =>
      {'gear_item_id': gearItemId, 'is_packed': isPacked ? 1 : 0};

  factory TripGearItem.fromMap(Map<String, dynamic> m) => TripGearItem(
        gearItemId: m['gear_item_id'] as String,
        isPacked: (m['is_packed'] as int? ?? 0) == 1,
      );
}

class Trip {
  final String id;
  final String name;
  final String? destination;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final TripStatus status;
  final List<TripGearItem> gearItems;
  final String? notes;

  const Trip({
    required this.id,
    required this.name,
    this.destination,
    this.departureDate,
    this.returnDate,
    this.status = TripStatus.planning,
    this.gearItems = const [],
    this.notes,
  });

  factory Trip.create({
    required String name,
    String? destination,
    DateTime? departureDate,
    DateTime? returnDate,
    TripStatus status = TripStatus.planning,
    List<TripGearItem>? gearItems,
    String? notes,
  }) =>
      Trip(
        id: const Uuid().v4(),
        name: name,
        destination: destination,
        departureDate: departureDate,
        returnDate: returnDate,
        status: status,
        gearItems: gearItems ?? [],
        notes: notes,
      );

  int get packedCount => gearItems.where((g) => g.isPacked).length;
  int get totalCount => gearItems.length;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'destination': destination,
        'departure_date': departureDate?.toIso8601String(),
        'return_date': returnDate?.toIso8601String(),
        'status': status.name,
        'notes': notes,
      };

  factory Trip.fromMap(
    Map<String, dynamic> map, {
    List<TripGearItem> gearItems = const [],
  }) =>
      Trip(
        id: map['id'] as String,
        name: map['name'] as String,
        destination: map['destination'] as String?,
        departureDate: map['departure_date'] != null
            ? DateTime.parse(map['departure_date'] as String)
            : null,
        returnDate: map['return_date'] != null
            ? DateTime.parse(map['return_date'] as String)
            : null,
        status: TripStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => TripStatus.planning,
        ),
        gearItems: gearItems,
        notes: map['notes'] as String?,
      );

  Trip copyWith({
    String? name,
    String? destination,
    DateTime? departureDate,
    DateTime? returnDate,
    TripStatus? status,
    List<TripGearItem>? gearItems,
    String? notes,
  }) =>
      Trip(
        id: id,
        name: name ?? this.name,
        destination: destination ?? this.destination,
        departureDate: departureDate ?? this.departureDate,
        returnDate: returnDate ?? this.returnDate,
        status: status ?? this.status,
        gearItems: gearItems ?? this.gearItems,
        notes: notes ?? this.notes,
      );
}

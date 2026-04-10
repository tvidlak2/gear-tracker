enum UsageSource { manual, strava, garmin, gpx, igc }

extension UsageSourceExtension on UsageSource {
  String get label {
    switch (this) {
      case UsageSource.manual:
        return 'Ruční zadání';
      case UsageSource.strava:
        return 'Strava';
      case UsageSource.garmin:
        return 'Garmin';
      case UsageSource.gpx:
        return 'GPX soubor';
      case UsageSource.igc:
        return 'IGC soubor';
    }
  }

  String get value => name;

  static UsageSource fromString(String value) {
    return UsageSource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UsageSource.manual,
    );
  }
}

class UsageLog {
  final int? id;
  final int gearItemId;
  final DateTime date;
  final int? durationMinutes;
  final double? distanceKm;
  final String? location;
  final UsageSource source;

  const UsageLog({
    this.id,
    required this.gearItemId,
    required this.date,
    this.durationMinutes,
    this.distanceKm,
    this.location,
    this.source = UsageSource.manual,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'gear_item_id': gearItemId,
      'date': date.toIso8601String(),
      'duration_minutes': durationMinutes,
      'distance_km': distanceKm,
      'location': location,
      'source': source.value,
    };
  }

  factory UsageLog.fromMap(Map<String, dynamic> map) {
    return UsageLog(
      id: map['id'] as int?,
      gearItemId: map['gear_item_id'] as int,
      date: DateTime.parse(map['date'] as String),
      durationMinutes: map['duration_minutes'] as int?,
      distanceKm: map['distance_km'] != null
          ? (map['distance_km'] as num).toDouble()
          : null,
      location: map['location'] as String?,
      source: UsageSourceExtension.fromString(
        map['source'] as String? ?? 'manual',
      ),
    );
  }

  UsageLog copyWith({
    int? id,
    int? gearItemId,
    DateTime? date,
    int? durationMinutes,
    double? distanceKm,
    String? location,
    UsageSource? source,
  }) {
    return UsageLog(
      id: id ?? this.id,
      gearItemId: gearItemId ?? this.gearItemId,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      location: location ?? this.location,
      source: source ?? this.source,
    );
  }

  @override
  String toString() =>
      'UsageLog(id: $id, gearItemId: $gearItemId, date: $date)';
}

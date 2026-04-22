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
  /// Nullable: null means a global/unassigned Strava activity not tied to
  /// any specific gear item. Non-null for manual logs and per-gear syncs.
  final int? gearItemId;
  final DateTime date;
  final int? durationMinutes;
  final double? distanceKm;
  /// Elevation gain in metres (e.g. from Strava's `total_elevation_gain`).
  final double? elevationGainM;
  final String? location;
  final UsageSource source;
  final String? stravaActivityId;

  const UsageLog({
    this.id,
    this.gearItemId,
    required this.date,
    this.durationMinutes,
    this.distanceKm,
    this.elevationGainM,
    this.location,
    this.source = UsageSource.manual,
    this.stravaActivityId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (gearItemId != null) 'gear_item_id': gearItemId,
      'date':               date.toIso8601String(),
      'duration_minutes':   durationMinutes,
      'distance_km':        distanceKm,
      'elevation_gain':     elevationGainM,
      'location':           location,
      'source':             source.value,
      'strava_activity_id': stravaActivityId,
    };
  }

  factory UsageLog.fromMap(Map<String, dynamic> map) {
    return UsageLog(
      id:             map['id'] as int?,
      gearItemId:     map['gear_item_id'] as int?,
      date:           DateTime.parse(map['date'] as String),
      durationMinutes: map['duration_minutes'] as int?,
      distanceKm: map['distance_km'] != null
          ? (map['distance_km'] as num).toDouble()
          : null,
      elevationGainM: map['elevation_gain'] != null
          ? (map['elevation_gain'] as num).toDouble()
          : null,
      location:         map['location'] as String?,
      source: UsageSourceExtension.fromString(
        map['source'] as String? ?? 'manual',
      ),
      stravaActivityId: map['strava_activity_id'] as String?,
    );
  }

  UsageLog copyWith({
    int? id,
    int? gearItemId,
    DateTime? date,
    int? durationMinutes,
    double? distanceKm,
    double? elevationGainM,
    String? location,
    UsageSource? source,
    String? stravaActivityId,
  }) {
    return UsageLog(
      id:               id               ?? this.id,
      gearItemId:       gearItemId       ?? this.gearItemId,
      date:             date             ?? this.date,
      durationMinutes:  durationMinutes  ?? this.durationMinutes,
      distanceKm:       distanceKm       ?? this.distanceKm,
      elevationGainM:   elevationGainM   ?? this.elevationGainM,
      location:         location         ?? this.location,
      source:           source           ?? this.source,
      stravaActivityId: stravaActivityId ?? this.stravaActivityId,
    );
  }

  @override
  String toString() =>
      'UsageLog(id: $id, gearItemId: $gearItemId, date: $date)';
}

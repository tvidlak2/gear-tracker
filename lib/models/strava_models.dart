/// Athlete profile returned by GET /athlete
class StravaAthlete {
  final int    id;
  final String firstname;
  final String lastname;
  final String? profileMedium;  // URL to 62x62 avatar

  const StravaAthlete({required this.id, required this.firstname, required this.lastname, this.profileMedium});

  factory StravaAthlete.fromJson(Map<String, dynamic> j) => StravaAthlete(
    id: j['id'] as int,
    firstname: j['firstname'] as String? ?? '',
    lastname:  j['lastname']  as String? ?? '',
    profileMedium: j['profile_medium'] as String?,
  );

  String get fullName => '$firstname $lastname'.trim();
}

/// Single activity from GET /athlete/activities
class StravaActivity {
  final int      id;
  final String   name;
  final String   type;          // e.g. "Ride", "Run"
  final DateTime startDateUtc;
  final int      movingTimeSec; // seconds
  final double   distanceM;     // metres

  const StravaActivity({required this.id, required this.name, required this.type,
    required this.startDateUtc, required this.movingTimeSec, required this.distanceM});

  int    get durationMinutes => (movingTimeSec / 60).round();
  double get distanceKm      => distanceM / 1000.0;

  factory StravaActivity.fromJson(Map<String, dynamic> j) => StravaActivity(
    id:            j['id']            as int,
    name:          j['name']          as String? ?? '',
    type:          j['type']          as String? ?? '',
    startDateUtc:  DateTime.parse(j['start_date'] as String).toLocal(),
    movingTimeSec: j['moving_time']   as int,
    distanceM:     (j['distance'] as num).toDouble(),
  );
}

/// Per-gear Strava sync settings, stored in gear_strava_settings table
class GearStravaSettings {
  final int          gearItemId;
  final List<String> activityTypes;  // list of Strava type strings
  final bool         syncEnabled;
  final DateTime?    syncFrom;

  const GearStravaSettings({
    required this.gearItemId,
    this.activityTypes = const [],
    this.syncEnabled = false,
    this.syncFrom,
  });

  GearStravaSettings copyWith({List<String>? activityTypes, bool? syncEnabled, DateTime? syncFrom}) =>
      GearStravaSettings(
        gearItemId:    gearItemId,
        activityTypes: activityTypes  ?? this.activityTypes,
        syncEnabled:   syncEnabled    ?? this.syncEnabled,
        syncFrom:      syncFrom       ?? this.syncFrom,
      );
}

/// Result of a sync operation
class StravaSyncResult {
  final int       added;
  final int       skipped;
  final double    totalKm;
  final int       totalMinutes;
  final String?   error;
  /// Date of the newest activity that was added (null when nothing was added).
  final DateTime? newestActivityDate;

  const StravaSyncResult({
    this.added = 0,
    this.skipped = 0,
    this.totalKm = 0,
    this.totalMinutes = 0,
    this.error,
    this.newestActivityDate,
  });

  bool get hasError => error != null;
  bool get isEmpty  => added == 0;
}

/// All activity types available in the dropdown
abstract class StravaActivityTypes {
  static const all = [
    'Ride', 'MountainBikeRide', 'EBikeRide', 'VirtualRide',
    'Run', 'TrailRun',
    'Hike', 'Walk',
    'AlpineSki', 'BackcountrySki', 'NordicSki',
    'Swim',
    'Kayaking', 'Rowing',
    'Yoga', 'WeightTraining', 'Crossfit', 'Workout',
  ];

  /// Suggested types by gear category icon
  static List<String> forIcon(String icon) => switch (icon) {
    'bike'        => ['Ride', 'VirtualRide', 'MountainBikeRide', 'EBikeRide'],
    'skis'        => ['BackcountrySki', 'AlpineSki', 'NordicSki'],
    'ice_axe'     => ['BackcountrySki', 'Hike'],
    'crampons'    => ['BackcountrySki', 'Hike'],
    'sleeping_bag'=> ['Hike', 'Walk'],
    'backpack'    => ['Hike', 'Walk', 'TrailRun'],
    _             => [],
  };

  /// Czech label for each type
  static String label(String type) => switch (type) {
    'Ride'             => 'Kolo (silniční)',
    'MountainBikeRide' => 'Kolo (MTB)',
    'EBikeRide'        => 'Kolo (elektro)',
    'VirtualRide'      => 'Kolo (virtuální)',
    'Run'              => 'Běh',
    'TrailRun'         => 'Trail běh',
    'Hike'             => 'Turistika',
    'Walk'             => 'Chůze',
    'AlpineSki'        => 'Sjezdové lyžování',
    'BackcountrySki'   => 'Skialpinismus',
    'NordicSki'        => 'Běžky',
    'Swim'             => 'Plavání',
    'Kayaking'         => 'Kayak',
    'Rowing'           => 'Veslování',
    'Yoga'             => 'Jóga',
    'WeightTraining'   => 'Posilovna',
    'Crossfit'         => 'Crossfit',
    'Workout'          => 'Trénink',
    _                  => type,
  };
}

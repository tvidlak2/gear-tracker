// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GearTracker';

  @override
  String get navOverview => 'Overview';

  @override
  String get navActivities => 'Activities';

  @override
  String get navMaintenance => 'Maintenance';

  @override
  String get navSettings => 'Settings';

  @override
  String get myGear => 'My Gear';

  @override
  String get addGear => 'Add Gear';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading…';

  @override
  String get noData => 'No data';

  @override
  String get statusActive => 'Active';

  @override
  String get statusRetired => 'Retired';

  @override
  String get statusLost => 'Lost';

  @override
  String get gearStatus => 'Gear Status';

  @override
  String get gearName => 'Name';

  @override
  String get gearBrand => 'Brand';

  @override
  String get gearModel => 'Model';

  @override
  String get gearCategory => 'Category';

  @override
  String get gearNotes => 'Notes';

  @override
  String get gearSerialNumber => 'Serial Number';

  @override
  String get gearPurchaseDate => 'Purchase Date';

  @override
  String get gearManufacturedDate => 'Manufacture Date';

  @override
  String get gearPhoto => 'Photo';

  @override
  String get gearAge => 'Age';

  @override
  String get requiresAttention => 'Requires Attention';

  @override
  String get allGoodTitle => 'All Good';

  @override
  String get allGoodSubtitle => 'No maintenance reminders';

  @override
  String get noGearYet => 'No gear yet';

  @override
  String get addFirstGear => 'Add your first piece of gear';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusWarning => 'Soon';

  @override
  String get statusOk => 'OK';

  @override
  String get totalHours => 'Total Hours';

  @override
  String get totalKm => 'Total km';

  @override
  String get age => 'Age';

  @override
  String get usageCount => 'Uses';

  @override
  String get hours => 'Hours';

  @override
  String get km => 'km';

  @override
  String get elevation => 'Elevation';

  @override
  String get activities => 'Activities';

  @override
  String get maintenancePlan => 'Maintenance Plan';

  @override
  String get addMaintenanceRule => 'Add Rule';

  @override
  String get logService => 'Log Service';

  @override
  String get noMaintenanceRules => 'No maintenance rules';

  @override
  String get addFirstRule => 'Add your first rule to track maintenance';

  @override
  String get triggerTypeDate => 'Date';

  @override
  String get triggerTypeHours => 'Hours';

  @override
  String get triggerTypeKm => 'km';

  @override
  String get triggerTypeCount => 'Count';

  @override
  String get safetyeCritical => 'Safety Critical';

  @override
  String get warningBefore => 'Warn Before';

  @override
  String get ruleName => 'Rule Name';

  @override
  String get triggerValue => 'Value';

  @override
  String get nextService => 'Next Service';

  @override
  String get lastService => 'Last Service';

  @override
  String get serviceHistory => 'Service History';

  @override
  String get noServiceHistory => 'No service history';

  @override
  String overdueBy(int days) {
    return 'Overdue by $days days';
  }

  @override
  String dueInDays(int days) {
    return 'In $days days';
  }

  @override
  String get activityHistory => 'Activity History';

  @override
  String get addActivity => 'Add Activity';

  @override
  String get noActivities => 'No usage records';

  @override
  String get importIgc => 'Import IGC';

  @override
  String showAll(int count) {
    return 'Show all ($count activities)';
  }

  @override
  String get hide => 'Hide';

  @override
  String loadMore(int count) {
    return 'Load more ($count remaining)';
  }

  @override
  String get sourceManual => 'Manual';

  @override
  String get sourceStrava => 'Strava';

  @override
  String get sourceIgc => 'IGC';

  @override
  String get sourceGarmin => 'Garmin';

  @override
  String get sourceGpx => 'GPX';

  @override
  String get stravaSync => 'Strava Sync';

  @override
  String get stravaConnect => 'Connect Strava';

  @override
  String get stravaDisconnect => 'Disconnect';

  @override
  String get stravaConnected => 'Connected';

  @override
  String get stravasyncActivities => 'Sync Activities';

  @override
  String get stravaAutoSync => 'Auto Sync';

  @override
  String get stravaSyncFrom => 'Sync From';

  @override
  String get stravaSyncTypes => 'Activity Types';

  @override
  String stravaSyncSuccess(int count, String date) {
    return 'Synced: $count activities (newest: $date)';
  }

  @override
  String get stravaSyncNoNew => 'No new activities';

  @override
  String stravaSyncError(String error) {
    return 'Sync error: $error';
  }

  @override
  String get stravaCredentials => 'API Credentials';

  @override
  String get stravaClientId => 'Client ID';

  @override
  String get stravaClientSecret => 'Client Secret';

  @override
  String get stravaSaved => 'Credentials saved';

  @override
  String get connectedServices => 'Connected Services';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get backupExport => 'Backup & Export';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearAllDataConfirm => 'Delete all data? This cannot be undone.';

  @override
  String get exportSuccess => 'Data exported';

  @override
  String get importSuccess => 'Data imported';

  @override
  String get dataCleared => 'All data cleared';

  @override
  String get language => 'Language';

  @override
  String get statistics => 'Statistics';

  @override
  String get activityOverTime => 'Activity Over Time';

  @override
  String get byGear => 'By Gear';

  @override
  String get recentActivities => 'Recent Activities';

  @override
  String get records => 'Records';

  @override
  String get longestActivity => 'Longest Activity';

  @override
  String get longestDistance => 'Longest Distance';

  @override
  String get mostActiveMonth => 'Most Active Month';

  @override
  String get mostUsedGear => 'Most Used';

  @override
  String get gearCount => 'Gear Items';

  @override
  String get maintenanceCount => 'Service Records';

  @override
  String get filterAll => 'All';

  @override
  String get timeFilter3M => '3M';

  @override
  String get timeFilter6M => '6M';

  @override
  String get timeFilter1Y => '1Y';

  @override
  String get timeFilter2Y => '2Y';

  @override
  String get timeFilterAll => 'All';

  @override
  String deleteGearConfirm(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteGearWarning =>
      'This will delete the gear and all its records.';

  @override
  String get performedBy => 'Performed By';

  @override
  String get cost => 'Cost';

  @override
  String get nextDueDate => 'Next Due';

  @override
  String get performedDate => 'Date Performed';

  @override
  String get notes => 'Notes';

  @override
  String durationHours(String h) {
    return '$h h';
  }

  @override
  String durationMinutes(int m) {
    return '$m min';
  }

  @override
  String distanceKm(String km) {
    return '$km km';
  }

  @override
  String elevationM(int m) {
    return '↑ $m m';
  }

  @override
  String get stravaCallbackProcessing => 'Completing Strava login…';

  @override
  String get stravaCallbackExchanging =>
      'Exchanging authorization code for access token.';

  @override
  String get stravaCallbackRedirecting => 'Redirecting back to settings…';

  @override
  String stravaAccessDenied(String error) {
    return 'Strava denied access: $error';
  }

  @override
  String get stravaMissingCode =>
      'Authorization code missing. Please try again.';

  @override
  String get maintenanceOverview => 'Maintenance Overview';

  @override
  String get allGear => 'All Good';

  @override
  String itemsNeedAttention(int count) {
    return '$count items need attention';
  }

  @override
  String get sportClimbing => 'Climbing';

  @override
  String get sportSkiAlpinism => 'Ski Mountaineering';

  @override
  String get sportCycling => 'Cycling';

  @override
  String get sportParagliding => 'Paragliding';

  @override
  String get sportGeneral => 'General';

  @override
  String get deleteConfirmTitle => 'Confirm Delete';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get addGearTitle => 'New Gear';

  @override
  String get editGearTitle => 'Edit Gear';

  @override
  String get gearSaved => 'Gear saved';

  @override
  String get locationLabel => 'Location';

  @override
  String get dateLabel => 'Date';

  @override
  String get durationLabel => 'Duration';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String stravaSyncedCount(int count) {
    return '$count activities synced';
  }

  @override
  String get stravaSyncedNone => 'No activities synced yet';
}

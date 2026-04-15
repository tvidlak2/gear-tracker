// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OutdoorGearTracker';

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

  @override
  String get insuranceTitle => 'Insurance';

  @override
  String get addInsurance => 'Add Insurance';

  @override
  String get noInsurance => 'No insurance';

  @override
  String get noInsuranceHint => 'Add your first insurance with the + button';

  @override
  String get deleteInsuranceTitle => 'Delete insurance?';

  @override
  String deleteInsuranceConfirm(String name) {
    return 'Really delete insurance \"$name\"?';
  }

  @override
  String get insuranceExpired => 'Expired';

  @override
  String get insuranceExpiringSoon => 'Expiring soon';

  @override
  String get insuranceActive => 'Active';

  @override
  String insuranceExpiredOn(String date) {
    return 'Expired $date';
  }

  @override
  String insuranceValidUntil(String date) {
    return 'Until $date';
  }

  @override
  String get totalAnnualCost => 'Total per year:';

  @override
  String get insuranceDetails => 'Insurance details';

  @override
  String get insuranceStartDate => 'Start date';

  @override
  String get insuranceExpiryDate => 'Expiry date';

  @override
  String get annualPremium => 'Annual premium';

  @override
  String get coverageAmount => 'Coverage amount';

  @override
  String get contractPhoto => 'Contract photo';

  @override
  String get linkedGear => 'Linked gear';

  @override
  String get insuranceActions => 'Actions';

  @override
  String get copyCompanyName => 'Insurance company name copied';

  @override
  String get contactButton => 'Contact';

  @override
  String get reminderButton => 'Reminder';

  @override
  String contractLabel(String number) {
    return 'Contract: $number';
  }

  @override
  String get editInsuranceTitle => 'Edit insurance';

  @override
  String get newInsuranceTitle => 'New insurance';

  @override
  String get insuranceNameLabel => 'Insurance name *';

  @override
  String get insuranceNameHint => 'e.g. Mountain gear insurance';

  @override
  String get insuranceNameRequired => 'Enter a name';

  @override
  String get insuranceTypeLabel => 'Insurance type';

  @override
  String get insuranceCompanyLabel => 'Insurance company *';

  @override
  String get insuranceCompanyHint => 'e.g. Allianz';

  @override
  String get insuranceCompanyRequired => 'Enter insurance company';

  @override
  String get policyNumberLabel => 'Policy number *';

  @override
  String get policyNumberHint => 'policy contract number';

  @override
  String get policyNumberRequired => 'Enter policy number';

  @override
  String get validitySection => 'Validity';

  @override
  String get financialSection => 'Financial information';

  @override
  String get annualPremiumLabel => 'Annual premium';

  @override
  String get coverageAmountLabel => 'Coverage amount';

  @override
  String get optionalHint => 'optional';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectDateRequired => 'Select date *';

  @override
  String get expiryDateRequired => 'Please select an expiry date.';

  @override
  String get basicInfoSection => 'Basic information';

  @override
  String get linkedGearSection => 'Linked gear';

  @override
  String get tripsTitle => 'Trips';

  @override
  String get addTrip => 'Plan a trip';

  @override
  String get noTrips => 'No trips';

  @override
  String get noTripsHint => 'Add your first trip and create a gear checklist.';

  @override
  String get deleteTrip => 'Delete trip?';

  @override
  String deleteTripConfirm(String name) {
    return 'Really delete trip \"$name\"?';
  }

  @override
  String get shareChecklist => 'Share checklist';

  @override
  String packingProgress(int packed, int total) {
    return '$packed/$total packed';
  }

  @override
  String get tripWarnings => 'Pre-trip warnings';

  @override
  String get tripGearOverdue => 'Requires service – limit exceeded';

  @override
  String get tripGearWarning => 'Service due soon';

  @override
  String gearChecklist(int packed, int total) {
    return 'Gear ($packed/$total packed)';
  }

  @override
  String get noGearInTrip => 'No gear yet. Tap Add to select.';

  @override
  String get selectGearTitle => 'Select gear';

  @override
  String get confirmSelection => 'Confirm selection';

  @override
  String get editTripTitle => 'Edit trip';

  @override
  String get newTripTitle => 'New trip';

  @override
  String get tripNameLabel => 'Trip name *';

  @override
  String get tripNameHint => 'e.g. Summer trekking in the Alps';

  @override
  String get tripNameRequired => 'Enter a name';

  @override
  String get destinationLabel => 'Destination';

  @override
  String get destinationHint => 'e.g. Dolomites, Italy';

  @override
  String get departureDateLabel => 'Departure date';

  @override
  String get returnDateLabel => 'Return date';

  @override
  String get tripStatusSection => 'Status';

  @override
  String get tripStatusLabel => 'Trip status';

  @override
  String get notSelected => 'Not selected';

  @override
  String get saveTripButton => 'Save trip';

  @override
  String get dateSection => 'Dates';

  @override
  String get portfolioTitle => 'Portfolio';

  @override
  String get purchaseValue => 'Purchase value';

  @override
  String get currentValue => 'Current value';

  @override
  String get annualInsuranceCost => 'Annual insurance';

  @override
  String get maintenanceCosts => 'Maintenance costs';

  @override
  String get valueByCategory => 'Value by category';

  @override
  String get maintenanceCostsByMonth => 'Maintenance costs by month';

  @override
  String get noMaintenanceCosts => 'No cost records';

  @override
  String get gearByValue => 'Gear by value';

  @override
  String get noGearWithPrice =>
      'No gear with purchase price.\nAdd a price in the gear detail.';

  @override
  String get exportForInsurance => 'Export for insurance';

  @override
  String get exportPdfComingSoon =>
      'PDF export will be available in the next version';

  @override
  String get exportPremiumMessage =>
      'Portfolio export for insurance is a premium feature.';

  @override
  String get portfolioLoadError => 'Failed to load data.';

  @override
  String depreciatedPercent(int pct) {
    return '–$pct% depreciated';
  }

  @override
  String get annualReportTitle => 'Annual report';

  @override
  String get annualReportPdfTitle => 'Annual overview as PDF';

  @override
  String get reportContains => 'Report includes:';

  @override
  String get reportItemActivities => 'Overall activities and service overview';

  @override
  String get reportItemGearStats => 'Statistics for each piece of gear';

  @override
  String get reportItemMonthly => 'Monthly activity breakdown';

  @override
  String get reportItemServiceHistory => 'Complete service history';

  @override
  String get reportItemInsurance => 'Insurance overview and portfolio value';

  @override
  String get reportItemNextYear => 'Service plan for next year';

  @override
  String get selectYear => 'Select year';

  @override
  String get currentYearLabel => 'Current year';

  @override
  String get lastYearLabel => 'Last year';

  @override
  String get twoYearsAgoLabel => 'Two years ago';

  @override
  String generateReport(int year) {
    return 'Generate $year report';
  }

  @override
  String get generatingReport => 'Generating report...';

  @override
  String reportError(String error) {
    return 'Error generating report: $error';
  }

  @override
  String get reportShareHint =>
      'After generating, the PDF will be shared via the system dialog (save, email, print...).';

  @override
  String get settingsInsuranceSection => 'Insurance';

  @override
  String get settingsInsuranceSubtitle => 'Manage your gear insurance';

  @override
  String get settingsAppSection => 'App';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceSubtitle => 'Light / dark / system theme';

  @override
  String get themeModeLight => 'Light theme';

  @override
  String get themeModeDark => 'Dark theme';

  @override
  String get themeModeSystem => 'Follow system';

  @override
  String get settingsNotificationsTitle => 'Notifications';

  @override
  String get settingsNotificationsOn =>
      'You\'ll get reminders before and after service deadlines.';

  @override
  String get settingsNotificationsOff =>
      'Service deadline reminders are disabled.';

  @override
  String get settingsNotificationsWeb =>
      'Push notifications are not supported in the browser.\nUse the Android / iOS app.';

  @override
  String get settingsBackupSection => 'Backup & export';

  @override
  String get settingsAnnualReport => 'Annual PDF report';

  @override
  String get settingsAnnualReportSubtitle => 'Export the year overview as PDF';

  @override
  String get settingsDataSection => 'Data';

  @override
  String get settingsImportSubtitle => 'Import from CSV or GPX file';

  @override
  String get settingsClearSubtitle =>
      'Permanently removes everything from the database';

  @override
  String get settingsWidgetSection => 'Widget';

  @override
  String get settingsWidgetAdd => 'Add widget';

  @override
  String get settingsWidgetAddSubtitle =>
      'Add widget to home screen: Long press screen → Widgets → OutdoorGearTracker';

  @override
  String get settingsWidgetRefresh => 'Refresh widget now';

  @override
  String get settingsWidgetRefreshed => 'Widget updated';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get backupSuccess => 'Backup successfully uploaded to Google Drive.';

  @override
  String get restoreSuccess =>
      'Data successfully restored. Please restart the app.';

  @override
  String get restoreConfirmTitle => 'Restore from backup?';

  @override
  String get restoreConfirmContent =>
      'This will replace the current database and photos with backup data. Continue?';

  @override
  String get restoreButton => 'Restore';

  @override
  String get notificationPermissionDenied =>
      'Notification permission was denied.';

  @override
  String get settingsButton => 'Settings';

  @override
  String get premiumUnlocked =>
      '🎉 Premium activated! Thank you for your support.';

  @override
  String get restorePurchasesButton => 'Restore purchases';

  @override
  String get noPreviousPurchases => 'No previous purchases found.';

  @override
  String get purchasesRestored => '✅ Purchases restored!';

  @override
  String get paywallTagline => 'Unlimited. Safety without compromise.';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get tapToUnlock => 'Tap to unlock';

  @override
  String getPremiumButton(String price) {
    return 'Get Premium – $price';
  }

  @override
  String get purchaseUnavailable =>
      'Purchase not yet available – configure a product in the RevenueCat dashboard.';

  @override
  String get deleteServiceRecord => 'Delete record';

  @override
  String get deleteServiceRecordConfirm =>
      'Are you sure you want to delete this service record?';

  @override
  String get editServiceRecord => 'Edit record';

  @override
  String get editServiceTitle => 'Edit service record';

  @override
  String get notYetPerformed => 'Not yet performed';

  @override
  String get noServiceEntries => 'No service records yet';

  @override
  String get recordFirstService => 'Record first service';

  @override
  String get serviceHistoryFull => 'Complete service history';

  @override
  String get warrantyExpired => 'Warranty expired';

  @override
  String get warrantySection => 'Warranty';

  @override
  String get gearInsuranceSection => 'Insurance';

  @override
  String get noInsurancesAttached => 'No insurance policies';

  @override
  String get igcLoadError => 'Failed to load IGC file. Check the format.';

  @override
  String get flightPreview => 'Flight preview';

  @override
  String get flightStartLabel => 'Start';

  @override
  String get flightLandingLabel => 'Landing';

  @override
  String get flightDurationLabel => 'Flight duration';

  @override
  String get maxAltitudeLabel => 'Max altitude';

  @override
  String get gpsStartLabel => 'GPS start';

  @override
  String get stravaNotConnectedHint =>
      'Strava not connected. Go to Settings → Connected Services.';

  @override
  String get stravaSyncFromHelpText => 'Sync activities from';

  @override
  String get widgetHowToAddTitle => 'How to add widget';

  @override
  String get widgetHowToStep1 =>
      '1. Long-press an empty space on the home screen';

  @override
  String get widgetHowToStep2 => '2. Tap \"Widgets\"';

  @override
  String get widgetHowToStep3 => '3. Find \"OutdoorGearTracker\" in the list';

  @override
  String get widgetHowToStep4 => '4. Drag the widget to the home screen';

  @override
  String get understood => 'Got it';

  @override
  String get apiKeysTitle => 'API keys';

  @override
  String get exportCsvLabel => 'Export as CSV';

  @override
  String get exportCsvSubtitle => 'Export all data to CSV file';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get featureComingSoon => 'Feature coming soon';

  @override
  String get signOutGoogleAccount => 'Sign out of Google';

  @override
  String get availableInPremium => 'Available in Premium';

  @override
  String deleteDataError(Object error) {
    return 'Error deleting data: $error';
  }

  @override
  String get exportCompleted => 'Export completed';

  @override
  String get syncTimedOut => 'Sync timed out. Please try again.';

  @override
  String get photoTakePhoto => 'Take photo';

  @override
  String get photoFromGallery => 'Choose from gallery';

  @override
  String get photoDeleteConfirm => 'Delete photo?';

  @override
  String get photoAdd => 'Add photo';

  @override
  String get photoChange => 'Change photo';

  @override
  String get apply => 'Apply';

  @override
  String serviceHistoryRecordCount(int count) {
    return '$count records';
  }

  @override
  String warrantyValidUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String intervalDays(String n) {
    return 'every $n days';
  }

  @override
  String intervalHours(String n) {
    return 'every $n h';
  }

  @override
  String intervalKm(String n) {
    return 'every $n km';
  }

  @override
  String intervalCount(String n) {
    return 'every $n×';
  }

  @override
  String flightAdded(String dur, String height) {
    return 'Flight added: $dur, max altitude $height m';
  }

  @override
  String get insuranceSection => 'Insurance';

  @override
  String get insurance => 'Insurance';

  @override
  String get insuranceSubtitle => 'Manage your gear insurance';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceSubtitle => 'Light / dark / system theme';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get applicationsSection => 'App';

  @override
  String get languageSection => 'Language';

  @override
  String get trips => 'Trips';
}

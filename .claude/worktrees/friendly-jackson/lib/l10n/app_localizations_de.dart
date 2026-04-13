// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'GearTracker';

  @override
  String get navOverview => 'Übersicht';

  @override
  String get navActivities => 'Aktivitäten';

  @override
  String get navMaintenance => 'Wartung';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get myGear => 'Meine Ausrüstung';

  @override
  String get addGear => 'Ausrüstung hinzufügen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get close => 'Schließen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get loading => 'Laden…';

  @override
  String get noData => 'Keine Daten';

  @override
  String get statusActive => 'Aktiv';

  @override
  String get statusRetired => 'Ausgemustert';

  @override
  String get statusLost => 'Verloren';

  @override
  String get gearStatus => 'Ausrüstungsstatus';

  @override
  String get gearName => 'Name';

  @override
  String get gearBrand => 'Marke';

  @override
  String get gearModel => 'Modell';

  @override
  String get gearCategory => 'Kategorie';

  @override
  String get gearNotes => 'Notizen';

  @override
  String get gearSerialNumber => 'Seriennummer';

  @override
  String get gearPurchaseDate => 'Kaufdatum';

  @override
  String get gearManufacturedDate => 'Herstellungsdatum';

  @override
  String get gearPhoto => 'Foto';

  @override
  String get gearAge => 'Alter';

  @override
  String get requiresAttention => 'Aufmerksamkeit erforderlich';

  @override
  String get allGoodTitle => 'Alles in Ordnung';

  @override
  String get allGoodSubtitle => 'Keine Wartungserinnerungen';

  @override
  String get noGearYet => 'Noch keine Ausrüstung';

  @override
  String get addFirstGear => 'Füge deine erste Ausrüstung hinzu';

  @override
  String get statusOverdue => 'Überfällig';

  @override
  String get statusWarning => 'Bald';

  @override
  String get statusOk => 'OK';

  @override
  String get totalHours => 'Gesamtstunden';

  @override
  String get totalKm => 'Gesamt km';

  @override
  String get age => 'Alter';

  @override
  String get usageCount => 'Verwendungen';

  @override
  String get hours => 'Stunden';

  @override
  String get km => 'km';

  @override
  String get elevation => 'Höhenmeter';

  @override
  String get activities => 'Aktivitäten';

  @override
  String get maintenancePlan => 'Wartungsplan';

  @override
  String get addMaintenanceRule => 'Regel hinzufügen';

  @override
  String get logService => 'Wartung eintragen';

  @override
  String get noMaintenanceRules => 'Keine Wartungsregeln';

  @override
  String get addFirstRule =>
      'Füge die erste Regel zur Wartungsverfolgung hinzu';

  @override
  String get triggerTypeDate => 'Datum';

  @override
  String get triggerTypeHours => 'Stunden';

  @override
  String get triggerTypeKm => 'km';

  @override
  String get triggerTypeCount => 'Anzahl';

  @override
  String get safetyeCritical => 'Sicherheitskritisch';

  @override
  String get warningBefore => 'Warnung vorher';

  @override
  String get ruleName => 'Regelname';

  @override
  String get triggerValue => 'Wert';

  @override
  String get nextService => 'Nächste Wartung';

  @override
  String get lastService => 'Letzte Wartung';

  @override
  String get serviceHistory => 'Wartungshistorie';

  @override
  String get noServiceHistory => 'Keine Wartungshistorie';

  @override
  String overdueBy(int days) {
    return 'Überfällig um $days Tage';
  }

  @override
  String dueInDays(int days) {
    return 'In $days Tagen';
  }

  @override
  String get activityHistory => 'Aktivitätsverlauf';

  @override
  String get addActivity => 'Aktivität hinzufügen';

  @override
  String get noActivities => 'Keine Nutzungseinträge';

  @override
  String get importIgc => 'IGC importieren';

  @override
  String showAll(int count) {
    return 'Alle anzeigen ($count Aktivitäten)';
  }

  @override
  String get hide => 'Ausblenden';

  @override
  String loadMore(int count) {
    return 'Mehr laden ($count verbleibend)';
  }

  @override
  String get sourceManual => 'Manuell';

  @override
  String get sourceStrava => 'Strava';

  @override
  String get sourceIgc => 'IGC';

  @override
  String get sourceGarmin => 'Garmin';

  @override
  String get sourceGpx => 'GPX';

  @override
  String get stravaSync => 'Strava-Synchronisation';

  @override
  String get stravaConnect => 'Strava verbinden';

  @override
  String get stravaDisconnect => 'Trennen';

  @override
  String get stravaConnected => 'Verbunden';

  @override
  String get stravasyncActivities => 'Aktivitäten synchronisieren';

  @override
  String get stravaAutoSync => 'Automatische Synchronisation';

  @override
  String get stravaSyncFrom => 'Synchronisieren ab';

  @override
  String get stravaSyncTypes => 'Aktivitätstypen';

  @override
  String stravaSyncSuccess(int count, String date) {
    return 'Synchronisiert: $count Aktivitäten (neueste: $date)';
  }

  @override
  String get stravaSyncNoNew => 'Keine neuen Aktivitäten';

  @override
  String stravaSyncError(String error) {
    return 'Synchronisationsfehler: $error';
  }

  @override
  String get stravaCredentials => 'API-Anmeldedaten';

  @override
  String get stravaClientId => 'Client ID';

  @override
  String get stravaClientSecret => 'Client Secret';

  @override
  String get stravaSaved => 'Anmeldedaten gespeichert';

  @override
  String get connectedServices => 'Verbundene Dienste';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get notificationsEnabled => 'Benachrichtigungen aktiviert';

  @override
  String get backupExport => 'Backup & Export';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get importData => 'Daten importieren';

  @override
  String get clearAllData => 'Alle Daten löschen';

  @override
  String get clearAllDataConfirm =>
      'Alle Daten löschen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get exportSuccess => 'Daten exportiert';

  @override
  String get importSuccess => 'Daten importiert';

  @override
  String get dataCleared => 'Alle Daten gelöscht';

  @override
  String get language => 'Sprache';

  @override
  String get statistics => 'Statistiken';

  @override
  String get activityOverTime => 'Aktivität im Zeitverlauf';

  @override
  String get byGear => 'Nach Ausrüstung';

  @override
  String get recentActivities => 'Letzte Aktivitäten';

  @override
  String get records => 'Rekorde';

  @override
  String get longestActivity => 'Längste Aktivität';

  @override
  String get longestDistance => 'Längste Strecke';

  @override
  String get mostActiveMonth => 'Aktivster Monat';

  @override
  String get mostUsedGear => 'Meist genutzt';

  @override
  String get gearCount => 'Ausrüstungsteile';

  @override
  String get maintenanceCount => 'Wartungseinträge';

  @override
  String get filterAll => 'Alle';

  @override
  String get timeFilter3M => '3M';

  @override
  String get timeFilter6M => '6M';

  @override
  String get timeFilter1Y => '1J';

  @override
  String get timeFilter2Y => '2J';

  @override
  String get timeFilterAll => 'Alle';

  @override
  String deleteGearConfirm(String name) {
    return '$name löschen?';
  }

  @override
  String get deleteGearWarning =>
      'Dies löscht die Ausrüstung und alle Einträge.';

  @override
  String get performedBy => 'Durchgeführt von';

  @override
  String get cost => 'Kosten';

  @override
  String get nextDueDate => 'Nächster Termin';

  @override
  String get performedDate => 'Durchführungsdatum';

  @override
  String get notes => 'Notizen';

  @override
  String durationHours(String h) {
    return '$h Std';
  }

  @override
  String durationMinutes(int m) {
    return '$m Min';
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
  String get stravaCallbackProcessing => 'Strava-Anmeldung abschließen…';

  @override
  String get stravaCallbackExchanging =>
      'Autorisierungscode gegen Zugriffstoken tauschen.';

  @override
  String get stravaCallbackRedirecting => 'Zurück zu den Einstellungen…';

  @override
  String stravaAccessDenied(String error) {
    return 'Strava hat den Zugriff verweigert: $error';
  }

  @override
  String get stravaMissingCode =>
      'Autorisierungscode fehlt. Bitte erneut versuchen.';

  @override
  String get maintenanceOverview => 'Wartungsübersicht';

  @override
  String get allGear => 'Alles in Ordnung';

  @override
  String itemsNeedAttention(int count) {
    return '$count Elemente benötigen Aufmerksamkeit';
  }

  @override
  String get sportClimbing => 'Klettern';

  @override
  String get sportSkiAlpinism => 'Skitour';

  @override
  String get sportCycling => 'Radfahren';

  @override
  String get sportParagliding => 'Paragliding';

  @override
  String get sportGeneral => 'Allgemein';

  @override
  String get deleteConfirmTitle => 'Löschen bestätigen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get addGearTitle => 'Neue Ausrüstung';

  @override
  String get editGearTitle => 'Ausrüstung bearbeiten';

  @override
  String get gearSaved => 'Ausrüstung gespeichert';

  @override
  String get locationLabel => 'Ort';

  @override
  String get dateLabel => 'Datum';

  @override
  String get durationLabel => 'Dauer';

  @override
  String get distanceLabel => 'Entfernung';

  @override
  String get notificationsDisabled => 'Benachrichtigungen deaktiviert';

  @override
  String stravaSyncedCount(int count) {
    return '$count Aktivitäten synchronisiert';
  }

  @override
  String get stravaSyncedNone => 'Noch keine synchronisierten Aktivitäten';
}

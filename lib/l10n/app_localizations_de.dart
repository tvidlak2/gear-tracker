// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'OutdoorGearTracker';

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

  @override
  String get insuranceTitle => 'Versicherungen';

  @override
  String get addInsurance => 'Versicherung hinzufügen';

  @override
  String get noInsurance => 'Keine Versicherungen';

  @override
  String get noInsuranceHint => 'Füge deine erste Versicherung mit dem + hinzu';

  @override
  String get deleteInsuranceTitle => 'Versicherung löschen?';

  @override
  String deleteInsuranceConfirm(String name) {
    return 'Versicherung \"$name\" wirklich löschen?';
  }

  @override
  String get insuranceExpired => 'Abgelaufen';

  @override
  String get insuranceExpiringSoon => 'Läuft bald ab';

  @override
  String get insuranceActive => 'Aktiv';

  @override
  String insuranceExpiredOn(String date) {
    return 'Abgelaufen $date';
  }

  @override
  String insuranceValidUntil(String date) {
    return 'Bis $date';
  }

  @override
  String get totalAnnualCost => 'Gesamt jährlich:';

  @override
  String get insuranceDetails => 'Versicherungsdetails';

  @override
  String get insuranceStartDate => 'Startdatum';

  @override
  String get insuranceExpiryDate => 'Ablaufdatum';

  @override
  String get annualPremium => 'Jahresprämie';

  @override
  String get coverageAmount => 'Versicherungssumme';

  @override
  String get contractPhoto => 'Vertragsfoto';

  @override
  String get linkedGear => 'Verknüpfte Ausrüstung';

  @override
  String get insuranceActions => 'Aktionen';

  @override
  String get copyCompanyName => 'Versicherungsname kopiert';

  @override
  String get contactButton => 'Kontakt';

  @override
  String get reminderButton => 'Erinnerung';

  @override
  String contractLabel(String number) {
    return 'Vertrag: $number';
  }

  @override
  String get editInsuranceTitle => 'Versicherung bearbeiten';

  @override
  String get newInsuranceTitle => 'Neue Versicherung';

  @override
  String get insuranceNameLabel => 'Versicherungsname *';

  @override
  String get insuranceNameHint => 'z.B. Ausrüstungsversicherung Berge';

  @override
  String get insuranceNameRequired => 'Name eingeben';

  @override
  String get insuranceTypeLabel => 'Versicherungstyp';

  @override
  String get insuranceCompanyLabel => 'Versicherungsgesellschaft *';

  @override
  String get insuranceCompanyHint => 'z.B. Allianz';

  @override
  String get insuranceCompanyRequired => 'Versicherungsgesellschaft eingeben';

  @override
  String get policyNumberLabel => 'Vertragsnummer *';

  @override
  String get policyNumberHint => 'Versicherungsvertragsnummer';

  @override
  String get policyNumberRequired => 'Vertragsnummer eingeben';

  @override
  String get validitySection => 'Gültigkeit';

  @override
  String get financialSection => 'Finanzinformationen';

  @override
  String get annualPremiumLabel => 'Jahresprämie';

  @override
  String get coverageAmountLabel => 'Versicherungssumme';

  @override
  String get optionalHint => 'optional';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get selectDateRequired => 'Datum auswählen *';

  @override
  String get expiryDateRequired => 'Bitte Ablaufdatum auswählen.';

  @override
  String get basicInfoSection => 'Grundinformationen';

  @override
  String get linkedGearSection => 'Verknüpfte Ausrüstung';

  @override
  String get tripsTitle => 'Touren';

  @override
  String get addTrip => 'Tour planen';

  @override
  String get noTrips => 'Keine Touren';

  @override
  String get noTripsHint =>
      'Füge deine erste Tour hinzu und erstelle eine Ausrüstungsliste.';

  @override
  String get deleteTrip => 'Tour löschen?';

  @override
  String deleteTripConfirm(String name) {
    return 'Tour \"$name\" wirklich löschen?';
  }

  @override
  String get shareChecklist => 'Checkliste teilen';

  @override
  String packingProgress(int packed, int total) {
    return '$packed/$total eingepackt';
  }

  @override
  String get tripWarnings => 'Warnungen vor der Tour';

  @override
  String get tripGearOverdue => 'Wartung erforderlich – Limit überschritten';

  @override
  String get tripGearWarning => 'Wartungstermin naht';

  @override
  String gearChecklist(int packed, int total) {
    return 'Ausrüstung ($packed/$total eingepackt)';
  }

  @override
  String get noGearInTrip => 'Noch keine Ausrüstung. Tippe auf Hinzufügen.';

  @override
  String get selectGearTitle => 'Ausrüstung auswählen';

  @override
  String get confirmSelection => 'Auswahl bestätigen';

  @override
  String get editTripTitle => 'Tour bearbeiten';

  @override
  String get newTripTitle => 'Neue Tour';

  @override
  String get tripNameLabel => 'Tourname *';

  @override
  String get tripNameHint => 'z.B. Sommertrekking in den Alpen';

  @override
  String get tripNameRequired => 'Name eingeben';

  @override
  String get destinationLabel => 'Ziel';

  @override
  String get destinationHint => 'z.B. Dolomiten, Italien';

  @override
  String get departureDateLabel => 'Abreisedatum';

  @override
  String get returnDateLabel => 'Rückreisedatum';

  @override
  String get tripStatusSection => 'Status';

  @override
  String get tripStatusLabel => 'Tourstatus';

  @override
  String get notSelected => 'Nicht ausgewählt';

  @override
  String get saveTripButton => 'Tour speichern';

  @override
  String get dateSection => 'Termine';

  @override
  String get portfolioTitle => 'Portfolio';

  @override
  String get purchaseValue => 'Kaufwert';

  @override
  String get currentValue => 'Aktueller Wert';

  @override
  String get annualInsuranceCost => 'Jahresprämie';

  @override
  String get maintenanceCosts => 'Wartungskosten';

  @override
  String get valueByCategory => 'Wert nach Kategorie';

  @override
  String get maintenanceCostsByMonth => 'Wartungskosten pro Monat';

  @override
  String get noMaintenanceCosts => 'Keine Kostendaten';

  @override
  String get gearByValue => 'Ausrüstung nach Wert';

  @override
  String get noGearWithPrice =>
      'Keine Ausrüstung mit Kaufpreis.\nPreis in den Ausrüstungsdetails hinzufügen.';

  @override
  String get exportForInsurance => 'Für Versicherung exportieren';

  @override
  String get exportPdfComingSoon =>
      'PDF-Export wird in der nächsten Version verfügbar sein';

  @override
  String get exportPremiumMessage =>
      'Portfolio-Export für Versicherungen ist eine Premium-Funktion.';

  @override
  String get portfolioLoadError => 'Daten konnten nicht geladen werden.';

  @override
  String depreciatedPercent(int pct) {
    return '–$pct% abgeschrieben';
  }

  @override
  String get annualReportTitle => 'Jahresbericht';

  @override
  String get annualReportPdfTitle => 'Jahresübersicht als PDF';

  @override
  String get reportContains => 'Bericht enthält:';

  @override
  String get reportItemActivities =>
      'Gesamtübersicht Aktivitäten und Wartungen';

  @override
  String get reportItemGearStats => 'Statistiken für jedes Ausrüstungsstück';

  @override
  String get reportItemMonthly => 'Monatliche Aktivitätsaufteilung';

  @override
  String get reportItemServiceHistory => 'Vollständige Wartungshistorie';

  @override
  String get reportItemInsurance => 'Versicherungsübersicht und Portfoliowert';

  @override
  String get reportItemNextYear => 'Wartungsplan für nächstes Jahr';

  @override
  String get selectYear => 'Jahr auswählen';

  @override
  String get currentYearLabel => 'Aktuelles Jahr';

  @override
  String get lastYearLabel => 'Letztes Jahr';

  @override
  String get twoYearsAgoLabel => 'Vor zwei Jahren';

  @override
  String generateReport(int year) {
    return 'Bericht $year generieren';
  }

  @override
  String get generatingReport => 'Bericht wird erstellt...';

  @override
  String reportError(String error) {
    return 'Fehler beim Erstellen des Berichts: $error';
  }

  @override
  String get reportShareHint =>
      'Nach der Erstellung wird das PDF über den Systemdialog geteilt (speichern, per E-Mail senden, drucken...).';

  @override
  String get settingsInsuranceSection => 'Versicherungen';

  @override
  String get settingsInsuranceSubtitle => 'Ausrüstungsversicherungen verwalten';

  @override
  String get settingsAppSection => 'App';

  @override
  String get settingsAppearance => 'Erscheinungsbild';

  @override
  String get settingsAppearanceSubtitle => 'Hell / dunkel / Systemdesign';

  @override
  String get themeModeLight => 'Helles Design';

  @override
  String get themeModeDark => 'Dunkles Design';

  @override
  String get themeModeSystem => 'Systemstandard';

  @override
  String get settingsNotificationsTitle => 'Benachrichtigungen';

  @override
  String get settingsNotificationsOn =>
      'Du bekommst Erinnerungen vor und nach Wartungsterminen.';

  @override
  String get settingsNotificationsOff =>
      'Wartungserinnerungen sind deaktiviert.';

  @override
  String get settingsNotificationsWeb =>
      'Push-Benachrichtigungen werden im Browser nicht unterstützt.\nVerwende die Android / iOS App.';

  @override
  String get settingsBackupSection => 'Sicherung & Export';

  @override
  String get settingsAnnualReport => 'Jahresbericht PDF';

  @override
  String get settingsAnnualReportSubtitle =>
      'Jahresübersicht als PDF exportieren';

  @override
  String get settingsDataSection => 'Daten';

  @override
  String get settingsImportSubtitle => 'Import aus CSV- oder GPX-Datei';

  @override
  String get settingsClearSubtitle =>
      'Löscht dauerhaft alles aus der Datenbank';

  @override
  String get settingsWidgetSection => 'Widget';

  @override
  String get settingsWidgetAdd => 'Widget hinzufügen';

  @override
  String get settingsWidgetAddSubtitle =>
      'Widget zum Startbildschirm hinzufügen: Lange drücken → Widgets → OutdoorGearTracker';

  @override
  String get settingsWidgetRefresh => 'Widget jetzt aktualisieren';

  @override
  String get settingsWidgetRefreshed => 'Widget aktualisiert';

  @override
  String get settingsAboutSection => 'Über';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get backupSuccess =>
      'Sicherung erfolgreich auf Google Drive hochgeladen.';

  @override
  String get restoreSuccess =>
      'Daten erfolgreich wiederhergestellt. App neu starten.';

  @override
  String get restoreConfirmTitle => 'Aus Sicherung wiederherstellen?';

  @override
  String get restoreConfirmContent =>
      'Dies ersetzt die aktuelle Datenbank und Fotos durch Sicherungsdaten. Fortfahren?';

  @override
  String get restoreButton => 'Wiederherstellen';

  @override
  String get notificationPermissionDenied =>
      'Benachrichtigungsberechtigung wurde abgelehnt.';

  @override
  String get settingsButton => 'Einstellungen';

  @override
  String get premiumUnlocked =>
      '🎉 Premium aktiviert! Danke für deine Unterstützung.';

  @override
  String get restorePurchasesButton => 'Käufe wiederherstellen';

  @override
  String get noPreviousPurchases => 'Keine früheren Käufe gefunden.';

  @override
  String get purchasesRestored => '✅ Käufe wiederhergestellt!';

  @override
  String get paywallTagline => 'Unbegrenzt. Sicherheit ohne Kompromisse.';

  @override
  String get maybeLater => 'Vielleicht später';

  @override
  String get tapToUnlock => 'Tippen zum Entsperren';

  @override
  String getPremiumButton(String price) {
    return 'Premium holen – $price';
  }

  @override
  String get purchaseUnavailable =>
      'Kauf noch nicht verfügbar – Produkt im RevenueCat-Dashboard konfigurieren.';

  @override
  String get deleteServiceRecord => 'Eintrag löschen';

  @override
  String get deleteServiceRecordConfirm =>
      'Möchten Sie diesen Serviceeintrag wirklich löschen?';

  @override
  String get editServiceRecord => 'Eintrag bearbeiten';

  @override
  String get editServiceTitle => 'Serviceeintrag bearbeiten';

  @override
  String get notYetPerformed => 'Noch nicht durchgeführt';

  @override
  String get noServiceEntries => 'Noch keine Serviceeinträge';

  @override
  String get recordFirstService => 'Ersten Service erfassen';

  @override
  String get serviceHistoryFull => 'Vollständiger Serviceverlauf';

  @override
  String get warrantyExpired => 'Garantie abgelaufen';

  @override
  String get warrantySection => 'Garantie';

  @override
  String get gearInsuranceSection => 'Versicherung';

  @override
  String get noInsurancesAttached => 'Keine Versicherungen';

  @override
  String get igcLoadError => 'IGC-Datei konnte nicht geladen werden.';

  @override
  String get flightPreview => 'Flugvorschau';

  @override
  String get flightStartLabel => 'Start';

  @override
  String get flightLandingLabel => 'Landung';

  @override
  String get flightDurationLabel => 'Flugdauer';

  @override
  String get maxAltitudeLabel => 'Max. Höhe';

  @override
  String get gpsStartLabel => 'GPS-Start';

  @override
  String get stravaNotConnectedHint =>
      'Strava nicht verbunden. Einstellungen → Verknüpfte Dienste.';

  @override
  String get stravaSyncFromHelpText => 'Aktivitäten synchronisieren ab';

  @override
  String get widgetHowToAddTitle => 'Widget hinzufügen';

  @override
  String get widgetHowToStep1 =>
      '1. Leeren Bereich auf dem Startbildschirm lang drücken';

  @override
  String get widgetHowToStep2 => '2. Auf \"Widgets\" tippen';

  @override
  String get widgetHowToStep3 =>
      '3. \"OutdoorGearTracker\" in der Liste finden';

  @override
  String get widgetHowToStep4 => '4. Widget auf den Startbildschirm ziehen';

  @override
  String get understood => 'Verstanden';

  @override
  String get apiKeysTitle => 'API-Schlüssel';

  @override
  String get exportCsvLabel => 'Als CSV exportieren';

  @override
  String get exportCsvSubtitle => 'Alle Daten als CSV exportieren';

  @override
  String get signInWithGoogle => 'Mit Google anmelden';

  @override
  String get featureComingSoon => 'Funktion kommt bald';

  @override
  String get signOutGoogleAccount => 'Google-Konto abmelden';

  @override
  String get availableInPremium => 'In Premium verfügbar';

  @override
  String deleteDataError(Object error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String get exportCompleted => 'Export abgeschlossen';

  @override
  String get syncTimedOut => 'Synchronisierung abgelaufen. Erneut versuchen.';

  @override
  String get photoTakePhoto => 'Foto aufnehmen';

  @override
  String get photoFromGallery => 'Aus Galerie wählen';

  @override
  String get photoDeleteConfirm => 'Foto löschen?';

  @override
  String get photoAdd => 'Foto hinzufügen';

  @override
  String get photoChange => 'Foto ändern';

  @override
  String get apply => 'Anwenden';

  @override
  String serviceHistoryRecordCount(int count) {
    return '$count Einträge';
  }

  @override
  String warrantyValidUntil(String date) {
    return 'Gültig bis $date';
  }

  @override
  String intervalDays(String n) {
    return 'alle $n Tage';
  }

  @override
  String intervalHours(String n) {
    return 'alle $n Std.';
  }

  @override
  String intervalKm(String n) {
    return 'alle $n km';
  }

  @override
  String intervalCount(String n) {
    return 'alle $n×';
  }

  @override
  String flightAdded(String dur, String height) {
    return 'Flug hinzugefügt: $dur, max. Höhe $height m';
  }
}

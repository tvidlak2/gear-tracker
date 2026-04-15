// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'OutdoorGearTracker';

  @override
  String get navOverview => 'Přehled';

  @override
  String get navActivities => 'Aktivity';

  @override
  String get navMaintenance => 'Servis';

  @override
  String get navSettings => 'Nastavení';

  @override
  String get myGear => 'Moje vybavení';

  @override
  String get addGear => 'Přidat vybavení';

  @override
  String get add => 'Přidat';

  @override
  String get edit => 'Upravit';

  @override
  String get delete => 'Smazat';

  @override
  String get save => 'Uložit';

  @override
  String get cancel => 'Zrušit';

  @override
  String get confirm => 'Potvrdit';

  @override
  String get close => 'Zavřít';

  @override
  String get retry => 'Zkusit znovu';

  @override
  String get loading => 'Načítání…';

  @override
  String get noData => 'Žádná data';

  @override
  String get statusActive => 'Aktivní';

  @override
  String get statusRetired => 'Vyřazeno';

  @override
  String get statusLost => 'Ztraceno';

  @override
  String get gearStatus => 'Stav vybavení';

  @override
  String get gearName => 'Název';

  @override
  String get gearBrand => 'Značka';

  @override
  String get gearModel => 'Model';

  @override
  String get gearCategory => 'Kategorie';

  @override
  String get gearNotes => 'Poznámky';

  @override
  String get gearSerialNumber => 'Sériové číslo';

  @override
  String get gearPurchaseDate => 'Datum koupě';

  @override
  String get gearManufacturedDate => 'Datum výroby';

  @override
  String get gearPhoto => 'Fotografie';

  @override
  String get gearAge => 'Stáří';

  @override
  String get requiresAttention => 'Vyžaduje pozornost';

  @override
  String get allGoodTitle => 'Vše v pořádku';

  @override
  String get allGoodSubtitle => 'Žádné servisní připomínky';

  @override
  String get noGearYet => 'Zatím žádné vybavení';

  @override
  String get addFirstGear => 'Přidej své první vybavení';

  @override
  String get statusOverdue => 'Po termínu';

  @override
  String get statusWarning => 'Brzy';

  @override
  String get statusOk => 'OK';

  @override
  String get totalHours => 'Celkem hodin';

  @override
  String get totalKm => 'Celkem km';

  @override
  String get age => 'Stáří';

  @override
  String get usageCount => 'Počet použití';

  @override
  String get hours => 'Hodiny';

  @override
  String get km => 'Km';

  @override
  String get elevation => 'Nastoupáno';

  @override
  String get activities => 'Aktivity';

  @override
  String get maintenancePlan => 'Plán údržby';

  @override
  String get addMaintenanceRule => 'Přidat pravidlo';

  @override
  String get logService => 'Zapsat servis';

  @override
  String get noMaintenanceRules => 'Žádná pravidla údržby';

  @override
  String get addFirstRule => 'Přidej první pravidlo pro sledování servisu';

  @override
  String get triggerTypeDate => 'Datum';

  @override
  String get triggerTypeHours => 'Hodiny';

  @override
  String get triggerTypeKm => 'Km';

  @override
  String get triggerTypeCount => 'Počet';

  @override
  String get safetyeCritical => 'Bezpečnostně kritické';

  @override
  String get warningBefore => 'Varovat předem';

  @override
  String get ruleName => 'Název pravidla';

  @override
  String get triggerValue => 'Hodnota';

  @override
  String get nextService => 'Příští servis';

  @override
  String get lastService => 'Poslední servis';

  @override
  String get serviceHistory => 'Historie servisu';

  @override
  String get noServiceHistory => 'Žádná historie servisu';

  @override
  String overdueBy(int days) {
    return 'Po termínu o $days dní';
  }

  @override
  String dueInDays(int days) {
    return 'Za $days dní';
  }

  @override
  String get activityHistory => 'Historie aktivit';

  @override
  String get addActivity => 'Přidat aktivitu';

  @override
  String get noActivities => 'Žádné záznamy o použití';

  @override
  String get importIgc => 'Importovat IGC';

  @override
  String showAll(int count) {
    return 'Zobrazit vše ($count aktivit)';
  }

  @override
  String get hide => 'Skrýt';

  @override
  String loadMore(int count) {
    return 'Načíst více ($count zbývá)';
  }

  @override
  String get sourceManual => 'Ručně';

  @override
  String get sourceStrava => 'Strava';

  @override
  String get sourceIgc => 'IGC';

  @override
  String get sourceGarmin => 'Garmin';

  @override
  String get sourceGpx => 'GPX';

  @override
  String get stravaSync => 'Strava synchronizace';

  @override
  String get stravaConnect => 'Připojit Strava';

  @override
  String get stravaDisconnect => 'Odpojit';

  @override
  String get stravaConnected => 'Připojeno';

  @override
  String get stravasyncActivities => 'Synchronizovat aktivity';

  @override
  String get stravaAutoSync => 'Automatická synchronizace';

  @override
  String get stravaSyncFrom => 'Synchronizovat od';

  @override
  String get stravaSyncTypes => 'Typy aktivit';

  @override
  String stravaSyncSuccess(int count, String date) {
    return 'Synchronizováno: $count aktivit (nejnovější: $date)';
  }

  @override
  String get stravaSyncNoNew => 'Žádné nové aktivity';

  @override
  String stravaSyncError(String error) {
    return 'Chyba synchronizace: $error';
  }

  @override
  String get stravaCredentials => 'API přihlašovací údaje';

  @override
  String get stravaClientId => 'Client ID';

  @override
  String get stravaClientSecret => 'Client Secret';

  @override
  String get stravaSaved => 'Přihlašovací údaje uloženy';

  @override
  String get connectedServices => 'Propojené služby';

  @override
  String get notifications => 'Notifikace';

  @override
  String get notificationsEnabled => 'Notifikace zapnuty';

  @override
  String get backupExport => 'Záloha a export';

  @override
  String get exportData => 'Exportovat data';

  @override
  String get importData => 'Importovat data';

  @override
  String get clearAllData => 'Vymazat všechna data';

  @override
  String get clearAllDataConfirm =>
      'Opravdu chceš smazat všechna data? Tato akce je nevratná.';

  @override
  String get exportSuccess => 'Data exportována';

  @override
  String get importSuccess => 'Data importována';

  @override
  String get dataCleared => 'Všechna data smazána';

  @override
  String get language => 'Jazyk';

  @override
  String get statistics => 'Statistiky';

  @override
  String get activityOverTime => 'Aktivita v čase';

  @override
  String get byGear => 'Podle vybavení';

  @override
  String get recentActivities => 'Nedávné aktivity';

  @override
  String get records => 'Rekordy';

  @override
  String get longestActivity => 'Nejdelší aktivita';

  @override
  String get longestDistance => 'Nejdelší vzdálenost';

  @override
  String get mostActiveMonth => 'Nejaktivnější měsíc';

  @override
  String get mostUsedGear => 'Nejpoužívanější';

  @override
  String get gearCount => 'Kusů vybavení';

  @override
  String get maintenanceCount => 'Servisních záznamů';

  @override
  String get filterAll => 'Vše';

  @override
  String get timeFilter3M => '3M';

  @override
  String get timeFilter6M => '6M';

  @override
  String get timeFilter1Y => '1R';

  @override
  String get timeFilter2Y => '2R';

  @override
  String get timeFilterAll => 'Vše';

  @override
  String deleteGearConfirm(String name) {
    return 'Smazat $name?';
  }

  @override
  String get deleteGearWarning => 'Tato akce smaže vybavení a všechny záznamy.';

  @override
  String get performedBy => 'Provedl';

  @override
  String get cost => 'Cena';

  @override
  String get nextDueDate => 'Příští termín';

  @override
  String get performedDate => 'Datum provedení';

  @override
  String get notes => 'Poznámky';

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
  String get stravaCallbackProcessing => 'Dokončuji přihlášení ke Stravě…';

  @override
  String get stravaCallbackExchanging =>
      'Vyměňuji autorizační kód za přístupový token.';

  @override
  String get stravaCallbackRedirecting => 'Přesměrovávám zpět do nastavení…';

  @override
  String stravaAccessDenied(String error) {
    return 'Strava odmítla přístup: $error';
  }

  @override
  String get stravaMissingCode =>
      'Autorizační kód chybí. Zkus přihlášení znovu.';

  @override
  String get maintenanceOverview => 'Přehled servisu';

  @override
  String get allGear => 'Vše v pořádku';

  @override
  String itemsNeedAttention(int count) {
    return '$count položek vyžaduje pozornost';
  }

  @override
  String get sportClimbing => 'Lezení';

  @override
  String get sportSkiAlpinism => 'Skialpinismus';

  @override
  String get sportCycling => 'Cyklistika';

  @override
  String get sportParagliding => 'Paragliding';

  @override
  String get sportGeneral => 'Obecné';

  @override
  String get deleteConfirmTitle => 'Potvrdit smazání';

  @override
  String get yes => 'Ano';

  @override
  String get no => 'Ne';

  @override
  String get addGearTitle => 'Nové vybavení';

  @override
  String get editGearTitle => 'Upravit vybavení';

  @override
  String get gearSaved => 'Vybavení uloženo';

  @override
  String get locationLabel => 'Místo';

  @override
  String get dateLabel => 'Datum';

  @override
  String get durationLabel => 'Délka';

  @override
  String get distanceLabel => 'Vzdálenost';

  @override
  String get notificationsDisabled => 'Notifikace vypnuty';

  @override
  String stravaSyncedCount(int count) {
    return 'Synchronizováno $count aktivit';
  }

  @override
  String get stravaSyncedNone => 'Žádné synchronizované aktivity';

  @override
  String get insuranceTitle => 'Pojistky';

  @override
  String get addInsurance => 'Přidat pojistku';

  @override
  String get noInsurance => 'Žádné pojistky';

  @override
  String get noInsuranceHint => 'Přidej první pojistku tlačítkem +';

  @override
  String get deleteInsuranceTitle => 'Smazat pojistku?';

  @override
  String deleteInsuranceConfirm(String name) {
    return 'Opravdu smazat pojistku \"$name\"?';
  }

  @override
  String get insuranceExpired => 'Vypršela';

  @override
  String get insuranceExpiringSoon => 'Vyprší brzy';

  @override
  String get insuranceActive => 'Aktivní';

  @override
  String insuranceExpiredOn(String date) {
    return 'Vypršela $date';
  }

  @override
  String insuranceValidUntil(String date) {
    return 'Do $date';
  }

  @override
  String get totalAnnualCost => 'Celkem ročně:';

  @override
  String get insuranceDetails => 'Detaily pojistky';

  @override
  String get insuranceStartDate => 'Datum začátku';

  @override
  String get insuranceExpiryDate => 'Datum vypršení';

  @override
  String get annualPremium => 'Roční pojistné';

  @override
  String get coverageAmount => 'Pojistná částka';

  @override
  String get contractPhoto => 'Foto smlouvy';

  @override
  String get linkedGear => 'Propojené vybavení';

  @override
  String get insuranceActions => 'Akce';

  @override
  String get copyCompanyName => 'Název pojišťovny zkopírován';

  @override
  String get contactButton => 'Kontakt';

  @override
  String get reminderButton => 'Připomínka';

  @override
  String contractLabel(String number) {
    return 'Smlouva: $number';
  }

  @override
  String get editInsuranceTitle => 'Upravit pojistku';

  @override
  String get newInsuranceTitle => 'Nová pojistka';

  @override
  String get insuranceNameLabel => 'Název pojistky *';

  @override
  String get insuranceNameHint => 'např. Pojištění vybavení na hory';

  @override
  String get insuranceNameRequired => 'Zadej název';

  @override
  String get insuranceTypeLabel => 'Typ pojistky';

  @override
  String get insuranceCompanyLabel => 'Pojišťovna *';

  @override
  String get insuranceCompanyHint => 'např. Allianz';

  @override
  String get insuranceCompanyRequired => 'Zadej pojišťovnu';

  @override
  String get policyNumberLabel => 'Číslo smlouvy *';

  @override
  String get policyNumberHint => 'číslo pojistné smlouvy';

  @override
  String get policyNumberRequired => 'Zadej číslo smlouvy';

  @override
  String get validitySection => 'Platnost';

  @override
  String get financialSection => 'Finanční informace';

  @override
  String get annualPremiumLabel => 'Roční pojistné (Kč)';

  @override
  String get coverageAmountLabel => 'Pojistná částka (Kč)';

  @override
  String get optionalHint => 'volitelné';

  @override
  String get selectDate => 'Vybrat datum';

  @override
  String get selectDateRequired => 'Vybrat datum *';

  @override
  String get expiryDateRequired => 'Vyber datum vypršení.';

  @override
  String get basicInfoSection => 'Základní informace';

  @override
  String get linkedGearSection => 'Propojené vybavení';

  @override
  String get tripsTitle => 'Výlety';

  @override
  String get addTrip => 'Naplánovat výlet';

  @override
  String get noTrips => 'Žádné výlety';

  @override
  String get noTripsHint =>
      'Přidejte svůj první výlet a sestavte si checklist vybavení.';

  @override
  String get deleteTrip => 'Smazat výlet?';

  @override
  String deleteTripConfirm(String name) {
    return 'Opravdu chcete smazat výlet \"$name\"?';
  }

  @override
  String get shareChecklist => 'Sdílet checklist';

  @override
  String packingProgress(int packed, int total) {
    return '$packed/$total zabaleno';
  }

  @override
  String get tripWarnings => 'Upozornění před cestou';

  @override
  String get tripGearOverdue => 'Vyžaduje servis – překročen limit';

  @override
  String get tripGearWarning => 'Blíží se termín servisu';

  @override
  String gearChecklist(int packed, int total) {
    return 'Vybavení ($packed/$total zabaleno)';
  }

  @override
  String get noGearInTrip =>
      'Zatím žádné vybavení. Klepněte na Přidat pro výběr.';

  @override
  String get selectGearTitle => 'Vybrat vybavení';

  @override
  String get confirmSelection => 'Potvrdit výběr';

  @override
  String get editTripTitle => 'Upravit výlet';

  @override
  String get newTripTitle => 'Nový výlet';

  @override
  String get tripNameLabel => 'Název výletu *';

  @override
  String get tripNameHint => 'např. Letní trekking v Alpách';

  @override
  String get tripNameRequired => 'Zadejte název';

  @override
  String get destinationLabel => 'Destinace';

  @override
  String get destinationHint => 'např. Dolomity, Itálie';

  @override
  String get departureDateLabel => 'Datum odjezdu';

  @override
  String get returnDateLabel => 'Datum návratu';

  @override
  String get tripStatusSection => 'Stav';

  @override
  String get tripStatusLabel => 'Stav výletu';

  @override
  String get notSelected => 'Nevybráno';

  @override
  String get saveTripButton => 'Uložit výlet';

  @override
  String get dateSection => 'Termín';

  @override
  String get portfolioTitle => 'Portfolio';

  @override
  String get purchaseValue => 'Pořizovací hodnota';

  @override
  String get currentValue => 'Aktuální hodnota';

  @override
  String get annualInsuranceCost => 'Roční pojistné';

  @override
  String get maintenanceCosts => 'Náklady na údržbu';

  @override
  String get valueByCategory => 'Hodnota podle kategorie';

  @override
  String get maintenanceCostsByMonth => 'Náklady na údržbu po měsících';

  @override
  String get noMaintenanceCosts => 'Žádné záznamy o nákladech';

  @override
  String get gearByValue => 'Vybavení podle hodnoty';

  @override
  String get noGearWithPrice =>
      'Žádné vybavení s pořizovací cenou.\nPřidejte cenu v detailu vybavení.';

  @override
  String get exportForInsurance => 'Exportovat pro pojišťovnu';

  @override
  String get exportPdfComingSoon => 'Export PDF bude dostupný v příští verzi';

  @override
  String get exportPremiumMessage =>
      'Export portfolia pro pojišťovnu je prémiová funkce.';

  @override
  String get portfolioLoadError => 'Nepodařilo se načíst data.';

  @override
  String depreciatedPercent(int pct) {
    return '–$pct% odepsáno';
  }

  @override
  String get annualReportTitle => 'Roční report';

  @override
  String get annualReportPdfTitle => 'Roční přehled jako PDF';

  @override
  String get reportContains => 'Report obsahuje:';

  @override
  String get reportItemActivities => 'Celkový přehled aktivit a servisů';

  @override
  String get reportItemGearStats => 'Statistiky pro každý kus vybavení';

  @override
  String get reportItemMonthly => 'Měsíční rozklad aktivit';

  @override
  String get reportItemServiceHistory => 'Kompletní servisní historii';

  @override
  String get reportItemInsurance => 'Přehled pojistek a hodnoty portfolia';

  @override
  String get reportItemNextYear => 'Plán servisů na příští rok';

  @override
  String get selectYear => 'Vyberte rok';

  @override
  String get currentYearLabel => 'Aktuální rok';

  @override
  String get lastYearLabel => 'Minulý rok';

  @override
  String get twoYearsAgoLabel => 'Před dvěma lety';

  @override
  String generateReport(int year) {
    return 'Vygenerovat report $year';
  }

  @override
  String get generatingReport => 'Generuji report...';

  @override
  String reportError(String error) {
    return 'Chyba při generování reportu: $error';
  }

  @override
  String get reportShareHint =>
      'Po vygenerování bude PDF sdíleno přes systémový dialog (uložit, odeslat e-mailem, vytisknout...).';

  @override
  String get settingsInsuranceSection => 'Pojistky';

  @override
  String get settingsInsuranceSubtitle => 'Spravuj pojistky svého vybavení';

  @override
  String get settingsAppSection => 'Aplikace';

  @override
  String get settingsAppearance => 'Vzhled';

  @override
  String get settingsAppearanceSubtitle => 'Světlý / tmavý / systémový motiv';

  @override
  String get themeModeLight => 'Světlý motiv';

  @override
  String get themeModeDark => 'Tmavý motiv';

  @override
  String get themeModeSystem => 'Podle systému';

  @override
  String get settingsNotificationsTitle => 'Oznámení';

  @override
  String get settingsNotificationsOn =>
      'Dostaneš připomenutí před termínem servisu i po termínu.';

  @override
  String get settingsNotificationsOff =>
      'Připomínky servisních termínů jsou vypnuty.';

  @override
  String get settingsNotificationsWeb =>
      'Push notifikace nejsou v prohlížeči podporovány.\nPoužij Android / iOS aplikaci.';

  @override
  String get settingsBackupSection => 'Záloha a export';

  @override
  String get settingsAnnualReport => 'Roční report PDF';

  @override
  String get settingsAnnualReportSubtitle => 'Export přehledu roku jako PDF';

  @override
  String get settingsDataSection => 'Data';

  @override
  String get settingsImportSubtitle => 'Import ze souboru CSV nebo GPX';

  @override
  String get settingsClearSubtitle => 'Trvale odstraní vše z databáze';

  @override
  String get settingsWidgetSection => 'Widget';

  @override
  String get settingsWidgetAdd => 'Přidání widgetu';

  @override
  String get settingsWidgetAddSubtitle =>
      'Přidej widget na domovskou obrazovku: Dlouze stiskni plochu → Widgety → OutdoorGearTracker';

  @override
  String get settingsWidgetRefresh => 'Aktualizovat widget nyní';

  @override
  String get settingsWidgetRefreshed => 'Widget aktualizován';

  @override
  String get settingsAboutSection => 'O aplikaci';

  @override
  String get settingsVersion => 'Verze';

  @override
  String get settingsPrivacyPolicy => 'Zásady ochrany osobních údajů';

  @override
  String get backupSuccess => 'Záloha byla úspěšně nahrána na Google Drive.';

  @override
  String get restoreSuccess =>
      'Data byla úspěšně obnovena. Restartuj aplikaci.';

  @override
  String get restoreConfirmTitle => 'Obnovit ze zálohy?';

  @override
  String get restoreConfirmContent =>
      'Tato akce nahradí aktuální databázi a fotky daty ze zálohy. Pokračovat?';

  @override
  String get restoreButton => 'Obnovit';

  @override
  String get notificationPermissionDenied =>
      'Oprávnění pro notifikace bylo zamítnuto.';

  @override
  String get settingsButton => 'Nastavení';

  @override
  String get premiumUnlocked => '🎉 Premium aktivováno! Děkujeme za podporu.';

  @override
  String get restorePurchasesButton => 'Obnovit nákupy';

  @override
  String get noPreviousPurchases => 'Žádné předchozí nákupy nenalezeny.';

  @override
  String get purchasesRestored => '✅ Nákupy obnoveny!';

  @override
  String get paywallTagline => 'Bez omezení. Bezpečnost bez kompromisů.';

  @override
  String get maybeLater => 'Možná později';

  @override
  String get tapToUnlock => 'Klepni pro odemknutí';

  @override
  String getPremiumButton(String price) {
    return 'Získat Premium – $price';
  }

  @override
  String get purchaseUnavailable =>
      'Nákup zatím není dostupný – nakonfiguruj produkt v RevenueCat dashboardu.';

  @override
  String get deleteServiceRecord => 'Smazat záznam';

  @override
  String get deleteServiceRecordConfirm =>
      'Opravdu chcete smazat tento záznam servisu?';

  @override
  String get editServiceRecord => 'Upravit záznam';

  @override
  String get editServiceTitle => 'Upravit záznam servisu';

  @override
  String get notYetPerformed => 'Dosud neprovedeno';

  @override
  String get noServiceEntries => 'Zatím žádné záznamy servisu';

  @override
  String get recordFirstService => 'Zapsat první servis';

  @override
  String get serviceHistoryFull => 'Kompletní historie servisu';

  @override
  String get warrantyExpired => 'Záruka vypršela';

  @override
  String get warrantySection => 'Záruka';

  @override
  String get gearInsuranceSection => 'Pojištění';

  @override
  String get noInsurancesAttached => 'Žádné pojistky';

  @override
  String get igcLoadError =>
      'Nepodařilo se načíst IGC soubor. Zkontroluj formát.';

  @override
  String get flightPreview => 'Náhled letu';

  @override
  String get flightStartLabel => 'Start';

  @override
  String get flightLandingLabel => 'Přistání';

  @override
  String get flightDurationLabel => 'Délka letu';

  @override
  String get maxAltitudeLabel => 'Max výška';

  @override
  String get gpsStartLabel => 'GPS start';

  @override
  String get stravaNotConnectedHint =>
      'Strava není připojena. Přejdi do Nastavení → Propojené služby.';

  @override
  String get stravaSyncFromHelpText => 'Synchronizovat aktivity od';

  @override
  String get widgetHowToAddTitle => 'Jak přidat widget';

  @override
  String get widgetHowToStep1 =>
      '1. Dlouze stiskněte prázdné místo na ploše telefonu';

  @override
  String get widgetHowToStep2 => '2. Klepněte na \"Widgety\"';

  @override
  String get widgetHowToStep3 => '3. Najděte \"OutdoorGearTracker\" v seznamu';

  @override
  String get widgetHowToStep4 => '4. Přetáhněte widget na plochu';

  @override
  String get understood => 'Rozumím';

  @override
  String get apiKeysTitle => 'API klíče';

  @override
  String get exportCsvLabel => 'Exportovat jako CSV';

  @override
  String get exportCsvSubtitle => 'Export všech dat do CSV souboru';

  @override
  String get signInWithGoogle => 'Přihlásit se s Google';

  @override
  String get featureComingSoon => 'Funkce připravována';

  @override
  String get signOutGoogleAccount => 'Odhlásit Google účet';

  @override
  String get availableInPremium => 'Dostupné v Premium';

  @override
  String deleteDataError(Object error) {
    return 'Chyba při mazání dat: $error';
  }

  @override
  String get exportCompleted => 'Export dokončen';

  @override
  String get syncTimedOut => 'Synchronizace vypršela. Zkus znovu.';

  @override
  String get photoTakePhoto => 'Vyfotit';

  @override
  String get photoFromGallery => 'Vybrat z galerie';

  @override
  String get photoDeleteConfirm => 'Smazat fotku?';

  @override
  String get photoAdd => 'Přidat fotku';

  @override
  String get photoChange => 'Změnit fotku';

  @override
  String get apply => 'Použít';

  @override
  String serviceHistoryRecordCount(int count) {
    return '$count záznamů';
  }

  @override
  String warrantyValidUntil(String date) {
    return 'Platí do $date';
  }

  @override
  String intervalDays(String n) {
    return 'každých $n dní';
  }

  @override
  String intervalHours(String n) {
    return 'každých $n h';
  }

  @override
  String intervalKm(String n) {
    return 'každých $n km';
  }

  @override
  String intervalCount(String n) {
    return 'každých $n×';
  }

  @override
  String flightAdded(String dur, String height) {
    return 'Let přidán: $dur, max výška $height m';
  }

  @override
  String get insuranceSection => 'Pojistky';

  @override
  String get insurance => 'Pojistky';

  @override
  String get insuranceSubtitle => 'Spravuj pojistky svého vybavení';

  @override
  String get appearanceSection => 'Vzhled';

  @override
  String get appearance => 'Vzhled';

  @override
  String get appearanceSubtitle => 'Světlý / tmavý / systémový motiv';

  @override
  String get notificationsSection => 'Oznámení';

  @override
  String get applicationsSection => 'Aplikace';

  @override
  String get languageSection => 'Jazyk';

  @override
  String get trips => 'Výlety';

  @override
  String get allDataDeleted => 'Všechna data byla vymazána';

  @override
  String get stravaDisconnectHint =>
      'Odstraní přístupové tokeny. Nalogované aktivity zůstanou.';

  @override
  String get stravaApiKeyHint =>
      'Zadej Client ID a Client Secret ze svého Strava API účtu (https://www.strava.com/settings/api).';

  @override
  String get stravaConnectDescription =>
      'Propoj aplikaci se Stravou a automaticky synchronizuj aktivity jako záznamy použití vybavení.';

  @override
  String get stravaAccount => 'Strava účet';

  @override
  String get stravaLoadError =>
      'Nepodařilo se načíst stav Stravy, zkus to znovu.';

  @override
  String get stravaConnectTimeout =>
      'Připojení vypršelo (30 s). Zkontroluj síť a zkus znovu.';

  @override
  String get googleDriveBackupTitle => 'Záloha na Google Drive';

  @override
  String get googleSignInPrompt =>
      'Přihlaste se s Googlem, abyste mohli zálohovat data do Google Drive.';

  @override
  String get googleAccount => 'Google účet';

  @override
  String get autoBackupLabel => 'Automatická záloha (každých 7 dní)';

  @override
  String get uploading => 'Nahrávám...';

  @override
  String get backupNow => 'Zálohovat';

  @override
  String get premiumAllFeaturesUnlocked => 'Máš odemknuté všechny funkce';

  @override
  String get upgradeToPremium => 'Upgradovat na Premium';

  @override
  String get premiumBenefits =>
      'Neomezené vybavení, celá historie aktivit a více';

  @override
  String exportError(String error) {
    return 'Chyba exportu: $error';
  }

  @override
  String lastBackupDate(String date) {
    return 'Poslední záloha: $date';
  }

  @override
  String syncToday(String time) {
    return 'Dnes v $time';
  }

  @override
  String syncYesterday(String time) {
    return 'Včera v $time';
  }

  @override
  String stravaConnectError(String error) {
    return 'Neočekávaná chyba: $error';
  }

  @override
  String stravaSyncDateLabel(String date) {
    return 'Poslední sync: $date';
  }
}

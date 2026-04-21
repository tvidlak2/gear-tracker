// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appTitle => 'OutdoorGearTracker';

  @override
  String get navOverview => 'Prehľad';

  @override
  String get navActivities => 'Aktivity';

  @override
  String get navMaintenance => 'Servis';

  @override
  String get navSettings => 'Nastavenia';

  @override
  String get myGear => 'Moje vybavenie';

  @override
  String get addGear => 'Pridať vybavenie';

  @override
  String get add => 'Pridať';

  @override
  String get edit => 'Upraviť';

  @override
  String get delete => 'Zmazať';

  @override
  String get save => 'Uložiť';

  @override
  String get cancel => 'Zrušiť';

  @override
  String get confirm => 'Potvrdiť';

  @override
  String get close => 'Zavrieť';

  @override
  String get retry => 'Skúsiť znova';

  @override
  String get loading => 'Načítanie…';

  @override
  String get noData => 'Žiadne dáta';

  @override
  String get statusActive => 'Aktívny';

  @override
  String get statusRetired => 'Vyradený';

  @override
  String get statusLost => 'Stratený';

  @override
  String get gearStatus => 'Stav vybavenia';

  @override
  String get gearName => 'Názov';

  @override
  String get gearBrand => 'Značka';

  @override
  String get gearModel => 'Model';

  @override
  String get gearCategory => 'Kategória';

  @override
  String get gearNotes => 'Poznámky';

  @override
  String get gearSerialNumber => 'Sériové číslo';

  @override
  String get gearPurchaseDate => 'Dátum kúpy';

  @override
  String get gearManufacturedDate => 'Dátum výroby';

  @override
  String get gearPhoto => 'Fotografia';

  @override
  String get gearAge => 'Vek';

  @override
  String get requiresAttention => 'Vyžaduje pozornosť';

  @override
  String get allGoodTitle => 'Všetko v poriadku';

  @override
  String get allGoodSubtitle => 'Žiadne servisné pripomienky';

  @override
  String get noGearYet => 'Zatiaľ žiadne vybavenie';

  @override
  String get addFirstGear => 'Pridaj svoje prvé vybavenie';

  @override
  String get statusOverdue => 'Po termíne';

  @override
  String get statusWarning => 'Čoskoro';

  @override
  String get statusOk => 'OK';

  @override
  String get totalHours => 'Celkom hodín';

  @override
  String get totalKm => 'Celkom km';

  @override
  String get age => 'Vek';

  @override
  String get usageCount => 'Počet použití';

  @override
  String get hours => 'Hodiny';

  @override
  String get km => 'Km';

  @override
  String get elevation => 'Nastúpané';

  @override
  String get activities => 'Aktivity';

  @override
  String get maintenancePlan => 'Plán údržby';

  @override
  String get addMaintenanceRule => 'Pridať pravidlo';

  @override
  String get logService => 'Zapísať servis';

  @override
  String get noMaintenanceRules => 'Žiadne pravidlá údržby';

  @override
  String get addFirstRule => 'Pridaj prvé pravidlo pre sledovanie servisu';

  @override
  String get triggerTypeDate => 'Dátum';

  @override
  String get triggerTypeHours => 'Hodiny';

  @override
  String get triggerTypeKm => 'Km';

  @override
  String get triggerTypeCount => 'Počet';

  @override
  String get safetyeCritical => 'Bezpečnostne kritické';

  @override
  String get warningBefore => 'Varovať vopred';

  @override
  String get ruleName => 'Názov pravidla';

  @override
  String get triggerValue => 'Hodnota';

  @override
  String get nextService => 'Ďalší servis';

  @override
  String get lastService => 'Posledný servis';

  @override
  String get serviceHistory => 'História servisu';

  @override
  String get noServiceHistory => 'Žiadna história servisu';

  @override
  String overdueBy(int days) {
    return 'Po termíne o $days dní';
  }

  @override
  String dueInDays(int days) {
    return 'Za $days dní';
  }

  @override
  String get activityHistory => 'História aktivít';

  @override
  String get addActivity => 'Pridať aktivitu';

  @override
  String get noActivities => 'Žiadne záznamy o použití';

  @override
  String get importIgc => 'Importovať IGC';

  @override
  String showAll(int count) {
    return 'Zobraziť všetko ($count aktivít)';
  }

  @override
  String get hide => 'Skryť';

  @override
  String loadMore(int count) {
    return 'Načítať viac ($count zostáva)';
  }

  @override
  String get sourceManual => 'Ručne';

  @override
  String get sourceStrava => 'Strava';

  @override
  String get sourceIgc => 'IGC';

  @override
  String get sourceGarmin => 'Garmin';

  @override
  String get sourceGpx => 'GPX';

  @override
  String get stravaSync => 'Strava synchronizácia';

  @override
  String get stravaConnect => 'Pripojiť Strava';

  @override
  String get stravaDisconnect => 'Odpojiť';

  @override
  String get stravaConnected => 'Pripojené';

  @override
  String get stravasyncActivities => 'Synchronizovať aktivity';

  @override
  String get stravaAutoSync => 'Automatická synchronizácia';

  @override
  String get stravaSyncFrom => 'Synchronizovať od';

  @override
  String get stravaSyncTypes => 'Typy aktivít';

  @override
  String stravaSyncSuccess(int count, String date) {
    return 'Synchronizované: $count aktivít (najnovšia: $date)';
  }

  @override
  String get stravaSyncNoNew => 'Žiadne nové aktivity';

  @override
  String stravaSyncError(String error) {
    return 'Chyba synchronizácie: $error';
  }

  @override
  String get stravaCredentials => 'API prihlasovacie údaje';

  @override
  String get stravaClientId => 'Client ID';

  @override
  String get stravaClientSecret => 'Client Secret';

  @override
  String get stravaSaved => 'Prihlasovacie údaje uložené';

  @override
  String get connectedServices => 'Prepojené služby';

  @override
  String get notifications => 'Notifikácie';

  @override
  String get notificationsEnabled => 'Notifikácie zapnuté';

  @override
  String get backupExport => 'Záloha a export';

  @override
  String get exportData => 'Exportovať dáta';

  @override
  String get importData => 'Importovať dáta';

  @override
  String get clearAllData => 'Vymazať všetky dáta';

  @override
  String get clearAllDataConfirm =>
      'Naozaj chceš zmazať všetky dáta? Táto akcia je nevratná.';

  @override
  String get exportSuccess => 'Dáta exportované';

  @override
  String get importSuccess => 'Dáta importované';

  @override
  String get dataCleared => 'Všetky dáta zmazané';

  @override
  String get language => 'Jazyk';

  @override
  String get statistics => 'Štatistiky';

  @override
  String get activityOverTime => 'Aktivita v čase';

  @override
  String get byGear => 'Podľa vybavenia';

  @override
  String get recentActivities => 'Nedávne aktivity';

  @override
  String get records => 'Rekordy';

  @override
  String get longestActivity => 'Najdlhšia aktivita';

  @override
  String get longestDistance => 'Najdlhšia vzdialenosť';

  @override
  String get mostActiveMonth => 'Najaktívnejší mesiac';

  @override
  String get mostUsedGear => 'Najpoužívanejšie';

  @override
  String get gearCount => 'Kusov vybavenia';

  @override
  String get maintenanceCount => 'Servisných záznamov';

  @override
  String get filterAll => 'Všetko';

  @override
  String get timeFilter3M => '3M';

  @override
  String get timeFilter6M => '6M';

  @override
  String get timeFilter1Y => '1R';

  @override
  String get timeFilter2Y => '2R';

  @override
  String get timeFilterAll => 'Všetko';

  @override
  String deleteGearConfirm(String name) {
    return 'Zmazať $name?';
  }

  @override
  String get deleteGearWarning =>
      'Táto akcia zmaže vybavenie a všetky záznamy.';

  @override
  String get performedBy => 'Vykonal';

  @override
  String get cost => 'Cena';

  @override
  String get nextDueDate => 'Ďalší termín';

  @override
  String get performedDate => 'Dátum vykonania';

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
  String get stravaCallbackProcessing => 'Dokončujem prihlásenie do Stravy…';

  @override
  String get stravaCallbackExchanging =>
      'Vymieňam autorizačný kód za prístupový token.';

  @override
  String get stravaCallbackRedirecting => 'Presmerovávam späť do nastavení…';

  @override
  String stravaAccessDenied(String error) {
    return 'Strava odmietla prístup: $error';
  }

  @override
  String get stravaMissingCode =>
      'Autorizačný kód chýba. Skús prihlásenie znova.';

  @override
  String get maintenanceOverview => 'Prehľad servisu';

  @override
  String get allGear => 'Všetko v poriadku';

  @override
  String itemsNeedAttention(int count) {
    return '$count položiek vyžaduje pozornosť';
  }

  @override
  String get sportClimbing => 'Lezenie';

  @override
  String get sportSkiAlpinism => 'Skialpinizmus';

  @override
  String get sportCycling => 'Cyklistika';

  @override
  String get sportParagliding => 'Paragliding';

  @override
  String get sportGeneral => 'Všeobecné';

  @override
  String get deleteConfirmTitle => 'Potvrdiť zmazanie';

  @override
  String get yes => 'Áno';

  @override
  String get no => 'Nie';

  @override
  String get addGearTitle => 'Nové vybavenie';

  @override
  String get editGearTitle => 'Upraviť vybavenie';

  @override
  String get gearSaved => 'Vybavenie uložené';

  @override
  String get locationLabel => 'Miesto';

  @override
  String get dateLabel => 'Dátum';

  @override
  String get durationLabel => 'Dĺžka';

  @override
  String get distanceLabel => 'Vzdialenosť';

  @override
  String get notificationsDisabled => 'Notifikácie vypnuté';

  @override
  String stravaSyncedCount(int count) {
    return 'Synchronizovaných $count aktivít';
  }

  @override
  String get stravaSyncedNone => 'Žiadne synchronizované aktivity';

  @override
  String get insuranceTitle => 'Poistky';

  @override
  String get addInsurance => 'Pridať poistku';

  @override
  String get noInsurance => 'Žiadne poistky';

  @override
  String get noInsuranceHint => 'Pridaj prvú poistku tlačidlom +';

  @override
  String get deleteInsuranceTitle => 'Zmazať poistku?';

  @override
  String deleteInsuranceConfirm(String name) {
    return 'Naozaj zmazať poistku \"$name\"?';
  }

  @override
  String get insuranceExpired => 'Vypršala';

  @override
  String get insuranceExpiringSoon => 'Vyprší čoskoro';

  @override
  String get insuranceActive => 'Aktívna';

  @override
  String insuranceExpiredOn(String date) {
    return 'Vypršala $date';
  }

  @override
  String insuranceValidUntil(String date) {
    return 'Do $date';
  }

  @override
  String get totalAnnualCost => 'Spolu ročne:';

  @override
  String get insuranceDetails => 'Detaily poistky';

  @override
  String get insuranceStartDate => 'Dátum začiatku';

  @override
  String get insuranceExpiryDate => 'Dátum vypršania';

  @override
  String get annualPremium => 'Ročné poistné';

  @override
  String get coverageAmount => 'Poistná suma';

  @override
  String get contractPhoto => 'Foto zmluvy';

  @override
  String get linkedGear => 'Prepojené vybavenie';

  @override
  String get insuranceActions => 'Akcie';

  @override
  String get copyCompanyName => 'Názov poisťovne skopírovaný';

  @override
  String get contactButton => 'Kontakt';

  @override
  String get reminderButton => 'Pripomienka';

  @override
  String contractLabel(String number) {
    return 'Zmluva: $number';
  }

  @override
  String get editInsuranceTitle => 'Upraviť poistku';

  @override
  String get newInsuranceTitle => 'Nová poistka';

  @override
  String get insuranceNameLabel => 'Názov poistky *';

  @override
  String get insuranceNameHint => 'napr. Poistenie vybavenia na hory';

  @override
  String get insuranceNameRequired => 'Zadaj názov';

  @override
  String get insuranceTypeLabel => 'Typ poistky';

  @override
  String get insuranceCompanyLabel => 'Poisťovňa *';

  @override
  String get insuranceCompanyHint => 'napr. Allianz';

  @override
  String get insuranceCompanyRequired => 'Zadaj poisťovňu';

  @override
  String get policyNumberLabel => 'Číslo zmluvy *';

  @override
  String get policyNumberHint => 'číslo poistnej zmluvy';

  @override
  String get policyNumberRequired => 'Zadaj číslo zmluvy';

  @override
  String get validitySection => 'Platnosť';

  @override
  String get financialSection => 'Finančné informácie';

  @override
  String get annualPremiumLabel => 'Ročné poistné';

  @override
  String get coverageAmountLabel => 'Poistná suma';

  @override
  String get optionalHint => 'voliteľné';

  @override
  String get selectDate => 'Vybrať dátum';

  @override
  String get selectDateRequired => 'Vybrať dátum *';

  @override
  String get expiryDateRequired => 'Vyber dátum vypršania.';

  @override
  String get basicInfoSection => 'Základné informácie';

  @override
  String get linkedGearSection => 'Prepojené vybavenie';

  @override
  String get tripsTitle => 'Výlety';

  @override
  String get addTrip => 'Naplánovať výlet';

  @override
  String get noTrips => 'Žiadne výlety';

  @override
  String get noTripsHint =>
      'Pridajte svoj prvý výlet a zostavte si checklist vybavenia.';

  @override
  String get deleteTrip => 'Zmazať výlet?';

  @override
  String deleteTripConfirm(String name) {
    return 'Naozaj chcete zmazať výlet \"$name\"?';
  }

  @override
  String get shareChecklist => 'Zdieľať checklist';

  @override
  String packingProgress(int packed, int total) {
    return '$packed/$total zabalené';
  }

  @override
  String get tripWarnings => 'Upozornenia pred cestou';

  @override
  String get tripGearOverdue => 'Vyžaduje servis – prekročený limit';

  @override
  String get tripGearWarning => 'Blíži sa termín servisu';

  @override
  String gearChecklist(int packed, int total) {
    return 'Vybavenie ($packed/$total zabalené)';
  }

  @override
  String get noGearInTrip =>
      'Zatiaľ žiadne vybavenie. Klepnite na Pridať pre výber.';

  @override
  String get selectGearTitle => 'Vybrať vybavenie';

  @override
  String get addCustomItem => 'Vlastná položka';

  @override
  String get customItemHint => 'napr. ponožky, lieky, nabíjačka';

  @override
  String get confirmSelection => 'Potvrdiť výber';

  @override
  String get editTripTitle => 'Upraviť výlet';

  @override
  String get newTripTitle => 'Nový výlet';

  @override
  String get tripNameLabel => 'Názov výletu *';

  @override
  String get tripNameHint => 'napr. Letný trekking v Alpách';

  @override
  String get tripNameRequired => 'Zadajte názov';

  @override
  String get destinationLabel => 'Destinácia';

  @override
  String get destinationHint => 'napr. Dolomity, Taliansko';

  @override
  String get departureDateLabel => 'Dátum odchodu';

  @override
  String get returnDateLabel => 'Dátum návratu';

  @override
  String get tripStatusSection => 'Stav';

  @override
  String get tripStatusLabel => 'Stav výletu';

  @override
  String get notSelected => 'Nevybrané';

  @override
  String get saveTripButton => 'Uložiť výlet';

  @override
  String get dateSection => 'Termín';

  @override
  String get portfolioTitle => 'Portfólio';

  @override
  String get purchaseValue => 'Obstarávacia hodnota';

  @override
  String get currentValue => 'Aktuálna hodnota';

  @override
  String get annualInsuranceCost => 'Ročné poistné';

  @override
  String get maintenanceCosts => 'Náklady na údržbu';

  @override
  String get valueByCategory => 'Hodnota podľa kategórie';

  @override
  String get maintenanceCostsByMonth => 'Náklady na údržbu po mesiacoch';

  @override
  String get noMaintenanceCosts => 'Žiadne záznamy o nákladoch';

  @override
  String get gearByValue => 'Vybavenie podľa hodnoty';

  @override
  String get noGearWithPrice =>
      'Žiadne vybavenie s obstarávacou cenou.\nPridajte cenu v detaile vybavenia.';

  @override
  String get exportForInsurance => 'Exportovať pre poisťovňu';

  @override
  String get exportPdfComingSoon =>
      'Export PDF bude dostupný v nasledujúcej verzii';

  @override
  String get exportPremiumMessage =>
      'Export portfólia pre poisťovňu je prémiová funkcia.';

  @override
  String get portfolioLoadError => 'Nepodarilo sa načítať dáta.';

  @override
  String depreciatedPercent(int pct) {
    return '–$pct% odpísané';
  }

  @override
  String get annualReportTitle => 'Ročný report';

  @override
  String get annualReportPdfTitle => 'Ročný prehľad ako PDF';

  @override
  String get reportContains => 'Report obsahuje:';

  @override
  String get reportItemActivities => 'Celkový prehľad aktivít a servisov';

  @override
  String get reportItemGearStats => 'Štatistiky pre každý kus vybavenia';

  @override
  String get reportItemMonthly => 'Mesačný rozklad aktivít';

  @override
  String get reportItemServiceHistory => 'Kompletná servisná história';

  @override
  String get reportItemInsurance => 'Prehľad poistiek a hodnoty portfólia';

  @override
  String get reportItemNextYear => 'Plán servisov na nasledujúci rok';

  @override
  String get selectYear => 'Vyberte rok';

  @override
  String get currentYearLabel => 'Aktuálny rok';

  @override
  String get lastYearLabel => 'Minulý rok';

  @override
  String get twoYearsAgoLabel => 'Pred dvoma rokmi';

  @override
  String generateReport(int year) {
    return 'Vygenerovať report $year';
  }

  @override
  String get generatingReport => 'Generujem report...';

  @override
  String reportError(String error) {
    return 'Chyba pri generovaní reportu: $error';
  }

  @override
  String get reportShareHint =>
      'Po vygenerovaní bude PDF zdieľané cez systémový dialóg (uložiť, odoslať e-mailom, vytlačiť...).';

  @override
  String get settingsInsuranceSection => 'Poistky';

  @override
  String get settingsInsuranceSubtitle => 'Spravuj poistky svojho vybavenia';

  @override
  String get settingsAppSection => 'Aplikácia';

  @override
  String get settingsAppearance => 'Vzhľad';

  @override
  String get settingsAppearanceSubtitle => 'Svetlý / tmavý / systémový motív';

  @override
  String get themeModeLight => 'Svetlý motív';

  @override
  String get themeModeDark => 'Tmavý motív';

  @override
  String get themeModeSystem => 'Podľa systému';

  @override
  String get settingsNotificationsTitle => 'Oznámenia';

  @override
  String get settingsNotificationsOn =>
      'Dostaneš pripomienky pred termínom servisu aj po termíne.';

  @override
  String get settingsNotificationsOff =>
      'Pripomienky servisných termínov sú vypnuté.';

  @override
  String get settingsNotificationsWeb =>
      'Push notifikácie nie sú v prehliadači podporované.\nPoužite Android / iOS aplikáciu.';

  @override
  String get settingsBackupSection => 'Záloha a export';

  @override
  String get settingsAnnualReport => 'Ročný report PDF';

  @override
  String get settingsAnnualReportSubtitle => 'Export prehľadu roku ako PDF';

  @override
  String get settingsDataSection => 'Dáta';

  @override
  String get settingsImportSubtitle => 'Import zo súboru CSV alebo GPX';

  @override
  String get settingsClearSubtitle => 'Trvalo odstráni všetko z databázy';

  @override
  String get settingsWidgetSection => 'Widget';

  @override
  String get settingsWidgetAdd => 'Pridanie widgetu';

  @override
  String get settingsWidgetAddSubtitle =>
      'Pridaj widget na domovskú obrazovku: Dlho stlač plochu → Widgety → OutdoorGearTracker';

  @override
  String get settingsWidgetRefresh => 'Aktualizovať widget teraz';

  @override
  String get settingsWidgetRefreshed => 'Widget aktualizovaný';

  @override
  String get settingsAboutSection => 'O aplikácii';

  @override
  String get settingsVersion => 'Verzia';

  @override
  String get settingsPrivacyPolicy => 'Zásady ochrany osobných údajov';

  @override
  String get backupSuccess => 'Záloha bola úspešne nahratá na Google Drive.';

  @override
  String get restoreSuccess =>
      'Dáta boli úspešne obnovené. Reštartuj aplikáciu.';

  @override
  String get restoreConfirmTitle => 'Obnoviť zo zálohy?';

  @override
  String get restoreConfirmContent =>
      'Táto akcia nahradí aktuálnu databázu a fotky dátami zo zálohy. Pokračovať?';

  @override
  String get restoreButton => 'Obnoviť';

  @override
  String get notificationPermissionDenied =>
      'Oprávnenie pre notifikácie bolo zamietnuté.';

  @override
  String get settingsButton => 'Nastavenia';

  @override
  String get premiumUnlocked => '🎉 Premium aktivované! Ďakujeme za podporu.';

  @override
  String get restorePurchasesButton => 'Obnoviť nákupy';

  @override
  String get noPreviousPurchases => 'Žiadne predchádzajúce nákupy nenájdené.';

  @override
  String get purchasesRestored => '✅ Nákupy obnovené!';

  @override
  String get paywallTagline => 'Bez obmedzení. Bezpečnosť bez kompromisov.';

  @override
  String get maybeLater => 'Možno neskôr';

  @override
  String get tapToUnlock => 'Klepni pre odomknutie';

  @override
  String getPremiumButton(String price) {
    return 'Získať Premium – $price';
  }

  @override
  String get purchaseUnavailable =>
      'Nákup momentálne nie je dostupný. Skús to prosím neskôr.';

  @override
  String get deleteServiceRecord => 'Zmazať záznam';

  @override
  String get deleteServiceRecordConfirm =>
      'Naozaj chcete zmazať tento záznam servisu?';

  @override
  String get editServiceRecord => 'Upraviť záznam';

  @override
  String get editServiceTitle => 'Upraviť záznam servisu';

  @override
  String get notYetPerformed => 'Zatiaľ neudené';

  @override
  String get noServiceEntries => 'Zatiaľ žiadne záznamy servisu';

  @override
  String get recordFirstService => 'Zapísať prvý servis';

  @override
  String get serviceHistoryFull => 'Kompletná história servisu';

  @override
  String get warrantyExpired => 'Záruka vypršala';

  @override
  String get warrantySection => 'Záruka';

  @override
  String get gearInsuranceSection => 'Poistenie';

  @override
  String get noInsurancesAttached => 'Žiadne poistky';

  @override
  String get igcLoadError =>
      'Nepodarilo sa načítať IGC súbor. Skontroluj formát.';

  @override
  String get flightPreview => 'Náhľad letu';

  @override
  String get flightStartLabel => 'Štart';

  @override
  String get flightLandingLabel => 'Pristátie';

  @override
  String get flightDurationLabel => 'Dĺžka letu';

  @override
  String get maxAltitudeLabel => 'Max výška';

  @override
  String get gpsStartLabel => 'GPS štart';

  @override
  String get stravaNotConnectedHint =>
      'Strava nie je pripojená. Prejdi do Nastavenia → Prepojené služby.';

  @override
  String get stravaSyncFromHelpText => 'Synchronizovať aktivity od';

  @override
  String get widgetHowToAddTitle => 'Ako pridať widget';

  @override
  String get widgetHowToStep1 =>
      '1. Dlho stlačte prázdne miesto na ploche telefónu';

  @override
  String get widgetHowToStep2 => '2. Klepnite na \"Widgety\"';

  @override
  String get widgetHowToStep3 => '3. Nájdite \"OutdoorGearTracker\" v zozname';

  @override
  String get widgetHowToStep4 => '4. Presuňte widget na plochu';

  @override
  String get understood => 'Rozumiem';

  @override
  String get apiKeysTitle => 'API kľúče';

  @override
  String get exportCsvLabel => 'Exportovať ako CSV';

  @override
  String get exportCsvSubtitle => 'Export všetkých dát do CSV súboru';

  @override
  String get signInWithGoogle => 'Prihlásiť sa cez Google';

  @override
  String get featureComingSoon => 'Funkcia sa pripravuje';

  @override
  String get signOutGoogleAccount => 'Odhlásiť Google účet';

  @override
  String get availableInPremium => 'Dostupné v Premium';

  @override
  String deleteDataError(Object error) {
    return 'Chyba pri mazaní dát: $error';
  }

  @override
  String get exportCompleted => 'Export dokončený';

  @override
  String get syncTimedOut => 'Synchronizácia vypršala. Skús znova.';

  @override
  String get photoTakePhoto => 'Odfotiť';

  @override
  String get photoFromGallery => 'Vybrať z galérie';

  @override
  String get photoDeleteConfirm => 'Zmazať fotku?';

  @override
  String get photoAdd => 'Pridať fotku';

  @override
  String get photoChange => 'Zmeniť fotku';

  @override
  String get apply => 'Použiť';

  @override
  String serviceHistoryRecordCount(int count) {
    return '$count záznamov';
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
    return 'Let pridaný: $dur, max výška $height m';
  }

  @override
  String get insuranceSection => 'Poistky';

  @override
  String get insurance => 'Poistky';

  @override
  String get insuranceSubtitle => 'Spravuj poistky svojho vybavenia';

  @override
  String get appearanceSection => 'Vzhľad';

  @override
  String get appearance => 'Vzhľad';

  @override
  String get appearanceSubtitle => 'Svetlý / tmavý / systémový motív';

  @override
  String get notificationsSection => 'Oznámenia';

  @override
  String get applicationsSection => 'Aplikácia';

  @override
  String get languageSection => 'Jazyk';

  @override
  String get trips => 'Výlety';

  @override
  String get allDataDeleted => 'Všetky dáta boli vymazané';

  @override
  String get stravaDisconnectHint =>
      'Odstráni prístupové tokeny. Zalogované aktivity zostanú.';

  @override
  String get stravaApiKeyHint =>
      'Zadaj Client ID a Client Secret zo svojho Strava API účtu (https://www.strava.com/settings/api).';

  @override
  String get stravaConnectDescription =>
      'Prepoj aplikáciu so Stravou a automaticky synchronizuj aktivity ako záznamy použitia vybavenia.';

  @override
  String get stravaAccount => 'Strava účet';

  @override
  String get stravaLoadError =>
      'Nepodarilo sa načítať stav Stravy, skús to znova.';

  @override
  String get stravaConnectTimeout =>
      'Pripojenie vypršalo (30 s). Skontroluj sieť a skús znova.';

  @override
  String get googleDriveBackupTitle => 'Záloha na Google Drive';

  @override
  String get googleSignInPrompt =>
      'Prihláste sa cez Google, aby ste mohli zálohovať dáta na Google Drive.';

  @override
  String get googleAccount => 'Google účet';

  @override
  String get autoBackupLabel => 'Automatická záloha (každých 7 dní)';

  @override
  String get uploading => 'Nahrávam...';

  @override
  String get backupNow => 'Zálohovať';

  @override
  String get premiumAllFeaturesUnlocked => 'Máš odomknuté všetky funkcie';

  @override
  String get upgradeToPremium => 'Upgradovať na Premium';

  @override
  String get premiumBenefits =>
      'Neobmedzené vybavenie, celá história aktivít a viac';

  @override
  String exportError(String error) {
    return 'Chyba exportu: $error';
  }

  @override
  String lastBackupDate(String date) {
    return 'Posledná záloha: $date';
  }

  @override
  String syncToday(String time) {
    return 'Dnes o $time';
  }

  @override
  String syncYesterday(String time) {
    return 'Včera o $time';
  }

  @override
  String stravaConnectError(String error) {
    return 'Neočakávaná chyba: $error';
  }

  @override
  String stravaSyncDateLabel(String date) {
    return 'Posledný sync: $date';
  }
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appTitle => 'GearTracker';

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
}

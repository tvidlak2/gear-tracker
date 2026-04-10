// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'GearTracker';

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
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_sk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('sk'),
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('it')
  ];

  /// App name
  ///
  /// In cs, this message translates to:
  /// **'GearTracker'**
  String get appTitle;

  /// Bottom nav: overview tab
  ///
  /// In cs, this message translates to:
  /// **'Přehled'**
  String get navOverview;

  /// Bottom nav: activities tab
  ///
  /// In cs, this message translates to:
  /// **'Aktivity'**
  String get navActivities;

  /// Bottom nav: maintenance tab
  ///
  /// In cs, this message translates to:
  /// **'Servis'**
  String get navMaintenance;

  /// Bottom nav: settings tab
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get navSettings;

  /// Gear list screen title
  ///
  /// In cs, this message translates to:
  /// **'Moje vybavení'**
  String get myGear;

  /// Button/FAB to add gear
  ///
  /// In cs, this message translates to:
  /// **'Přidat vybavení'**
  String get addGear;

  /// Generic add button
  ///
  /// In cs, this message translates to:
  /// **'Přidat'**
  String get add;

  /// Generic edit button
  ///
  /// In cs, this message translates to:
  /// **'Upravit'**
  String get edit;

  /// Generic delete button
  ///
  /// In cs, this message translates to:
  /// **'Smazat'**
  String get delete;

  /// Generic save button
  ///
  /// In cs, this message translates to:
  /// **'Uložit'**
  String get save;

  /// Generic cancel button
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get cancel;

  /// Generic confirm button
  ///
  /// In cs, this message translates to:
  /// **'Potvrdit'**
  String get confirm;

  /// Generic close button
  ///
  /// In cs, this message translates to:
  /// **'Zavřít'**
  String get close;

  /// Retry button
  ///
  /// In cs, this message translates to:
  /// **'Zkusit znovu'**
  String get retry;

  /// Loading indicator text
  ///
  /// In cs, this message translates to:
  /// **'Načítání…'**
  String get loading;

  /// Empty state: no data
  ///
  /// In cs, this message translates to:
  /// **'Žádná data'**
  String get noData;

  /// Gear status: active
  ///
  /// In cs, this message translates to:
  /// **'Aktivní'**
  String get statusActive;

  /// Gear status: retired
  ///
  /// In cs, this message translates to:
  /// **'Vyřazeno'**
  String get statusRetired;

  /// Gear status: lost
  ///
  /// In cs, this message translates to:
  /// **'Ztraceno'**
  String get statusLost;

  /// Label for gear status field
  ///
  /// In cs, this message translates to:
  /// **'Stav vybavení'**
  String get gearStatus;

  /// Label for gear name field
  ///
  /// In cs, this message translates to:
  /// **'Název'**
  String get gearName;

  /// Label for gear brand field
  ///
  /// In cs, this message translates to:
  /// **'Značka'**
  String get gearBrand;

  /// Label for gear model field
  ///
  /// In cs, this message translates to:
  /// **'Model'**
  String get gearModel;

  /// Label for gear category field
  ///
  /// In cs, this message translates to:
  /// **'Kategorie'**
  String get gearCategory;

  /// Label for gear notes field
  ///
  /// In cs, this message translates to:
  /// **'Poznámky'**
  String get gearNotes;

  /// Label for serial number field
  ///
  /// In cs, this message translates to:
  /// **'Sériové číslo'**
  String get gearSerialNumber;

  /// Label for purchase date field
  ///
  /// In cs, this message translates to:
  /// **'Datum koupě'**
  String get gearPurchaseDate;

  /// Label for manufacture date field
  ///
  /// In cs, this message translates to:
  /// **'Datum výroby'**
  String get gearManufacturedDate;

  /// Label for gear photo
  ///
  /// In cs, this message translates to:
  /// **'Fotografie'**
  String get gearPhoto;

  /// Label for gear age
  ///
  /// In cs, this message translates to:
  /// **'Stáří'**
  String get gearAge;

  /// Maintenance alert: requires attention
  ///
  /// In cs, this message translates to:
  /// **'Vyžaduje pozornost'**
  String get requiresAttention;

  /// Empty maintenance state title
  ///
  /// In cs, this message translates to:
  /// **'Vše v pořádku'**
  String get allGoodTitle;

  /// Empty maintenance state subtitle
  ///
  /// In cs, this message translates to:
  /// **'Žádné servisní připomínky'**
  String get allGoodSubtitle;

  /// Empty gear list state
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné vybavení'**
  String get noGearYet;

  /// Empty gear list CTA
  ///
  /// In cs, this message translates to:
  /// **'Přidej své první vybavení'**
  String get addFirstGear;

  /// Maintenance status: overdue
  ///
  /// In cs, this message translates to:
  /// **'Po termínu'**
  String get statusOverdue;

  /// Maintenance status: coming soon
  ///
  /// In cs, this message translates to:
  /// **'Brzy'**
  String get statusWarning;

  /// Maintenance status: OK
  ///
  /// In cs, this message translates to:
  /// **'OK'**
  String get statusOk;

  /// Stat label: total hours
  ///
  /// In cs, this message translates to:
  /// **'Celkem hodin'**
  String get totalHours;

  /// Stat label: total km
  ///
  /// In cs, this message translates to:
  /// **'Celkem km'**
  String get totalKm;

  /// Stat label: age
  ///
  /// In cs, this message translates to:
  /// **'Stáří'**
  String get age;

  /// Stat label: usage count
  ///
  /// In cs, this message translates to:
  /// **'Počet použití'**
  String get usageCount;

  /// Unit label: hours
  ///
  /// In cs, this message translates to:
  /// **'Hodiny'**
  String get hours;

  /// Unit label: km
  ///
  /// In cs, this message translates to:
  /// **'Km'**
  String get km;

  /// Stat label: elevation gained
  ///
  /// In cs, this message translates to:
  /// **'Nastoupáno'**
  String get elevation;

  /// Stat label: activities
  ///
  /// In cs, this message translates to:
  /// **'Aktivity'**
  String get activities;

  /// Section header: maintenance plan
  ///
  /// In cs, this message translates to:
  /// **'Plán údržby'**
  String get maintenancePlan;

  /// Button to add maintenance rule
  ///
  /// In cs, this message translates to:
  /// **'Přidat pravidlo'**
  String get addMaintenanceRule;

  /// Button to log a service
  ///
  /// In cs, this message translates to:
  /// **'Zapsat servis'**
  String get logService;

  /// Empty state: no maintenance rules
  ///
  /// In cs, this message translates to:
  /// **'Žádná pravidla údržby'**
  String get noMaintenanceRules;

  /// Empty maintenance rules CTA
  ///
  /// In cs, this message translates to:
  /// **'Přidej první pravidlo pro sledování servisu'**
  String get addFirstRule;

  /// Trigger type: date
  ///
  /// In cs, this message translates to:
  /// **'Datum'**
  String get triggerTypeDate;

  /// Trigger type: hours
  ///
  /// In cs, this message translates to:
  /// **'Hodiny'**
  String get triggerTypeHours;

  /// Trigger type: km
  ///
  /// In cs, this message translates to:
  /// **'Km'**
  String get triggerTypeKm;

  /// Trigger type: count
  ///
  /// In cs, this message translates to:
  /// **'Počet'**
  String get triggerTypeCount;

  /// Label: safety critical checkbox
  ///
  /// In cs, this message translates to:
  /// **'Bezpečnostně kritické'**
  String get safetyeCritical;

  /// Label: warn before due
  ///
  /// In cs, this message translates to:
  /// **'Varovat předem'**
  String get warningBefore;

  /// Field label: rule name
  ///
  /// In cs, this message translates to:
  /// **'Název pravidla'**
  String get ruleName;

  /// Field label: trigger value
  ///
  /// In cs, this message translates to:
  /// **'Hodnota'**
  String get triggerValue;

  /// Label: next service
  ///
  /// In cs, this message translates to:
  /// **'Příští servis'**
  String get nextService;

  /// Label: last service
  ///
  /// In cs, this message translates to:
  /// **'Poslední servis'**
  String get lastService;

  /// Section header: service history
  ///
  /// In cs, this message translates to:
  /// **'Historie servisu'**
  String get serviceHistory;

  /// Empty state: no service history
  ///
  /// In cs, this message translates to:
  /// **'Žádná historie servisu'**
  String get noServiceHistory;

  /// Overdue message with day count
  ///
  /// In cs, this message translates to:
  /// **'Po termínu o {days} dní'**
  String overdueBy(int days);

  /// Due in N days message
  ///
  /// In cs, this message translates to:
  /// **'Za {days} dní'**
  String dueInDays(int days);

  /// Section header: activity history
  ///
  /// In cs, this message translates to:
  /// **'Historie aktivit'**
  String get activityHistory;

  /// Button to add activity
  ///
  /// In cs, this message translates to:
  /// **'Přidat aktivitu'**
  String get addActivity;

  /// Empty state: no activities
  ///
  /// In cs, this message translates to:
  /// **'Žádné záznamy o použití'**
  String get noActivities;

  /// Button to import IGC file
  ///
  /// In cs, this message translates to:
  /// **'Importovat IGC'**
  String get importIgc;

  /// Button to show all activities
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit vše ({count} aktivit)'**
  String showAll(int count);

  /// Button to hide/collapse
  ///
  /// In cs, this message translates to:
  /// **'Skrýt'**
  String get hide;

  /// Button to load more items
  ///
  /// In cs, this message translates to:
  /// **'Načíst více ({count} zbývá)'**
  String loadMore(int count);

  /// Activity source: manual
  ///
  /// In cs, this message translates to:
  /// **'Ručně'**
  String get sourceManual;

  /// Activity source: Strava
  ///
  /// In cs, this message translates to:
  /// **'Strava'**
  String get sourceStrava;

  /// Activity source: IGC
  ///
  /// In cs, this message translates to:
  /// **'IGC'**
  String get sourceIgc;

  /// Activity source: Garmin
  ///
  /// In cs, this message translates to:
  /// **'Garmin'**
  String get sourceGarmin;

  /// Activity source: GPX
  ///
  /// In cs, this message translates to:
  /// **'GPX'**
  String get sourceGpx;

  /// Strava sync section title
  ///
  /// In cs, this message translates to:
  /// **'Strava synchronizace'**
  String get stravaSync;

  /// Button to connect Strava
  ///
  /// In cs, this message translates to:
  /// **'Připojit Strava'**
  String get stravaConnect;

  /// Button to disconnect Strava
  ///
  /// In cs, this message translates to:
  /// **'Odpojit'**
  String get stravaDisconnect;

  /// Strava connected badge
  ///
  /// In cs, this message translates to:
  /// **'Připojeno'**
  String get stravaConnected;

  /// Button to sync Strava activities
  ///
  /// In cs, this message translates to:
  /// **'Synchronizovat aktivity'**
  String get stravasyncActivities;

  /// Label: auto sync toggle
  ///
  /// In cs, this message translates to:
  /// **'Automatická synchronizace'**
  String get stravaAutoSync;

  /// Label: sync from date
  ///
  /// In cs, this message translates to:
  /// **'Synchronizovat od'**
  String get stravaSyncFrom;

  /// Label: activity types to sync
  ///
  /// In cs, this message translates to:
  /// **'Typy aktivit'**
  String get stravaSyncTypes;

  /// Strava sync success message
  ///
  /// In cs, this message translates to:
  /// **'Synchronizováno: {count} aktivit (nejnovější: {date})'**
  String stravaSyncSuccess(int count, String date);

  /// Strava sync: no new activities
  ///
  /// In cs, this message translates to:
  /// **'Žádné nové aktivity'**
  String get stravaSyncNoNew;

  /// Strava sync error message
  ///
  /// In cs, this message translates to:
  /// **'Chyba synchronizace: {error}'**
  String stravaSyncError(String error);

  /// Label: Strava API credentials
  ///
  /// In cs, this message translates to:
  /// **'API přihlašovací údaje'**
  String get stravaCredentials;

  /// Label: Strava client ID
  ///
  /// In cs, this message translates to:
  /// **'Client ID'**
  String get stravaClientId;

  /// Label: Strava client secret
  ///
  /// In cs, this message translates to:
  /// **'Client Secret'**
  String get stravaClientSecret;

  /// Snackbar: credentials saved
  ///
  /// In cs, this message translates to:
  /// **'Přihlašovací údaje uloženy'**
  String get stravaSaved;

  /// Section header: connected services
  ///
  /// In cs, this message translates to:
  /// **'Propojené služby'**
  String get connectedServices;

  /// Section header: notifications
  ///
  /// In cs, this message translates to:
  /// **'Notifikace'**
  String get notifications;

  /// Label: notifications enabled
  ///
  /// In cs, this message translates to:
  /// **'Notifikace zapnuty'**
  String get notificationsEnabled;

  /// Settings tile: backup and export
  ///
  /// In cs, this message translates to:
  /// **'Záloha a export'**
  String get backupExport;

  /// Button to export data
  ///
  /// In cs, this message translates to:
  /// **'Exportovat data'**
  String get exportData;

  /// Button to import data
  ///
  /// In cs, this message translates to:
  /// **'Importovat data'**
  String get importData;

  /// Button to clear all data
  ///
  /// In cs, this message translates to:
  /// **'Vymazat všechna data'**
  String get clearAllData;

  /// Confirmation dialog: clear all data
  ///
  /// In cs, this message translates to:
  /// **'Opravdu chceš smazat všechna data? Tato akce je nevratná.'**
  String get clearAllDataConfirm;

  /// Snackbar: export success
  ///
  /// In cs, this message translates to:
  /// **'Data exportována'**
  String get exportSuccess;

  /// Snackbar: import success
  ///
  /// In cs, this message translates to:
  /// **'Data importována'**
  String get importSuccess;

  /// Snackbar: data cleared
  ///
  /// In cs, this message translates to:
  /// **'Všechna data smazána'**
  String get dataCleared;

  /// Settings tile: language
  ///
  /// In cs, this message translates to:
  /// **'Jazyk'**
  String get language;

  /// Screen title: statistics
  ///
  /// In cs, this message translates to:
  /// **'Statistiky'**
  String get statistics;

  /// Chart label: activity over time
  ///
  /// In cs, this message translates to:
  /// **'Aktivita v čase'**
  String get activityOverTime;

  /// Filter label: by gear
  ///
  /// In cs, this message translates to:
  /// **'Podle vybavení'**
  String get byGear;

  /// Section header: recent activities
  ///
  /// In cs, this message translates to:
  /// **'Nedávné aktivity'**
  String get recentActivities;

  /// Section header: records
  ///
  /// In cs, this message translates to:
  /// **'Rekordy'**
  String get records;

  /// Record label: longest activity
  ///
  /// In cs, this message translates to:
  /// **'Nejdelší aktivita'**
  String get longestActivity;

  /// Record label: longest distance
  ///
  /// In cs, this message translates to:
  /// **'Nejdelší vzdálenost'**
  String get longestDistance;

  /// Record label: most active month
  ///
  /// In cs, this message translates to:
  /// **'Nejaktivnější měsíc'**
  String get mostActiveMonth;

  /// Record label: most used gear
  ///
  /// In cs, this message translates to:
  /// **'Nejpoužívanější'**
  String get mostUsedGear;

  /// Stat label: gear count
  ///
  /// In cs, this message translates to:
  /// **'Kusů vybavení'**
  String get gearCount;

  /// Stat label: maintenance records
  ///
  /// In cs, this message translates to:
  /// **'Servisních záznamů'**
  String get maintenanceCount;

  /// Filter chip: all
  ///
  /// In cs, this message translates to:
  /// **'Vše'**
  String get filterAll;

  /// Time filter: 3 months
  ///
  /// In cs, this message translates to:
  /// **'3M'**
  String get timeFilter3M;

  /// Time filter: 6 months
  ///
  /// In cs, this message translates to:
  /// **'6M'**
  String get timeFilter6M;

  /// Time filter: 1 year
  ///
  /// In cs, this message translates to:
  /// **'1R'**
  String get timeFilter1Y;

  /// Time filter: 2 years
  ///
  /// In cs, this message translates to:
  /// **'2R'**
  String get timeFilter2Y;

  /// Time filter: all
  ///
  /// In cs, this message translates to:
  /// **'Vše'**
  String get timeFilterAll;

  /// Delete gear confirmation title
  ///
  /// In cs, this message translates to:
  /// **'Smazat {name}?'**
  String deleteGearConfirm(String name);

  /// Delete gear warning text
  ///
  /// In cs, this message translates to:
  /// **'Tato akce smaže vybavení a všechny záznamy.'**
  String get deleteGearWarning;

  /// Field label: performed by
  ///
  /// In cs, this message translates to:
  /// **'Provedl'**
  String get performedBy;

  /// Field label: cost
  ///
  /// In cs, this message translates to:
  /// **'Cena'**
  String get cost;

  /// Label: next due date
  ///
  /// In cs, this message translates to:
  /// **'Příští termín'**
  String get nextDueDate;

  /// Label: date performed
  ///
  /// In cs, this message translates to:
  /// **'Datum provedení'**
  String get performedDate;

  /// Field label: notes
  ///
  /// In cs, this message translates to:
  /// **'Poznámky'**
  String get notes;

  /// Duration formatted as hours
  ///
  /// In cs, this message translates to:
  /// **'{h} h'**
  String durationHours(String h);

  /// Duration formatted as minutes
  ///
  /// In cs, this message translates to:
  /// **'{m} min'**
  String durationMinutes(int m);

  /// Distance formatted as km
  ///
  /// In cs, this message translates to:
  /// **'{km} km'**
  String distanceKm(String km);

  /// Elevation formatted as meters
  ///
  /// In cs, this message translates to:
  /// **'↑ {m} m'**
  String elevationM(int m);

  /// Strava callback: processing login
  ///
  /// In cs, this message translates to:
  /// **'Dokončuji přihlášení ke Stravě…'**
  String get stravaCallbackProcessing;

  /// Strava callback: exchanging code
  ///
  /// In cs, this message translates to:
  /// **'Vyměňuji autorizační kód za přístupový token.'**
  String get stravaCallbackExchanging;

  /// Strava callback: redirecting
  ///
  /// In cs, this message translates to:
  /// **'Přesměrovávám zpět do nastavení…'**
  String get stravaCallbackRedirecting;

  /// Strava access denied error
  ///
  /// In cs, this message translates to:
  /// **'Strava odmítla přístup: {error}'**
  String stravaAccessDenied(String error);

  /// Strava error: missing auth code
  ///
  /// In cs, this message translates to:
  /// **'Autorizační kód chybí. Zkus přihlášení znovu.'**
  String get stravaMissingCode;

  /// Screen title: maintenance overview
  ///
  /// In cs, this message translates to:
  /// **'Přehled servisu'**
  String get maintenanceOverview;

  /// Maintenance overview: all gear good
  ///
  /// In cs, this message translates to:
  /// **'Vše v pořádku'**
  String get allGear;

  /// Maintenance: N items need attention
  ///
  /// In cs, this message translates to:
  /// **'{count} položek vyžaduje pozornost'**
  String itemsNeedAttention(int count);

  /// Sport category: climbing
  ///
  /// In cs, this message translates to:
  /// **'Lezení'**
  String get sportClimbing;

  /// Sport category: ski alpinism
  ///
  /// In cs, this message translates to:
  /// **'Skialpinismus'**
  String get sportSkiAlpinism;

  /// Sport category: cycling
  ///
  /// In cs, this message translates to:
  /// **'Cyklistika'**
  String get sportCycling;

  /// Sport category: paragliding
  ///
  /// In cs, this message translates to:
  /// **'Paragliding'**
  String get sportParagliding;

  /// Sport category: general
  ///
  /// In cs, this message translates to:
  /// **'Obecné'**
  String get sportGeneral;

  /// Dialog title: confirm delete
  ///
  /// In cs, this message translates to:
  /// **'Potvrdit smazání'**
  String get deleteConfirmTitle;

  /// Generic yes button
  ///
  /// In cs, this message translates to:
  /// **'Ano'**
  String get yes;

  /// Generic no button
  ///
  /// In cs, this message translates to:
  /// **'Ne'**
  String get no;

  /// Screen title: add gear
  ///
  /// In cs, this message translates to:
  /// **'Nové vybavení'**
  String get addGearTitle;

  /// Screen title: edit gear
  ///
  /// In cs, this message translates to:
  /// **'Upravit vybavení'**
  String get editGearTitle;

  /// Snackbar: gear saved
  ///
  /// In cs, this message translates to:
  /// **'Vybavení uloženo'**
  String get gearSaved;

  /// Field label: location
  ///
  /// In cs, this message translates to:
  /// **'Místo'**
  String get locationLabel;

  /// Field label: date
  ///
  /// In cs, this message translates to:
  /// **'Datum'**
  String get dateLabel;

  /// Field label: duration
  ///
  /// In cs, this message translates to:
  /// **'Délka'**
  String get durationLabel;

  /// Field label: distance
  ///
  /// In cs, this message translates to:
  /// **'Vzdálenost'**
  String get distanceLabel;

  /// Snackbar: notifications disabled
  ///
  /// In cs, this message translates to:
  /// **'Notifikace vypnuty'**
  String get notificationsDisabled;

  /// Strava: N activities synced
  ///
  /// In cs, this message translates to:
  /// **'Synchronizováno {count} aktivit'**
  String stravaSyncedCount(int count);

  /// Strava: no activities synced yet
  ///
  /// In cs, this message translates to:
  /// **'Žádné synchronizované aktivity'**
  String get stravaSyncedNone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'cs',
        'de',
        'en',
        'es',
        'fr',
        'it',
        'sk'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'sk':
      return AppLocalizationsSk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

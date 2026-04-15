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
  /// **'OutdoorGearTracker'**
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

  /// No description provided for @insuranceTitle.
  ///
  /// In cs, this message translates to:
  /// **'Pojistky'**
  String get insuranceTitle;

  /// No description provided for @addInsurance.
  ///
  /// In cs, this message translates to:
  /// **'Přidat pojistku'**
  String get addInsurance;

  /// No description provided for @noInsurance.
  ///
  /// In cs, this message translates to:
  /// **'Žádné pojistky'**
  String get noInsurance;

  /// No description provided for @noInsuranceHint.
  ///
  /// In cs, this message translates to:
  /// **'Přidej první pojistku tlačítkem +'**
  String get noInsuranceHint;

  /// No description provided for @deleteInsuranceTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat pojistku?'**
  String get deleteInsuranceTitle;

  /// No description provided for @deleteInsuranceConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Opravdu smazat pojistku \"{name}\"?'**
  String deleteInsuranceConfirm(String name);

  /// No description provided for @insuranceExpired.
  ///
  /// In cs, this message translates to:
  /// **'Vypršela'**
  String get insuranceExpired;

  /// No description provided for @insuranceExpiringSoon.
  ///
  /// In cs, this message translates to:
  /// **'Vyprší brzy'**
  String get insuranceExpiringSoon;

  /// No description provided for @insuranceActive.
  ///
  /// In cs, this message translates to:
  /// **'Aktivní'**
  String get insuranceActive;

  /// No description provided for @insuranceExpiredOn.
  ///
  /// In cs, this message translates to:
  /// **'Vypršela {date}'**
  String insuranceExpiredOn(String date);

  /// No description provided for @insuranceValidUntil.
  ///
  /// In cs, this message translates to:
  /// **'Do {date}'**
  String insuranceValidUntil(String date);

  /// No description provided for @totalAnnualCost.
  ///
  /// In cs, this message translates to:
  /// **'Celkem ročně:'**
  String get totalAnnualCost;

  /// No description provided for @insuranceDetails.
  ///
  /// In cs, this message translates to:
  /// **'Detaily pojistky'**
  String get insuranceDetails;

  /// No description provided for @insuranceStartDate.
  ///
  /// In cs, this message translates to:
  /// **'Datum začátku'**
  String get insuranceStartDate;

  /// No description provided for @insuranceExpiryDate.
  ///
  /// In cs, this message translates to:
  /// **'Datum vypršení'**
  String get insuranceExpiryDate;

  /// No description provided for @annualPremium.
  ///
  /// In cs, this message translates to:
  /// **'Roční pojistné'**
  String get annualPremium;

  /// No description provided for @coverageAmount.
  ///
  /// In cs, this message translates to:
  /// **'Pojistná částka'**
  String get coverageAmount;

  /// No description provided for @contractPhoto.
  ///
  /// In cs, this message translates to:
  /// **'Foto smlouvy'**
  String get contractPhoto;

  /// No description provided for @linkedGear.
  ///
  /// In cs, this message translates to:
  /// **'Propojené vybavení'**
  String get linkedGear;

  /// No description provided for @insuranceActions.
  ///
  /// In cs, this message translates to:
  /// **'Akce'**
  String get insuranceActions;

  /// No description provided for @copyCompanyName.
  ///
  /// In cs, this message translates to:
  /// **'Název pojišťovny zkopírován'**
  String get copyCompanyName;

  /// No description provided for @contactButton.
  ///
  /// In cs, this message translates to:
  /// **'Kontakt'**
  String get contactButton;

  /// No description provided for @reminderButton.
  ///
  /// In cs, this message translates to:
  /// **'Připomínka'**
  String get reminderButton;

  /// No description provided for @contractLabel.
  ///
  /// In cs, this message translates to:
  /// **'Smlouva: {number}'**
  String contractLabel(String number);

  /// No description provided for @editInsuranceTitle.
  ///
  /// In cs, this message translates to:
  /// **'Upravit pojistku'**
  String get editInsuranceTitle;

  /// No description provided for @newInsuranceTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nová pojistka'**
  String get newInsuranceTitle;

  /// No description provided for @insuranceNameLabel.
  ///
  /// In cs, this message translates to:
  /// **'Název pojistky *'**
  String get insuranceNameLabel;

  /// No description provided for @insuranceNameHint.
  ///
  /// In cs, this message translates to:
  /// **'např. Pojištění vybavení na hory'**
  String get insuranceNameHint;

  /// No description provided for @insuranceNameRequired.
  ///
  /// In cs, this message translates to:
  /// **'Zadej název'**
  String get insuranceNameRequired;

  /// No description provided for @insuranceTypeLabel.
  ///
  /// In cs, this message translates to:
  /// **'Typ pojistky'**
  String get insuranceTypeLabel;

  /// No description provided for @insuranceCompanyLabel.
  ///
  /// In cs, this message translates to:
  /// **'Pojišťovna *'**
  String get insuranceCompanyLabel;

  /// No description provided for @insuranceCompanyHint.
  ///
  /// In cs, this message translates to:
  /// **'např. Allianz'**
  String get insuranceCompanyHint;

  /// No description provided for @insuranceCompanyRequired.
  ///
  /// In cs, this message translates to:
  /// **'Zadej pojišťovnu'**
  String get insuranceCompanyRequired;

  /// No description provided for @policyNumberLabel.
  ///
  /// In cs, this message translates to:
  /// **'Číslo smlouvy *'**
  String get policyNumberLabel;

  /// No description provided for @policyNumberHint.
  ///
  /// In cs, this message translates to:
  /// **'číslo pojistné smlouvy'**
  String get policyNumberHint;

  /// No description provided for @policyNumberRequired.
  ///
  /// In cs, this message translates to:
  /// **'Zadej číslo smlouvy'**
  String get policyNumberRequired;

  /// No description provided for @validitySection.
  ///
  /// In cs, this message translates to:
  /// **'Platnost'**
  String get validitySection;

  /// No description provided for @financialSection.
  ///
  /// In cs, this message translates to:
  /// **'Finanční informace'**
  String get financialSection;

  /// No description provided for @annualPremiumLabel.
  ///
  /// In cs, this message translates to:
  /// **'Roční pojistné (Kč)'**
  String get annualPremiumLabel;

  /// No description provided for @coverageAmountLabel.
  ///
  /// In cs, this message translates to:
  /// **'Pojistná částka (Kč)'**
  String get coverageAmountLabel;

  /// No description provided for @optionalHint.
  ///
  /// In cs, this message translates to:
  /// **'volitelné'**
  String get optionalHint;

  /// No description provided for @selectDate.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat datum'**
  String get selectDate;

  /// No description provided for @selectDateRequired.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat datum *'**
  String get selectDateRequired;

  /// No description provided for @expiryDateRequired.
  ///
  /// In cs, this message translates to:
  /// **'Vyber datum vypršení.'**
  String get expiryDateRequired;

  /// No description provided for @basicInfoSection.
  ///
  /// In cs, this message translates to:
  /// **'Základní informace'**
  String get basicInfoSection;

  /// No description provided for @linkedGearSection.
  ///
  /// In cs, this message translates to:
  /// **'Propojené vybavení'**
  String get linkedGearSection;

  /// No description provided for @tripsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Výlety'**
  String get tripsTitle;

  /// No description provided for @addTrip.
  ///
  /// In cs, this message translates to:
  /// **'Naplánovat výlet'**
  String get addTrip;

  /// No description provided for @noTrips.
  ///
  /// In cs, this message translates to:
  /// **'Žádné výlety'**
  String get noTrips;

  /// No description provided for @noTripsHint.
  ///
  /// In cs, this message translates to:
  /// **'Přidejte svůj první výlet a sestavte si checklist vybavení.'**
  String get noTripsHint;

  /// No description provided for @deleteTrip.
  ///
  /// In cs, this message translates to:
  /// **'Smazat výlet?'**
  String get deleteTrip;

  /// No description provided for @deleteTripConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Opravdu chcete smazat výlet \"{name}\"?'**
  String deleteTripConfirm(String name);

  /// No description provided for @shareChecklist.
  ///
  /// In cs, this message translates to:
  /// **'Sdílet checklist'**
  String get shareChecklist;

  /// No description provided for @packingProgress.
  ///
  /// In cs, this message translates to:
  /// **'{packed}/{total} zabaleno'**
  String packingProgress(int packed, int total);

  /// No description provided for @tripWarnings.
  ///
  /// In cs, this message translates to:
  /// **'Upozornění před cestou'**
  String get tripWarnings;

  /// No description provided for @tripGearOverdue.
  ///
  /// In cs, this message translates to:
  /// **'Vyžaduje servis – překročen limit'**
  String get tripGearOverdue;

  /// No description provided for @tripGearWarning.
  ///
  /// In cs, this message translates to:
  /// **'Blíží se termín servisu'**
  String get tripGearWarning;

  /// No description provided for @gearChecklist.
  ///
  /// In cs, this message translates to:
  /// **'Vybavení ({packed}/{total} zabaleno)'**
  String gearChecklist(int packed, int total);

  /// No description provided for @noGearInTrip.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné vybavení. Klepněte na Přidat pro výběr.'**
  String get noGearInTrip;

  /// No description provided for @selectGearTitle.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat vybavení'**
  String get selectGearTitle;

  /// No description provided for @confirmSelection.
  ///
  /// In cs, this message translates to:
  /// **'Potvrdit výběr'**
  String get confirmSelection;

  /// No description provided for @editTripTitle.
  ///
  /// In cs, this message translates to:
  /// **'Upravit výlet'**
  String get editTripTitle;

  /// No description provided for @newTripTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nový výlet'**
  String get newTripTitle;

  /// No description provided for @tripNameLabel.
  ///
  /// In cs, this message translates to:
  /// **'Název výletu *'**
  String get tripNameLabel;

  /// No description provided for @tripNameHint.
  ///
  /// In cs, this message translates to:
  /// **'např. Letní trekking v Alpách'**
  String get tripNameHint;

  /// No description provided for @tripNameRequired.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte název'**
  String get tripNameRequired;

  /// No description provided for @destinationLabel.
  ///
  /// In cs, this message translates to:
  /// **'Destinace'**
  String get destinationLabel;

  /// No description provided for @destinationHint.
  ///
  /// In cs, this message translates to:
  /// **'např. Dolomity, Itálie'**
  String get destinationHint;

  /// No description provided for @departureDateLabel.
  ///
  /// In cs, this message translates to:
  /// **'Datum odjezdu'**
  String get departureDateLabel;

  /// No description provided for @returnDateLabel.
  ///
  /// In cs, this message translates to:
  /// **'Datum návratu'**
  String get returnDateLabel;

  /// No description provided for @tripStatusSection.
  ///
  /// In cs, this message translates to:
  /// **'Stav'**
  String get tripStatusSection;

  /// No description provided for @tripStatusLabel.
  ///
  /// In cs, this message translates to:
  /// **'Stav výletu'**
  String get tripStatusLabel;

  /// No description provided for @notSelected.
  ///
  /// In cs, this message translates to:
  /// **'Nevybráno'**
  String get notSelected;

  /// No description provided for @saveTripButton.
  ///
  /// In cs, this message translates to:
  /// **'Uložit výlet'**
  String get saveTripButton;

  /// No description provided for @dateSection.
  ///
  /// In cs, this message translates to:
  /// **'Termín'**
  String get dateSection;

  /// No description provided for @portfolioTitle.
  ///
  /// In cs, this message translates to:
  /// **'Portfolio'**
  String get portfolioTitle;

  /// No description provided for @purchaseValue.
  ///
  /// In cs, this message translates to:
  /// **'Pořizovací hodnota'**
  String get purchaseValue;

  /// No description provided for @currentValue.
  ///
  /// In cs, this message translates to:
  /// **'Aktuální hodnota'**
  String get currentValue;

  /// No description provided for @annualInsuranceCost.
  ///
  /// In cs, this message translates to:
  /// **'Roční pojistné'**
  String get annualInsuranceCost;

  /// No description provided for @maintenanceCosts.
  ///
  /// In cs, this message translates to:
  /// **'Náklady na údržbu'**
  String get maintenanceCosts;

  /// No description provided for @valueByCategory.
  ///
  /// In cs, this message translates to:
  /// **'Hodnota podle kategorie'**
  String get valueByCategory;

  /// No description provided for @maintenanceCostsByMonth.
  ///
  /// In cs, this message translates to:
  /// **'Náklady na údržbu po měsících'**
  String get maintenanceCostsByMonth;

  /// No description provided for @noMaintenanceCosts.
  ///
  /// In cs, this message translates to:
  /// **'Žádné záznamy o nákladech'**
  String get noMaintenanceCosts;

  /// No description provided for @gearByValue.
  ///
  /// In cs, this message translates to:
  /// **'Vybavení podle hodnoty'**
  String get gearByValue;

  /// No description provided for @noGearWithPrice.
  ///
  /// In cs, this message translates to:
  /// **'Žádné vybavení s pořizovací cenou.\nPřidejte cenu v detailu vybavení.'**
  String get noGearWithPrice;

  /// No description provided for @exportForInsurance.
  ///
  /// In cs, this message translates to:
  /// **'Exportovat pro pojišťovnu'**
  String get exportForInsurance;

  /// No description provided for @exportPdfComingSoon.
  ///
  /// In cs, this message translates to:
  /// **'Export PDF bude dostupný v příští verzi'**
  String get exportPdfComingSoon;

  /// No description provided for @exportPremiumMessage.
  ///
  /// In cs, this message translates to:
  /// **'Export portfolia pro pojišťovnu je prémiová funkce.'**
  String get exportPremiumMessage;

  /// No description provided for @portfolioLoadError.
  ///
  /// In cs, this message translates to:
  /// **'Nepodařilo se načíst data.'**
  String get portfolioLoadError;

  /// No description provided for @depreciatedPercent.
  ///
  /// In cs, this message translates to:
  /// **'–{pct}% odepsáno'**
  String depreciatedPercent(int pct);

  /// No description provided for @annualReportTitle.
  ///
  /// In cs, this message translates to:
  /// **'Roční report'**
  String get annualReportTitle;

  /// No description provided for @annualReportPdfTitle.
  ///
  /// In cs, this message translates to:
  /// **'Roční přehled jako PDF'**
  String get annualReportPdfTitle;

  /// No description provided for @reportContains.
  ///
  /// In cs, this message translates to:
  /// **'Report obsahuje:'**
  String get reportContains;

  /// No description provided for @reportItemActivities.
  ///
  /// In cs, this message translates to:
  /// **'Celkový přehled aktivit a servisů'**
  String get reportItemActivities;

  /// No description provided for @reportItemGearStats.
  ///
  /// In cs, this message translates to:
  /// **'Statistiky pro každý kus vybavení'**
  String get reportItemGearStats;

  /// No description provided for @reportItemMonthly.
  ///
  /// In cs, this message translates to:
  /// **'Měsíční rozklad aktivit'**
  String get reportItemMonthly;

  /// No description provided for @reportItemServiceHistory.
  ///
  /// In cs, this message translates to:
  /// **'Kompletní servisní historii'**
  String get reportItemServiceHistory;

  /// No description provided for @reportItemInsurance.
  ///
  /// In cs, this message translates to:
  /// **'Přehled pojistek a hodnoty portfolia'**
  String get reportItemInsurance;

  /// No description provided for @reportItemNextYear.
  ///
  /// In cs, this message translates to:
  /// **'Plán servisů na příští rok'**
  String get reportItemNextYear;

  /// No description provided for @selectYear.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte rok'**
  String get selectYear;

  /// No description provided for @currentYearLabel.
  ///
  /// In cs, this message translates to:
  /// **'Aktuální rok'**
  String get currentYearLabel;

  /// No description provided for @lastYearLabel.
  ///
  /// In cs, this message translates to:
  /// **'Minulý rok'**
  String get lastYearLabel;

  /// No description provided for @twoYearsAgoLabel.
  ///
  /// In cs, this message translates to:
  /// **'Před dvěma lety'**
  String get twoYearsAgoLabel;

  /// No description provided for @generateReport.
  ///
  /// In cs, this message translates to:
  /// **'Vygenerovat report {year}'**
  String generateReport(int year);

  /// No description provided for @generatingReport.
  ///
  /// In cs, this message translates to:
  /// **'Generuji report...'**
  String get generatingReport;

  /// No description provided for @reportError.
  ///
  /// In cs, this message translates to:
  /// **'Chyba při generování reportu: {error}'**
  String reportError(String error);

  /// No description provided for @reportShareHint.
  ///
  /// In cs, this message translates to:
  /// **'Po vygenerování bude PDF sdíleno přes systémový dialog (uložit, odeslat e-mailem, vytisknout...).'**
  String get reportShareHint;

  /// No description provided for @settingsInsuranceSection.
  ///
  /// In cs, this message translates to:
  /// **'Pojistky'**
  String get settingsInsuranceSection;

  /// No description provided for @settingsInsuranceSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Spravuj pojistky svého vybavení'**
  String get settingsInsuranceSubtitle;

  /// No description provided for @settingsAppSection.
  ///
  /// In cs, this message translates to:
  /// **'Aplikace'**
  String get settingsAppSection;

  /// No description provided for @settingsAppearance.
  ///
  /// In cs, this message translates to:
  /// **'Vzhled'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Světlý / tmavý / systémový motiv'**
  String get settingsAppearanceSubtitle;

  /// No description provided for @themeModeLight.
  ///
  /// In cs, this message translates to:
  /// **'Světlý motiv'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In cs, this message translates to:
  /// **'Tmavý motiv'**
  String get themeModeDark;

  /// No description provided for @themeModeSystem.
  ///
  /// In cs, this message translates to:
  /// **'Podle systému'**
  String get themeModeSystem;

  /// No description provided for @settingsNotificationsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Oznámení'**
  String get settingsNotificationsTitle;

  /// No description provided for @settingsNotificationsOn.
  ///
  /// In cs, this message translates to:
  /// **'Dostaneš připomenutí před termínem servisu i po termínu.'**
  String get settingsNotificationsOn;

  /// No description provided for @settingsNotificationsOff.
  ///
  /// In cs, this message translates to:
  /// **'Připomínky servisních termínů jsou vypnuty.'**
  String get settingsNotificationsOff;

  /// No description provided for @settingsNotificationsWeb.
  ///
  /// In cs, this message translates to:
  /// **'Push notifikace nejsou v prohlížeči podporovány.\nPoužij Android / iOS aplikaci.'**
  String get settingsNotificationsWeb;

  /// No description provided for @settingsBackupSection.
  ///
  /// In cs, this message translates to:
  /// **'Záloha a export'**
  String get settingsBackupSection;

  /// No description provided for @settingsAnnualReport.
  ///
  /// In cs, this message translates to:
  /// **'Roční report PDF'**
  String get settingsAnnualReport;

  /// No description provided for @settingsAnnualReportSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Export přehledu roku jako PDF'**
  String get settingsAnnualReportSubtitle;

  /// No description provided for @settingsDataSection.
  ///
  /// In cs, this message translates to:
  /// **'Data'**
  String get settingsDataSection;

  /// No description provided for @settingsImportSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Import ze souboru CSV nebo GPX'**
  String get settingsImportSubtitle;

  /// No description provided for @settingsClearSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Trvale odstraní vše z databáze'**
  String get settingsClearSubtitle;

  /// No description provided for @settingsWidgetSection.
  ///
  /// In cs, this message translates to:
  /// **'Widget'**
  String get settingsWidgetSection;

  /// No description provided for @settingsWidgetAdd.
  ///
  /// In cs, this message translates to:
  /// **'Přidání widgetu'**
  String get settingsWidgetAdd;

  /// No description provided for @settingsWidgetAddSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Přidej widget na domovskou obrazovku: Dlouze stiskni plochu → Widgety → OutdoorGearTracker'**
  String get settingsWidgetAddSubtitle;

  /// No description provided for @settingsWidgetRefresh.
  ///
  /// In cs, this message translates to:
  /// **'Aktualizovat widget nyní'**
  String get settingsWidgetRefresh;

  /// No description provided for @settingsWidgetRefreshed.
  ///
  /// In cs, this message translates to:
  /// **'Widget aktualizován'**
  String get settingsWidgetRefreshed;

  /// No description provided for @settingsAboutSection.
  ///
  /// In cs, this message translates to:
  /// **'O aplikaci'**
  String get settingsAboutSection;

  /// No description provided for @settingsVersion.
  ///
  /// In cs, this message translates to:
  /// **'Verze'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In cs, this message translates to:
  /// **'Zásady ochrany osobních údajů'**
  String get settingsPrivacyPolicy;

  /// No description provided for @backupSuccess.
  ///
  /// In cs, this message translates to:
  /// **'Záloha byla úspěšně nahrána na Google Drive.'**
  String get backupSuccess;

  /// No description provided for @restoreSuccess.
  ///
  /// In cs, this message translates to:
  /// **'Data byla úspěšně obnovena. Restartuj aplikaci.'**
  String get restoreSuccess;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In cs, this message translates to:
  /// **'Obnovit ze zálohy?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmContent.
  ///
  /// In cs, this message translates to:
  /// **'Tato akce nahradí aktuální databázi a fotky daty ze zálohy. Pokračovat?'**
  String get restoreConfirmContent;

  /// No description provided for @restoreButton.
  ///
  /// In cs, this message translates to:
  /// **'Obnovit'**
  String get restoreButton;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In cs, this message translates to:
  /// **'Oprávnění pro notifikace bylo zamítnuto.'**
  String get notificationPermissionDenied;

  /// No description provided for @settingsButton.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get settingsButton;

  /// No description provided for @premiumUnlocked.
  ///
  /// In cs, this message translates to:
  /// **'🎉 Premium aktivováno! Děkujeme za podporu.'**
  String get premiumUnlocked;

  /// No description provided for @restorePurchasesButton.
  ///
  /// In cs, this message translates to:
  /// **'Obnovit nákupy'**
  String get restorePurchasesButton;

  /// No description provided for @noPreviousPurchases.
  ///
  /// In cs, this message translates to:
  /// **'Žádné předchozí nákupy nenalezeny.'**
  String get noPreviousPurchases;

  /// No description provided for @purchasesRestored.
  ///
  /// In cs, this message translates to:
  /// **'✅ Nákupy obnoveny!'**
  String get purchasesRestored;

  /// No description provided for @paywallTagline.
  ///
  /// In cs, this message translates to:
  /// **'Bez omezení. Bezpečnost bez kompromisů.'**
  String get paywallTagline;

  /// No description provided for @maybeLater.
  ///
  /// In cs, this message translates to:
  /// **'Možná později'**
  String get maybeLater;

  /// No description provided for @tapToUnlock.
  ///
  /// In cs, this message translates to:
  /// **'Klepni pro odemknutí'**
  String get tapToUnlock;

  /// No description provided for @getPremiumButton.
  ///
  /// In cs, this message translates to:
  /// **'Získat Premium – {price}'**
  String getPremiumButton(String price);

  /// No description provided for @purchaseUnavailable.
  ///
  /// In cs, this message translates to:
  /// **'Nákup zatím není dostupný – nakonfiguruj produkt v RevenueCat dashboardu.'**
  String get purchaseUnavailable;

  /// No description provided for @deleteServiceRecord.
  ///
  /// In cs, this message translates to:
  /// **'Smazat záznam'**
  String get deleteServiceRecord;

  /// No description provided for @deleteServiceRecordConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Opravdu chcete smazat tento záznam servisu?'**
  String get deleteServiceRecordConfirm;

  /// No description provided for @editServiceRecord.
  ///
  /// In cs, this message translates to:
  /// **'Upravit záznam'**
  String get editServiceRecord;

  /// No description provided for @editServiceTitle.
  ///
  /// In cs, this message translates to:
  /// **'Upravit záznam servisu'**
  String get editServiceTitle;

  /// No description provided for @notYetPerformed.
  ///
  /// In cs, this message translates to:
  /// **'Dosud neprovedeno'**
  String get notYetPerformed;

  /// No description provided for @noServiceEntries.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné záznamy servisu'**
  String get noServiceEntries;

  /// No description provided for @recordFirstService.
  ///
  /// In cs, this message translates to:
  /// **'Zapsat první servis'**
  String get recordFirstService;

  /// No description provided for @serviceHistoryFull.
  ///
  /// In cs, this message translates to:
  /// **'Kompletní historie servisu'**
  String get serviceHistoryFull;

  /// No description provided for @warrantyExpired.
  ///
  /// In cs, this message translates to:
  /// **'Záruka vypršela'**
  String get warrantyExpired;

  /// No description provided for @warrantySection.
  ///
  /// In cs, this message translates to:
  /// **'Záruka'**
  String get warrantySection;

  /// No description provided for @gearInsuranceSection.
  ///
  /// In cs, this message translates to:
  /// **'Pojištění'**
  String get gearInsuranceSection;

  /// No description provided for @noInsurancesAttached.
  ///
  /// In cs, this message translates to:
  /// **'Žádné pojistky'**
  String get noInsurancesAttached;

  /// No description provided for @igcLoadError.
  ///
  /// In cs, this message translates to:
  /// **'Nepodařilo se načíst IGC soubor. Zkontroluj formát.'**
  String get igcLoadError;

  /// No description provided for @flightPreview.
  ///
  /// In cs, this message translates to:
  /// **'Náhled letu'**
  String get flightPreview;

  /// No description provided for @flightStartLabel.
  ///
  /// In cs, this message translates to:
  /// **'Start'**
  String get flightStartLabel;

  /// No description provided for @flightLandingLabel.
  ///
  /// In cs, this message translates to:
  /// **'Přistání'**
  String get flightLandingLabel;

  /// No description provided for @flightDurationLabel.
  ///
  /// In cs, this message translates to:
  /// **'Délka letu'**
  String get flightDurationLabel;

  /// No description provided for @maxAltitudeLabel.
  ///
  /// In cs, this message translates to:
  /// **'Max výška'**
  String get maxAltitudeLabel;

  /// No description provided for @gpsStartLabel.
  ///
  /// In cs, this message translates to:
  /// **'GPS start'**
  String get gpsStartLabel;

  /// No description provided for @stravaNotConnectedHint.
  ///
  /// In cs, this message translates to:
  /// **'Strava není připojena. Přejdi do Nastavení → Propojené služby.'**
  String get stravaNotConnectedHint;

  /// No description provided for @stravaSyncFromHelpText.
  ///
  /// In cs, this message translates to:
  /// **'Synchronizovat aktivity od'**
  String get stravaSyncFromHelpText;

  /// No description provided for @widgetHowToAddTitle.
  ///
  /// In cs, this message translates to:
  /// **'Jak přidat widget'**
  String get widgetHowToAddTitle;

  /// No description provided for @widgetHowToStep1.
  ///
  /// In cs, this message translates to:
  /// **'1. Dlouze stiskněte prázdné místo na ploše telefonu'**
  String get widgetHowToStep1;

  /// No description provided for @widgetHowToStep2.
  ///
  /// In cs, this message translates to:
  /// **'2. Klepněte na \"Widgety\"'**
  String get widgetHowToStep2;

  /// No description provided for @widgetHowToStep3.
  ///
  /// In cs, this message translates to:
  /// **'3. Najděte \"OutdoorGearTracker\" v seznamu'**
  String get widgetHowToStep3;

  /// No description provided for @widgetHowToStep4.
  ///
  /// In cs, this message translates to:
  /// **'4. Přetáhněte widget na plochu'**
  String get widgetHowToStep4;

  /// No description provided for @understood.
  ///
  /// In cs, this message translates to:
  /// **'Rozumím'**
  String get understood;

  /// No description provided for @apiKeysTitle.
  ///
  /// In cs, this message translates to:
  /// **'API klíče'**
  String get apiKeysTitle;

  /// No description provided for @exportCsvLabel.
  ///
  /// In cs, this message translates to:
  /// **'Exportovat jako CSV'**
  String get exportCsvLabel;

  /// No description provided for @exportCsvSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Export všech dat do CSV souboru'**
  String get exportCsvSubtitle;

  /// No description provided for @signInWithGoogle.
  ///
  /// In cs, this message translates to:
  /// **'Přihlásit se s Google'**
  String get signInWithGoogle;

  /// No description provided for @featureComingSoon.
  ///
  /// In cs, this message translates to:
  /// **'Funkce připravována'**
  String get featureComingSoon;

  /// No description provided for @signOutGoogleAccount.
  ///
  /// In cs, this message translates to:
  /// **'Odhlásit Google účet'**
  String get signOutGoogleAccount;

  /// No description provided for @availableInPremium.
  ///
  /// In cs, this message translates to:
  /// **'Dostupné v Premium'**
  String get availableInPremium;

  /// No description provided for @deleteDataError.
  ///
  /// In cs, this message translates to:
  /// **'Chyba při mazání dat: {error}'**
  String deleteDataError(Object error);

  /// No description provided for @exportCompleted.
  ///
  /// In cs, this message translates to:
  /// **'Export dokončen'**
  String get exportCompleted;

  /// No description provided for @syncTimedOut.
  ///
  /// In cs, this message translates to:
  /// **'Synchronizace vypršela. Zkus znovu.'**
  String get syncTimedOut;

  /// No description provided for @photoTakePhoto.
  ///
  /// In cs, this message translates to:
  /// **'Vyfotit'**
  String get photoTakePhoto;

  /// No description provided for @photoFromGallery.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat z galerie'**
  String get photoFromGallery;

  /// No description provided for @photoDeleteConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Smazat fotku?'**
  String get photoDeleteConfirm;

  /// No description provided for @photoAdd.
  ///
  /// In cs, this message translates to:
  /// **'Přidat fotku'**
  String get photoAdd;

  /// No description provided for @photoChange.
  ///
  /// In cs, this message translates to:
  /// **'Změnit fotku'**
  String get photoChange;

  /// No description provided for @apply.
  ///
  /// In cs, this message translates to:
  /// **'Použít'**
  String get apply;

  /// No description provided for @serviceHistoryRecordCount.
  ///
  /// In cs, this message translates to:
  /// **'{count} záznamů'**
  String serviceHistoryRecordCount(int count);

  /// No description provided for @warrantyValidUntil.
  ///
  /// In cs, this message translates to:
  /// **'Platí do {date}'**
  String warrantyValidUntil(String date);

  /// No description provided for @intervalDays.
  ///
  /// In cs, this message translates to:
  /// **'každých {n} dní'**
  String intervalDays(String n);

  /// No description provided for @intervalHours.
  ///
  /// In cs, this message translates to:
  /// **'každých {n} h'**
  String intervalHours(String n);

  /// No description provided for @intervalKm.
  ///
  /// In cs, this message translates to:
  /// **'každých {n} km'**
  String intervalKm(String n);

  /// No description provided for @intervalCount.
  ///
  /// In cs, this message translates to:
  /// **'každých {n}×'**
  String intervalCount(String n);

  /// No description provided for @flightAdded.
  ///
  /// In cs, this message translates to:
  /// **'Let přidán: {dur}, max výška {height} m'**
  String flightAdded(String dur, String height);
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

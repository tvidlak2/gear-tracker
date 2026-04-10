// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'GearTracker';

  @override
  String get navOverview => 'Panoramica';

  @override
  String get navActivities => 'Attività';

  @override
  String get navMaintenance => 'Manutenzione';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get myGear => 'Il mio equipaggiamento';

  @override
  String get addGear => 'Aggiungi attrezzatura';

  @override
  String get add => 'Aggiungi';

  @override
  String get edit => 'Modifica';

  @override
  String get delete => 'Elimina';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get confirm => 'Conferma';

  @override
  String get close => 'Chiudi';

  @override
  String get retry => 'Riprova';

  @override
  String get loading => 'Caricamento…';

  @override
  String get noData => 'Nessun dato';

  @override
  String get statusActive => 'Attivo';

  @override
  String get statusRetired => 'Ritirato';

  @override
  String get statusLost => 'Perso';

  @override
  String get gearStatus => 'Stato attrezzatura';

  @override
  String get gearName => 'Nome';

  @override
  String get gearBrand => 'Marca';

  @override
  String get gearModel => 'Modello';

  @override
  String get gearCategory => 'Categoria';

  @override
  String get gearNotes => 'Note';

  @override
  String get gearSerialNumber => 'Numero di serie';

  @override
  String get gearPurchaseDate => 'Data di acquisto';

  @override
  String get gearManufacturedDate => 'Data di produzione';

  @override
  String get gearPhoto => 'Foto';

  @override
  String get gearAge => 'Età';

  @override
  String get requiresAttention => 'Richiede attenzione';

  @override
  String get allGoodTitle => 'Tutto a posto';

  @override
  String get allGoodSubtitle => 'Nessun promemoria di manutenzione';

  @override
  String get noGearYet => 'Nessuna attrezzatura';

  @override
  String get addFirstGear => 'Aggiungi la tua prima attrezzatura';

  @override
  String get statusOverdue => 'Scaduto';

  @override
  String get statusWarning => 'Presto';

  @override
  String get statusOk => 'OK';

  @override
  String get totalHours => 'Ore totali';

  @override
  String get totalKm => 'Km totali';

  @override
  String get age => 'Età';

  @override
  String get usageCount => 'Utilizzi';

  @override
  String get hours => 'Ore';

  @override
  String get km => 'km';

  @override
  String get elevation => 'Dislivello';

  @override
  String get activities => 'Attività';

  @override
  String get maintenancePlan => 'Piano di manutenzione';

  @override
  String get addMaintenanceRule => 'Aggiungi regola';

  @override
  String get logService => 'Registra manutenzione';

  @override
  String get noMaintenanceRules => 'Nessuna regola di manutenzione';

  @override
  String get addFirstRule =>
      'Aggiungi la prima regola per tracciare la manutenzione';

  @override
  String get triggerTypeDate => 'Data';

  @override
  String get triggerTypeHours => 'Ore';

  @override
  String get triggerTypeKm => 'km';

  @override
  String get triggerTypeCount => 'Conteggio';

  @override
  String get safetyeCritical => 'Critico per la sicurezza';

  @override
  String get warningBefore => 'Avvisa prima';

  @override
  String get ruleName => 'Nome regola';

  @override
  String get triggerValue => 'Valore';

  @override
  String get nextService => 'Prossima manutenzione';

  @override
  String get lastService => 'Ultima manutenzione';

  @override
  String get serviceHistory => 'Storico manutenzioni';

  @override
  String get noServiceHistory => 'Nessuno storico manutenzioni';

  @override
  String overdueBy(int days) {
    return 'Scaduto da $days giorni';
  }

  @override
  String dueInDays(int days) {
    return 'Tra $days giorni';
  }

  @override
  String get activityHistory => 'Storico attività';

  @override
  String get addActivity => 'Aggiungi attività';

  @override
  String get noActivities => 'Nessun record di utilizzo';

  @override
  String get importIgc => 'Importa IGC';

  @override
  String showAll(int count) {
    return 'Mostra tutto ($count attività)';
  }

  @override
  String get hide => 'Nascondi';

  @override
  String loadMore(int count) {
    return 'Carica altro ($count rimanenti)';
  }

  @override
  String get sourceManual => 'Manuale';

  @override
  String get sourceStrava => 'Strava';

  @override
  String get sourceIgc => 'IGC';

  @override
  String get sourceGarmin => 'Garmin';

  @override
  String get sourceGpx => 'GPX';

  @override
  String get stravaSync => 'Sincronizzazione Strava';

  @override
  String get stravaConnect => 'Collega Strava';

  @override
  String get stravaDisconnect => 'Disconnetti';

  @override
  String get stravaConnected => 'Collegato';

  @override
  String get stravasyncActivities => 'Sincronizza attività';

  @override
  String get stravaAutoSync => 'Sincronizzazione automatica';

  @override
  String get stravaSyncFrom => 'Sincronizza da';

  @override
  String get stravaSyncTypes => 'Tipi di attività';

  @override
  String stravaSyncSuccess(int count, String date) {
    return 'Sincronizzato: $count attività (più recente: $date)';
  }

  @override
  String get stravaSyncNoNew => 'Nessuna nuova attività';

  @override
  String stravaSyncError(String error) {
    return 'Errore di sincronizzazione: $error';
  }

  @override
  String get stravaCredentials => 'Credenziali API';

  @override
  String get stravaClientId => 'Client ID';

  @override
  String get stravaClientSecret => 'Client Secret';

  @override
  String get stravaSaved => 'Credenziali salvate';

  @override
  String get connectedServices => 'Servizi collegati';

  @override
  String get notifications => 'Notifiche';

  @override
  String get notificationsEnabled => 'Notifiche attivate';

  @override
  String get backupExport => 'Backup ed esportazione';

  @override
  String get exportData => 'Esporta dati';

  @override
  String get importData => 'Importa dati';

  @override
  String get clearAllData => 'Cancella tutti i dati';

  @override
  String get clearAllDataConfirm =>
      'Eliminare tutti i dati? Questa azione è irreversibile.';

  @override
  String get exportSuccess => 'Dati esportati';

  @override
  String get importSuccess => 'Dati importati';

  @override
  String get dataCleared => 'Tutti i dati cancellati';

  @override
  String get language => 'Lingua';

  @override
  String get statistics => 'Statistiche';

  @override
  String get activityOverTime => 'Attività nel tempo';

  @override
  String get byGear => 'Per attrezzatura';

  @override
  String get recentActivities => 'Attività recenti';

  @override
  String get records => 'Record';

  @override
  String get longestActivity => 'Attività più lunga';

  @override
  String get longestDistance => 'Distanza più lunga';

  @override
  String get mostActiveMonth => 'Mese più attivo';

  @override
  String get mostUsedGear => 'Più utilizzato';

  @override
  String get gearCount => 'Pezzi di attrezzatura';

  @override
  String get maintenanceCount => 'Record di manutenzione';

  @override
  String get filterAll => 'Tutto';

  @override
  String get timeFilter3M => '3M';

  @override
  String get timeFilter6M => '6M';

  @override
  String get timeFilter1Y => '1A';

  @override
  String get timeFilter2Y => '2A';

  @override
  String get timeFilterAll => 'Tutto';

  @override
  String deleteGearConfirm(String name) {
    return 'Eliminare $name?';
  }

  @override
  String get deleteGearWarning =>
      'Questo eliminerà l\'attrezzatura e tutti i suoi record.';

  @override
  String get performedBy => 'Eseguito da';

  @override
  String get cost => 'Costo';

  @override
  String get nextDueDate => 'Prossima scadenza';

  @override
  String get performedDate => 'Data di esecuzione';

  @override
  String get notes => 'Note';

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
  String get stravaCallbackProcessing => 'Completamento accesso Strava…';

  @override
  String get stravaCallbackExchanging =>
      'Scambio del codice di autorizzazione con il token di accesso.';

  @override
  String get stravaCallbackRedirecting => 'Reindirizzamento alle impostazioni…';

  @override
  String stravaAccessDenied(String error) {
    return 'Strava ha negato l\'accesso: $error';
  }

  @override
  String get stravaMissingCode => 'Codice di autorizzazione mancante. Riprova.';

  @override
  String get maintenanceOverview => 'Panoramica manutenzione';

  @override
  String get allGear => 'Tutto a posto';

  @override
  String itemsNeedAttention(int count) {
    return '$count elementi richiedono attenzione';
  }

  @override
  String get sportClimbing => 'Arrampicata';

  @override
  String get sportSkiAlpinism => 'Scialpinismo';

  @override
  String get sportCycling => 'Ciclismo';

  @override
  String get sportParagliding => 'Parapendio';

  @override
  String get sportGeneral => 'Generale';

  @override
  String get deleteConfirmTitle => 'Conferma eliminazione';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get addGearTitle => 'Nuova attrezzatura';

  @override
  String get editGearTitle => 'Modifica attrezzatura';

  @override
  String get gearSaved => 'Attrezzatura salvata';

  @override
  String get locationLabel => 'Luogo';

  @override
  String get dateLabel => 'Data';

  @override
  String get durationLabel => 'Durata';

  @override
  String get distanceLabel => 'Distanza';

  @override
  String get notificationsDisabled => 'Notifiche disabilitate';

  @override
  String stravaSyncedCount(int count) {
    return '$count attività sincronizzate';
  }

  @override
  String get stravaSyncedNone => 'Nessuna attività sincronizzata';
}

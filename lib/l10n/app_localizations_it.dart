// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'OutdoorGearTracker';

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

  @override
  String get insuranceTitle => 'Assicurazioni';

  @override
  String get addInsurance => 'Aggiungi assicurazione';

  @override
  String get noInsurance => 'Nessuna assicurazione';

  @override
  String get noInsuranceHint =>
      'Aggiungi la prima assicurazione con il pulsante +';

  @override
  String get deleteInsuranceTitle => 'Eliminare l\'assicurazione?';

  @override
  String deleteInsuranceConfirm(String name) {
    return 'Eliminare l\'assicurazione \"$name\"?';
  }

  @override
  String get insuranceExpired => 'Scaduta';

  @override
  String get insuranceExpiringSoon => 'Scade presto';

  @override
  String get insuranceActive => 'Attiva';

  @override
  String insuranceExpiredOn(String date) {
    return 'Scaduta il $date';
  }

  @override
  String insuranceValidUntil(String date) {
    return 'Fino al $date';
  }

  @override
  String get totalAnnualCost => 'Totale annuale:';

  @override
  String get insuranceDetails => 'Dettagli assicurazione';

  @override
  String get insuranceStartDate => 'Data di inizio';

  @override
  String get insuranceExpiryDate => 'Data di scadenza';

  @override
  String get annualPremium => 'Premio annuale';

  @override
  String get coverageAmount => 'Somma assicurata';

  @override
  String get contractPhoto => 'Foto del contratto';

  @override
  String get linkedGear => 'Attrezzatura collegata';

  @override
  String get insuranceActions => 'Azioni';

  @override
  String get copyCompanyName => 'Nome assicuratore copiato';

  @override
  String get contactButton => 'Contatto';

  @override
  String get reminderButton => 'Promemoria';

  @override
  String contractLabel(String number) {
    return 'Contratto: $number';
  }

  @override
  String get editInsuranceTitle => 'Modifica assicurazione';

  @override
  String get newInsuranceTitle => 'Nuova assicurazione';

  @override
  String get insuranceNameLabel => 'Nome assicurazione *';

  @override
  String get insuranceNameHint => 'es. Assicurazione attrezzatura montagna';

  @override
  String get insuranceNameRequired => 'Inserisci un nome';

  @override
  String get insuranceTypeLabel => 'Tipo di assicurazione';

  @override
  String get insuranceCompanyLabel => 'Compagnia assicurativa *';

  @override
  String get insuranceCompanyHint => 'es. Allianz';

  @override
  String get insuranceCompanyRequired => 'Inserisci la compagnia assicurativa';

  @override
  String get policyNumberLabel => 'Numero polizza *';

  @override
  String get policyNumberHint => 'numero del contratto assicurativo';

  @override
  String get policyNumberRequired => 'Inserisci il numero polizza';

  @override
  String get validitySection => 'Validità';

  @override
  String get financialSection => 'Informazioni finanziarie';

  @override
  String get annualPremiumLabel => 'Premio annuale';

  @override
  String get coverageAmountLabel => 'Somma assicurata';

  @override
  String get optionalHint => 'opzionale';

  @override
  String get selectDate => 'Seleziona data';

  @override
  String get selectDateRequired => 'Seleziona data *';

  @override
  String get expiryDateRequired => 'Seleziona la data di scadenza.';

  @override
  String get basicInfoSection => 'Informazioni di base';

  @override
  String get linkedGearSection => 'Attrezzatura collegata';

  @override
  String get tripsTitle => 'Escursioni';

  @override
  String get addTrip => 'Pianifica un\'escursione';

  @override
  String get noTrips => 'Nessuna escursione';

  @override
  String get noTripsHint =>
      'Aggiungi la prima escursione e crea una lista di attrezzatura.';

  @override
  String get deleteTrip => 'Eliminare l\'escursione?';

  @override
  String deleteTripConfirm(String name) {
    return 'Eliminare l\'escursione \"$name\"?';
  }

  @override
  String get shareChecklist => 'Condividi lista';

  @override
  String packingProgress(int packed, int total) {
    return '$packed/$total impacchettato';
  }

  @override
  String get tripWarnings => 'Avvisi prima del viaggio';

  @override
  String get tripGearOverdue => 'Manutenzione richiesta – limite superato';

  @override
  String get tripGearWarning => 'Scadenza manutenzione vicina';

  @override
  String gearChecklist(int packed, int total) {
    return 'Attrezzatura ($packed/$total impacchettato)';
  }

  @override
  String get noGearInTrip =>
      'Nessuna attrezzatura. Tocca «Aggiungi» per selezionare.';

  @override
  String get selectGearTitle => 'Seleziona attrezzatura';

  @override
  String get confirmSelection => 'Conferma selezione';

  @override
  String get editTripTitle => 'Modifica escursione';

  @override
  String get newTripTitle => 'Nuova escursione';

  @override
  String get tripNameLabel => 'Nome escursione *';

  @override
  String get tripNameHint => 'es. Trekking estivo sulle Alpi';

  @override
  String get tripNameRequired => 'Inserisci un nome';

  @override
  String get destinationLabel => 'Destinazione';

  @override
  String get destinationHint => 'es. Dolomiti, Italia';

  @override
  String get departureDateLabel => 'Data di partenza';

  @override
  String get returnDateLabel => 'Data di ritorno';

  @override
  String get tripStatusSection => 'Stato';

  @override
  String get tripStatusLabel => 'Stato escursione';

  @override
  String get notSelected => 'Non selezionato';

  @override
  String get saveTripButton => 'Salva escursione';

  @override
  String get dateSection => 'Date';

  @override
  String get portfolioTitle => 'Portafoglio';

  @override
  String get purchaseValue => 'Valore di acquisto';

  @override
  String get currentValue => 'Valore attuale';

  @override
  String get annualInsuranceCost => 'Premio annuale';

  @override
  String get maintenanceCosts => 'Costi di manutenzione';

  @override
  String get valueByCategory => 'Valore per categoria';

  @override
  String get maintenanceCostsByMonth => 'Costi di manutenzione per mese';

  @override
  String get noMaintenanceCosts => 'Nessun dato sui costi';

  @override
  String get gearByValue => 'Attrezzatura per valore';

  @override
  String get noGearWithPrice =>
      'Nessuna attrezzatura con prezzo di acquisto.\nAggiungi il prezzo nel dettaglio attrezzatura.';

  @override
  String get exportForInsurance => 'Esporta per assicurazione';

  @override
  String get exportPdfComingSoon =>
      'L\'esportazione PDF sarà disponibile nella prossima versione';

  @override
  String get exportPremiumMessage =>
      'L\'esportazione del portafoglio per le assicurazioni è una funzione premium.';

  @override
  String get portfolioLoadError => 'Impossibile caricare i dati.';

  @override
  String depreciatedPercent(int pct) {
    return '–$pct% ammortizzato';
  }

  @override
  String get annualReportTitle => 'Rapporto annuale';

  @override
  String get annualReportPdfTitle => 'Panoramica annuale in PDF';

  @override
  String get reportContains => 'Il rapporto contiene:';

  @override
  String get reportItemActivities =>
      'Panoramica generale di attività e manutenzioni';

  @override
  String get reportItemGearStats => 'Statistiche per ogni attrezzatura';

  @override
  String get reportItemMonthly => 'Suddivisione mensile delle attività';

  @override
  String get reportItemServiceHistory =>
      'Cronologia completa delle manutenzioni';

  @override
  String get reportItemInsurance =>
      'Panoramica assicurazioni e valore portafoglio';

  @override
  String get reportItemNextYear => 'Piano di manutenzione per l\'anno prossimo';

  @override
  String get selectYear => 'Seleziona anno';

  @override
  String get currentYearLabel => 'Anno corrente';

  @override
  String get lastYearLabel => 'Anno scorso';

  @override
  String get twoYearsAgoLabel => 'Due anni fa';

  @override
  String generateReport(int year) {
    return 'Genera rapporto $year';
  }

  @override
  String get generatingReport => 'Generazione rapporto...';

  @override
  String reportError(String error) {
    return 'Errore durante la generazione: $error';
  }

  @override
  String get reportShareHint =>
      'Dopo la generazione, il PDF verrà condiviso tramite il dialogo di sistema (salva, invia email, stampa...).';

  @override
  String get settingsInsuranceSection => 'Assicurazioni';

  @override
  String get settingsInsuranceSubtitle =>
      'Gestisci le assicurazioni della tua attrezzatura';

  @override
  String get settingsAppSection => 'App';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get settingsAppearanceSubtitle => 'Tema chiaro / scuro / sistema';

  @override
  String get themeModeLight => 'Tema chiaro';

  @override
  String get themeModeDark => 'Tema scuro';

  @override
  String get themeModeSystem => 'Come il sistema';

  @override
  String get settingsNotificationsTitle => 'Notifiche';

  @override
  String get settingsNotificationsOn =>
      'Riceverai promemoria prima e dopo le scadenze di manutenzione.';

  @override
  String get settingsNotificationsOff =>
      'I promemoria di manutenzione sono disabilitati.';

  @override
  String get settingsNotificationsWeb =>
      'Le notifiche push non sono disponibili nel browser.\nUsa l\'app Android / iOS.';

  @override
  String get settingsBackupSection => 'Backup ed esportazione';

  @override
  String get settingsAnnualReport => 'Rapporto PDF annuale';

  @override
  String get settingsAnnualReportSubtitle =>
      'Esporta la panoramica annuale in PDF';

  @override
  String get settingsDataSection => 'Dati';

  @override
  String get settingsImportSubtitle => 'Importa da file CSV o GPX';

  @override
  String get settingsClearSubtitle =>
      'Rimuove definitivamente tutto dal database';

  @override
  String get settingsWidgetSection => 'Widget';

  @override
  String get settingsWidgetAdd => 'Aggiungi widget';

  @override
  String get settingsWidgetAddSubtitle =>
      'Aggiungi widget alla schermata home: Premi a lungo → Widget → OutdoorGearTracker';

  @override
  String get settingsWidgetRefresh => 'Aggiorna widget ora';

  @override
  String get settingsWidgetRefreshed => 'Widget aggiornato';

  @override
  String get settingsAboutSection => 'Info';

  @override
  String get settingsVersion => 'Versione';

  @override
  String get settingsPrivacyPolicy => 'Informativa sulla privacy';

  @override
  String get backupSuccess => 'Backup caricato su Google Drive con successo.';

  @override
  String get restoreSuccess =>
      'Dati ripristinati con successo. Riavvia l\'app.';

  @override
  String get restoreConfirmTitle => 'Ripristinare dal backup?';

  @override
  String get restoreConfirmContent =>
      'Questo sostituirà il database e le foto attuali con i dati del backup. Continuare?';

  @override
  String get restoreButton => 'Ripristina';

  @override
  String get notificationPermissionDenied => 'Autorizzazione notifiche negata.';

  @override
  String get settingsButton => 'Impostazioni';

  @override
  String get premiumUnlocked =>
      '🎉 Premium attivato! Grazie per il tuo supporto.';

  @override
  String get restorePurchasesButton => 'Ripristina acquisti';

  @override
  String get noPreviousPurchases => 'Nessun acquisto precedente trovato.';

  @override
  String get purchasesRestored => '✅ Acquisti ripristinati!';

  @override
  String get paywallTagline => 'Senza limiti. Sicurezza senza compromessi.';

  @override
  String get maybeLater => 'Forse più tardi';

  @override
  String get tapToUnlock => 'Tocca per sbloccare';

  @override
  String getPremiumButton(String price) {
    return 'Ottieni Premium – $price';
  }

  @override
  String get purchaseUnavailable =>
      'L\'acquisto non è attualmente disponibile. Riprova più tardi.';

  @override
  String get deleteServiceRecord => 'Elimina registro';

  @override
  String get deleteServiceRecordConfirm =>
      'Eliminare questo record di manutenzione?';

  @override
  String get editServiceRecord => 'Modifica record';

  @override
  String get editServiceTitle => 'Modifica record manutenzione';

  @override
  String get notYetPerformed => 'Non ancora eseguito';

  @override
  String get noServiceEntries => 'Nessun record di manutenzione';

  @override
  String get recordFirstService => 'Registra il primo servizio';

  @override
  String get serviceHistoryFull => 'Storico manutenzione completo';

  @override
  String get warrantyExpired => 'Garanzia scaduta';

  @override
  String get warrantySection => 'Garanzia';

  @override
  String get gearInsuranceSection => 'Assicurazione';

  @override
  String get noInsurancesAttached => 'Nessuna polizza';

  @override
  String get igcLoadError => 'Impossibile caricare il file IGC.';

  @override
  String get flightPreview => 'Anteprima volo';

  @override
  String get flightStartLabel => 'Partenza';

  @override
  String get flightLandingLabel => 'Atterraggio';

  @override
  String get flightDurationLabel => 'Durata del volo';

  @override
  String get maxAltitudeLabel => 'Alt. max';

  @override
  String get gpsStartLabel => 'GPS partenza';

  @override
  String get stravaNotConnectedHint =>
      'Strava non connessa. Impostazioni → Servizi collegati.';

  @override
  String get stravaSyncFromHelpText => 'Sincronizza attività da';

  @override
  String get widgetHowToAddTitle => 'Come aggiungere il widget';

  @override
  String get widgetHowToStep1 =>
      '1. Tieni premuto uno spazio vuoto nella schermata';

  @override
  String get widgetHowToStep2 => '2. Tocca \"Widget\"';

  @override
  String get widgetHowToStep3 => '3. Trova \"OutdoorGearTracker\" nell\'elenco';

  @override
  String get widgetHowToStep4 => '4. Trascina il widget nella schermata';

  @override
  String get understood => 'Capito';

  @override
  String get apiKeysTitle => 'Chiavi API';

  @override
  String get exportCsvLabel => 'Esporta come CSV';

  @override
  String get exportCsvSubtitle => 'Esporta tutti i dati in CSV';

  @override
  String get signInWithGoogle => 'Accedi con Google';

  @override
  String get featureComingSoon => 'Funzione in arrivo';

  @override
  String get signOutGoogleAccount => 'Disconnetti account Google';

  @override
  String get availableInPremium => 'Disponibile in Premium';

  @override
  String deleteDataError(Object error) {
    return 'Errore eliminazione: $error';
  }

  @override
  String get exportCompleted => 'Esportazione completata';

  @override
  String get syncTimedOut => 'Sincronizzazione scaduta. Riprova.';

  @override
  String get photoTakePhoto => 'Scatta foto';

  @override
  String get photoFromGallery => 'Scegli dalla galleria';

  @override
  String get photoDeleteConfirm => 'Eliminare la foto?';

  @override
  String get photoAdd => 'Aggiungi foto';

  @override
  String get photoChange => 'Cambia foto';

  @override
  String get apply => 'Applica';

  @override
  String serviceHistoryRecordCount(int count) {
    return '$count record';
  }

  @override
  String warrantyValidUntil(String date) {
    return 'Valido fino al $date';
  }

  @override
  String intervalDays(String n) {
    return 'ogni $n giorni';
  }

  @override
  String intervalHours(String n) {
    return 'ogni $n h';
  }

  @override
  String intervalKm(String n) {
    return 'ogni $n km';
  }

  @override
  String intervalCount(String n) {
    return 'ogni $n×';
  }

  @override
  String flightAdded(String dur, String height) {
    return 'Volo aggiunto: $dur, alt. max $height m';
  }

  @override
  String get insuranceSection => 'Assicurazioni';

  @override
  String get insurance => 'Assicurazioni';

  @override
  String get insuranceSubtitle =>
      'Gestisci le assicurazioni della tua attrezzatura';

  @override
  String get appearanceSection => 'Aspetto';

  @override
  String get appearance => 'Aspetto';

  @override
  String get appearanceSubtitle => 'Tema chiaro / scuro / sistema';

  @override
  String get notificationsSection => 'Notifiche';

  @override
  String get applicationsSection => 'App';

  @override
  String get languageSection => 'Lingua';

  @override
  String get trips => 'Escursioni';

  @override
  String get allDataDeleted => 'Tutti i dati eliminati';

  @override
  String get stravaDisconnectHint =>
      'Rimuove i token di accesso. Le attività registrate rimarranno.';

  @override
  String get stravaApiKeyHint =>
      'Inserisci Client ID e Client Secret dal tuo account API Strava (https://www.strava.com/settings/api).';

  @override
  String get stravaConnectDescription =>
      'Collega l\'app a Strava e sincronizza automaticamente le attività come record di utilizzo dell\'attrezzatura.';

  @override
  String get stravaAccount => 'Account Strava';

  @override
  String get stravaLoadError =>
      'Impossibile caricare lo stato di Strava. Riprova.';

  @override
  String get stravaConnectTimeout =>
      'Connessione scaduta (30 s). Controlla la rete e riprova.';

  @override
  String get googleDriveBackupTitle => 'Backup su Google Drive';

  @override
  String get googleSignInPrompt =>
      'Accedi con Google per salvare i tuoi dati su Google Drive.';

  @override
  String get googleAccount => 'Account Google';

  @override
  String get autoBackupLabel => 'Backup automatico (ogni 7 giorni)';

  @override
  String get uploading => 'Caricamento...';

  @override
  String get backupNow => 'Esegui backup';

  @override
  String get premiumAllFeaturesUnlocked =>
      'Hai tutte le funzionalità sbloccate';

  @override
  String get upgradeToPremium => 'Passa a Premium';

  @override
  String get premiumBenefits =>
      'Attrezzatura illimitata, storico attività completo e altro';

  @override
  String exportError(String error) {
    return 'Errore di esportazione: $error';
  }

  @override
  String lastBackupDate(String date) {
    return 'Ultimo backup: $date';
  }

  @override
  String syncToday(String time) {
    return 'Oggi alle $time';
  }

  @override
  String syncYesterday(String time) {
    return 'Ieri alle $time';
  }

  @override
  String stravaConnectError(String error) {
    return 'Errore imprevisto: $error';
  }

  @override
  String stravaSyncDateLabel(String date) {
    return 'Ultima sync: $date';
  }
}

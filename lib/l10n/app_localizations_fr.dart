// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'OutdoorGearTracker';

  @override
  String get navOverview => 'Aperçu';

  @override
  String get navActivities => 'Activités';

  @override
  String get navMaintenance => 'Maintenance';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get myGear => 'Mon équipement';

  @override
  String get addGear => 'Ajouter équipement';

  @override
  String get add => 'Ajouter';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get close => 'Fermer';

  @override
  String get retry => 'Réessayer';

  @override
  String get loading => 'Chargement…';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get statusActive => 'Actif';

  @override
  String get statusRetired => 'Retraité';

  @override
  String get statusLost => 'Perdu';

  @override
  String get gearStatus => 'État de l\'équipement';

  @override
  String get gearName => 'Nom';

  @override
  String get gearBrand => 'Marque';

  @override
  String get gearModel => 'Modèle';

  @override
  String get gearCategory => 'Catégorie';

  @override
  String get gearNotes => 'Notes';

  @override
  String get gearSerialNumber => 'Numéro de série';

  @override
  String get gearPurchaseDate => 'Date d\'achat';

  @override
  String get gearManufacturedDate => 'Date de fabrication';

  @override
  String get gearPhoto => 'Photo';

  @override
  String get gearAge => 'Âge';

  @override
  String get requiresAttention => 'Nécessite une attention';

  @override
  String get allGoodTitle => 'Tout est bon';

  @override
  String get allGoodSubtitle => 'Aucun rappel de maintenance';

  @override
  String get noGearYet => 'Aucun équipement';

  @override
  String get addFirstGear => 'Ajoutez votre premier équipement';

  @override
  String get statusOverdue => 'En retard';

  @override
  String get statusWarning => 'Bientôt';

  @override
  String get statusOk => 'OK';

  @override
  String get totalHours => 'Total heures';

  @override
  String get totalKm => 'Total km';

  @override
  String get age => 'Âge';

  @override
  String get usageCount => 'Utilisations';

  @override
  String get hours => 'Heures';

  @override
  String get km => 'km';

  @override
  String get elevation => 'Dénivelé';

  @override
  String get activities => 'Activités';

  @override
  String get maintenancePlan => 'Plan de maintenance';

  @override
  String get addMaintenanceRule => 'Ajouter une règle';

  @override
  String get logService => 'Enregistrer un service';

  @override
  String get noMaintenanceRules => 'Aucune règle de maintenance';

  @override
  String get addFirstRule =>
      'Ajoutez la première règle pour suivre la maintenance';

  @override
  String get triggerTypeDate => 'Date';

  @override
  String get triggerTypeHours => 'Heures';

  @override
  String get triggerTypeKm => 'km';

  @override
  String get triggerTypeCount => 'Nombre';

  @override
  String get safetyeCritical => 'Critique pour la sécurité';

  @override
  String get warningBefore => 'Avertir avant';

  @override
  String get ruleName => 'Nom de la règle';

  @override
  String get triggerValue => 'Valeur';

  @override
  String get nextService => 'Prochain service';

  @override
  String get lastService => 'Dernier service';

  @override
  String get serviceHistory => 'Historique des services';

  @override
  String get noServiceHistory => 'Aucun historique de service';

  @override
  String overdueBy(int days) {
    return 'En retard de $days jours';
  }

  @override
  String dueInDays(int days) {
    return 'Dans $days jours';
  }

  @override
  String get activityHistory => 'Historique des activités';

  @override
  String get addActivity => 'Ajouter une activité';

  @override
  String get noActivities => 'Aucun enregistrement d\'utilisation';

  @override
  String get importIgc => 'Importer IGC';

  @override
  String showAll(int count) {
    return 'Tout afficher ($count activités)';
  }

  @override
  String get hide => 'Masquer';

  @override
  String loadMore(int count) {
    return 'Charger plus ($count restants)';
  }

  @override
  String get sourceManual => 'Manuel';

  @override
  String get sourceStrava => 'Strava';

  @override
  String get sourceIgc => 'IGC';

  @override
  String get sourceGarmin => 'Garmin';

  @override
  String get sourceGpx => 'GPX';

  @override
  String get stravaSync => 'Synchronisation Strava';

  @override
  String get stravaConnect => 'Connecter Strava';

  @override
  String get stravaDisconnect => 'Déconnecter';

  @override
  String get stravaConnected => 'Connecté';

  @override
  String get stravasyncActivities => 'Synchroniser les activités';

  @override
  String get stravaAutoSync => 'Synchronisation automatique';

  @override
  String get stravaSyncFrom => 'Synchroniser depuis';

  @override
  String get stravaSyncTypes => 'Types d\'activité';

  @override
  String stravaSyncSuccess(int count, String date) {
    return 'Synchronisé : $count activités (plus récente : $date)';
  }

  @override
  String get stravaSyncNoNew => 'Aucune nouvelle activité';

  @override
  String stravaSyncError(String error) {
    return 'Erreur de synchronisation : $error';
  }

  @override
  String get stravaCredentials => 'Identifiants API';

  @override
  String get stravaClientId => 'Client ID';

  @override
  String get stravaClientSecret => 'Client Secret';

  @override
  String get stravaSaved => 'Identifiants enregistrés';

  @override
  String get connectedServices => 'Services connectés';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabled => 'Notifications activées';

  @override
  String get backupExport => 'Sauvegarde et exportation';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get importData => 'Importer des données';

  @override
  String get clearAllData => 'Effacer toutes les données';

  @override
  String get clearAllDataConfirm =>
      'Supprimer toutes les données ? Cette action est irréversible.';

  @override
  String get exportSuccess => 'Données exportées';

  @override
  String get importSuccess => 'Données importées';

  @override
  String get dataCleared => 'Toutes les données effacées';

  @override
  String get language => 'Langue';

  @override
  String get statistics => 'Statistiques';

  @override
  String get activityOverTime => 'Activité dans le temps';

  @override
  String get byGear => 'Par équipement';

  @override
  String get recentActivities => 'Activités récentes';

  @override
  String get records => 'Records';

  @override
  String get longestActivity => 'Activité la plus longue';

  @override
  String get longestDistance => 'Distance la plus longue';

  @override
  String get mostActiveMonth => 'Mois le plus actif';

  @override
  String get mostUsedGear => 'Le plus utilisé';

  @override
  String get gearCount => 'Pièces d\'équipement';

  @override
  String get maintenanceCount => 'Enregistrements de service';

  @override
  String get filterAll => 'Tout';

  @override
  String get timeFilter3M => '3M';

  @override
  String get timeFilter6M => '6M';

  @override
  String get timeFilter1Y => '1A';

  @override
  String get timeFilter2Y => '2A';

  @override
  String get timeFilterAll => 'Tout';

  @override
  String deleteGearConfirm(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get deleteGearWarning =>
      'Cela supprimera l\'équipement et tous ses enregistrements.';

  @override
  String get performedBy => 'Réalisé par';

  @override
  String get cost => 'Coût';

  @override
  String get nextDueDate => 'Prochaine échéance';

  @override
  String get performedDate => 'Date de réalisation';

  @override
  String get notes => 'Notes';

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
  String get stravaCallbackProcessing => 'Finalisation de la connexion Strava…';

  @override
  String get stravaCallbackExchanging =>
      'Échange du code d\'autorisation contre le jeton d\'accès.';

  @override
  String get stravaCallbackRedirecting => 'Redirection vers les paramètres…';

  @override
  String stravaAccessDenied(String error) {
    return 'Strava a refusé l\'accès : $error';
  }

  @override
  String get stravaMissingCode =>
      'Code d\'autorisation manquant. Veuillez réessayer.';

  @override
  String get maintenanceOverview => 'Vue d\'ensemble de la maintenance';

  @override
  String get allGear => 'Tout est bon';

  @override
  String itemsNeedAttention(int count) {
    return '$count éléments nécessitent une attention';
  }

  @override
  String get sportClimbing => 'Escalade';

  @override
  String get sportSkiAlpinism => 'Ski-alpinisme';

  @override
  String get sportCycling => 'Cyclisme';

  @override
  String get sportParagliding => 'Parapente';

  @override
  String get sportGeneral => 'Général';

  @override
  String get deleteConfirmTitle => 'Confirmer la suppression';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get addGearTitle => 'Nouvel équipement';

  @override
  String get editGearTitle => 'Modifier l\'équipement';

  @override
  String get gearSaved => 'Équipement enregistré';

  @override
  String get locationLabel => 'Lieu';

  @override
  String get dateLabel => 'Date';

  @override
  String get durationLabel => 'Durée';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get notificationsDisabled => 'Notifications désactivées';

  @override
  String stravaSyncedCount(int count) {
    return '$count activités synchronisées';
  }

  @override
  String get stravaSyncedNone => 'Aucune activité synchronisée';

  @override
  String get insuranceTitle => 'Assurances';

  @override
  String get addInsurance => 'Ajouter une assurance';

  @override
  String get noInsurance => 'Aucune assurance';

  @override
  String get noInsuranceHint => 'Ajoute ta première assurance avec le bouton +';

  @override
  String get deleteInsuranceTitle => 'Supprimer l\'assurance ?';

  @override
  String deleteInsuranceConfirm(String name) {
    return 'Supprimer l\'assurance \"$name\" ?';
  }

  @override
  String get insuranceExpired => 'Expirée';

  @override
  String get insuranceExpiringSoon => 'Expire bientôt';

  @override
  String get insuranceActive => 'Active';

  @override
  String insuranceExpiredOn(String date) {
    return 'Expirée le $date';
  }

  @override
  String insuranceValidUntil(String date) {
    return 'Jusqu\'au $date';
  }

  @override
  String get totalAnnualCost => 'Total annuel :';

  @override
  String get insuranceDetails => 'Détails de l\'assurance';

  @override
  String get insuranceStartDate => 'Date de début';

  @override
  String get insuranceExpiryDate => 'Date d\'expiration';

  @override
  String get annualPremium => 'Prime annuelle';

  @override
  String get coverageAmount => 'Montant assuré';

  @override
  String get contractPhoto => 'Photo du contrat';

  @override
  String get linkedGear => 'Équipement lié';

  @override
  String get insuranceActions => 'Actions';

  @override
  String get copyCompanyName => 'Nom de l\'assureur copié';

  @override
  String get contactButton => 'Contact';

  @override
  String get reminderButton => 'Rappel';

  @override
  String contractLabel(String number) {
    return 'Contrat : $number';
  }

  @override
  String get editInsuranceTitle => 'Modifier l\'assurance';

  @override
  String get newInsuranceTitle => 'Nouvelle assurance';

  @override
  String get insuranceNameLabel => 'Nom de l\'assurance *';

  @override
  String get insuranceNameHint => 'ex. Assurance équipement montagne';

  @override
  String get insuranceNameRequired => 'Saisir un nom';

  @override
  String get insuranceTypeLabel => 'Type d\'assurance';

  @override
  String get insuranceCompanyLabel => 'Assureur *';

  @override
  String get insuranceCompanyHint => 'ex. Allianz';

  @override
  String get insuranceCompanyRequired => 'Saisir l\'assureur';

  @override
  String get policyNumberLabel => 'Numéro de police *';

  @override
  String get policyNumberHint => 'numéro de contrat d\'assurance';

  @override
  String get policyNumberRequired => 'Saisir le numéro de police';

  @override
  String get validitySection => 'Validité';

  @override
  String get financialSection => 'Informations financières';

  @override
  String get annualPremiumLabel => 'Prime annuelle';

  @override
  String get coverageAmountLabel => 'Montant assuré';

  @override
  String get optionalHint => 'optionnel';

  @override
  String get selectDate => 'Sélectionner une date';

  @override
  String get selectDateRequired => 'Sélectionner une date *';

  @override
  String get expiryDateRequired => 'Sélectionne une date d\'expiration.';

  @override
  String get basicInfoSection => 'Informations de base';

  @override
  String get linkedGearSection => 'Équipement lié';

  @override
  String get tripsTitle => 'Voyages';

  @override
  String get addTrip => 'Planifier un voyage';

  @override
  String get noTrips => 'Aucun voyage';

  @override
  String get noTripsHint =>
      'Ajoute ton premier voyage et crée une liste d\'équipement.';

  @override
  String get deleteTrip => 'Supprimer le voyage ?';

  @override
  String deleteTripConfirm(String name) {
    return 'Supprimer le voyage \"$name\" ?';
  }

  @override
  String get shareChecklist => 'Partager la liste';

  @override
  String packingProgress(int packed, int total) {
    return '$packed/$total emballé';
  }

  @override
  String get tripWarnings => 'Avertissements avant le voyage';

  @override
  String get tripGearOverdue => 'Entretien requis – limite dépassée';

  @override
  String get tripGearWarning => 'Échéance d\'entretien proche';

  @override
  String gearChecklist(int packed, int total) {
    return 'Équipement ($packed/$total emballé)';
  }

  @override
  String get noGearInTrip =>
      'Aucun équipement. Appuie sur « Ajouter » pour sélectionner.';

  @override
  String get selectGearTitle => 'Sélectionner l\'équipement';

  @override
  String get confirmSelection => 'Confirmer la sélection';

  @override
  String get editTripTitle => 'Modifier le voyage';

  @override
  String get newTripTitle => 'Nouveau voyage';

  @override
  String get tripNameLabel => 'Nom du voyage *';

  @override
  String get tripNameHint => 'ex. Trek d\'été dans les Alpes';

  @override
  String get tripNameRequired => 'Saisir un nom';

  @override
  String get destinationLabel => 'Destination';

  @override
  String get destinationHint => 'ex. Dolomites, Italie';

  @override
  String get departureDateLabel => 'Date de départ';

  @override
  String get returnDateLabel => 'Date de retour';

  @override
  String get tripStatusSection => 'Statut';

  @override
  String get tripStatusLabel => 'Statut du voyage';

  @override
  String get notSelected => 'Non sélectionné';

  @override
  String get saveTripButton => 'Enregistrer le voyage';

  @override
  String get dateSection => 'Dates';

  @override
  String get portfolioTitle => 'Portefeuille';

  @override
  String get purchaseValue => 'Valeur d\'achat';

  @override
  String get currentValue => 'Valeur actuelle';

  @override
  String get annualInsuranceCost => 'Prime annuelle';

  @override
  String get maintenanceCosts => 'Frais d\'entretien';

  @override
  String get valueByCategory => 'Valeur par catégorie';

  @override
  String get maintenanceCostsByMonth => 'Frais d\'entretien par mois';

  @override
  String get noMaintenanceCosts => 'Aucun enregistrement de coûts';

  @override
  String get gearByValue => 'Équipement par valeur';

  @override
  String get noGearWithPrice =>
      'Aucun équipement avec prix d\'achat.\nAjoute le prix dans le détail de l\'équipement.';

  @override
  String get exportForInsurance => 'Exporter pour l\'assurance';

  @override
  String get exportPdfComingSoon =>
      'L\'export PDF sera disponible dans la prochaine version';

  @override
  String get exportPremiumMessage =>
      'L\'export du portefeuille pour les assurances est une fonctionnalité premium.';

  @override
  String get portfolioLoadError => 'Impossible de charger les données.';

  @override
  String depreciatedPercent(int pct) {
    return '–$pct% amorti';
  }

  @override
  String get annualReportTitle => 'Rapport annuel';

  @override
  String get annualReportPdfTitle => 'Aperçu annuel en PDF';

  @override
  String get reportContains => 'Le rapport contient :';

  @override
  String get reportItemActivities =>
      'Aperçu général des activités et entretiens';

  @override
  String get reportItemGearStats => 'Statistiques pour chaque équipement';

  @override
  String get reportItemMonthly => 'Répartition mensuelle des activités';

  @override
  String get reportItemServiceHistory => 'Historique complet des entretiens';

  @override
  String get reportItemInsurance =>
      'Aperçu des assurances et valeur du portefeuille';

  @override
  String get reportItemNextYear => 'Plan d\'entretien pour l\'année prochaine';

  @override
  String get selectYear => 'Sélectionner l\'année';

  @override
  String get currentYearLabel => 'Année en cours';

  @override
  String get lastYearLabel => 'Année dernière';

  @override
  String get twoYearsAgoLabel => 'Il y a deux ans';

  @override
  String generateReport(int year) {
    return 'Générer le rapport $year';
  }

  @override
  String get generatingReport => 'Génération du rapport...';

  @override
  String reportError(String error) {
    return 'Erreur lors de la génération : $error';
  }

  @override
  String get reportShareHint =>
      'Après génération, le PDF sera partagé via le dialogue système (enregistrer, envoyer par e-mail, imprimer...).';

  @override
  String get settingsInsuranceSection => 'Assurances';

  @override
  String get settingsInsuranceSubtitle =>
      'Gérer les assurances de ton équipement';

  @override
  String get settingsAppSection => 'Application';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsAppearanceSubtitle => 'Thème clair / sombre / système';

  @override
  String get themeModeLight => 'Thème clair';

  @override
  String get themeModeDark => 'Thème sombre';

  @override
  String get themeModeSystem => 'Selon le système';

  @override
  String get settingsNotificationsTitle => 'Notifications';

  @override
  String get settingsNotificationsOn =>
      'Tu recevras des rappels avant et après les échéances d\'entretien.';

  @override
  String get settingsNotificationsOff =>
      'Les rappels d\'entretien sont désactivés.';

  @override
  String get settingsNotificationsWeb =>
      'Les notifications push ne sont pas disponibles dans le navigateur.\nUtilise l\'app Android / iOS.';

  @override
  String get settingsBackupSection => 'Sauvegarde et export';

  @override
  String get settingsAnnualReport => 'Rapport PDF annuel';

  @override
  String get settingsAnnualReportSubtitle => 'Exporter l\'aperçu annuel en PDF';

  @override
  String get settingsDataSection => 'Données';

  @override
  String get settingsImportSubtitle => 'Importer depuis un fichier CSV ou GPX';

  @override
  String get settingsClearSubtitle =>
      'Supprime définitivement tout de la base de données';

  @override
  String get settingsWidgetSection => 'Widget';

  @override
  String get settingsWidgetAdd => 'Ajouter un widget';

  @override
  String get settingsWidgetAddSubtitle =>
      'Ajoute un widget à l\'écran d\'accueil : Appui long → Widgets → OutdoorGearTracker';

  @override
  String get settingsWidgetRefresh => 'Actualiser le widget maintenant';

  @override
  String get settingsWidgetRefreshed => 'Widget mis à jour';

  @override
  String get settingsAboutSection => 'À propos';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get backupSuccess =>
      'Sauvegarde téléchargée sur Google Drive avec succès.';

  @override
  String get restoreSuccess =>
      'Données restaurées avec succès. Redémarre l\'app.';

  @override
  String get restoreConfirmTitle => 'Restaurer depuis la sauvegarde ?';

  @override
  String get restoreConfirmContent =>
      'Cela remplacera la base de données et les photos actuelles par les données de sauvegarde. Continuer ?';

  @override
  String get restoreButton => 'Restaurer';

  @override
  String get notificationPermissionDenied =>
      'Permission de notification refusée.';

  @override
  String get settingsButton => 'Paramètres';

  @override
  String get premiumUnlocked => '🎉 Premium activé ! Merci pour ton soutien.';

  @override
  String get restorePurchasesButton => 'Restaurer les achats';

  @override
  String get noPreviousPurchases => 'Aucun achat précédent trouvé.';

  @override
  String get purchasesRestored => '✅ Achats restaurés !';

  @override
  String get paywallTagline => 'Sans limites. Sécurité sans compromis.';

  @override
  String get maybeLater => 'Peut-être plus tard';

  @override
  String get tapToUnlock => 'Appuie pour déverrouiller';

  @override
  String getPremiumButton(String price) {
    return 'Obtenir Premium – $price';
  }

  @override
  String get purchaseUnavailable =>
      'Achat pas encore disponible – configure un produit dans le tableau de bord RevenueCat.';

  @override
  String get deleteServiceRecord => 'Supprimer l\'entrée';

  @override
  String get deleteServiceRecordConfirm =>
      'Voulez-vous vraiment supprimer cet enregistrement?';

  @override
  String get editServiceRecord => 'Modifier l\'entrée';

  @override
  String get editServiceTitle => 'Modifier l\'enregistrement';

  @override
  String get notYetPerformed => 'Pas encore effectué';

  @override
  String get noServiceEntries => 'Aucun enregistrement de service';

  @override
  String get recordFirstService => 'Enregistrer le premier service';

  @override
  String get serviceHistoryFull => 'Historique complet des services';

  @override
  String get warrantyExpired => 'Garantie expirée';

  @override
  String get warrantySection => 'Garantie';

  @override
  String get gearInsuranceSection => 'Assurance';

  @override
  String get noInsurancesAttached => 'Aucune police';

  @override
  String get igcLoadError => 'Impossible de charger le fichier IGC.';

  @override
  String get flightPreview => 'Aperçu du vol';

  @override
  String get flightStartLabel => 'Départ';

  @override
  String get flightLandingLabel => 'Atterrissage';

  @override
  String get flightDurationLabel => 'Durée du vol';

  @override
  String get maxAltitudeLabel => 'Alt. max.';

  @override
  String get gpsStartLabel => 'GPS départ';

  @override
  String get stravaNotConnectedHint =>
      'Strava non connectée. Paramètres → Services connectés.';

  @override
  String get stravaSyncFromHelpText => 'Synchroniser les activités depuis';

  @override
  String get widgetHowToAddTitle => 'Comment ajouter le widget';

  @override
  String get widgetHowToStep1 =>
      '1. Appuyez longuement sur un espace vide de l\'écran';

  @override
  String get widgetHowToStep2 => '2. Appuyez sur \"Widgets\"';

  @override
  String get widgetHowToStep3 =>
      '3. Trouvez \"OutdoorGearTracker\" dans la liste';

  @override
  String get widgetHowToStep4 => '4. Faites glisser le widget sur l\'écran';

  @override
  String get understood => 'Compris';

  @override
  String get apiKeysTitle => 'Clés API';

  @override
  String get exportCsvLabel => 'Exporter en CSV';

  @override
  String get exportCsvSubtitle => 'Exporter toutes les données en CSV';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get featureComingSoon => 'Fonctionnalité à venir';

  @override
  String get signOutGoogleAccount => 'Se déconnecter de Google';

  @override
  String get availableInPremium => 'Disponible en Premium';

  @override
  String deleteDataError(Object error) {
    return 'Erreur lors de la suppression: $error';
  }

  @override
  String get exportCompleted => 'Export terminé';

  @override
  String get syncTimedOut => 'La synchronisation a expiré. Réessayez.';

  @override
  String get photoTakePhoto => 'Prendre une photo';

  @override
  String get photoFromGallery => 'Choisir dans la galerie';

  @override
  String get photoDeleteConfirm => 'Supprimer la photo?';

  @override
  String get photoAdd => 'Ajouter une photo';

  @override
  String get photoChange => 'Changer la photo';

  @override
  String get apply => 'Appliquer';

  @override
  String serviceHistoryRecordCount(int count) {
    return '$count entrées';
  }

  @override
  String warrantyValidUntil(String date) {
    return 'Valable jusqu\'au $date';
  }

  @override
  String intervalDays(String n) {
    return 'tous les $n jours';
  }

  @override
  String intervalHours(String n) {
    return 'toutes les $n h';
  }

  @override
  String intervalKm(String n) {
    return 'tous les $n km';
  }

  @override
  String intervalCount(String n) {
    return 'tous les $n×';
  }

  @override
  String flightAdded(String dur, String height) {
    return 'Vol ajouté: $dur, alt. max. $height m';
  }
}

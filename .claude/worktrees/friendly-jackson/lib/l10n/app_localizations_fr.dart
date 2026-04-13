// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'GearTracker';

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
}

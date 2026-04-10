// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'GearTracker';

  @override
  String get navOverview => 'Resumen';

  @override
  String get navActivities => 'Actividades';

  @override
  String get navMaintenance => 'Mantenimiento';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get myGear => 'Mi equipo';

  @override
  String get addGear => 'Añadir equipo';

  @override
  String get add => 'Añadir';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Cerrar';

  @override
  String get retry => 'Reintentar';

  @override
  String get loading => 'Cargando…';

  @override
  String get noData => 'Sin datos';

  @override
  String get statusActive => 'Activo';

  @override
  String get statusRetired => 'Retirado';

  @override
  String get statusLost => 'Perdido';

  @override
  String get gearStatus => 'Estado del equipo';

  @override
  String get gearName => 'Nombre';

  @override
  String get gearBrand => 'Marca';

  @override
  String get gearModel => 'Modelo';

  @override
  String get gearCategory => 'Categoría';

  @override
  String get gearNotes => 'Notas';

  @override
  String get gearSerialNumber => 'Número de serie';

  @override
  String get gearPurchaseDate => 'Fecha de compra';

  @override
  String get gearManufacturedDate => 'Fecha de fabricación';

  @override
  String get gearPhoto => 'Foto';

  @override
  String get gearAge => 'Antigüedad';

  @override
  String get requiresAttention => 'Requiere atención';

  @override
  String get allGoodTitle => 'Todo en orden';

  @override
  String get allGoodSubtitle => 'Sin recordatorios de mantenimiento';

  @override
  String get noGearYet => 'Aún no hay equipo';

  @override
  String get addFirstGear => 'Añade tu primer equipo';

  @override
  String get statusOverdue => 'Vencido';

  @override
  String get statusWarning => 'Pronto';

  @override
  String get statusOk => 'OK';

  @override
  String get totalHours => 'Total de horas';

  @override
  String get totalKm => 'Total km';

  @override
  String get age => 'Antigüedad';

  @override
  String get usageCount => 'Usos';

  @override
  String get hours => 'Horas';

  @override
  String get km => 'km';

  @override
  String get elevation => 'Desnivel';

  @override
  String get activities => 'Actividades';

  @override
  String get maintenancePlan => 'Plan de mantenimiento';

  @override
  String get addMaintenanceRule => 'Añadir regla';

  @override
  String get logService => 'Registrar servicio';

  @override
  String get noMaintenanceRules => 'Sin reglas de mantenimiento';

  @override
  String get addFirstRule =>
      'Añade la primera regla para seguir el mantenimiento';

  @override
  String get triggerTypeDate => 'Fecha';

  @override
  String get triggerTypeHours => 'Horas';

  @override
  String get triggerTypeKm => 'km';

  @override
  String get triggerTypeCount => 'Cantidad';

  @override
  String get safetyeCritical => 'Crítico para la seguridad';

  @override
  String get warningBefore => 'Avisar antes';

  @override
  String get ruleName => 'Nombre de la regla';

  @override
  String get triggerValue => 'Valor';

  @override
  String get nextService => 'Próximo servicio';

  @override
  String get lastService => 'Último servicio';

  @override
  String get serviceHistory => 'Historial de servicio';

  @override
  String get noServiceHistory => 'Sin historial de servicio';

  @override
  String overdueBy(int days) {
    return 'Vencido hace $days días';
  }

  @override
  String dueInDays(int days) {
    return 'En $days días';
  }

  @override
  String get activityHistory => 'Historial de actividades';

  @override
  String get addActivity => 'Añadir actividad';

  @override
  String get noActivities => 'Sin registros de uso';

  @override
  String get importIgc => 'Importar IGC';

  @override
  String showAll(int count) {
    return 'Mostrar todo ($count actividades)';
  }

  @override
  String get hide => 'Ocultar';

  @override
  String loadMore(int count) {
    return 'Cargar más ($count restantes)';
  }

  @override
  String get sourceManual => 'Manual';

  @override
  String get sourceStrava => 'Strava';

  @override
  String get sourceIgc => 'IGC';

  @override
  String get sourceGarmin => 'Garmin';

  @override
  String get sourceGpx => 'GPX';

  @override
  String get stravaSync => 'Sincronización con Strava';

  @override
  String get stravaConnect => 'Conectar Strava';

  @override
  String get stravaDisconnect => 'Desconectar';

  @override
  String get stravaConnected => 'Conectado';

  @override
  String get stravasyncActivities => 'Sincronizar actividades';

  @override
  String get stravaAutoSync => 'Sincronización automática';

  @override
  String get stravaSyncFrom => 'Sincronizar desde';

  @override
  String get stravaSyncTypes => 'Tipos de actividad';

  @override
  String stravaSyncSuccess(int count, String date) {
    return 'Sincronizado: $count actividades (más reciente: $date)';
  }

  @override
  String get stravaSyncNoNew => 'Sin nuevas actividades';

  @override
  String stravaSyncError(String error) {
    return 'Error de sincronización: $error';
  }

  @override
  String get stravaCredentials => 'Credenciales de API';

  @override
  String get stravaClientId => 'Client ID';

  @override
  String get stravaClientSecret => 'Client Secret';

  @override
  String get stravaSaved => 'Credenciales guardadas';

  @override
  String get connectedServices => 'Servicios conectados';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationsEnabled => 'Notificaciones activadas';

  @override
  String get backupExport => 'Copia de seguridad y exportación';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get importData => 'Importar datos';

  @override
  String get clearAllData => 'Borrar todos los datos';

  @override
  String get clearAllDataConfirm =>
      '¿Eliminar todos los datos? Esta acción no se puede deshacer.';

  @override
  String get exportSuccess => 'Datos exportados';

  @override
  String get importSuccess => 'Datos importados';

  @override
  String get dataCleared => 'Todos los datos eliminados';

  @override
  String get language => 'Idioma';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get activityOverTime => 'Actividad en el tiempo';

  @override
  String get byGear => 'Por equipo';

  @override
  String get recentActivities => 'Actividades recientes';

  @override
  String get records => 'Récords';

  @override
  String get longestActivity => 'Actividad más larga';

  @override
  String get longestDistance => 'Distancia más larga';

  @override
  String get mostActiveMonth => 'Mes más activo';

  @override
  String get mostUsedGear => 'Más usado';

  @override
  String get gearCount => 'Piezas de equipo';

  @override
  String get maintenanceCount => 'Registros de servicio';

  @override
  String get filterAll => 'Todo';

  @override
  String get timeFilter3M => '3M';

  @override
  String get timeFilter6M => '6M';

  @override
  String get timeFilter1Y => '1A';

  @override
  String get timeFilter2Y => '2A';

  @override
  String get timeFilterAll => 'Todo';

  @override
  String deleteGearConfirm(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get deleteGearWarning =>
      'Esto eliminará el equipo y todos sus registros.';

  @override
  String get performedBy => 'Realizado por';

  @override
  String get cost => 'Coste';

  @override
  String get nextDueDate => 'Próximo vencimiento';

  @override
  String get performedDate => 'Fecha de realización';

  @override
  String get notes => 'Notas';

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
  String get stravaCallbackProcessing =>
      'Completando inicio de sesión en Strava…';

  @override
  String get stravaCallbackExchanging =>
      'Intercambiando código de autorización por token de acceso.';

  @override
  String get stravaCallbackRedirecting => 'Redirigiendo de vuelta a ajustes…';

  @override
  String stravaAccessDenied(String error) {
    return 'Strava denegó el acceso: $error';
  }

  @override
  String get stravaMissingCode =>
      'Código de autorización no encontrado. Por favor, inténtalo de nuevo.';

  @override
  String get maintenanceOverview => 'Resumen de mantenimiento';

  @override
  String get allGear => 'Todo en orden';

  @override
  String itemsNeedAttention(int count) {
    return '$count elementos necesitan atención';
  }

  @override
  String get sportClimbing => 'Escalada';

  @override
  String get sportSkiAlpinism => 'Esquí de montaña';

  @override
  String get sportCycling => 'Ciclismo';

  @override
  String get sportParagliding => 'Parapente';

  @override
  String get sportGeneral => 'General';

  @override
  String get deleteConfirmTitle => 'Confirmar eliminación';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get addGearTitle => 'Nuevo equipo';

  @override
  String get editGearTitle => 'Editar equipo';

  @override
  String get gearSaved => 'Equipo guardado';

  @override
  String get locationLabel => 'Lugar';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get durationLabel => 'Duración';

  @override
  String get distanceLabel => 'Distancia';

  @override
  String get notificationsDisabled => 'Notificaciones desactivadas';

  @override
  String stravaSyncedCount(int count) {
    return '$count actividades sincronizadas';
  }

  @override
  String get stravaSyncedNone => 'No hay actividades sincronizadas';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'OutdoorGearTracker';

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

  @override
  String get insuranceTitle => 'Seguros';

  @override
  String get addInsurance => 'Añadir seguro';

  @override
  String get noInsurance => 'Sin seguros';

  @override
  String get noInsuranceHint => 'Añade tu primer seguro con el botón +';

  @override
  String get deleteInsuranceTitle => '¿Eliminar seguro?';

  @override
  String deleteInsuranceConfirm(String name) {
    return '¿Eliminar el seguro \"$name\"?';
  }

  @override
  String get insuranceExpired => 'Caducado';

  @override
  String get insuranceExpiringSoon => 'Caduca pronto';

  @override
  String get insuranceActive => 'Activo';

  @override
  String insuranceExpiredOn(String date) {
    return 'Caducó el $date';
  }

  @override
  String insuranceValidUntil(String date) {
    return 'Hasta $date';
  }

  @override
  String get totalAnnualCost => 'Total anual:';

  @override
  String get insuranceDetails => 'Detalles del seguro';

  @override
  String get insuranceStartDate => 'Fecha de inicio';

  @override
  String get insuranceExpiryDate => 'Fecha de caducidad';

  @override
  String get annualPremium => 'Prima anual';

  @override
  String get coverageAmount => 'Suma asegurada';

  @override
  String get contractPhoto => 'Foto del contrato';

  @override
  String get linkedGear => 'Equipo vinculado';

  @override
  String get insuranceActions => 'Acciones';

  @override
  String get copyCompanyName => 'Nombre de aseguradora copiado';

  @override
  String get contactButton => 'Contacto';

  @override
  String get reminderButton => 'Recordatorio';

  @override
  String contractLabel(String number) {
    return 'Contrato: $number';
  }

  @override
  String get editInsuranceTitle => 'Editar seguro';

  @override
  String get newInsuranceTitle => 'Nuevo seguro';

  @override
  String get insuranceNameLabel => 'Nombre del seguro *';

  @override
  String get insuranceNameHint => 'p.ej. Seguro de equipo de montaña';

  @override
  String get insuranceNameRequired => 'Introduce un nombre';

  @override
  String get insuranceTypeLabel => 'Tipo de seguro';

  @override
  String get insuranceCompanyLabel => 'Aseguradora *';

  @override
  String get insuranceCompanyHint => 'p.ej. Allianz';

  @override
  String get insuranceCompanyRequired => 'Introduce la aseguradora';

  @override
  String get policyNumberLabel => 'Número de póliza *';

  @override
  String get policyNumberHint => 'número de contrato de seguro';

  @override
  String get policyNumberRequired => 'Introduce el número de póliza';

  @override
  String get validitySection => 'Vigencia';

  @override
  String get financialSection => 'Información financiera';

  @override
  String get annualPremiumLabel => 'Prima anual';

  @override
  String get coverageAmountLabel => 'Suma asegurada';

  @override
  String get optionalHint => 'opcional';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get selectDateRequired => 'Seleccionar fecha *';

  @override
  String get expiryDateRequired => 'Selecciona la fecha de caducidad.';

  @override
  String get basicInfoSection => 'Información básica';

  @override
  String get linkedGearSection => 'Equipo vinculado';

  @override
  String get tripsTitle => 'Excursiones';

  @override
  String get addTrip => 'Planificar excursión';

  @override
  String get noTrips => 'Sin excursiones';

  @override
  String get noTripsHint =>
      'Añade tu primera excursión y crea una lista de equipo.';

  @override
  String get deleteTrip => '¿Eliminar excursión?';

  @override
  String deleteTripConfirm(String name) {
    return '¿Eliminar la excursión \"$name\"?';
  }

  @override
  String get shareChecklist => 'Compartir lista';

  @override
  String packingProgress(int packed, int total) {
    return '$packed/$total empaquetado';
  }

  @override
  String get tripWarnings => 'Avisos previos al viaje';

  @override
  String get tripGearOverdue => 'Requiere servicio – límite superado';

  @override
  String get tripGearWarning => 'Fecha de servicio próxima';

  @override
  String gearChecklist(int packed, int total) {
    return 'Equipo ($packed/$total empaquetado)';
  }

  @override
  String get noGearInTrip => 'Sin equipo aún. Toca «Añadir» para seleccionar.';

  @override
  String get selectGearTitle => 'Seleccionar equipo';

  @override
  String get addCustomItem => 'Elemento personalizado';

  @override
  String get customItemHint => 'p. ej. calcetines, medicamentos, cargador';

  @override
  String get confirmSelection => 'Confirmar selección';

  @override
  String get editTripTitle => 'Editar excursión';

  @override
  String get newTripTitle => 'Nueva excursión';

  @override
  String get tripNameLabel => 'Nombre de la excursión *';

  @override
  String get tripNameHint => 'p.ej. Trekking de verano en los Alpes';

  @override
  String get tripNameRequired => 'Introduce un nombre';

  @override
  String get destinationLabel => 'Destino';

  @override
  String get destinationHint => 'p.ej. Dolomitas, Italia';

  @override
  String get departureDateLabel => 'Fecha de salida';

  @override
  String get returnDateLabel => 'Fecha de regreso';

  @override
  String get tripStatusSection => 'Estado';

  @override
  String get tripStatusLabel => 'Estado de la excursión';

  @override
  String get notSelected => 'No seleccionado';

  @override
  String get saveTripButton => 'Guardar excursión';

  @override
  String get dateSection => 'Fechas';

  @override
  String get portfolioTitle => 'Portafolio';

  @override
  String get purchaseValue => 'Valor de compra';

  @override
  String get currentValue => 'Valor actual';

  @override
  String get annualInsuranceCost => 'Prima anual';

  @override
  String get maintenanceCosts => 'Costes de mantenimiento';

  @override
  String get valueByCategory => 'Valor por categoría';

  @override
  String get maintenanceCostsByMonth => 'Costes de mantenimiento por mes';

  @override
  String get noMaintenanceCosts => 'Sin registros de costes';

  @override
  String get gearByValue => 'Equipo por valor';

  @override
  String get noGearWithPrice =>
      'Sin equipo con precio de compra.\nAñade el precio en el detalle del equipo.';

  @override
  String get exportForInsurance => 'Exportar para seguro';

  @override
  String get exportPdfComingSoon =>
      'La exportación PDF estará disponible en la próxima versión';

  @override
  String get exportPremiumMessage =>
      'La exportación del portafolio para seguros es una función premium.';

  @override
  String get portfolioLoadError => 'No se pudieron cargar los datos.';

  @override
  String depreciatedPercent(int pct) {
    return '–$pct% depreciado';
  }

  @override
  String get annualReportTitle => 'Informe anual';

  @override
  String get annualReportPdfTitle => 'Resumen anual en PDF';

  @override
  String get reportContains => 'El informe incluye:';

  @override
  String get reportItemActivities =>
      'Resumen general de actividades y servicios';

  @override
  String get reportItemGearStats => 'Estadísticas de cada equipo';

  @override
  String get reportItemMonthly => 'Desglose mensual de actividades';

  @override
  String get reportItemServiceHistory => 'Historial completo de servicios';

  @override
  String get reportItemInsurance => 'Resumen de seguros y valor del portafolio';

  @override
  String get reportItemNextYear => 'Plan de servicios para el próximo año';

  @override
  String get selectYear => 'Seleccionar año';

  @override
  String get currentYearLabel => 'Año actual';

  @override
  String get lastYearLabel => 'Año pasado';

  @override
  String get twoYearsAgoLabel => 'Hace dos años';

  @override
  String generateReport(int year) {
    return 'Generar informe $year';
  }

  @override
  String get generatingReport => 'Generando informe...';

  @override
  String reportError(String error) {
    return 'Error al generar el informe: $error';
  }

  @override
  String get reportShareHint =>
      'Tras generarlo, el PDF se compartirá mediante el diálogo del sistema (guardar, enviar por correo, imprimir...).';

  @override
  String get settingsInsuranceSection => 'Seguros';

  @override
  String get settingsInsuranceSubtitle => 'Gestiona los seguros de tu equipo';

  @override
  String get settingsAppSection => 'App';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsAppearanceSubtitle => 'Tema claro / oscuro / sistema';

  @override
  String get themeModeLight => 'Tema claro';

  @override
  String get themeModeDark => 'Tema oscuro';

  @override
  String get themeModeSystem => 'Según el sistema';

  @override
  String get settingsNotificationsTitle => 'Notificaciones';

  @override
  String get settingsNotificationsOn =>
      'Recibirás recordatorios antes y después de las fechas de servicio.';

  @override
  String get settingsNotificationsOff =>
      'Los recordatorios de servicio están desactivados.';

  @override
  String get settingsNotificationsWeb =>
      'Las notificaciones push no están disponibles en el navegador.\nUsa la app Android / iOS.';

  @override
  String get settingsBackupSection => 'Copia de seguridad y exportación';

  @override
  String get settingsAnnualReport => 'Informe PDF anual';

  @override
  String get settingsAnnualReportSubtitle =>
      'Exportar el resumen anual como PDF';

  @override
  String get settingsDataSection => 'Datos';

  @override
  String get settingsImportSubtitle => 'Importar desde archivo CSV o GPX';

  @override
  String get settingsClearSubtitle =>
      'Elimina permanentemente todo de la base de datos';

  @override
  String get settingsWidgetSection => 'Widget';

  @override
  String get settingsWidgetAdd => 'Añadir widget';

  @override
  String get settingsWidgetAddSubtitle =>
      'Añade widget a la pantalla de inicio: Mantén pulsado → Widgets → OutdoorGearTracker';

  @override
  String get settingsWidgetRefresh => 'Actualizar widget ahora';

  @override
  String get settingsWidgetRefreshed => 'Widget actualizado';

  @override
  String get settingsAboutSection => 'Acerca de';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get backupSuccess =>
      'Copia de seguridad subida correctamente a Google Drive.';

  @override
  String get restoreSuccess =>
      'Datos restaurados correctamente. Reinicia la app.';

  @override
  String get restoreConfirmTitle => '¿Restaurar desde copia de seguridad?';

  @override
  String get restoreConfirmContent =>
      'Esto reemplazará la base de datos y fotos actuales con los datos de la copia. ¿Continuar?';

  @override
  String get restoreButton => 'Restaurar';

  @override
  String get notificationPermissionDenied =>
      'Permiso de notificaciones denegado.';

  @override
  String get settingsButton => 'Ajustes';

  @override
  String get premiumUnlocked => '🎉 ¡Premium activado! Gracias por tu apoyo.';

  @override
  String get restorePurchasesButton => 'Restaurar compras';

  @override
  String get noPreviousPurchases => 'No se encontraron compras anteriores.';

  @override
  String get purchasesRestored => '✅ ¡Compras restauradas!';

  @override
  String get paywallTagline => 'Sin límites. Seguridad sin compromisos.';

  @override
  String get maybeLater => 'Quizás más tarde';

  @override
  String get tapToUnlock => 'Toca para desbloquear';

  @override
  String getPremiumButton(String price) {
    return 'Obtener Premium – $price';
  }

  @override
  String get purchaseUnavailable =>
      'La compra no está disponible actualmente. Inténtalo de nuevo más tarde.';

  @override
  String get deleteServiceRecord => 'Eliminar registro';

  @override
  String get deleteServiceRecordConfirm =>
      '¿Desea eliminar este registro de servicio?';

  @override
  String get editServiceRecord => 'Editar registro';

  @override
  String get editServiceTitle => 'Editar registro de servicio';

  @override
  String get notYetPerformed => 'Aún no realizado';

  @override
  String get noServiceEntries => 'Sin registros de servicio';

  @override
  String get recordFirstService => 'Registrar primer servicio';

  @override
  String get serviceHistoryFull => 'Historial completo de servicio';

  @override
  String get warrantyExpired => 'Garantía vencida';

  @override
  String get warrantySection => 'Garantía';

  @override
  String get gearInsuranceSection => 'Seguro';

  @override
  String get noInsurancesAttached => 'Sin pólizas de seguro';

  @override
  String get igcLoadError => 'No se pudo cargar el archivo IGC.';

  @override
  String get flightPreview => 'Vista previa del vuelo';

  @override
  String get flightStartLabel => 'Salida';

  @override
  String get flightLandingLabel => 'Aterrizaje';

  @override
  String get flightDurationLabel => 'Duración del vuelo';

  @override
  String get maxAltitudeLabel => 'Alt. máx.';

  @override
  String get gpsStartLabel => 'GPS inicio';

  @override
  String get stravaNotConnectedHint =>
      'Strava no conectada. Ve a Ajustes → Servicios conectados.';

  @override
  String get stravaSyncFromHelpText => 'Sincronizar actividades desde';

  @override
  String get widgetHowToAddTitle => 'Cómo añadir widget';

  @override
  String get widgetHowToStep1 =>
      '1. Mantén pulsado un espacio vacío en la pantalla de inicio';

  @override
  String get widgetHowToStep2 => '2. Toca \"Widgets\"';

  @override
  String get widgetHowToStep3 => '3. Busca \"OutdoorGearTracker\" en la lista';

  @override
  String get widgetHowToStep4 =>
      '4. Arrastra el widget a la pantalla de inicio';

  @override
  String get understood => 'Entendido';

  @override
  String get apiKeysTitle => 'Claves API';

  @override
  String get exportCsvLabel => 'Exportar como CSV';

  @override
  String get exportCsvSubtitle => 'Exportar todos los datos a CSV';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get featureComingSoon => 'Función próximamente';

  @override
  String get signOutGoogleAccount => 'Cerrar sesión de Google';

  @override
  String get availableInPremium => 'Disponible en Premium';

  @override
  String deleteDataError(Object error) {
    return 'Error al eliminar datos: $error';
  }

  @override
  String get exportCompleted => 'Exportación completada';

  @override
  String get syncTimedOut => 'La sincronización expiró. Inténtalo de nuevo.';

  @override
  String get photoTakePhoto => 'Tomar foto';

  @override
  String get photoFromGallery => 'Elegir de la galería';

  @override
  String get photoDeleteConfirm => '¿Eliminar foto?';

  @override
  String get photoAdd => 'Añadir foto';

  @override
  String get photoChange => 'Cambiar foto';

  @override
  String get apply => 'Aplicar';

  @override
  String serviceHistoryRecordCount(int count) {
    return '$count registros';
  }

  @override
  String warrantyValidUntil(String date) {
    return 'Válido hasta $date';
  }

  @override
  String intervalDays(String n) {
    return 'cada $n días';
  }

  @override
  String intervalHours(String n) {
    return 'cada $n h';
  }

  @override
  String intervalKm(String n) {
    return 'cada $n km';
  }

  @override
  String intervalCount(String n) {
    return 'cada $n×';
  }

  @override
  String flightAdded(String dur, String height) {
    return 'Vuelo añadido: $dur, alt. máx. $height m';
  }

  @override
  String get insuranceSection => 'Seguros';

  @override
  String get insurance => 'Seguros';

  @override
  String get insuranceSubtitle => 'Gestiona los seguros de tu equipo';

  @override
  String get appearanceSection => 'Apariencia';

  @override
  String get appearance => 'Apariencia';

  @override
  String get appearanceSubtitle => 'Tema claro / oscuro / sistema';

  @override
  String get notificationsSection => 'Notificaciones';

  @override
  String get applicationsSection => 'App';

  @override
  String get languageSection => 'Idioma';

  @override
  String get trips => 'Excursiones';

  @override
  String get allDataDeleted => 'Todos los datos eliminados';

  @override
  String get stravaDisconnectHint =>
      'Elimina los tokens de acceso. Las actividades registradas permanecerán.';

  @override
  String get stravaApiKeyHint =>
      'Introduce el Client ID y Client Secret de tu cuenta de API de Strava (https://www.strava.com/settings/api).';

  @override
  String get stravaConnectDescription =>
      'Conecta la app con Strava y sincroniza actividades automáticamente como registros de uso del equipo.';

  @override
  String get stravaAccount => 'Cuenta de Strava';

  @override
  String get stravaLoadError =>
      'No se pudo cargar el estado de Strava. Inténtalo de nuevo.';

  @override
  String get stravaConnectTimeout =>
      'La conexión expiró (30 s). Comprueba tu red e inténtalo de nuevo.';

  @override
  String get googleDriveBackupTitle => 'Copia de seguridad en Google Drive';

  @override
  String get googleSignInPrompt =>
      'Inicia sesión con Google para hacer una copia de seguridad en Google Drive.';

  @override
  String get googleAccount => 'Cuenta de Google';

  @override
  String get autoBackupLabel => 'Copia de seguridad automática (cada 7 días)';

  @override
  String get uploading => 'Subiendo...';

  @override
  String get backupNow => 'Hacer copia';

  @override
  String get premiumAllFeaturesUnlocked =>
      'Tienes todas las funciones desbloqueadas';

  @override
  String get upgradeToPremium => 'Actualizar a Premium';

  @override
  String get premiumBenefits =>
      'Equipo ilimitado, historial completo de actividades y más';

  @override
  String exportError(String error) {
    return 'Error de exportación: $error';
  }

  @override
  String lastBackupDate(String date) {
    return 'Última copia: $date';
  }

  @override
  String syncToday(String time) {
    return 'Hoy a las $time';
  }

  @override
  String syncYesterday(String time) {
    return 'Ayer a las $time';
  }

  @override
  String stravaConnectError(String error) {
    return 'Error inesperado: $error';
  }

  @override
  String stravaSyncDateLabel(String date) {
    return 'Última sincronización: $date';
  }
}

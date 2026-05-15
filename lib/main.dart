import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/db_factory.dart';
import 'database/database_helper.dart';
import 'l10n/app_localizations.dart';
import 'mock_data.dart';
import 'services/backup_service.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';
import 'services/widget_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/gear_list_screen.dart';
import 'screens/gear_detail_screen.dart';
import 'screens/add_gear_screen.dart';
import 'screens/maintenance_screen.dart';
import 'screens/activities_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/strava_callback_screen.dart';
import 'screens/insurance_list_screen.dart';
import 'screens/add_edit_insurance_screen.dart';
import 'screens/insurance_detail_screen.dart';
import 'screens/trip_list_screen.dart';
import 'screens/add_edit_trip_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/annual_report_screen.dart';
import 'services/insurance_service.dart';
import 'models/trip.dart';

/// Global locale notifier – updated by SettingsScreen when the user picks a language.
final localeNotifier = ValueNotifier<Locale>(const Locale('cs'));

/// Global theme mode notifier – updated by SettingsScreen.
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

Future<void> _loadLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('app_locale') ?? 'cs';
  localeNotifier.value = Locale(code);
}

Future<void> _loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getString('app_theme_mode') ?? 'system';
  themeModeNotifier.value = switch (value) {
    'light'  => ThemeMode.light,
    'dark'   => ThemeMode.dark,
    _        => ThemeMode.system,
  };
}

/// Called from [main] – contains all initialization logic.
/// Separated so the top-level [main] can wrap it in a runZonedGuarded error
/// boundary and catch any unhandled async exception that would otherwise
/// produce a silent black screen.
Future<void> _mainBody() async {
  debugPrint('[Main] ══════════════════════════════════════');
  debugPrint('[Main] GearTracker startup — v1.0.15+16');
  debugPrint('[Main] ══════════════════════════════════════');

  debugPrint('[Main] Step 1/9 — usePathUrlStrategy');
  usePathUrlStrategy(); // path-based URLs on web (no #); must be first

  debugPrint('[Main] Step 2/9 — WidgetsFlutterBinding.ensureInitialized');
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('[Main] Step 3/9 — initDatabaseFactory');
  await initDatabaseFactory();
  debugPrint('[Main] Step 3/9 — initDatabaseFactory OK');

  // ── Apply pending restore BEFORE any DB or widget is initialised ────────
  // If the user triggered a restore in a previous session, the ZIP was saved
  // locally and flagged in SharedPreferences.  We extract it here — while no
  // SQLite connection is open and no widget tree exists — to guarantee a clean
  // DB replacement with zero chance of a black screen / stale-state crash.
  debugPrint('[Main] Step 4/9 — applyPendingRestoreIfNeeded');
  await BackupService.instance.applyPendingRestoreIfNeeded();
  debugPrint('[Main] Step 4/9 — applyPendingRestoreIfNeeded OK');

  // ── Zajisti výchozí kategorie ───────────────────────────────────────────
  // Musí běžet AŽ PO případném restore (přepisuje DB soubor) a PŘED runApp.
  // onCreate se na obnovené / přežilé DB nezavolá, takže seed kategorií
  // explicitně tady — count-based check, nikoli persistovaný flag.
  // Selhání nesmí zhasnout start: runApp() musí proběhnout vždy, jinak by
  // uživatel místo error UI viděl prázdnou obrazovku.
  debugPrint('[Main] Step 4b/9 — ensureCategoriesSeeded');
  try {
    final seed = await DatabaseHelper.instance.ensureCategoriesSeeded();
    debugPrint('[Main] Step 4b/9 — ensureCategoriesSeeded OK '
        '(inserted=${seed.inserted}, failed=${seed.failed})');
  } catch (e, st) {
    debugPrint('[Main] Step 4b/9 — ensureCategoriesSeeded FAILED (non-fatal): $e\n$st');
  }

  debugPrint('[Main] Step 5/9 — MockDataSeeder.seedIfEmpty');
  await MockDataSeeder.seedIfEmpty();
  debugPrint('[Main] Step 5/9 — MockDataSeeder OK');

  debugPrint('[Main] Step 6/9 — _loadLocale + _loadThemeMode');
  await _loadLocale();
  await _loadThemeMode();
  debugPrint('[Main] Step 6/9 — locale/theme OK');

  // In-app purchases – initialize before runApp so isPremium() works immediately
  debugPrint('[Main] Step 7/9 — PurchaseService.init');
  try {
    await PurchaseService.instance.init();
    debugPrint('[Main] Step 7/9 — PurchaseService OK');
  } catch (e, st) {
    debugPrint('[Main] Step 7/9 — PurchaseService FAILED (non-fatal): $e\n$st');
  }

  // Auto-backup (silent, checks premium + auto-backup enabled + 7-day interval)
  debugPrint('[Main] Step 8/9 — BackupService.autoBackupIfNeeded');
  try {
    await BackupService.instance.autoBackupIfNeeded();
    debugPrint('[Main] Step 8/9 — autoBackup OK');
  } catch (e, st) {
    debugPrint('[Main] Step 8/9 — autoBackup FAILED (non-fatal): $e\n$st');
  }

  // Home screen widget – initialise and push fresh data
  debugPrint('[Main] Step 9a/9 — WidgetService.init + updateWidget');
  try {
    await WidgetService.instance.init();
    await WidgetService.instance.updateWidget();
    debugPrint('[Main] Step 9a/9 — WidgetService OK');
  } catch (e, st) {
    debugPrint('[Main] Step 9a/9 — WidgetService FAILED (non-fatal): $e\n$st');
  }

  // Notifications are an optional feature – never crash the app if they fail
  // (e.g. exact-alarm permission not granted, or platform doesn't support them)
  debugPrint('[Main] Step 9b/9 — NotificationService.init + scheduleAll');
  try {
    await NotificationService.instance.init();
    debugPrint('[Main] Step 9b/9 — NotificationService.init OK');
    await NotificationService.instance.scheduleAll();
    debugPrint('[Main] Step 9b/9 — NotificationService.scheduleAll OK');
  } catch (e, st) {
    debugPrint('[Main] Step 9b/9 — NotificationService FAILED (non-fatal): $e\n$st');
  }

  debugPrint('[Main] ✓ All init steps complete — calling runApp()');
  runApp(const GearTrackerApp());
}

void main() {
  // ── Global Flutter error handler ──────────────────────────────────────────
  // Catches synchronous Flutter framework errors (widget build exceptions,
  // layout errors, etc.) that would otherwise silently produce a black screen.
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('[FlutterError] ${details.exception}\n${details.stack}');
    // Try to show the error on-screen if we can
    runApp(_ErrorApp(
      error: details.exception.toString(),
      stack: details.stack.toString(),
    ));
  };

  // ── Zone error boundary ───────────────────────────────────────────────────
  // Catches ALL unhandled async exceptions thrown anywhere in the app — including
  // those inside main() initialization steps and futures not wrapped in try-catch.
  runZonedGuarded(
    _mainBody,
    (Object error, StackTrace stack) {
      debugPrint('[ZoneError] $error\n$stack');
      runApp(_ErrorApp(error: error.toString(), stack: stack.toString()));
    },
  );
}

// ─── Router ───────────────────────────────────────────────────────────────────

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _Shell(child: child),
      routes: [
        GoRoute(path: '/',            builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/activities',  builder: (_, __) => const ActivitiesScreen()),
        GoRoute(path: '/maintenance', builder: (_, __) => const MaintenanceOverviewScreen()),
        GoRoute(path: '/trips',       builder: (_, __) => const TripListScreen()),
        GoRoute(path: '/settings',    builder: (_, __) => const SettingsScreen()),
      ],
    ),
    GoRoute(path: '/gear',     builder: (_, __) => const GearListScreen()),
    GoRoute(path: '/gear/add', builder: (_, __) => const AddGearScreen()),
    GoRoute(
      path: '/gear/:id',
      builder: (_, s) => GearDetailScreen(gearItemId: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/gear/:id/edit',
      builder: (_, s) => AddGearScreen(gearItemId: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/gear/:id/maintenance/add',
      builder: (_, s) => AddMaintenanceLogScreen(gearItemId: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/gear/:id/rules/add',
      builder: (_, s) => AddMaintenanceRuleScreen(gearItemId: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/gear/:id/usage/add',
      builder: (_, s) => AddUsageLogScreen(gearItemId: int.parse(s.pathParameters['id']!)),
    ),

    // ── Trips ─────────────────────────────────────────────────────────────────
    GoRoute(
      path: '/trips/add',
      builder: (_, __) => const AddEditTripScreen(),
    ),
    GoRoute(
      path: '/trips/:id',
      builder: (_, s) => TripDetailScreen(tripId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/trips/:id/edit',
      builder: (_, s) {
        final trip = s.extra as Trip?;
        return AddEditTripScreen(trip: trip);
      },
    ),

    // ── Portfolio ─────────────────────────────────────────────────────────────
    GoRoute(
      path: '/portfolio',
      builder: (_, __) => const PortfolioScreen(),
    ),

    // ── Annual Report ─────────────────────────────────────────────────────────
    GoRoute(
      path: '/annual-report',
      builder: (_, __) => const AnnualReportScreen(),
    ),

    // ── Insurance ─────────────────────────────────────────────────────────────
    GoRoute(
      path: '/insurance',
      builder: (_, __) => const InsuranceListScreen(),
    ),
    GoRoute(
      path: '/insurance/add',
      builder: (_, state) {
        final gearId = state.uri.queryParameters['gearId'];
        return AddEditInsuranceScreen(preselectedGearId: gearId);
      },
    ),
    GoRoute(
      path: '/insurance/:id',
      builder: (_, s) => InsuranceDetailScreen(
        insuranceId: s.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/insurance/:id/edit',
      redirect: (context, state) async {
        // We can't easily load the insurance here since redirect is sync
        // Returning null means no redirect; the builder handles loading
        return null;
      },
      builder: (_, s) => _InsuranceEditLoader(
        insuranceId: s.pathParameters['id']!,
      ),
    ),

    // ── Premium paywall ───────────────────────────────────────────────────────
    GoRoute(
      path: '/paywall',
      builder: (_, state) => PaywallScreen(
        contextMessage: state.uri.queryParameters['msg'],
      ),
    ),

    // ── Strava OAuth2 web callback ────────────────────────────────────────────
    // Strava redirects the browser here after authorisation:
    //   http://localhost:PORT/strava-callback?code=XXX
    // Only used on the web platform; Android uses the geartracker:// deep link.
    GoRoute(
      path: '/strava-callback',
      builder: (_, state) => StravaCallbackScreen(
        code:        state.uri.queryParameters['code'],
        oauthError:  state.uri.queryParameters['error'],
      ),
    ),
  ],
);

// ─── App ─────────────────────────────────────────────────────────────────────

class GearTrackerApp extends StatelessWidget {
  const GearTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) => ValueListenableBuilder<Locale>(
        valueListenable: localeNotifier,
        builder: (context, locale, _) => MaterialApp.router(
          title: 'OutdoorGearTracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          routerConfig: _router,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
  }
}

// ─── Shell with custom nav bar ────────────────────────────────────────────────

class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});

  int _selectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/activities'))  return 1;
    if (path.startsWith('/maintenance')) return 2;
    if (path.startsWith('/trips'))       return 3;
    if (path.startsWith('/settings'))    return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _AppNavBar(
        selectedIndex: _selectedIndex(context),
        onTap: (i) {
          switch (i) {
            case 0: context.go('/');
            case 1: context.go('/activities');
            case 2: context.go('/maintenance');
            case 3: context.go('/trips');
            case 4: context.go('/settings');
          }
        },
      ),
    );
  }
}

// ─── Custom bottom nav bar with dot indicator ─────────────────────────────────

class _AppNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _AppNavBar({required this.selectedIndex, required this.onTap});

  static const _icons = [
    (Icons.home_outlined,                Icons.home_rounded),
    (Icons.directions_run_outlined,      Icons.directions_run_rounded),
    (Icons.build_outlined,               Icons.build_rounded),
    (Icons.flight_takeoff_outlined,      Icons.flight_takeoff_rounded),
    (Icons.settings_outlined,            Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(_icons.length, (i) {
              final l10n = AppLocalizations.of(context);
              final labels = [
                l10n.navOverview,
                l10n.navActivities,
                l10n.navMaintenance,
                l10n.trips,
                l10n.navSettings,
              ];
              final (inactiveIcon, activeIcon) = _icons[i];
              final label = labels[i];
              final active = selectedIndex == i;
              final color = active
                  ? AppColors.primary
                  : const Color(0xFF9E9E9E);

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? activeIcon : inactiveIcon,
                        color: color,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // ── Dot indicator – vždy zabírá místo, animuje velikost ──
                      SizedBox(
                        height: 5,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            width:  active ? 4 : 0,
                            height: active ? 4 : 0,
                            decoration: BoxDecoration(
                              color: active ? AppColors.primary : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Startup error screen ─────────────────────────────────────────────────────
// Shown instead of a black screen when main() throws an unhandled exception.
// Displays the full error + stack trace so testers can copy it from a screenshot.

class _ErrorApp extends StatelessWidget {
  final String error;
  final String stack;
  const _ErrorApp({required this.error, required this.stack});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 48),
                const SizedBox(height: 12),
                const Text(
                  'GearTracker — Startup Error',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Screenshot this screen and send it to the developer.',
                  style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _section('ERROR', error, const Color(0xFFFF9F43)),
                        const SizedBox(height: 12),
                        _section('STACK TRACE', stack, const Color(0xFF9ECFFF)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D1A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: SelectableText(
            content,
            style: const TextStyle(
              color: Color(0xFFE0E0E0),
              fontSize: 10,
              fontFamily: 'monospace',
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Insurance edit loader ─────────────────────────────────────────────────────
// Loads the insurance asynchronously then shows the edit form.

class _InsuranceEditLoader extends StatefulWidget {
  final String insuranceId;
  const _InsuranceEditLoader({required this.insuranceId});

  @override
  State<_InsuranceEditLoader> createState() => _InsuranceEditLoaderState();
}

class _InsuranceEditLoaderState extends State<_InsuranceEditLoader> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await InsuranceService.instance.getAllInsurances();
    final ins = all.where((i) => i.id == widget.insuranceId).firstOrNull;
    if (!mounted) return;
    if (ins == null) {
      context.pop();
      return;
    }
    // Replace current route with the edit screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AddEditInsuranceScreen(insurance: ins),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/db_factory.dart';
import 'l10n/app_localizations.dart';
import 'mock_data.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/gear_list_screen.dart';
import 'screens/gear_detail_screen.dart';
import 'screens/add_gear_screen.dart';
import 'screens/maintenance_screen.dart';
import 'screens/activities_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/strava_callback_screen.dart';

/// Global locale notifier – updated by SettingsScreen when the user picks a language.
final localeNotifier = ValueNotifier<Locale>(const Locale('cs'));

Future<void> _loadLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('app_locale') ?? 'cs';
  localeNotifier.value = Locale(code);
}

void main() async {
  usePathUrlStrategy(); // path-based URLs on web (no #); must be first
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabaseFactory();
  await MockDataSeeder.seedIfEmpty();
  await _loadLocale();

  // Notifications are an optional feature – never crash the app if they fail
  // (e.g. exact-alarm permission not granted, or platform doesn't support them)
  try {
    await NotificationService.instance.init();
    await NotificationService.instance.scheduleAll();
  } catch (e) {
    // Silently ignore – the rest of the app works without notifications
    debugPrint('NotificationService init/scheduleAll failed: $e');
  }

  runApp(const GearTrackerApp());
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
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) => MaterialApp.router(
        title: 'GearTracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: _router,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
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
    if (path.startsWith('/settings'))    return 3;
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
            case 3: context.go('/settings');
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
    (Icons.home_outlined,           Icons.home_rounded),
    (Icons.directions_run_outlined, Icons.directions_run_rounded),
    (Icons.build_outlined,          Icons.build_rounded),
    (Icons.settings_outlined,       Icons.settings_rounded),
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

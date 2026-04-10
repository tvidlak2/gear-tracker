import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'database/db_factory.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabaseFactory();
  await MockDataSeeder.seedIfEmpty();
  await NotificationService.instance.init();
  await NotificationService.instance.scheduleAll();
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
  ],
);

// ─── App ─────────────────────────────────────────────────────────────────────

class GearTrackerApp extends StatelessWidget {
  const GearTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GearTracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
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

  static const _items = [
    (Icons.home_outlined,         Icons.home_rounded,           'Přehled'),
    (Icons.directions_run_outlined, Icons.directions_run_rounded, 'Aktivity'),
    (Icons.build_outlined,        Icons.build_rounded,           'Servis'),
    (Icons.settings_outlined,     Icons.settings_rounded,        'Nastavení'),
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
            children: List.generate(_items.length, (i) {
              final (inactiveIcon, activeIcon, label) = _items[i];
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

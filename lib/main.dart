import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'database/db_factory.dart';
import 'mock_data.dart';
import 'screens/home_screen.dart';
import 'screens/gear_list_screen.dart';
import 'screens/gear_detail_screen.dart';
import 'screens/add_gear_screen.dart';
import 'screens/maintenance_screen.dart';
import 'screens/activities_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializuj správnou SQLite factory pro aktuální platformu.
  // Web → sqflite_common_ffi_web (WASM), Android/iOS → standardní sqflite.
  await initDatabaseFactory();
  await MockDataSeeder.seedIfEmpty();
  runApp(const GearTrackerApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _Shell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/activities', builder: (_, __) => const ActivitiesScreen()),
        GoRoute(path: '/maintenance', builder: (_, __) => const MaintenanceOverviewScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
    GoRoute(path: '/gear', builder: (_, __) => const GearListScreen()),
    GoRoute(path: '/gear/add', builder: (_, __) => const AddGearScreen()),
    GoRoute(
      path: '/gear/:id',
      builder: (_, state) => GearDetailScreen(
        gearItemId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/gear/:id/edit',
      builder: (_, state) => AddGearScreen(
        gearItemId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/gear/:id/maintenance/add',
      builder: (_, state) => AddMaintenanceLogScreen(
        gearItemId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/gear/:id/rules/add',
      builder: (_, state) => AddMaintenanceRuleScreen(
        gearItemId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/gear/:id/usage/add',
      builder: (_, state) => AddUsageLogScreen(
        gearItemId: int.parse(state.pathParameters['id']!),
      ),
    ),
  ],
);

class GearTrackerApp extends StatelessWidget {
  const GearTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GearTracker',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      routerConfig: _router,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1D9E75),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        scrolledUnderElevation: 1,
      ),
    );
  }
}

class _Shell extends StatelessWidget {
  final Widget child;

  const _Shell({required this.child});

  int _selectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/activities')) return 1;
    if (path.startsWith('/maintenance')) return 2;
    if (path.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(context),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/');
            case 1: context.go('/activities');
            case 2: context.go('/maintenance');
            case 3: context.go('/settings');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Přehled',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_run_outlined),
            selectedIcon: Icon(Icons.directions_run),
            label: 'Aktivity',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build_rounded),
            label: 'Servis',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Nastavení',
          ),
        ],
      ),
    );
  }
}

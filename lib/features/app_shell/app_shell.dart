import 'package:flutter/material.dart';
import 'package:calorie_calculator/features/home/screens/home_page.dart';
import 'package:calorie_calculator/features/food/screens/food_database_page.dart';
import 'package:calorie_calculator/features/reports/screens/reports_page.dart';
import 'package:calorie_calculator/features/settings/screens/settings_page.dart';
import 'package:calorie_calculator/l10n/app_localizations.dart';
import 'package:calorie_calculator/core/navigation/tab_refresh.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _homeKey = GlobalKey();
  final _foodKey = GlobalKey();
  final _reportsKey = GlobalKey();
  final _settingsKey = GlobalKey();

  late final List<Widget> _pages = [
    HomePage(key: _homeKey),
    FoodDatabasePage(key: _foodKey),
    ReportsPage(key: _reportsKey),
    SettingsPage(key: _settingsKey),
  ];

  void _refreshSelected() {
    final keys = [_homeKey, _foodKey, _reportsKey, _settingsKey];
    final state = keys[_index].currentState;
    if (state is TabRefresh) {
      (state as TabRefresh).onTabSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: t.bottom_navigation_home,
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: t.bottom_navigation_food,
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: t.bottom_navigation_records,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: t.bottom_navigation_settings,
          ),
        ],
        onDestinationSelected: (i) {
          setState(() => _index = i);
          // Execute after the stack rebuild so currentState is available
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _refreshSelected(),
          );
        },
      ),
    );
  }
}

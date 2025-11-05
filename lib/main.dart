import 'package:flutter/material.dart';
import './l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:calorie_calculator/core/utils/locale_service.dart';
import 'package:calorie_calculator/core/utils/theme_service.dart';

import './features/auth/screens/login_page.dart';
import './features/auth/screens/signup_page.dart';
import './features/app_shell/app_shell.dart';
import './features/profile/screens/user_profile_page.dart';
import './features/profile/screens/goal_setup_page.dart';
import './features/profile/screens/daily_target_page.dart';
import './features/food/screens/add_meal_page.dart';
import './features/food/screens/add_custom_food_page.dart';
import './features/food/screens/record_page.dart';
import 'core/db/seed_service.dart';
import 'core/navigation/route_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Defer SharedPreferences-backed init until after engine & plugins are ready.
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize persisted services after the app is bootstrapped
    // to avoid early MethodChannel calls before plugin registration.
    LocaleService.instance.init();
    ThemeService.instance.init();
    // Seed local database if needed (foods)
    SeedService.instance.seedIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleService.instance.locale,
      builder: (context, currentLocale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.instance.mode,
          builder: (context, themeMode, __) {
            return MaterialApp(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)!.appTitle,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('ar')],
              locale: currentLocale, // null => system default
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
                brightness: Brightness.dark,
              ),
              themeMode: themeMode,
              navigatorObservers: [routeObserver],
              home: const LoginPage(),
              routes: {
                '/login': (context) => const LoginPage(),
                '/signup': (context) => const SignupPage(),
                '/app': (context) => const AppShell(),
                '/profile': (context) => const UserProfilePage(),
                '/goal-setup': (context) => const GoalSetupPage(),
                '/daily-target': (context) => const DailyTargetPage(),
                '/food/add-meal': (context) => const AddMealPage(),
                '/food/custom': (context) => const AddCustomFoodPage(),
                '/food/records': (context) => const RecordPage(),
              },
            );
          },
        );
      },
    );
  }
}

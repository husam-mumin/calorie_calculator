import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  static const _keyThemeMode = 'app_theme_mode';

  final ValueNotifier<ThemeMode> mode = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyThemeMode);
    switch (saved) {
      case 'light':
        mode.value = ThemeMode.light;
        break;
      case 'dark':
        mode.value = ThemeMode.dark;
        break;
      default:
        mode.value = ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode newMode) async {
    final prefs = await SharedPreferences.getInstance();
    mode.value = newMode;
    String val;
    switch (newMode) {
      case ThemeMode.light:
        val = 'light';
        break;
      case ThemeMode.dark:
        val = 'dark';
        break;
      case ThemeMode.system:
        val = 'system';
        break;
    }
    await prefs.setString(_keyThemeMode, val);
  }

  Future<void> toggleDark(bool isDark) =>
      setMode(isDark ? ThemeMode.dark : ThemeMode.light);
}

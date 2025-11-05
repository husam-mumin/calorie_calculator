import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

class SettingsDao {
  SettingsDao._();
  static final SettingsDao instance = SettingsDao._();

  Future<void> setValue(String key, Object? value) async {
    final db = await AppDatabase.instance.database;
    final val = value?.toString();
    await db.insert('settings', {
      'key': key,
      'value': val,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getValue(String key) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  // Typed helpers
  Future<void> setJson(String key, Map<String, Object?> map) =>
      setValue(key, jsonEncode(map));
  Future<Map<String, Object?>?> getJson(String key) async {
    final s = await getValue(key);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, Object?>;
  }

  // Known keys
  static const keyLanguage = 'language'; // en/ar/system
  static const keyTheme = 'theme_mode'; // system/light/dark
  static const keyUnits = 'units'; // metric/imperial
  static const keyDefaultMeal = 'default_meal'; // breakfast/lunch/dinner/snacks
  static const keyDefaultPortion = 'default_portion'; // number
  static const keyGoal = 'goal'; // lose/maintain/gain

  Future<void> setLanguage(String? code) =>
      setValue(keyLanguage, code ?? 'system');
  Future<String> getLanguage() async =>
      (await getValue(keyLanguage)) ?? 'system';

  Future<void> setTheme(String mode) => setValue(keyTheme, mode);
  Future<String> getTheme() async => (await getValue(keyTheme)) ?? 'system';

  Future<void> setUnits(String units) => setValue(keyUnits, units);
  Future<String> getUnits() async => (await getValue(keyUnits)) ?? 'metric';

  Future<void> setDefaultMeal(String meal) => setValue(keyDefaultMeal, meal);
  Future<String> getDefaultMeal() async =>
      (await getValue(keyDefaultMeal)) ?? 'breakfast';

  Future<void> setDefaultPortion(String qty) =>
      setValue(keyDefaultPortion, qty);
  Future<String> getDefaultPortion() async =>
      (await getValue(keyDefaultPortion)) ?? '1';

  Future<void> setGoal(String goal) => setValue(keyGoal, goal);
  Future<String> getGoal() async => (await getValue(keyGoal)) ?? 'maintain';
}

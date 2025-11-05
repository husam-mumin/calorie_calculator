import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  static const _keyLocaleCode = 'app_locale_code';

  // null means: use system default
  final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyLocaleCode);
    if (code != null && code.isNotEmpty) {
      locale.value = Locale(code);
    } else {
      locale.value = null; // use device default
    }
  }

  Future<void> setLocale(Locale? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_keyLocaleCode);
    } else {
      await prefs.setString(_keyLocaleCode, value.languageCode);
    }
    locale.value = value;
  }
}

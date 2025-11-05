import 'package:flutter/material.dart';
import 'package:calorie_calculator/core/db/app_database.dart';
import 'package:calorie_calculator/core/db/dao/settings_dao.dart';
import 'package:calorie_calculator/core/utils/locale_service.dart';
import 'package:calorie_calculator/core/utils/theme_service.dart';
import 'package:calorie_calculator/l10n/app_localizations.dart';
import 'package:calorie_calculator/core/navigation/tab_refresh.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> implements TabRefresh {
  bool _notifications = true;
  String _units = 'metric';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _units = await SettingsDao.instance.getUnits();
    setState(() {});
  }

  void _go(String route) => Navigator.pushNamed(context, route);

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  void onTabSelected() {
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.settings_title)),
      body: ListView(
        children: [
          SwitchListTile(
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
            title: Text(t.settings_notifications),
          ),
          // Theme mode selector (System/Light/Dark)
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.instance.mode,
            builder: (context, mode, _) {
              return ListTile(
                title: Text(t.settings_theme),
                subtitle: Text(
                  mode == ThemeMode.system
                      ? t.settings_theme_system
                      : mode == ThemeMode.light
                      ? t.settings_theme_light
                      : t.settings_theme_dark,
                ),
                trailing: DropdownButton<ThemeMode>(
                  value: mode,
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(t.settings_theme_system),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(t.settings_theme_light),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(t.settings_theme_dark),
                    ),
                  ],
                  onChanged: (m) async {
                    if (m != null) {
                      await ThemeService.instance.setMode(m);
                      final str = m == ThemeMode.system
                          ? 'system'
                          : m == ThemeMode.light
                          ? 'light'
                          : 'dark';
                      await SettingsDao.instance.setTheme(str);
                    }
                  },
                ),
              );
            },
          ),
          // Language selector (System/English/Arabic)
          ValueListenableBuilder<Locale?>(
            valueListenable: LocaleService.instance.locale,
            builder: (context, loc, _) {
              final current = loc?.languageCode ?? 'system';
              return ListTile(
                title: Text(t.settings_language),
                subtitle: Text(
                  current == 'system'
                      ? t.settings_language_system_default
                      : current == 'en'
                      ? t.language_english
                      : t.language_arabic,
                ),
                trailing: DropdownButton<String>(
                  value: current,
                  items: [
                    DropdownMenuItem(
                      value: 'system',
                      child: Text(t.language_system),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(t.language_english),
                    ),
                    DropdownMenuItem(
                      value: 'ar',
                      child: Text(t.language_arabic),
                    ),
                  ],
                  onChanged: (code) async {
                    if (code == null) return;
                    if (code == 'system') {
                      await LocaleService.instance.setLocale(null);
                      await SettingsDao.instance.setLanguage('system');
                    } else {
                      await LocaleService.instance.setLocale(Locale(code));
                      await SettingsDao.instance.setLanguage(code);
                    }
                  },
                ),
              );
            },
          ),
          ListTile(
            title: Text(t.settings_units),
            subtitle: Text(
              _units == 'metric'
                  ? t.settings_units_metric_label
                  : t.settings_units_imperial_label,
            ),
            trailing: DropdownButton<String>(
              value: _units,
              items: [
                DropdownMenuItem(
                  value: 'metric',
                  child: Text(t.settings_units_metric),
                ),
                DropdownMenuItem(
                  value: 'imperial',
                  child: Text(t.settings_units_imperial),
                ),
              ],
              onChanged: (v) async {
                final val = v ?? 'metric';
                await SettingsDao.instance.setUnits(val);
                setState(() => _units = val);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: Text(t.settings_clear_all_data),
            onTap: () async {
              final ctx = context;
              final ok = await showDialog<bool>(
                context: ctx,
                builder: (dialogContext) => AlertDialog(
                  title: Text(t.settings_clear_title),
                  content: Text(t.settings_clear_confirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(t.common_cancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: Text(t.common_clear),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                final db = await AppDatabase.instance.database;
                await db.delete('meal_records');
                await db.delete('meals');
                await db.delete('foods');
                await db.delete('settings');
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(t.settings_data_cleared)),
                );
                _load();
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(t.settings_profile),
            onTap: () => _go('/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: Text(t.settings_goal_setup),
            onTap: () => _go('/goal-setup'),
          ),
          ListTile(
            leading: const Icon(Icons.local_fire_department_outlined),
            title: Text(t.settings_daily_targets),
            onTap: () => _go('/daily-target'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(t.settings_logout),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:calorie_calculator/l10n/app_localizations.dart';
import '../../../core/db/dao/users_dao.dart';
import '../../../core/db/dao/settings_dao.dart';
import '../../../core/utils/target_calculator.dart';

class DailyTargetPage extends StatefulWidget {
  const DailyTargetPage({super.key});

  @override
  State<DailyTargetPage> createState() => _DailyTargetPageState();
}

class _DailyTargetPageState extends State<DailyTargetPage> {
  TargetResult? _res;
  String _goal = 'maintain';
  double _rate = 0.5;

  @override
  void initState() {
    super.initState();
    _calc();
  }

  Future<void> _calc() async {
    final u = await UsersDao.instance.getFirstUser();
    if (u == null || u.age == null || u.height == null || u.weight == null) {
      if (!mounted) return;
      setState(() => _res = null);
      return;
    }
    _goal = await SettingsDao.instance.getGoal();
    final rateStr = await SettingsDao.instance.getValue('goal_rate');
    _rate = double.tryParse(rateStr ?? '') ?? 0.5;
    final res = TargetCalculator.calculate(
      gender: u.gender ?? 'male',
      age: u.age!,
      heightCm: u.height!,
      weightKg: u.weight!,
      activityLevel: u.activityLevel ?? 'sedentary',
      goal: _goal,
      targetRateKgPerWeek: _rate,
    );
    if (!mounted) return;
    setState(() => _res = res);
  }

  @override
  Widget build(BuildContext context) {
    final res = _res;
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.settings_daily_targets)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (res == null)
              Text(t.settings_daily_setup_your_profile)
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${t.result_target_calories}: ${res.targetCalories.round()} ${t.unit_kcal_per_day}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${t.result_bmr} (${res.formula}): ${res.bmr.round()} ${t.unit_kcal}',
                      ),
                      Text(
                        '${t.form_activity_level} x${res.activityMultiplier.toStringAsFixed(2)} → ${t.result_tdee}: ${res.tdee.round()} ${t.unit_kcal}',
                      ),
                      Text(
                        '${t.form_goal}: $_goal @ ${_rate.toStringAsFixed(2)} kg/week',
                      ),
                      const SizedBox(height: 12),
                      Text(t.daily_target_macros_title),
                      const SizedBox(height: 8),
                      _MacroRow(
                        label: t.label_carbs,
                        grams: res.macros['carbs']!.round(),
                      ),
                      _MacroRow(
                        label: t.label_protein,
                        grams: res.macros['protein']!.round(),
                      ),
                      _MacroRow(
                        label: t.label_fat,
                        grams: res.macros['fat']!.round(),
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calc,
                icon: const Icon(Icons.refresh),
                label: Text(t.settings_daily_button_recalculate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final int grams;
  const _MacroRow({required this.label, required this.grams});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: (grams / 500).clamp(0, 1).toDouble(),
            ),
          ),
          const SizedBox(width: 12),
          Text('$grams ${t.unit_g}'),
        ],
      ),
    );
  }
}

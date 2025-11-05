import 'package:flutter/material.dart';
import 'package:calorie_calculator/l10n/app_localizations.dart';
import '../../../core/db/dao/settings_dao.dart';

class GoalSetupPage extends StatefulWidget {
  const GoalSetupPage({super.key});

  @override
  State<GoalSetupPage> createState() => _GoalSetupPageState();
}

class _GoalSetupPageState extends State<GoalSetupPage> {
  String _goal = 'maintain';
  double _rate = 0.5; // kg per week

  Future<void> _save() async {
    await SettingsDao.instance.setGoal(_goal);
    await SettingsDao.instance.setValue('goal_rate', _rate.toString());
    if (!mounted) return;
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.goal_saved_snackbar)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.goal_setup_title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.goal_choose_title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            RadioGroup<String>(
              groupValue: _goal,
              onChanged: (v) => setState(() => _goal = v ?? 'lose'),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'lose',
                    title: Text(t.goal_option_lose),
                  ),
                  RadioListTile<String>(
                    value: 'maintain',
                    title: Text(t.goal_option_maintain),
                  ),
                  RadioListTile<String>(
                    value: 'gain',
                    title: Text(t.goal_option_gain),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(t.goal_target_rate),
            const SizedBox(height: 8),
            DropdownButton<double>(
              value: _rate,
              items: [
                DropdownMenuItem(
                  value: 0.25,
                  child: Text(t.goal_rate_option('0.25')),
                ),
                DropdownMenuItem(
                  value: 0.5,
                  child: Text(t.goal_rate_option('0.5')),
                ),
                DropdownMenuItem(
                  value: 1.0,
                  child: Text(t.goal_rate_option('1.0')),
                ),
              ],
              onChanged: (v) => setState(() => _rate = v ?? 0.5),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: Text(t.common_save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

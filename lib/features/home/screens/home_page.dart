import 'package:flutter/material.dart';
import 'package:calorie_calculator/core/navigation/tab_refresh.dart';
import 'package:intl/intl.dart';
import '../../food/data/meal_dao.dart';
import 'package:calorie_calculator/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements TabRefresh {
  final _ageCtrl = TextEditingController(text: '25');
  final _heightCtrl = TextEditingController(text: '175'); // cm
  final _weightCtrl = TextEditingController(text: '70'); // kg

  String _sex = 'male';
  String _activity = 'sedentary';
  String _goal = 'maintain';

  double? _bmr;
  double? _tdee;
  double? _target;
  int _consumed = 0;
  int _breakfastCal = 0;
  int _lunchCal = 0;
  int _dinnerCal = 0;
  int _snacksCal = 0;

  @override
  void dispose() {
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  static const _activityMultipliers = <String, double>{
    'sedentary': 1.2, // Little or no exercise
    'light': 1.375, // 1-3 days/week
    'moderate': 1.55, // 3-5 days/week
    'very': 1.725, // 6-7 days/week
    'extra': 1.9, // Physical job/athlete
  };

  void _calculate() {
    final age = int.tryParse(_ageCtrl.text.trim());
    final height = double.tryParse(_heightCtrl.text.trim()); // cm
    final weight = double.tryParse(_weightCtrl.text.trim()); // kg

    if (age == null ||
        age <= 0 ||
        height == null ||
        height <= 0 ||
        weight == null ||
        weight <= 0) {
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.home_enter_valid_anthro)));
      return;
    }

    // Mifflin-St Jeor BMR (metric)
    double bmr;
    if (_sex == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    final tdee = bmr * _activityMultipliers[_activity]!;
    double target = tdee;
    if (_goal == 'lose') target = tdee - 500;
    if (_goal == 'gain') target = tdee + 300;

    setState(() {
      _bmr = bmr;
      _tdee = tdee;
      _target = target.clamp(1000, 5000); // simple bounds
    });
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  void initState() {
    super.initState();
    _loadConsumed();
  }

  Future<void> _loadConsumed() async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final total = await MealDao.instance.sumCaloriesByDate(date);
    // Compute per-meal breakdown from today's records
    final items = await MealDao.instance.listByDate(date);
    int b = 0, l = 0, d = 0, s = 0;
    for (final r in items) {
      switch (r.mealType) {
        case 'breakfast':
          b += r.calories;
          break;
        case 'lunch':
          l += r.calories;
          break;
        case 'dinner':
          d += r.calories;
          break;
        default:
          s += r.calories;
      }
    }
    if (mounted) {
      setState(() {
        _consumed = total;
        _breakfastCal = b;
        _lunchCal = l;
        _dinnerCal = d;
        _snacksCal = s;
      });
    }
  }

  @override
  void onTabSelected() {
    _loadConsumed();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.home_title),
        actions: [
          IconButton(
            tooltip: t.settings_logout,
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Dashboard summary
              _DashboardSummary(
                target: _target?.round(),
                consumed: _consumed, // from DB
                breakfast: _breakfastCal,
                lunch: _lunchCal,
                dinner: _dinnerCal,
                snacks: _snacksCal,
                onAddMeal: () => Navigator.pushNamed(
                  context,
                  '/food/add-meal',
                ).then((_) => _loadConsumed()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _sex,
                      decoration: InputDecoration(
                        labelText: t.form_sex,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'male',
                          child: Text(t.sex_male),
                        ),
                        DropdownMenuItem(
                          value: 'female',
                          child: Text(t.sex_female),
                        ),
                      ],
                      onChanged: (v) => setState(() => _sex = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _ageCtrl,
                      decoration: InputDecoration(
                        labelText: t.form_age_years,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightCtrl,
                      decoration: InputDecoration(
                        labelText: t.form_height_cm,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightCtrl,
                      decoration: InputDecoration(
                        labelText: t.form_weight_kg,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _activity,
                decoration: InputDecoration(
                  labelText: t.form_activity_level,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'sedentary',
                    child: Text(t.home_activity_sedentary_desc),
                  ),
                  DropdownMenuItem(
                    value: 'light',
                    child: Text(t.home_activity_light_desc),
                  ),
                  DropdownMenuItem(
                    value: 'moderate',
                    child: Text(t.home_activity_moderate_desc),
                  ),
                  DropdownMenuItem(
                    value: 'very',
                    child: Text(t.home_activity_very_desc),
                  ),
                  DropdownMenuItem(
                    value: 'extra',
                    child: Text(t.home_activity_extra_desc),
                  ),
                ],
                onChanged: (v) => setState(() => _activity = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _goal,
                decoration: InputDecoration(
                  labelText: t.form_goal,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'lose',
                    child: Text(t.home_goal_lose_desc),
                  ),
                  DropdownMenuItem(
                    value: 'maintain',
                    child: Text(t.home_goal_maintain),
                  ),
                  DropdownMenuItem(
                    value: 'gain',
                    child: Text(t.home_goal_gain_desc),
                  ),
                ],
                onChanged: (v) => setState(() => _goal = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: Text(t.common_calculate),
                ),
              ),
              const SizedBox(height: 16),
              if (_bmr != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _ResultRow(label: t.result_bmr, value: _bmr!.round()),
                        _ResultRow(label: t.result_tdee, value: _tdee!.round()),
                        _ResultRow(
                          label: t.result_target_calories,
                          value: _target!.round(),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final int value;
  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          Text(
            '$value ${t.unit_kcal_per_day}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _DashboardSummary extends StatelessWidget {
  final int? target;
  final int consumed;
  final VoidCallback onAddMeal;
  final int breakfast;
  final int lunch;
  final int dinner;
  final int snacks;
  const _DashboardSummary({
    required this.target,
    required this.consumed,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
    required this.onAddMeal,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = target ?? 2000;
    final c = consumed;
    final remaining = (total - c).clamp(0, total);
    final pct = (c / total).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.home_today,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('$c / $total ${l10n.unit_kcal}'),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onAddMeal,
                  icon: const Icon(Icons.restaurant),
                  label: Text(l10n.home_add_meal),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: pct),
            const SizedBox(height: 8),
            Text('${l10n.home_remaining}: $remaining ${l10n.unit_kcal}'),
            const Divider(height: 24),
            _MealRow(label: l10n.meal_breakfast, cal: breakfast),
            _MealRow(label: l10n.meal_lunch, cal: lunch),
            _MealRow(label: l10n.meal_dinner, cal: dinner),
            _MealRow(label: l10n.meal_snacks, cal: snacks),
          ],
        ),
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final String label;
  final int cal;
  const _MealRow({required this.label, required this.cal});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('$cal ${t.unit_kcal}'),
        ],
      ),
    );
  }
}

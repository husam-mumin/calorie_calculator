import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calorie_calculator/l10n/app_localizations.dart';
import 'package:calorie_calculator/core/db/dao/settings_dao.dart';
import 'package:calorie_calculator/features/food/data/meal_dao.dart';
import 'package:calorie_calculator/features/food/models/meal_record.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  final _mealTypes = const ['breakfast', 'lunch', 'dinner', 'snacks'];
  String _selectedMeal = 'breakfast';
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _argsApplied = false;

  void _addCustomFood() async {
    await Navigator.pushNamed(context, '/food/custom');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsApplied) return;
    final route = ModalRoute.of(context);
    final args = route?.settings.arguments;
    if (args is Map) {
      final name = args['name']?.toString();
      final calories = args['calories'];
      if (name != null && name.isNotEmpty) {
        _nameCtrl.text = name;
      }
      if (calories is num) {
        _calCtrl.text = calories.round().toString();
      } else if (calories is String) {
        final n = num.tryParse(calories);
        if (n != null) _calCtrl.text = n.round().toString();
      }
      _argsApplied = true;
    }
  }

  Future<void> _loadDefaults() async {
    final def = await SettingsDao.instance.getDefaultMeal();
    setState(() => _selectedMeal = def);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final cal = int.tryParse(_calCtrl.text.trim()) ?? 0;
    final rec = MealRecord(
      date: date,
      mealType: _selectedMeal,
      name: _nameCtrl.text.trim(),
      calories: cal,
    );
    await MealDao.instance.add(rec);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.food_saved)),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    String mealLabel(String key) {
      switch (key) {
        case 'breakfast':
          return t.meal_breakfast;
        case 'lunch':
          return t.meal_lunch;
        case 'dinner':
          return t.meal_dinner;
        default:
          return t.meal_snacks;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.add_meal_title),
        actions: [
          IconButton(onPressed: _addCustomFood, icon: const Icon(Icons.add)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedMeal,
                items: _mealTypes
                    .map(
                      (m) =>
                          DropdownMenuItem(value: m, child: Text(mealLabel(m))),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedMeal = v!),
                decoration: InputDecoration(
                  labelText: t.field_meal,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: t.field_food_name,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? t.form_required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _calCtrl,
                decoration: InputDecoration(
                  labelText: t.field_calories,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.isEmpty) ? t.form_required : null,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_alt),
                  label: Text(t.common_save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:calorie_calculator/core/db/dao/foods_dao.dart';
import 'package:calorie_calculator/l10n/app_localizations.dart';

class AddCustomFoodPage extends StatefulWidget {
  const AddCustomFoodPage({super.key});

  @override
  State<AddCustomFoodPage> createState() => _AddCustomFoodPageState();
}

class _AddCustomFoodPageState extends State<AddCustomFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _carbCtrl.dispose();
    _proteinCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final food = Food(
      name: _nameCtrl.text.trim(),
      caloriesPer100g: double.tryParse(_calCtrl.text.trim()) ?? 0,
      carbsPer100g: double.tryParse(_carbCtrl.text.trim()),
      proteinPer100g: double.tryParse(_proteinCtrl.text.trim()),
      fatPer100g: double.tryParse(_fatCtrl.text.trim()),
      userCreated: true,
    );
    await FoodsDao.instance.insert(food);
    if (!mounted) return;
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.food_saved)));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.food_add_custom)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: t.field_food_name,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? t.form_required : null,
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
                    v == null || v.isEmpty ? t.form_required : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _carbCtrl,
                      decoration: InputDecoration(
                        labelText: t.field_carbs_g,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _proteinCtrl,
                      decoration: InputDecoration(
                        labelText: t.field_protein_g,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _fatCtrl,
                      decoration: InputDecoration(
                        labelText: t.field_fat_g,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calorie_calculator/features/food/data/meal_dao.dart';
import 'package:calorie_calculator/features/food/models/meal_record.dart';
import 'package:calorie_calculator/l10n/app_localizations.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  DateTime _selected = DateTime.now();
  List<MealRecord> _items = [];
  int _total = 0;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selected = picked);
      await _load();
    }
  }

  Future<void> _load() async {
    final d = DateFormat('yyyy-MM-dd').format(_selected);
    final items = await MealDao.instance.listByDate(d);
    final total = await MealDao.instance.sumCaloriesByDate(d);
    setState(() {
      _items = items;
      _total = total;
    });
  }

  Future<void> _delete(MealRecord rec) async {
    await MealDao.instance.deleteById(rec.id!);
    await _load();
  }

  Future<void> _edit(MealRecord rec) async {
    final t = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: rec.name);
    final calCtrl = TextEditingController(text: rec.calories.toString());
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.records_edit_title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: t.field_food_name),
              ),
              TextField(
                controller: calCtrl,
                decoration: InputDecoration(labelText: t.field_calories),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.common_cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.common_save),
            ),
          ],
        );
      },
    );
    if (ok == true) {
      final updated = MealRecord(
        id: rec.id,
        date: rec.date,
        mealType: rec.mealType,
        name: nameCtrl.text.trim(),
        calories: int.tryParse(calCtrl.text.trim()) ?? rec.calories,
        carbs: rec.carbs,
        protein: rec.protein,
        fat: rec.fat,
      );
      await MealDao.instance.update(updated);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final dateLabel = DateFormat.yMMMd().format(_selected);
    final visible = _query.isEmpty
        ? _items
        : _items
              .where(
                (e) => (e.name).toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(t.records_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDate,
            tooltip: t.records_select_date,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: t.food_search,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: Center(child: Text(t.records_empty)),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (context, index) {
                        final it = visible[index];
                        return Dismissible(
                          key: ValueKey(it.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) async =>
                              await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(t.common_delete),
                                  content: Text(t.records_confirm_delete),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(t.common_cancel),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(t.common_delete),
                                    ),
                                  ],
                                ),
                              ) ??
                              false,
                          onDismissed: (_) => _delete(it),
                          child: ListTile(
                            leading: Icon(_iconFor(it.mealType)),
                            title: Text(it.name),
                            subtitle: Text('${it.mealType} • ${it.date}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${it.calories} ${t.unit_kcal}'),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _edit(it),
                                  tooltip: t.common_edit,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: visible.length,
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/food/add-meal');
          await _load();
        },
        icon: const Icon(Icons.add),
        label: Text(t.home_add_meal),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(child: Text('${t.records_date}: $dateLabel')),
              Text('${t.records_total}: $_total ${t.unit_kcal}'),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.free_breakfast_outlined;
      case 'lunch':
        return Icons.lunch_dining_outlined;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.emoji_food_beverage_outlined;
    }
  }
}

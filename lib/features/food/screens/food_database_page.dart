import 'package:flutter/material.dart';
import 'package:calorie_calculator/l10n/app_localizations.dart';
import 'package:calorie_calculator/core/db/dao/foods_dao.dart';
import 'package:calorie_calculator/core/navigation/tab_refresh.dart';

class FoodDatabasePage extends StatefulWidget {
  const FoodDatabasePage({super.key});

  @override
  State<FoodDatabasePage> createState() => _FoodDatabasePageState();
}

class _FoodDatabasePageState extends State<FoodDatabasePage>
    implements TabRefresh {
  final _searchCtrl = TextEditingController();
  List<Food> _items = const [];
  bool _loading = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAddCustom() {
    Navigator.pushNamed(
      context,
      '/food/custom',
    ).then((_) => _load(q: _searchCtrl.text.trim()));
  }

  void _openAddMeal([Food? food]) {
    if (food != null) {
      Navigator.pushNamed(
        context,
        '/food/add-meal',
        arguments: {
          'name': food.name,
          // Default to per-100g calories as a starting point
          'calories': food.caloriesPer100g,
        },
      );
    } else {
      Navigator.pushNamed(context, '/food/add-meal');
    }
  }

  Future<void> _load({String q = ''}) async {
    setState(() => _loading = true);
    final items = q.isEmpty
        ? await FoodsDao.instance.all(limit: 200)
        : await FoodsDao.instance.search(q, limit: 200);
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  void onTabSelected() {
    _load(q: _searchCtrl.text.trim());
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.food_database_title),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/food/records'),
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: t.records_title,
          ),
          IconButton(
            onPressed: _openAddCustom,
            icon: const Icon(Icons.add_box_outlined),
            tooltip: t.food_add_custom,
          ),
        ],
      ),
      body: Column(
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
              onChanged: (v) => _load(q: v.trim()),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                ? Center(child: Text(t.food_empty_list))
                : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final it = _items[index];
                      return ListTile(
                        leading: Icon(
                          it.userCreated
                              ? Icons.star_outline
                              : Icons.rice_bowl_outlined,
                          color: it.userCreated
                              ? Theme.of(context).colorScheme.tertiary
                              : null,
                        ),
                        title: Text(it.name),
                        subtitle: Text(
                          t.food_macro_line(
                            it.caloriesPer100g,
                            it.carbsPer100g ?? 0,
                            it.proteinPer100g ?? 0,
                            it.fatPer100g ?? 0,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _openAddMeal(it),
                          tooltip: t.food_add_to_meal,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddMeal(),
        icon: const Icon(Icons.restaurant),
        label: Text(t.home_add_meal),
      ),
    );
  }
}

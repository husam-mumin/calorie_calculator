import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

class Food {
  final int? id;
  final String name;
  final double caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
  final bool userCreated;

  Food({
    this.id,
    required this.name,
    required this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.userCreated = false,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'calories_per_100g': caloriesPer100g,
    'protein_per_100g': proteinPer100g,
    'carbs_per_100g': carbsPer100g,
    'fat_per_100g': fatPer100g,
    'user_created': userCreated ? 1 : 0,
  };

  static Food fromMap(Map<String, Object?> m) => Food(
    id: m['id'] as int?,
    name: m['name'] as String,
    caloriesPer100g: (m['calories_per_100g'] as num).toDouble(),
    proteinPer100g: (m['protein_per_100g'] as num?)?.toDouble(),
    carbsPer100g: (m['carbs_per_100g'] as num?)?.toDouble(),
    fatPer100g: (m['fat_per_100g'] as num?)?.toDouble(),
    userCreated: ((m['user_created'] as int?) ?? 0) == 1,
  );
}

class FoodsDao {
  FoodsDao._();
  static final FoodsDao instance = FoodsDao._();

  Future<int> insert(Food food) async {
    final db = await AppDatabase.instance.database;
    return db.insert(
      'foods',
      food.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Food food) async {
    if (food.id == null) return 0;
    final db = await AppDatabase.instance.database;
    return db.update(
      'foods',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete('foods', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Food>> search(String query, {int limit = 50}) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'foods',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      limit: limit,
      orderBy: 'user_created DESC, name ASC',
    );
    return rows.map((e) => Food.fromMap(e)).toList();
  }

  Future<List<Food>> all({int limit = 100}) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'foods',
      limit: limit,
      // Surface user-created foods first, then alphabetical
      orderBy: 'user_created DESC, name ASC',
    );
    return rows.map((e) => Food.fromMap(e)).toList();
  }

  // Export foods to CSV
  Future<String> exportCsv() async {
    final foods = await all(limit: 100000);
    final headers = [
      'id',
      'name',
      'calories_per_100g',
      'protein_per_100g',
      'carbs_per_100g',
      'fat_per_100g',
      'user_created',
    ];
    final rows = [
      headers,
      ...foods.map(
        (f) => [
          f.id ?? '',
          f.name,
          f.caloriesPer100g,
          f.proteinPer100g ?? '',
          f.carbsPer100g ?? '',
          f.fatPer100g ?? '',
          f.userCreated ? 1 : 0,
        ],
      ),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  // Import foods from CSV
  Future<int> importCsv(String csv) async {
    final rows = const CsvToListConverter(eol: '\n').convert(csv);
    if (rows.isEmpty) return 0;
    final headers = rows.first.map((e) => e.toString()).toList();
    int nameIdx = headers.indexOf('name');
    int calIdx = headers.indexOf('calories_per_100g');
    int pIdx = headers.indexOf('protein_per_100g');
    int cIdx = headers.indexOf('carbs_per_100g');
    int fIdx = headers.indexOf('fat_per_100g');
    int ucIdx = headers.indexOf('user_created');
    int count = 0;
    for (int i = 1; i < rows.length; i++) {
      final r = rows[i];
      final name = r[nameIdx]?.toString();
      if (name == null || name.isEmpty) continue;
      final cal = (r[calIdx] as num?)?.toDouble() ?? 0;
      final p = (r[pIdx] as num?)?.toDouble();
      final c = (r[cIdx] as num?)?.toDouble();
      final f = (r[fIdx] as num?)?.toDouble();
      final uc = (r[ucIdx] is num) ? ((r[ucIdx] as num).toInt() == 1) : true;
      await insert(
        Food(
          name: name,
          caloriesPer100g: cal,
          proteinPer100g: p,
          carbsPer100g: c,
          fatPer100g: f,
          userCreated: uc,
        ),
      );
      count++;
    }
    return count;
  }

  Future<int> seedFromJsonString(String jsonString) async {
    final list = (jsonDecode(jsonString) as List).cast<Map<String, dynamic>>();
    int count = 0;
    for (final m in list) {
      await insert(
        Food(
          name: m['name'] as String,
          caloriesPer100g: (m['calories_per_100g'] as num).toDouble(),
          proteinPer100g: (m['protein_per_100g'] as num?)?.toDouble(),
          carbsPer100g: (m['carbs_per_100g'] as num?)?.toDouble(),
          fatPer100g: (m['fat_per_100g'] as num?)?.toDouble(),
          userCreated: false,
        ),
      );
      count++;
    }
    return count;
  }
}

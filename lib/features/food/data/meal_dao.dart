import 'package:calorie_calculator/core/db/app_database.dart';
import '../models/meal_record.dart';

class MealDao {
  MealDao._();
  static final MealDao instance = MealDao._();

  Future<int> add(MealRecord rec) async {
    final db = await AppDatabase.instance.database;
    return db.insert('meal_records', rec.toMap());
  }

  Future<List<MealRecord>> listByDate(String date) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'meal_records',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'createdAt DESC',
    );
    return rows.map((m) => MealRecord.fromMap(m)).toList();
  }

  Future<int> deleteById(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete('meal_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(MealRecord rec) async {
    if (rec.id == null) return 0;
    final db = await AppDatabase.instance.database;
    return db.update(
      'meal_records',
      rec.toMap(),
      where: 'id = ?',
      whereArgs: [rec.id],
    );
  }

  Future<int> sumCaloriesByDate(String date) async {
    final db = await AppDatabase.instance.database;
    final res = await db.rawQuery(
      'SELECT SUM(calories) as total FROM meal_records WHERE date = ?',
      [date],
    );
    final first = res.firstOrNull ?? {};
    final total = first['total'] as int?;
    return total ?? 0;
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

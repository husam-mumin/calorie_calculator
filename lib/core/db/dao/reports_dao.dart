import '../app_database.dart';

class ReportsDao {
  ReportsDao._();
  static final ReportsDao instance = ReportsDao._();

  Future<int> totalCaloriesByDate(String date) async {
    final db = await AppDatabase.instance.database;
    final res = await db.rawQuery(
      'SELECT COALESCE(SUM(calories), 0) as total FROM meal_records WHERE date = ?',
      [date],
    );
    final row = res.isNotEmpty ? res.first : {};
    return (row['total'] as int?) ?? (row['total'] as num?)?.toInt() ?? 0;
  }

  Future<List<Map<String, Object?>>> weeklyTotals(
    String startDateInclusive,
    String endDateInclusive,
  ) async {
    final db = await AppDatabase.instance.database;
    return db.rawQuery(
      '''
      SELECT date, SUM(calories) as total
      FROM meal_records
      WHERE date BETWEEN ? AND ?
      GROUP BY date
      ORDER BY date ASC
      ''',
      [startDateInclusive, endDateInclusive],
    );
  }

  Future<List<Map<String, Object?>>> monthlyTotals(
    String yearMonthPrefix,
  ) async {
    final db = await AppDatabase.instance.database;
    // yearMonthPrefix like '2025-11%'
    return db.rawQuery(
      '''
      SELECT date, SUM(calories) as total
      FROM meal_records
      WHERE date LIKE ?
      GROUP BY date
      ORDER BY date ASC
      ''',
      ['$yearMonthPrefix%'],
    );
  }
}

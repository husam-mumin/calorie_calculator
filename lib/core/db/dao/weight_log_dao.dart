import '../app_database.dart';

class WeightEntry {
  final int? id;
  final int? userId;
  final String date; // YYYY-MM-DD
  final double weight;

  WeightEntry({this.id, this.userId, required this.date, required this.weight});

  Map<String, Object?> toMap() => {
    'id': id,
    'user_id': userId,
    'date': date,
    'weight': weight,
  };

  static WeightEntry fromMap(Map<String, Object?> m) => WeightEntry(
    id: m['id'] as int?,
    userId: m['user_id'] as int?,
    date: m['date'] as String,
    weight: (m['weight'] as num).toDouble(),
  );
}

class WeightLogDao {
  WeightLogDao._();
  static final WeightLogDao instance = WeightLogDao._();

  Future<int> add(WeightEntry e) async {
    final db = await AppDatabase.instance.database;
    return db.insert('weight_log', e.toMap());
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete('weight_log', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WeightEntry>> listByMonth(String yearMonthPrefix) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'weight_log',
      where: 'date LIKE ?',
      whereArgs: ['$yearMonthPrefix%'],
      orderBy: 'date ASC',
    );
    return rows.map((e) => WeightEntry.fromMap(e)).toList();
  }
}

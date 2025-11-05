import 'package:sqflite/sqflite.dart';
import 'package:calorie_calculator/core/db/app_database.dart';
import '../models/app_user.dart';

class UserDao {
  UserDao._();
  static final UserDao instance = UserDao._();

  Future<int> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await AppDatabase.instance.database;
    final user = AppUser(
      name: name.trim(),
      email: email.toLowerCase().trim(),
      passwordHash: password,
      createdAt: DateTime.now(),
    );
    return db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<AppUser?> getByEmail(String email) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<bool> validateLogin({
    required String email,
    required String password,
  }) async {
    final user = await getByEmail(email);
    if (user == null) return false;
    return user.passwordHash == password;
  }
}

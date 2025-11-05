import '../app_database.dart';

class UserProfile {
  final int? id;
  final String? name;
  final int? age;
  final String? gender; // male/female
  final double? height; // cm
  final double? weight; // kg
  final String? activityLevel; // sedentary/light/moderate/very/extra

  UserProfile({
    this.id,
    this.name,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.activityLevel,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'age': age,
    'gender': gender,
    'height': height,
    'weight': weight,
    'activity_level': activityLevel,
    'updated_at': DateTime.now().toIso8601String(),
  };

  static UserProfile fromMap(Map<String, Object?> m) => UserProfile(
    id: m['id'] as int?,
    name: m['name'] as String?,
    age: (m['age'] as int?) ?? (m['age'] as num?)?.toInt(),
    gender: m['gender'] as String?,
    height: (m['height'] as num?)?.toDouble(),
    weight: (m['weight'] as num?)?.toDouble(),
    activityLevel: m['activity_level'] as String?,
  );
}

class UsersDao {
  UsersDao._();
  static final UsersDao instance = UsersDao._();
  bool? _hasEmail;
  bool? _emailNotNull;

  Future<void> _ensureEmailColumnInfo() async {
    if (_hasEmail != null) return;
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery("PRAGMA table_info('users')");
    bool hasEmail = false;
    bool emailNotNull = false;
    for (final r in rows) {
      final name = (r['name'] ?? r['cid']).toString();
      if (name == 'email') {
        hasEmail = true;
        // notnull is 1 if NOT NULL
        final nn = r['notnull'];
        if (nn is int) emailNotNull = nn == 1;
        break;
      }
    }
    _hasEmail = hasEmail;
    _emailNotNull = emailNotNull;
  }

  Future<Map<String, Object?>> _massageForLegacy(Map<String, Object?> m) async {
    await _ensureEmailColumnInfo();
    final hasEmail = _hasEmail ?? false;
    final emailNotNull = _emailNotNull ?? false;
    if (hasEmail && emailNotNull && !m.containsKey('email')) {
      return {...m, 'email': ''};
    }
    return m;
  }

  Future<UserProfile?> getFirstUser() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('users', orderBy: 'id ASC', limit: 1);
    if (rows.isEmpty) return null;
    return UserProfile.fromMap(rows.first);
  }

  Future<int> upsert(UserProfile u) async {
    final db = await AppDatabase.instance.database;
    final data = await _massageForLegacy(u.toMap());
    if (u.id != null) {
      return db.update('users', data, where: 'id = ?', whereArgs: [u.id]);
    }
    return db.insert('users', data);
  }
}

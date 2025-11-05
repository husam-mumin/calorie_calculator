import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  static sqflite.Database? _db;

  Future<sqflite.Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<sqflite.Database> _open() async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = p.join(dbPath, 'medical_patient.db');
    return sqflite.openDatabase(
      path,
      version: 8,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // settings key-value store
        await db.execute('''
          CREATE TABLE settings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT NOT NULL UNIQUE,
            value TEXT,
            updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
          );
        ''');

        // users profile per requirements (keep email/password if present from previous app)
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age INTEGER,
            gender TEXT,
            height REAL,
            weight REAL,
            activity_level TEXT,
            email TEXT,
            passwordHash TEXT,
            createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT
          );
        ''');

        // foods database (per 100g)
        await db.execute('''
          CREATE TABLE foods(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            calories_per_100g REAL NOT NULL,
            protein_per_100g REAL,
            carbs_per_100g REAL,
            fat_per_100g REAL,
            user_created INTEGER NOT NULL DEFAULT 0,
            
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
          );
        ''');
        await db.execute('CREATE INDEX idx_foods_name ON foods(name);');

        // exercises (optional usage)
        await db.execute('''
          CREATE TABLE exercises(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            mets REAL,
            kcal_per_min_by_weight REAL,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
          );
        ''');

        // meals container (optional grouping)
        await db.execute('''
          CREATE TABLE meals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            date TEXT NOT NULL,
            meal_type TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL
          );
        ''');
        await db.execute('CREATE INDEX idx_meals_date ON meals(date);');

        // meal records (self-contained; keeps legacy columns for simplicity)
        await db.execute('''
          CREATE TABLE meal_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            meal_id INTEGER,
            food_id INTEGER,
            name TEXT,
            qty REAL DEFAULT 1,
            unit TEXT DEFAULT 'g',
            calories INTEGER NOT NULL,
            protein REAL,
            carbs REAL,
            fat REAL,
            date TEXT NOT NULL,
            mealType TEXT NOT NULL,
            source TEXT DEFAULT 'custom',
            timestamp TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(meal_id) REFERENCES meals(id) ON DELETE CASCADE,
            FOREIGN KEY(food_id) REFERENCES foods(id) ON DELETE SET NULL
          );
        ''');
        await db.execute(
          'CREATE INDEX idx_meal_records_date ON meal_records(date);',
        );

        // weight log
        await db.execute('''
          CREATE TABLE weight_log(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            date TEXT NOT NULL,
            weight REAL NOT NULL,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL
          );
        ''');
        await db.execute(
          'CREATE INDEX idx_weight_log_date ON weight_log(date);',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // v3: settings
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS settings(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              key TEXT NOT NULL UNIQUE,
              value TEXT,
              updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );
          ''');
        }
        // v4: foods
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS foods(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              calories_per_100g REAL NOT NULL,
              protein_per_100g REAL,
              carbs_per_100g REAL,
              fat_per_100g REAL,
              user_created INTEGER NOT NULL DEFAULT 0,
              created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );
          ''');
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_foods_name ON foods(name);',
          );
        }
        // v5: exercises
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS exercises(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              mets REAL,
              kcal_per_min_by_weight REAL,
              created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );
          ''');
        }
        // v6: meals table
        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS meals(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER,
              date TEXT NOT NULL,
              meal_type TEXT NOT NULL,
              created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );
          ''');
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_meals_date ON meals(date);',
          );
        }
        // v7: extend meal_records + users profile columns
        if (oldVersion < 7) {
          // ensure meal_records exist
          await db.execute('''
            CREATE TABLE IF NOT EXISTS meal_records(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL,
              mealType TEXT NOT NULL,
              name TEXT NOT NULL,
              calories INTEGER NOT NULL,
              carbs REAL,
              protein REAL,
              fat REAL,
              createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );
          ''');
          // Try to add missing columns; ignore errors if already exist
          Future<void> attemptExec(String sql) async {
            try {
              await db.execute(sql);
            } catch (_) {}
          }

          await attemptExec(
            "ALTER TABLE meal_records ADD COLUMN meal_id INTEGER",
          );
          await attemptExec(
            "ALTER TABLE meal_records ADD COLUMN food_id INTEGER",
          );
          await attemptExec(
            "ALTER TABLE meal_records ADD COLUMN qty REAL DEFAULT 1",
          );
          await attemptExec(
            "ALTER TABLE meal_records ADD COLUMN unit TEXT DEFAULT 'g'",
          );
          await attemptExec(
            "ALTER TABLE meal_records ADD COLUMN source TEXT DEFAULT 'custom'",
          );
          await attemptExec(
            "ALTER TABLE meal_records ADD COLUMN timestamp TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP",
          );
          await attemptExec(
            "CREATE INDEX IF NOT EXISTS idx_meal_records_date ON meal_records(date)",
          );

          // users: add profile columns if missing
          await attemptExec("ALTER TABLE users ADD COLUMN age INTEGER");
          await attemptExec("ALTER TABLE users ADD COLUMN gender TEXT");
          await attemptExec("ALTER TABLE users ADD COLUMN height REAL");
          await attemptExec("ALTER TABLE users ADD COLUMN weight REAL");
          await attemptExec("ALTER TABLE users ADD COLUMN activity_level TEXT");
          await attemptExec("ALTER TABLE users ADD COLUMN email TEXT");
          await attemptExec(
            "ALTER TABLE users ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP",
          );
          await attemptExec("ALTER TABLE users ADD COLUMN updated_at TEXT");
        }

        // v8: ensure users has passwordHash column (to match model/DAO)
        if (oldVersion < 8) {
          Future<void> attemptExec(String sql) async {
            try {
              await db.execute(sql);
            } catch (_) {}
          }

          await attemptExec("ALTER TABLE users ADD COLUMN passwordHash TEXT");
          // Some older schemas used created_at instead of createdAt; make sure the one
          // expected by the model exists to avoid mapping errors.
          await attemptExec(
            "ALTER TABLE users ADD COLUMN createdAt TEXT DEFAULT CURRENT_TIMESTAMP",
          );
        }
      },
    );
  }
}

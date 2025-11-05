import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;

class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  Future<String> get databasePath async {
    final dbDir = await sqflite.getDatabasesPath();
    return p.join(dbDir, 'medical_patient.db');
  }

  Future<File> exportToFile(File targetFile) async {
    final dbPath = await databasePath;
    final src = File(dbPath);
    if (!await src.exists()) {
      throw Exception('Database file not found');
    }
    await targetFile.create(recursive: true);
    return src.copy(targetFile.path);
  }

  Future<void> importFromFile(File sourceFile) async {
    final dbPath = await databasePath;
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    await sourceFile.copy(dbPath);
  }
}

import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _dbName = 'game_tracker.db';
  static const _dbVersion = 1;
  static Database? _db;

  static Future<Database> instance() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE games (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            platform TEXT NOT NULL,
            status TEXT NOT NULL CHECK(status IN ('planned','playing','finished')),
            rating INTEGER,
            hours REAL,
            startedAt TEXT,
            finishedAt TEXT,
            notes TEXT,
            coverUrl TEXT,
            createdAt TEXT DEFAULT (datetime('now')),
            updatedAt TEXT
          );
        ''');
        await db.execute('CREATE INDEX idx_games_title ON games(title);');
        await db.execute('CREATE INDEX idx_games_status ON games(status);');
        await db.execute('CREATE INDEX idx_games_finishedAt ON games(finishedAt);');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Add migrations here when bumping _dbVersion
      },
    );
    return _db!;
  }
}

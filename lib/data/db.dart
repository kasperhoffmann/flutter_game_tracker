import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class AppDatabase {
  static const _dbName = 'game_tracker.db';
  static const _dbVersion = 1;
  static Database? _db;

  static Future<Database> instance() async {
    if (_db != null) return _db!;

  // --- 1️⃣ WEB BROWSER ---
  if (kIsWeb) {
      // Web: IndexedDB + WASM (requires files in web/ created by the setup tool)
      databaseFactory = databaseFactoryFfiWeb;
      _db = await databaseFactory.openDatabase(
        _dbName,
        options: OpenDatabaseOptions(
          version: _dbVersion,
          onCreate: (db, v) async => _onCreate(db),
          onUpgrade: (db, o, n) async => _onUpgrade(db, o, n),
        ),
      );
      return _db!;
    }

  // --- 2️⃣ DESKTOP (Windows/macOS/Linux) ---
  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = await getApplicationSupportDirectory();
    final path = p.join(dir.path, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  // --- 3️⃣ MOBILE (Android/iOS) ---
  final dir = await getApplicationDocumentsDirectory();
  final path = p.join(dir.path, _dbName);
  _db = await openDatabase(
    path,
    version: _dbVersion,
    onCreate: _onCreate,
    onUpgrade: _onUpgrade,
  );
  return _db!;
}

  static Future<void> _onCreate(Database db, [int? version]) async {
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
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // future migrations
  }
}

import 'package:sqflite/sqflite.dart';
import '../models/game.dart';
import '../models/enums.dart';
import 'db.dart';

class GameDao {
  Future<Database> get _db async => AppDatabase.instance();

  Future<List<Game>> list({
    String search = '',
    GameStatus? statusFilter,
    String? platformFilter,
    String sort = 'updatedAt DESC',
  }) async {
    final db = await _db;
    final where = <String>[];
    final args = <Object?>[];

    if (search.isNotEmpty) {
      where.add('(title LIKE ? OR platform LIKE ?)');
      args.addAll(['%$search%', '%$search%']);
    }
    if (statusFilter != null) {
      where.add('status = ?');
      args.add(statusFilter.name);
    }
    if (platformFilter != null && platformFilter.isNotEmpty) {
      where.add('platform = ?');
      args.add(platformFilter);
    }

    final rows = await db.query(
      'games',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: sort,
    );
    return rows.map((e) => Game.fromMap(e)).toList();
  }

  Future<void> upsert(Game g) async {
    final db = await _db;
    await db.insert(
      'games',
      g.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('games', where: 'id = ?', whereArgs: [id]);
  }

  Future<Game?> getById(String id) async {
    final db = await _db;
    final rows = await db.query('games', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Game.fromMap(rows.first);
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('taptoeat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        coins INTEGER DEFAULT 0,
        last_played_stage_id INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE owned_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        item_id TEXT,
        item_type TEXT,
        is_equipped INTEGER DEFAULT 0,
        owned_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE stage_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        stage_id INTEGER,
        score INTEGER,
        max_combo INTEGER,
        perfect INTEGER DEFAULT 0,
        good INTEGER DEFAULT 0,
        bad INTEGER DEFAULT 0,
        miss INTEGER DEFAULT 0,
        rank TEXT DEFAULT '-',
        cleared INTEGER DEFAULT 0,
        played_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE quest_claims (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        quest_id TEXT,
        claimed_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // 기본 유저 생성 (게스트)
    final userId = await db.insert('users', {'coins': 0, 'last_played_stage_id': 1});
    // 기본 소유곡: stage_1
    await db.insert('owned_items', {
      'user_id': userId,
      'item_id': 'stage_1',
      'item_type': 'song',
      'is_equipped': 1,
    });
  }

  Future<int> getOrCreateUser() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }
    return await db.insert('users', {'coins': 0, 'last_played_stage_id': 1});
  }

  // ── 코인 ──

  Future<int> getCoins(int userId) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (result.isEmpty) return 0;
    return result.first['coins'] as int;
  }

  Future<void> addCoins(int userId, int amount) async {
    final db = await database;
    final current = await getCoins(userId);
    await db.update('users', {'coins': current + amount}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<bool> spendCoins(int userId, int amount) async {
    final db = await database;
    final current = await getCoins(userId);
    if (current < amount) return false;
    await db.update('users', {'coins': current - amount}, where: 'id = ?', whereArgs: [userId]);
    return true;
  }

  // ── 소유 아이템 ──

  Future<List<Map<String, dynamic>>> getOwnedItems(int userId, {String? type}) async {
    final db = await database;
    if (type != null) {
      return await db.query('owned_items',
          where: 'user_id = ? AND item_type = ?', whereArgs: [userId, type]);
    }
    return await db.query('owned_items', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> addOwnedItem(int userId, String itemId, String type) async {
    final db = await database;
    await db.insert('owned_items', {
      'user_id': userId,
      'item_id': itemId,
      'item_type': type,
      'is_equipped': 0,
    });
  }

  // ── 장착 상태 ──

  Future<List<Map<String, dynamic>>> getEquippedItems(int userId, {String? type}) async {
    final db = await database;
    if (type != null) {
      return await db.query('owned_items',
          where: 'user_id = ? AND is_equipped = 1 AND item_type = ?',
          whereArgs: [userId, type]);
    }
    return await db.query('owned_items',
        where: 'user_id = ? AND is_equipped = 1', whereArgs: [userId]);
  }

  Future<void> equipItem(int userId, String itemId) async {
    final db = await database;
    // 같은 타입의 다른 아이템 장착 해제
    final item = await db.query('owned_items',
        where: 'user_id = ? AND item_id = ?', whereArgs: [userId, itemId]);
    if (item.isNotEmpty) {
      final itemType = item.first['item_type'] as String;
      await db.update('owned_items', {'is_equipped': 0},
          where: 'user_id = ? AND item_type = ?', whereArgs: [userId, itemType]);
      await db.update('owned_items', {'is_equipped': 1},
          where: 'user_id = ? AND item_id = ?', whereArgs: [userId, itemId]);
    }
  }

  Future<void> unequipItem(int userId, String itemId) async {
    final db = await database;
    await db.update('owned_items', {'is_equipped': 0},
        where: 'user_id = ? AND item_id = ?', whereArgs: [userId, itemId]);
  }

  // ── 최근 플레이 ──

  Future<int> getLastPlayedStage(int userId) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (result.isEmpty) return 1;
    return result.first['last_played_stage_id'] as int;
  }

  Future<void> setLastPlayedStage(int userId, int stageId) async {
    final db = await database;
    await db.update('users', {'last_played_stage_id': stageId},
        where: 'id = ?', whereArgs: [userId]);
  }

  // ── 클리어 기록 ──

  Future<void> saveStageResult(
    int userId,
    int stageId,
    int score,
    int maxCombo,
    int perfect,
    int good,
    int bad,
    int miss,
    String rank,
    bool cleared,
  ) async {
    final db = await database;
    await db.insert('stage_results', {
      'user_id': userId,
      'stage_id': stageId,
      'score': score,
      'max_combo': maxCombo,
      'perfect': perfect,
      'good': good,
      'bad': bad,
      'miss': miss,
      'rank': rank,
      'cleared': cleared ? 1 : 0,
    });
  }

  // ── 퀘스트 / 업적 통계 ──

  Future<int> getClearedCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM stage_results WHERE user_id = ? AND cleared = 1',
      [userId],
    );
    if (result.isEmpty) return 0;
    return (result.first['cnt'] as int?) ?? 0;
  }

  Future<bool> hasRankS(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM stage_results WHERE user_id = ? AND rank = \'S\'',
      [userId],
    );
    if (result.isEmpty) return false;
    return ((result.first['cnt'] as int?) ?? 0) > 0;
  }

  Future<bool> isQuestClaimed(int userId, String questId) async {
    final db = await database;
    final result = await db.query('quest_claims',
        where: 'user_id = ? AND quest_id = ?', whereArgs: [userId, questId]);
    return result.isNotEmpty;
  }

  Future<void> claimQuest(int userId, String questId) async {
    final db = await database;
    await db.insert('quest_claims', {'user_id': userId, 'quest_id': questId});
  }
}

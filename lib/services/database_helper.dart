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
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN plays INTEGER DEFAULT 10');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        coins INTEGER DEFAULT 0,
        plays INTEGER DEFAULT 10,
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
  }

  Future<int> getOrCreateUser() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }

    // 유저가 없는 경우 초기 유저 및 기본 곡 지급을 트랜잭션으로 처리
    return await db.transaction((txn) async {
      final userId = await txn.insert('users', {
        'coins': 0,
        'plays': 10,
        'last_played_stage_id': 1,
      });
      await txn.insert('owned_items', {
        'user_id': userId,
        'item_id': 'stage_1',
        'item_type': 'song',
        'is_equipped': 1,
      });
      return userId;
    });
  }

  // ── 코인 (SQL direct update 방식 적용) ──

  Future<int> getCoins(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['coins'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (result.isEmpty) return 0;
    return result.first['coins'] as int? ?? 0;
  }

  Future<void> addCoins(int userId, int amount) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE users SET coins = coins + ? WHERE id = ?',
      [amount, userId],
    );
  }

  Future<bool> spendCoins(int userId, int amount) async {
    final db = await database;
    // 조건절에서 잔액을 확인하여 차감
    final count = await db.rawUpdate(
      'UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?',
      [amount, userId, amount],
    );
    return count > 0; // 0보다 크면 차감 성공
  }

  // ── 플레이 재화 ──

  Future<int> getPlays(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['plays'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (result.isEmpty) return 0;
    return result.first['plays'] as int? ?? 0;
  }

  Future<void> addPlays(int userId, int amount) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE users SET plays = plays + ? WHERE id = ?',
      [amount, userId],
    );
  }

  Future<bool> spendPlay(int userId) async {
    final db = await database;
    final count = await db.rawUpdate(
      'UPDATE users SET plays = plays - 1 WHERE id = ? AND plays >= 1',
      [userId],
    );
    return count > 0;
  }

  // ── 소유 아이템 ──

  Future<List<Map<String, dynamic>>> getOwnedItems(
      int userId, {
        String? type,
      }) async {
    final db = await database;
    if (type != null) {
      return await db.query(
        'owned_items',
        where: 'user_id = ? AND item_type = ?',
        whereArgs: [userId, type],
      );
    }
    return await db.query(
      'owned_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
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

  // ── 장착 상태 (트랜잭션으로 안전하게 교체) ──

  Future<List<Map<String, dynamic>>> getEquippedItems(
      int userId, {
        String? type,
      }) async {
    final db = await database;
    if (type != null) {
      return await db.query(
        'owned_items',
        where: 'user_id = ? AND is_equipped = 1 AND item_type = ?',
        whereArgs: [userId, type],
      );
    }
    return await db.query(
      'owned_items',
      where: 'user_id = ? AND is_equipped = 1',
      whereArgs: [userId],
    );
  }

  Future<void> equipItem(int userId, String itemId) async {
    final db = await database;
    await db.transaction((txn) async {
      final item = await txn.query(
        'owned_items',
        where: 'user_id = ? AND item_id = ?',
        whereArgs: [userId, itemId],
      );
      if (item.isNotEmpty) {
        final itemType = item.first['item_type'] as String;
        // 같은 타입의 기존 장착 해제
        await txn.update(
          'owned_items',
          {'is_equipped': 0},
          where: 'user_id = ? AND item_type = ?',
          whereArgs: [userId, itemType],
        );
        // 새로운 아이템 장착
        await txn.update(
          'owned_items',
          {'is_equipped': 1},
          where: 'user_id = ? AND item_id = ?',
          whereArgs: [userId, itemId],
        );
      }
    });
  }

  Future<void> unequipItem(int userId, String itemId) async {
    final db = await database;
    await db.update(
      'owned_items',
      {'is_equipped': 0},
      where: 'user_id = ? AND item_id = ?',
      whereArgs: [userId, itemId],
    );
  }

  // ── 최근 플레이 ──

  Future<int> getLastPlayedStage(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['last_played_stage_id'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (result.isEmpty) return 1;
    return result.first['last_played_stage_id'] as int? ?? 1;
  }

  Future<void> setLastPlayedStage(int userId, int stageId) async {
    final db = await database;
    await db.update(
      'users',
      {'last_played_stage_id': stageId},
      where: 'id = ?',
      whereArgs: [userId],
    );
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

  /// 스테이지별 최고 점수 및 최고 랭크 추출 (점수가 최고점일 때 갱신)
  Future<Map<int, ({int bestScore, String bestRank})>> getBestStageResults(
      int userId,
      ) async {
    final db = await database;
    final rows = await db.query(
      'stage_results',
      where: 'user_id = ?',
      whereArgs: [userId],
      columns: ['stage_id', 'score', 'rank'],
    );

    final bests = <int, ({int bestScore, String bestRank})>{};
    for (final row in rows) {
      final stageId = row['stage_id'] as int?;
      if (stageId == null) continue;
      final score = row['score'] as int? ?? 0;
      final rank = row['rank'] as String? ?? '-';

      final current = bests[stageId];
      // 최고 점수 갱신 시 랭크도 같이 최고 점수의 랭크로 정렬 유지
      if (current == null || score > current.bestScore) {
        bests[stageId] = (bestScore: score, bestRank: rank);
      }
    }
    return bests;
  }

  Future<bool> isQuestClaimed(int userId, String questId) async {
    final db = await database;
    final result = await db.query(
      'quest_claims',
      where: 'user_id = ? AND quest_id = ?',
      whereArgs: [userId, questId],
    );
    return result.isNotEmpty;
  }

  Future<void> claimQuest(int userId, String questId) async {
    final db = await database;
    await db.insert('quest_claims', {'user_id': userId, 'quest_id': questId});
  }

  // ── 출석 (7일 연속) ──

  Future<DateTime?> getLastAttendanceClaimDate(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT MAX(claimed_at) AS last FROM quest_claims "
          "WHERE user_id = ? AND quest_id LIKE 'attendance_%'",
      [userId],
    );
    if (result.isEmpty) return null;
    final lastStr = result.first['last'] as String?;
    if (lastStr == null || lastStr.isEmpty) return null;
    return DateTime.tryParse(lastStr);
  }
}
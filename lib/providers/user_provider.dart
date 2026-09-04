import 'package:flutter/foundation.dart';
import '../services/database_helper.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  int _userId = 1;
  int _coins = 0;
  int _lastPlayedStageId = 1;
  Set<String> _ownedSongs = {};
  Set<String> _ownedEffects = {};
  Set<String> _equippedSongs = {};
  Set<String> _equippedEffects = {};

  int get userId => _userId;
  int get coins => _coins;
  int get lastPlayedStageId => _lastPlayedStageId;

  bool ownsSong(String itemId) => _ownedSongs.contains(itemId);
  bool ownsEffect(String itemId) => _ownedEffects.contains(itemId);
  bool isSongEquipped(String itemId) => _equippedSongs.contains(itemId);
  bool isEffectEquipped(String itemId) => _equippedEffects.contains(itemId);

  Future<void> init() async {
    _userId = await _db.getOrCreateUser();
    _coins = await _db.getCoins(_userId);
    _lastPlayedStageId = await _db.getLastPlayedStage(_userId);
    await _loadOwnedItems();
    notifyListeners();
  }

  Future<void> _loadOwnedItems() async {
    final songs = await _db.getOwnedItems(_userId, type: 'song');
    final effects = await _db.getOwnedItems(_userId, type: 'effect');

    _ownedSongs = songs.map((e) => e['item_id'] as String).toSet();
    _ownedEffects = effects.map((e) => e['item_id'] as String).toSet();

    final equippedSongs = await _db.getEquippedItems(_userId, type: 'song');
    final equippedEffects = await _db.getEquippedItems(_userId, type: 'effect');

    _equippedSongs = equippedSongs.map((e) => e['item_id'] as String).toSet();
    _equippedEffects = equippedEffects.map((e) => e['item_id'] as String).toSet();
  }

  // ── 코인 ──

  Future<void> addCoins(int amount) async {
    await _db.addCoins(_userId, amount);
    _coins = await _db.getCoins(_userId);
    notifyListeners();
  }

  Future<bool> spendCoins(int amount) async {
    final success = await _db.spendCoins(_userId, amount);
    if (success) {
      _coins = await _db.getCoins(_userId);
      notifyListeners();
    }
    return success;
  }

  // ── 곡 구매 ──

  Future<bool> purchaseSong(String itemId, int cost) async {
    if (_ownedSongs.contains(itemId)) return false;
    final success = await spendCoins(cost);
    if (!success) return false;
    await _db.addOwnedItem(_userId, itemId, 'song');
    _ownedSongs.add(itemId);
    notifyListeners();
    return true;
  }

  // ── 이펙트 구매 ──

  Future<bool> purchaseEffect(String itemId, int cost) async {
    if (_ownedEffects.contains(itemId)) return false;
    final success = await spendCoins(cost);
    if (!success) return false;
    await _db.addOwnedItem(_userId, itemId, 'effect');
    _ownedEffects.add(itemId);
    notifyListeners();
    return true;
  }

  // ── 장착 ──

  Future<void> toggleEquipSong(String itemId) async {
    if (_equippedSongs.contains(itemId)) {
      await _db.unequipItem(_userId, itemId);
      _equippedSongs.remove(itemId);
    } else {
      await _db.equipItem(_userId, itemId);
      // 같은 타입의 다른 곡 장착 해제
      _equippedSongs.clear();
      _equippedSongs.add(itemId);
    }
    notifyListeners();
  }

  Future<void> toggleEquipEffect(String itemId) async {
    if (_equippedEffects.contains(itemId)) {
      await _db.unequipItem(_userId, itemId);
      _equippedEffects.remove(itemId);
    } else {
      await _db.equipItem(_userId, itemId);
      _equippedEffects.clear();
      _equippedEffects.add(itemId);
    }
    notifyListeners();
  }

  // ── 최근 플레이 ──

  Future<void> setLastPlayedStage(int stageId) async {
    await _db.setLastPlayedStage(_userId, stageId);
    _lastPlayedStageId = stageId;
    notifyListeners();
  }

  // ── 클리어 기록 ──

  Future<void> saveStageResult(
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
    await _db.saveStageResult(
      _userId, stageId, score, maxCombo,
      perfect, good, bad, miss, rank, cleared,
    );
  }

  // ── 퀘스트 / 업적 ──

  Future<int> getClearedCount() async => _db.getClearedCount(_userId);
  Future<bool> hasRankS() async => _db.hasRankS(_userId);
  Future<bool> isQuestClaimed(String questId) async => _db.isQuestClaimed(_userId, questId);
  Future<void> claimQuest(String questId) async => _db.claimQuest(_userId, questId);
}

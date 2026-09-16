import 'package:flutter/foundation.dart';
import '../services/database_helper.dart';
import '../models/effect_model.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  int _userId = 1;
  int _coins = 0;
  Set<String> _ownedSongs = {};
  Set<String> _ownedEffects = {};
  Set<String> _equippedSongs = {};
  Set<String> _equippedEffects = {};
  Map<int, ({int bestScore, String bestRank})> _bestResults = {};

  int get coins => _coins;

  bool ownsSong(String itemId) {
    if (_ownedSongs.contains(itemId)) return true;
    for (final song in ShopData.allSongs) {
      if (song.isBasic &&
          song.type == 'music' &&
          (itemId == 'stage_${song.stageNumber}' ||
              itemId.toLowerCase() ==
                  'music_${song.name.toLowerCase().replaceAll(" ", "_")}')) {
        return true;
      }
    }
    return false;
  }

  // ── 공개 판정 getter ──

  bool ownsEffect(String itemId) => _ownedEffects.contains(itemId);
  bool isSongEquipped(String itemId) => _equippedSongs.contains(itemId);
  bool isEffectEquipped(String itemId) => _equippedEffects.contains(itemId);

  ({int bestScore, String bestRank})? bestResultForStage(int stageNumber) =>
      _bestResults[stageNumber];

  // ── 곡/스테이지 보유 통합 판정 메서드 ──
  bool isStageOwned(int stageNumber, {String? stageTitle}) {
    final song = ShopData.allSongs.firstWhere(
      (s) => s.stageNumber == stageNumber,
      orElse: () => ShopData.allSongs.first,
    );
    if (song.isBasic) return true;
    if (_ownedSongs.contains('stage_$stageNumber')) return true;
    for (final ownedId in _ownedSongs) {
      if (ownedId.startsWith('stage_')) continue;
      if (stageTitle != null &&
          ownedId.toLowerCase().contains(
            stageTitle.toLowerCase().replaceAll(' ', '_'),
          )) {
        return true;
      }
    }
    return false;
  }

  Future<void> init() async {
    _userId = await _db.getOrCreateUser();
    _coins = await _db.getCoins(_userId);
    await _loadOwnedItems();
    await _loadBestResults();
    notifyListeners();
  }

  Future<void> _loadBestResults() async {
    _bestResults = await _db.getBestStageResults(_userId);
  }

  Future<void> _loadOwnedItems() async {
    final songs = await _db.getOwnedItems(_userId, type: 'song');
    final effects = await _db.getOwnedItems(_userId, type: 'effect');

    _ownedSongs = songs.map((e) => e['item_id'] as String).toSet();
    _ownedEffects = effects.map((e) => e['item_id'] as String).toSet();

    final equippedSongs = await _db.getEquippedItems(_userId, type: 'song');
    final equippedEffects = await _db.getEquippedItems(_userId, type: 'effect');

    _equippedSongs = equippedSongs.map((e) => e['item_id'] as String).toSet();
    _equippedEffects = equippedEffects
        .map((e) => e['item_id'] as String)
        .toSet();
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
    for (final song in ShopData.allSongs) {
      if (song.isBasic &&
          song.type == 'music' &&
          (itemId == 'stage_${song.stageNumber}' ||
              itemId.toLowerCase() ==
                  'music_${song.name.toLowerCase().replaceAll(" ", "_")}')) {
        _ownedSongs.add(itemId);
        try {
          await _db.addOwnedItem(_userId, itemId, 'song');
        } catch (e) {
          rethrow;
        }
        notifyListeners();
        return true;
      }
    }
    final coinSuccess = await spendCoins(cost);
    if (!coinSuccess) return false;
    try {
      await _db.addOwnedItem(_userId, itemId, 'song');
    } catch (e) {
      await addCoins(cost);
      rethrow;
    }
    _ownedSongs.add(itemId);
    notifyListeners();
    return true;
  }

  // ── 이펙트 구매 ──

  Future<bool> purchaseEffect(String itemId, int cost) async {
    if (_ownedEffects.contains(itemId)) return false;

    final coinSuccess = await spendCoins(cost);
    if (!coinSuccess) return false;

    try {
      await _db.addOwnedItem(_userId, itemId, 'effect');
    } catch (e) {
      await addCoins(cost);
      rethrow;
    }

    _ownedEffects.add(itemId);
    notifyListeners();
    return true;
  }

  // ── 장착 ──

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
      _userId,
      stageId,
      score,
      maxCombo,
      perfect,
      good,
      bad,
      miss,
      rank,
      cleared,
    );
    _bestResults = await _db.getBestStageResults(_userId);
    notifyListeners();
  }

  // ── 퀘스트 / 업적 ──

  Future<int> getClearedCount() async => _db.getClearedCount(_userId);
  Future<bool> hasRankS() async => _db.hasRankS(_userId);
  Future<bool> isQuestClaimed(String questId) async =>
      _db.isQuestClaimed(_userId, questId);
  Future<void> claimQuest(String questId) async =>
      _db.claimQuest(_userId, questId);

  // ── 출석 (7일 연속) ──

  Future<DateTime?> getLastAttendanceClaimDate() async =>
      _db.getLastAttendanceClaimDate(_userId);
}

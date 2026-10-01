import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/stage_model.dart';
import '../models/effect_model.dart';

class StageGenerator {
  static List<StageModel> get allStages {
    return ShopData.allSongs
        .map((song) => generateStage(song.stageNumber, difficulty: 'NORMAL'))
        .toList();
  }

  static const Map<String, Map<String, double>> difficultySpecs = {
    'EASY': {'level': 2, 'rewardMul': 1.0},
    'NORMAL': {'level': 4, 'rewardMul': 1.5},
    'HARD': {'level': 6, 'rewardMul': 2.0},
  };

  static const Map<String, Map<String, double>> playSpecs = {
    'EASY': {
      'notes': 80,
      'perfectMs': 100,
      'goodMs': 160,
      'badMs': 240,
      'missGraceMs': 240,
      'fallMs': 2000,
      'missDmg': 4,
      'badDmg': 1.5,
      'healPerfect': 4,
      'healGood': 2,
    },
    'NORMAL': {
      'notes': 140,
      'perfectMs': 80,
      'goodMs': 140,
      'badMs': 210,
      'missGraceMs': 200,
      'fallMs': 1600,
      'missDmg': 6,
      'badDmg': 2.5,
      'healPerfect': 3,
      'healGood': 1.5,
    },
    'HARD': {
      'notes': 220,
      'perfectMs': 65,
      'goodMs': 125,
      'badMs': 200,
      'missGraceMs': 180,
      'fallMs': 1300,
      'missDmg': 7,
      'badDmg': 3,
      'healPerfect': 3,
      'healGood': 1,
    },
  };

  static double playValue(String? difficulty, String key) {
    final diffKey = normalizeDifficulty(difficulty);
    return playSpecs[diffKey]![key]!;
  }

  static String normalizeDifficulty(String? input) {
    final key = (input ?? 'NORMAL').toUpperCase();
    return difficultySpecs.containsKey(key) ? key : 'NORMAL';
  }

  static final Map<int, List<NoteData>> _chartCache = {};
  static final Map<int, int> _chartEndMs = {};
  static bool _isPreloaded = false;

  /// 모든 차트 프리로딩
  static Future<void> preloadCharts() async {
    if (_isPreloaded) return;

    for (final song in ShopData.allSongs) {
      if (song.chartPath != null && song.chartPath!.isNotEmpty) {
        try {
          final data = await rootBundle.loadString(song.chartPath!);
          final List<dynamic> jsonList = jsonDecode(data);

          final notes = jsonList.map((item) {
            return NoteData(
              timeMs: item['timeMs'] as int,
              lane: item['lane'] as int,
            );
          }).toList();

          // 타임스탬프 순 정렬
          notes.sort((a, b) => a.timeMs.compareTo(b.timeMs));

          _chartCache[song.stageNumber] = notes;
          _chartEndMs[song.stageNumber] =
          notes.isEmpty ? 90000 : notes.last.timeMs;
        } catch (e) {
          debugPrint('Chart load error for ${song.name}: $e');
        }
      }
    }
    _isPreloaded = true;
  }

  /// 동일 타임스탬프(동시타) 그룹화 유지형 난이도 조절
  static List<NoteData> _sampleByDifficulty(
      List<NoteData> source, int targetCount) {
    if (source.isEmpty || source.length <= targetCount) return List.from(source);

    // 타임스탬프 단위로 그룹화 (동시타 깨짐 방지)
    final Map<int, List<NoteData>> grouped = {};
    for (var note in source) {
      grouped.putIfAbsent(note.timeMs, () => []).add(note);
    }

    final keys = grouped.keys.toList()..sort();
    if (keys.isEmpty) return [];

    final double step = keys.length / max(1, (targetCount / 1.2));
    final List<NoteData> sampled = [];

    double currentIdx = 0;
    while (currentIdx < keys.length) {
      final key = keys[currentIdx.toInt()];
      sampled.addAll(grouped[key]!);
      currentIdx += max(1.0, step);
    }

    return sampled;
  }

  static StageModel generateStage(int stageNum, {String difficulty = 'NORMAL'}) {
    final song = ShopData.allSongs.firstWhere(
          (s) => s.stageNumber == stageNum,
      orElse: () => ShopData.allSongs.first,
    );

    final diffKey = normalizeDifficulty(difficulty);
    final spec = difficultySpecs[diffKey]!;
    final level = spec['level']!.toInt();
    final rewardMul = spec['rewardMul']!;

    final cachedNotes = _chartCache[song.stageNumber];
    if (cachedNotes != null && cachedNotes.isNotEmpty) {
      return _generateFromChart(song, diffKey, level, rewardMul, cachedNotes);
    }

    return _generateOriginal(stageNum, diffKey, level, rewardMul, song);
  }

  static StageModel _generateFromChart(
      ShopItem song,
      String diffKey,
      int level,
      double rewardMul,
      List<NoteData> chartNotes,
      ) {
    final targetNotes = playSpecs[diffKey]!['notes']!.toInt();
    final notes = _sampleByDifficulty(chartNotes, targetNotes);

    return StageModel(
      stageNumber: song.stageNumber,
      title: song.name,
      artist: song.artist ?? 'Unknown Artist',
      bpm: song.bpm ?? 120,
      difficulty: diffKey,
      difficultyLevel: level,
      audioPath: song.audioPath ?? '',
      notes: notes,
      rewardCoins: ((song.baseRewardCoins ?? 100) * rewardMul).round(),
    );
  }

  /// 리듬 패턴 엔진: 단순 반복 탈피 (계단, 트릴, 동시타, 16분 연타 조합)
  static StageModel _generateOriginal(
      int stageNum, String diffKey, int level, double rewardMul, ShopItem song) {
    // 지정된 곡 길이가 없으면 기본 90초 설정
    final endMs = _chartEndMs[stageNum] ?? 90000;
    final random = Random(42 + stageNum * 10 + level);
    final notes = <NoteData>[];

    final bpm = song.bpm ?? 130.0;
    final beatMs = 60000 / bpm; // 1비트(4분음표) ms

    double currentTime = 2000.0; // 시작 여유 시간 2초
    int prevLane = -1;

    while (currentTime < endMs) {
      final patternType = random.nextInt(100);

      // 1. HARD / NORMAL 일 때 높은 확률로 16분음표 트릴 (D-F-D-F)
      if (diffKey != 'EASY' && patternType < 30) {
        int laneA = random.nextInt(3);
        int laneB = laneA + 1;
        for (int i = 0; i < 4; i++) {
          notes.add(NoteData(
            timeMs: (currentTime + i * (beatMs / 4)).round(),
            lane: i % 2 == 0 ? laneA : laneB,
          ));
        }
        currentTime += beatMs;
      }
      // 2. 계단 패턴 (0 -> 1 -> 2 -> 3 또는 역순)
      else if (patternType < 55) {
        bool isReverse = random.nextBool();
        for (int i = 0; i < 4; i++) {
          int lane = isReverse ? (3 - i) : i;
          notes.add(NoteData(
            timeMs: (currentTime + i * (beatMs / 2)).round(),
            lane: lane,
          ));
        }
        currentTime += beatMs * 2;
      }
      // 3. 동시타 (HARD 80% 미만, NORMAL 70% 미만)
      else if ((diffKey == 'HARD' && patternType < 80) ||
          (diffKey == 'NORMAL' && patternType < 70)) {
        int lane1 = random.nextInt(4);
        int lane2 = (lane1 + 2) % 4; // 서로 떨어진 레인
        notes.add(NoteData(timeMs: currentTime.round(), lane: lane1));
        notes.add(NoteData(timeMs: currentTime.round(), lane: lane2));
        currentTime += beatMs / 2;
      }
      // 4. 일반 단타 (이전 레인과 중복 회피)
      else {
        int lane = random.nextInt(4);
        while (lane == prevLane) {
          lane = random.nextInt(4);
        }
        prevLane = lane;
        notes.add(NoteData(timeMs: currentTime.round(), lane: lane));
        currentTime += beatMs / 2;
      }
    }

    // 시간 순 정렬 보장
    notes.sort((a, b) => a.timeMs.compareTo(b.timeMs));

    return StageModel(
      stageNumber: song.stageNumber,
      title: song.name,
      artist: song.artist ?? 'Unknown Artist',
      bpm: song.bpm ?? 130,
      difficulty: diffKey,
      difficultyLevel: level,
      audioPath: song.audioPath ?? '',
      notes: notes,
      rewardCoins: ((song.baseRewardCoins ?? 100) * rewardMul).round(),
    );
  }

  static StageModel getStage(int id, {String difficulty = 'NORMAL'}) =>
      generateStage(id, difficulty: difficulty);
}
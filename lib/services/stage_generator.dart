import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/stage_model.dart';
import '../data/song_registry.dart';

class StageGenerator {
  static List<StageModel> get allStages {
    return SongRegistry.allSongs
        .map((song) => generateStage(song.id, difficulty: 'NORMAL'))
        .toList();
  }

  static const Map<String, Map<String, double>> difficultySpecs = {
    'EASY': {'level': 2, 'rewardMul': 1.0},
    'NORMAL': {'level': 4, 'rewardMul': 1.5},
    'HARD': {'level': 6, 'rewardMul': 2.0},
  };

  static const Map<String, Map<String, double>> playSpecs = {
    'EASY': {
      'notes': 60, 'perfectMs': 100, 'goodMs': 160, 'badMs': 240,
      'missGraceMs': 240, 'fallMs': 2000, 'missDmg': 4, 'badDmg': 1.5,
      'healPerfect': 4, 'healGood': 2,
    },
    'NORMAL': {
      'notes': 110, 'perfectMs': 80, 'goodMs': 140, 'badMs': 210,
      'missGraceMs': 200, 'fallMs': 1600, 'missDmg': 6, 'badDmg': 2.5,
      'healPerfect': 3, 'healGood': 1.5,
    },
    'HARD': {
      'notes': 170, 'perfectMs': 65, 'goodMs': 125, 'badMs': 200,
      'missGraceMs': 180, 'fallMs': 1300, 'missDmg': 7, 'badDmg': 3,
      'healPerfect': 3, 'healGood': 1,
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

  // 📌 맵핑 구조를 List<NoteData>로 변경하여 JSON에 저장된 lane을 그대로 사용
  static final Map<int, List<NoteData>> _chartCache = {};

  static Future<void> preloadCharts() async {
    for (final song in SongRegistry.allSongs) {
      if (song.chartPath != null) {
        try {
          final data = await rootBundle.loadString(song.chartPath!);
          final List<dynamic> jsonList = jsonDecode(data);

          // JSON에서 timeMs와 lane을 읽어 NoteData로 변환 후 캐싱
          final notes = jsonList.map((item) {
            return NoteData(
              timeMs: item['timeMs'] as int,
              lane: item['lane'] as int,
            );
          }).toList();

          _chartCache[song.id] = notes;
        } catch (e) {
          debugPrint('Chart load error for ${song.title}: $e');
        }
      }
    }
  }

  static StageModel generateStage(int stageNum, {String difficulty = 'NORMAL'}) {
    final song = SongRegistry.allSongs.firstWhere(
          (s) => s.id == stageNum,
      orElse: () => SongRegistry.allSongs.first,
    );

    final diffKey = normalizeDifficulty(difficulty);
    final spec = difficultySpecs[diffKey]!;
    final level = spec['level']!.toInt();
    final rewardMul = spec['rewardMul']!;

    final cachedNotes = _chartCache[song.id];
    if (cachedNotes != null && cachedNotes.isNotEmpty) {
      return _generateFromChart(song, diffKey, level, rewardMul, cachedNotes);
    }

    return _generateOriginal(stageNum, diffKey, level, rewardMul, song);
  }

  // 📌 JSON에 정의된 고정 노트를 난이도별 규칙에 맞춰 가져오기
  static StageModel _generateFromChart(
      SongData song,
      String diffKey,
      int level,
      double rewardMul,
      List<NoteData> chartNotes,
      ) {
    final targetNotes = playSpecs[diffKey]!['notes']!.toInt();
    final notes = <NoteData>[];

    int selectedIndex = 0;
    for (int i = 0; i < targetNotes; i++) {
      if (selectedIndex >= chartNotes.length) {
        selectedIndex = 0; // 데이터가 부족하면 처음부터 반복
      }

      final sourceNote = chartNotes[selectedIndex];

      switch (diffKey) {
        case 'EASY':
        // EASY 모드는 2칸씩 건너뛰며 절반 정도의 노트만 사용
          notes.add(NoteData(timeMs: sourceNote.timeMs, lane: sourceNote.lane));
          selectedIndex += 2;
          break;
        case 'HARD':
        // HARD 모드는 모든 노트 사용 + 사이사이에 추가 노트 배치 가능
          notes.add(NoteData(timeMs: sourceNote.timeMs, lane: sourceNote.lane));
          selectedIndex += 1;
          break;
        default: // NORMAL
        // NORMAL 모드는 순서대로 모든 노트 사용
          notes.add(NoteData(timeMs: sourceNote.timeMs, lane: sourceNote.lane));
          selectedIndex += 1;
          break;
      }
    }

    return StageModel(
      stageNumber: song.id,
      title: song.title,
      artist: song.artist,
      bpm: song.bpm,
      difficulty: diffKey,
      difficultyLevel: level,
      audioPath: song.audioPath,
      notes: notes,
      rank: 'S',
      rewardCoins: (song.baseRewardCoins * rewardMul).round(),
    );
  }

  static StageModel _generateOriginal(int stageNum, String diffKey, int level, double rewardMul, SongData song) {
    // (기존 폴백 메서드 유지)
    final targetNotes = (playSpecs[diffKey]!['notes']! + stageNum * 5).toInt();
    final random = Random(42 + stageNum * 10 + level);
    final notes = <NoteData>[];
    double timeMs = 1000.0;

    for (int i = 0; i < targetNotes; i++) {
      final lane = random.nextInt(4);
      notes.add(NoteData(timeMs: timeMs.round(), lane: lane));
      final beatMs = 60000 / song.bpm;
      timeMs += beatMs / 2;
    }

    return StageModel(
      stageNumber: song.id,
      title: song.title,
      artist: song.artist,
      bpm: song.bpm,
      difficulty: diffKey,
      difficultyLevel: level,
      audioPath: song.audioPath,
      notes: notes,
      rank: 'S',
      rewardCoins: (song.baseRewardCoins * rewardMul).round(),
    );
  }

  static StageModel getStage(int id, {String difficulty = 'NORMAL'}) =>
      generateStage(id, difficulty: difficulty);
}
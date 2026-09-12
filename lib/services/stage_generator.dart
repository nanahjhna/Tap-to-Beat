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

  static final Map<int, List<NoteData>> _chartCache = {};

  static Future<void> preloadCharts() async {
    for (final song in ShopData.allSongs) {
      if (song.chartPath != null) {
        try {
          final data = await rootBundle.loadString(song.chartPath!);
          final List<dynamic> jsonList = jsonDecode(data);

          final notes = jsonList.map((item) {
            return NoteData(
              timeMs: item['timeMs'] as int,
              lane: item['lane'] as int,
            );
          }).toList();

          _chartCache[song.stageNumber] = notes;
        } catch (e) {
          debugPrint('Chart load error for ${song.name}: $e');
        }
      }
    }
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
    final notes = <NoteData>[];

    int selectedIndex = 0;
    for (int i = 0; i < targetNotes; i++) {
      if (selectedIndex >= chartNotes.length) {
        selectedIndex = 0;
      }

      final sourceNote = chartNotes[selectedIndex];

      switch (diffKey) {
        case 'EASY':
          notes.add(NoteData(timeMs: sourceNote.timeMs, lane: sourceNote.lane));
          selectedIndex += 2;
          break;
        case 'HARD':
          notes.add(NoteData(timeMs: sourceNote.timeMs, lane: sourceNote.lane));
          selectedIndex += 1;
          break;
        default:
          notes.add(NoteData(timeMs: sourceNote.timeMs, lane: sourceNote.lane));
          selectedIndex += 1;
          break;
      }
    }

    return StageModel(
      stageNumber: song.stageNumber,
      title: song.name,
      artist: song.artist!,
      bpm: song.bpm!,
      difficulty: diffKey,
      difficultyLevel: level,
      audioPath: song.audioPath!,
      notes: notes,
      rank: 'S',
      rewardCoins: (song.baseRewardCoins! * rewardMul).round(),
    );
  }

  static StageModel _generateOriginal(int stageNum, String diffKey, int level, double rewardMul, ShopItem song) {
    final targetNotes = (playSpecs[diffKey]!['notes']! + stageNum * 5).toInt();
    final random = Random(42 + stageNum * 10 + level);
    final notes = <NoteData>[];
    double timeMs = 1000.0;

    for (int i = 0; i < targetNotes; i++) {
      final lane = random.nextInt(4);
      notes.add(NoteData(timeMs: timeMs.round(), lane: lane));
      final beatMs = 60000 / song.bpm!;
      timeMs += beatMs / 2;
    }

    return StageModel(
      stageNumber: song.stageNumber,
      title: song.name,
      artist: song.artist!,
      bpm: song.bpm!,
      difficulty: diffKey,
      difficultyLevel: level,
      audioPath: song.audioPath!,
      notes: notes,
      rank: 'S',
      rewardCoins: (song.baseRewardCoins! * rewardMul).round(),
    );
  }

  static StageModel getStage(int id, {String difficulty = 'NORMAL'}) =>
      generateStage(id, difficulty: difficulty);
}

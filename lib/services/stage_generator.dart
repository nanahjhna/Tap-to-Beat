import 'dart:math';
import '../models/stage_model.dart';
import '../data/song_registry.dart'; // SongRegistry와 SongData가 정의된 파일

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

  static StageModel generateStage(int stageNum, {String difficulty = 'NORMAL'}) {
    final song = SongRegistry.allSongs.firstWhere(
          (s) => s.id == stageNum,
      orElse: () => SongRegistry.allSongs.first,
    );

    final diffKey = normalizeDifficulty(difficulty);
    final spec = difficultySpecs[diffKey]!;
    final level = spec['level']!.toInt();
    final rewardMul = spec['rewardMul']!;

    final random = Random(42 + stageNum * 10 + level);
    final targetNotes = (playSpecs[diffKey]!['notes']! + stageNum * 5).toInt();
    final notes = <NoteData>[];
    double timeMs = 1000.0;

    for (int i = 0; i < targetNotes; i++) {
      final lane = random.nextInt(4);
      notes.add(NoteData(timeMs: timeMs.round(), lane: lane));
      final beatMs = 60000 / song.bpm;

      switch (diffKey) {
        case 'EASY':
          timeMs += (i % 2 == 0) ? beatMs : beatMs / 2;
          break;
        case 'HARD':
          timeMs += (i % 4 == 0) ? beatMs / 2 : beatMs / 4;
          break;
        default:
          timeMs += (i % 4 == 0) ? beatMs / 1.5 : beatMs / 3;
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

  static StageModel getStage(int id, {String difficulty = 'NORMAL'}) =>
      generateStage(id, difficulty: difficulty);
}
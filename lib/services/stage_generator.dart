import 'dart:math';
import '../models/stage_model.dart';

class StageGenerator {
  static final List<StageModel> allStages = [
    StageModel(
      stageNumber: 1,
      title: 'Mikoshi Mayhem',
      artist: 'Matsuri Sound Team',
      bpm: 140,
      difficulty: 'NORMAL',
      difficultyLevel: 4,
      audioPath: 'sounds/basicmusic/MikoshiMayhem.mp3',
      rank: 'S',
      rewardCoins: 200,
      notes: [
        NoteData(timeMs: 1000, lane: 0),
        NoteData(timeMs: 1428, lane: 1),
        NoteData(timeMs: 1856, lane: 2),
        NoteData(timeMs: 2284, lane: 3),
      ],
    ),
  ];

  // 곡별 난이도 선택용 스펙: 레벨 / 보상 배율
  static const Map<String, Map<String, double>> difficultySpecs = {
    'EASY': {'level': 2, 'rewardMul': 1.0},
    'NORMAL': {'level': 4, 'rewardMul': 1.5},
    'HARD': {'level': 6, 'rewardMul': 2.0},
  };

  // 난이도별 플레이 체감 스펙 (입문용 EASY → 넉넉하게)
  // notes: 목표 노트 수 / perfectMs·goodMs·badMs: 판정폭
  // missGraceMs: 놓침 유예 / fallMs: 낙하 시간(클수록 느림)
  // missDmg·badDmg: 라이프 감소 / healPerfect·healGood: 라이프 회복
  static const Map<String, Map<String, double>> playSpecs = {
    'EASY': {
      'notes': 60,
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
      'notes': 110,
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
      'notes': 170,
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

  static StageModel generateStage(int stageNum, {String difficulty = 'NORMAL'}) {
    final base = allStages.firstWhere(
      (stage) => stage.stageNumber == stageNum,
      orElse: () => allStages.first,
    );

    final diffKey = normalizeDifficulty(difficulty);
    final spec = difficultySpecs[diffKey]!;
    final level = spec['level']!.toInt();
    final rewardMul = spec['rewardMul']!;

    final random = Random(42 + stageNum * 10 + level);
    final targetNotes =
        (playSpecs[diffKey]!['notes']! + stageNum * 5).toInt();
    final notes = <NoteData>[];
    double timeMs = 1000.0;
    for (int i = 0; i < targetNotes; i++) {
      final lane = random.nextInt(4);
      notes.add(NoteData(timeMs: timeMs.round(), lane: lane));
      final beatMs = 60000 / base.bpm;
      // EASY는 성기게·느리게, HARD는 빽빽하게
      switch (diffKey) {
        case 'EASY':
          timeMs += (i % 2 == 0) ? beatMs : beatMs / 2;
          break;
        case 'HARD':
          timeMs += (i % 4 == 0) ? beatMs / 2 : beatMs / 4;
          break;
        default: // NORMAL
          timeMs += (i % 4 == 0) ? beatMs / 1.5 : beatMs / 3;
          break;
      }
    }

    return StageModel(
      stageNumber: base.stageNumber,
      title: base.title,
      artist: base.artist,
      bpm: base.bpm,
      difficulty: diffKey,
      difficultyLevel: level,
      audioPath: base.audioPath,
      notes: notes,
      rank: base.rank,
      rewardCoins: (base.rewardCoins * rewardMul).round(),
    );
  }

  static StageModel getStage(int id, {String difficulty = 'NORMAL'}) =>
      generateStage(id, difficulty: difficulty);
}
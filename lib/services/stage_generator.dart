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
      difficultyLevel: 3,
      audioPath: 'sounds/Mikoshi_Mayhem.mp3',
      jacketAsset: 'assets/images/jacket_mikoshi.png',
      isUnlocked: true,
      rank: 'S',
      rewardCoins: 200,
      notes: [
        NoteData(timeMs: 1000, lane: 0),
        NoteData(timeMs: 1428, lane: 1),
        NoteData(timeMs: 1856, lane: 2),
        NoteData(timeMs: 2284, lane: 3),
      ],
    ),
    StageModel(
      stageNumber: 2,
      title: 'Neon Cyberpunk',
      artist: 'Bit Runner',
      bpm: 155,
      difficulty: 'HARD',
      difficultyLevel: 6,
      audioPath: 'sounds/Mikoshi_Mayhem.mp3',
      jacketAsset: 'assets/images/jacket_neon.png',
      isUnlocked: true,
      rank: '-',
      rewardCoins: 350,
      notes: [
        NoteData(timeMs: 800, lane: 3),
        NoteData(timeMs: 1200, lane: 0),
      ],
    ),
  ];

  static StageModel generateStage(int stageNum, int userMaxStage) {
    final base = allStages.firstWhere(
      (stage) => stage.stageNumber == stageNum,
      orElse: () => allStages.first,
    );

    final random = Random(42 + stageNum);
    final targetNotes = 60 + (base.difficultyLevel * 20) + (stageNum * 10);
    final notes = <NoteData>[];
    double timeMs = 1000.0;
    for (int i = 0; i < targetNotes; i++) {
      final lane = random.nextInt(4);
      notes.add(NoteData(timeMs: timeMs.round(), lane: lane));
      final beatMs = 60000 / base.bpm;
      timeMs += (i % 4 == 0) ? beatMs / 2 : beatMs / 4;
    }

    return StageModel(
      stageNumber: base.stageNumber,
      title: base.title,
      artist: base.artist,
      bpm: base.bpm,
      difficulty: base.difficulty,
      difficultyLevel: base.difficultyLevel,
      audioPath: base.audioPath,
      jacketAsset: base.jacketAsset,
      notes: notes,
      isUnlocked: base.isUnlocked,
      rank: base.rank,
      rewardCoins: base.rewardCoins,
    );
  }

  static StageModel getStage(int id) => generateStage(id, id);
}
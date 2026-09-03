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
      audioPath: 'assets/audio/Mikoshi_Mayhem.mp3',
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
      audioPath: 'assets/audio/neon_cyberpunk.mp3',
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
    return allStages.firstWhere(
          (stage) => stage.stageNumber == stageNum,
      orElse: () => allStages.first,
    );
  }

  static StageModel getStage(int id) => generateStage(id, id);
}
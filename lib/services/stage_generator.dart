import '../models/stage_model.dart';

class StageGenerator {
  static final List<Map<String, dynamic>> _trackCatalog = [
    {
      'title': 'Mikoshi Mayhem',
      'artist': 'Matsuri Sound Team',
      'bpm': 140,
      'difficulty': 'NORMAL',
      'difficultyLevel': 3,
      'audioPath': 'sounds/Mikoshi_Mayhem.mp3',
      'noteCount': 80,
    },
    {
      'title': 'Cyber Neon Pulse',
      'artist': 'DJ Electro Wave',
      'bpm': 150,
      'difficulty': 'HARD',
      'difficultyLevel': 5,
      'audioPath': 'sounds/Mikoshi_Mayhem.mp3',
      'noteCount': 100,
    },
    {
      'title': 'Tokyo Midnight Rush',
      'artist': 'Synth Samurai',
      'bpm': 160,
      'difficulty': 'EXPERT',
      'difficultyLevel': 7,
      'audioPath': 'sounds/Mikoshi_Mayhem.mp3',
      'noteCount': 120,
    },
    {
      'title': 'Sakura Beat Fantasy',
      'artist': 'Miko Harmonic',
      'bpm': 135,
      'difficulty': 'EASY',
      'difficultyLevel': 2,
      'audioPath': 'sounds/Mikoshi_Mayhem.mp3',
      'noteCount': 60,
    },
    {
      'title': 'Bass Cannon Overdrive',
      'artist': 'Subwoofer Junkies',
      'bpm': 175,
      'difficulty': 'MASTER',
      'difficultyLevel': 9,
      'audioPath': 'sounds/Mikoshi_Mayhem.mp3',
      'noteCount': 150,
    },
  ];

  static StageModel generateStage(int stageNum, int currentMaxStage) {
    final catalogIdx = (stageNum - 1) % _trackCatalog.length;
    final info = _trackCatalog[catalogIdx];
    final loopCount = (stageNum - 1) ~/ _trackCatalog.length;

    final title = loopCount == 0 ? info['title'] as String : '${info['title']} Remix v${loopCount + 1}';
    final bpm = (info['bpm'] as int) + (loopCount * 5);
    final diffLevel = (info['difficultyLevel'] as int) + (loopCount * 2);
    final noteCount = (info['noteCount'] as int) + (loopCount * 20);
    final reward = 100 + (stageNum * 50);
    final unlocked = stageNum <= currentMaxStage + 1;

    return StageModel(
      stageNumber: stageNum,
      title: title,
      artist: info['artist'] as String,
      bpm: bpm,
      difficulty: info['difficulty'] as String,
      difficultyLevel: diffLevel,
      audioPath: info['audioPath'] as String,
      noteCount: noteCount,
      rewardCoins: reward,
      isUnlocked: unlocked,
      highScore: unlocked ? (stageNum == 1 ? 24000 : 0) : 0,
      rank: unlocked ? (stageNum == 1 ? 'S' : '-') : '-',
    );
  }
}
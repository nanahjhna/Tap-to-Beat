class StageModel {
  final int stageNumber;
  final String title;
  final String artist;
  final int bpm;
  final String difficulty;
  final int difficultyLevel;
  final String audioPath;
  final int noteCount;
  final int rewardCoins;
  final bool isUnlocked;
  final int highScore;
  final String rank;

  StageModel({
    required this.stageNumber,
    required this.title,
    required this.artist,
    required this.bpm,
    required this.difficulty,
    required this.difficultyLevel,
    required this.audioPath,
    required this.noteCount,
    required this.rewardCoins,
    required this.isUnlocked,
    this.highScore = 0,
    this.rank = '-',
  });

  // 이전 코드와의 하위 호환성을 위한 게터들
  String get bossName => title;
  String get imagePath => 'assets/images/album_cover.png';
  int get recommendedPower => bpm;
}
class NoteData {
  final int timeMs;
  final int lane;
  NoteData({required this.timeMs, required this.lane});
}

class StageModel {
  final int stageNumber;
  final String title;
  final String artist;
  final int bpm;
  final String difficulty;
  final int difficultyLevel;
  final String audioPath;
  final String jacketAsset;
  final List<NoteData> notes;

  // Extra UI states
  final bool isUnlocked;
  final String rank;
  final int rewardCoins;

  StageModel({
    required this.stageNumber,
    required this.title,
    required this.artist,
    required this.bpm,
    required this.difficulty,
    required this.difficultyLevel,
    required this.audioPath,
    required this.jacketAsset,
    required this.notes,
    this.isUnlocked = true,
    this.rank = '-',
    this.rewardCoins = 150,
  });

  int get id => stageNumber;
  int get noteCount => notes.length;
}
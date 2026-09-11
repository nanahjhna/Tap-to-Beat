import '../models/stage_model.dart';

class SongData {
  final int id;
  final String title;
  final String artist;
  final int bpm;
  final String audioPath;
  final String? chartPath;
  final int baseRewardCoins;
  final List<NoteData> baseNotes;

  const SongData({
    required this.id,
    required this.title,
    required this.artist,
    required this.bpm,
    required this.audioPath,
    required this.baseRewardCoins,
    this.chartPath,
    required this.baseNotes,
  });
}

class SongRegistry {
  static final List<SongData> allSongs = [
    SongData(
      id: 1,
      title: 'Mikoshi Mayhem',
      artist: 'Matsuri Sound Team',
      bpm: 140,
      audioPath: 'sounds/basicmusic/MikoshiMayhem.mp3',
      chartPath: 'assets/charts/basicmusic/MikoshiMayhem.json',
      baseRewardCoins: 200,
      baseNotes: [
        NoteData(timeMs: 1000, lane: 0),
        NoteData(timeMs: 1428, lane: 1),
        NoteData(timeMs: 1856, lane: 2),
        NoteData(timeMs: 2284, lane: 3),
      ],
    ),
    SongData(
      id: 2,
      title: 'Twilight Highway',
      artist: 'Matsuri Sound Team',
      bpm: 140,
      audioPath: 'sounds/shopmusic/TwilightHighway.mp3',
      chartPath: 'assets/charts/shopmusic/TwilightHighway.json',
      baseRewardCoins: 200,
      baseNotes: [
        NoteData(timeMs: 1000, lane: 0),
        NoteData(timeMs: 1428, lane: 1),
        NoteData(timeMs: 1856, lane: 2),
        NoteData(timeMs: 2284, lane: 3),
      ],
    ),
  ];
}
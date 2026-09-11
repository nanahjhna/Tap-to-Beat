import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../models/stage_model.dart';

class RhythmNoteComponent extends RectangleComponent {
  final int track;
  final double targetTimeMs;
  bool isHit = false;
  bool isMissed = false;

  RhythmNoteComponent({
    required this.track,
    required this.targetTimeMs,
    required Color color,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position, paint: Paint()..color = color);
}

class RhythmGameWorld extends FlameGame {
  final StageModel stageData;
  final double fallDurationMs;
  final double Function() getEffectiveMs;

  late double boardWidth;
  late double boardHeight;
  late double judgeLineY;

  final List<RhythmNoteComponent> noteComponents = [];
  Color noteColor;

  Color judgeLineColor = const Color(0xFFFFFA65);
  DateTime? _flashRedUntil;

  RhythmGameWorld({
    required this.stageData,
    required this.fallDurationMs,
    required this.getEffectiveMs,
    required this.noteColor,
  });

  void flashRed(Duration duration) {
    _flashRedUntil = DateTime.now().add(duration);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    boardWidth = size.x;
    boardHeight = size.y;
    judgeLineY = boardHeight - 80.0;

    final trackWidth = boardWidth / 4.0;

    int id = 0;
    for (final n in stageData.notes) {
      final noteComp = RhythmNoteComponent(
        track: n.lane,
        targetTimeMs: n.timeMs.toDouble(),
        color: noteColor,
        size: Vector2(trackWidth - 8, 18),
        position: Vector2(n.lane * trackWidth + 4, -999),
      );
      noteComponents.add(noteComp);
      add(noteComp);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final currentMs = getEffectiveMs();
    final trackWidth = boardWidth / 4.0;

    if (_flashRedUntil != null && DateTime.now().isAfter(_flashRedUntil!)) {
      _flashRedUntil = null;
    }

    bool hasNoteAtJudgeLine = false;
    bool hasMissedNote = false;

    for (final note in noteComponents) {
      if (note.isMissed) {
        hasMissedNote = true;
      }
      if (note.isHit || note.isMissed) {
        note.position.y = -999;
        continue;
      }

      final diff = (currentMs - note.targetTimeMs).abs();
      if (diff < 200) {
        hasNoteAtJudgeLine = true;
      }

      final noteStartTime = note.targetTimeMs - fallDurationMs;
      final progress = (currentMs - noteStartTime) / fallDurationMs;

      if (progress < -0.2 || progress > 1.3) {
        note.position.y = -999;
      } else {
        final currentY = progress * judgeLineY;
        note.position.y = currentY;
      }
    }

    if (_flashRedUntil != null) {
      judgeLineColor = const Color(0xFFFF4757);
    } else if (hasNoteAtJudgeLine) {
      judgeLineColor = const Color(0xFF2ED573);
    } else if (hasMissedNote) {
      judgeLineColor = const Color(0xFFFF4757);
    } else {
      judgeLineColor = const Color(0xFFFFFA65);
    }
  }

  void updateNoteColor(Color newColor) {
    noteColor = newColor;
    for (final note in noteComponents) {
      note.paint.color = newColor;
    }
  }
}

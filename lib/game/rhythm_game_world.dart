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

  RhythmGameWorld({
    required this.stageData,
    required this.fallDurationMs,
    required this.getEffectiveMs,
    required this.noteColor,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
    boardWidth = size.x;
    boardHeight = size.y;
    judgeLineY = boardHeight - 80.0;

    final trackWidth = boardWidth / 4.0;

    // 노트 컴포넌트 생성 및 추가
    int id = 0;
    for (final n in stageData.notes) {
      final noteComp = RhythmNoteComponent(
        track: n.lane,
        targetTimeMs: n.timeMs.toDouble(),
        color: noteColor,
        size: Vector2(trackWidth - 8, 18),
        position: Vector2(n.lane * trackWidth + 4, -999), // 초기 위치 대기
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

    for (final note in noteComponents) {
      if (note.isHit || note.isMissed) {
        note.position.y = -999; // 화면 밖으로 이동
        continue;
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
  }

  void updateNoteColor(Color newColor) {
    noteColor = newColor;
    for (final note in noteComponents) {
      note.paint.color = newColor;
    }
  }
}
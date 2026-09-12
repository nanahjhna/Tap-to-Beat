import 'dart:math';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../models/stage_model.dart';

class RhythmNoteComponent extends PositionComponent {
  final int track;
  final double targetTimeMs;
  bool isHit = false;
  bool isMissed = false;

  Color _color;

  RectangleComponent? _glowRect;
  RectangleComponent? _coreRect;
  RectangleComponent? _edgeRect;

  RhythmNoteComponent({
    required this.track,
    required this.targetTimeMs,
    required Color color,
    required Vector2 size,
    required Vector2 position,
  })  : _color = color,
        super(size: size, position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _glowRect = RectangleComponent(
      size: Vector2(size.x + 6, size.y + 6),
      position: Vector2(-3, -3),
      paint: Paint()
        ..color = _color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    _coreRect = RectangleComponent(
      size: size,
      paint: Paint()..color = _color,
    );
    _edgeRect = RectangleComponent(
      size: Vector2(size.x, size.y),
      paint: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.65),
    );
    add(_glowRect!);
    add(_coreRect!);
    add(_edgeRect!);
  }

  void setColor(Color newColor) {
    _color = newColor;
    _glowRect?.paint.color = newColor.withValues(alpha: 0.35);
    _coreRect?.paint.color = newColor;
  }
}

class NoteTrailComponent extends PositionComponent {
  double life;
  final double maxLife;
  final Color color;

  late final Paint _paint;

  NoteTrailComponent({
    required this.life,
    required this.maxLife,
    required this.color,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size) {
    _paint = Paint()..color = color.withValues(alpha: 0.4);
  }

  @override
  void update(double dt) {
    life -= dt;
    if (life <= 0) {
      removeFromParent();
      return;
    }
    final fraction = (life / maxLife).clamp(0.0, 1.0);
    _paint.color = color.withValues(alpha: 0.4 * fraction);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect, _paint);
  }
}

class NoteHitParticle extends PositionComponent {
  final Vector2 velocity;
  final Color color;
  final double radius;

  double life;
  final double maxLife;

  NoteHitParticle({
    required this.velocity,
    required this.color,
    required this.radius,
    required this.life,
    required this.maxLife,
    required Vector2 position,
  }) : super(position: position);

  @override
  void update(double dt) {
    position.add(velocity * dt);
    life -= dt;
    if (life <= 0) {
      removeFromParent();
      return;
    }
  }

  @override
  void render(Canvas canvas) {
    final alpha = (life / maxLife).clamp(0.0, 1.0);
    final glowPaint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset.zero, radius * (0.5 + 0.5 * alpha), glowPaint);
    canvas.drawCircle(
      Offset.zero,
      radius * 0.45,
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.9 * alpha),
    );
  }
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

  Color judgeLineColor = const Color(0xFFFFFFFF);
  Color? _flashColor;
  DateTime? _flashColorUntil;

  double _trailAccumulator = 0;

  RhythmGameWorld({
    required this.stageData,
    required this.fallDurationMs,
    required this.getEffectiveMs,
    required this.noteColor,
  });

  void flashJudgeLine(Color color, Duration duration) {
    _flashColor = color;
    _flashColorUntil = DateTime.now().add(duration);
  }

  void spawnHitParticles(Vector2 position, {Color? color}) {
    final random = Random();
    final particleColor = color ?? noteColor;
    for (int i = 0; i < 8; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 140 + random.nextDouble() * 200;
      final life = 0.3 + random.nextDouble() * 0.25;
      add(NoteHitParticle(
        velocity: Vector2(cos(angle), sin(angle)) * speed,
        color: particleColor,
        radius: 3 + random.nextDouble() * 3,
        life: life,
        maxLife: life,
        position: position.clone(),
      ));
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    boardWidth = size.x;
    boardHeight = size.y;
    judgeLineY = boardHeight - 80.0;

    final trackWidth = boardWidth / 4.0;

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

    if (_flashColorUntil != null && DateTime.now().isAfter(_flashColorUntil!)) {
      _flashColor = null;
      _flashColorUntil = null;
    }

    _spawnTrails(dt, trackWidth);
    _updateNotes(currentMs);

    if (_flashColor != null && _flashColorUntil != null) {
      judgeLineColor = _flashColor!;
    } else {
      judgeLineColor = const Color(0xFFFFFFFF);
    }
  }

  void _updateNotes(double currentMs) {
    for (final note in noteComponents) {
      if (note.isHit || note.isMissed) {
        note.position.y = -999;
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

  void _spawnTrails(double dt, double trackWidth) {
    _trailAccumulator += dt;
    if (_trailAccumulator < 0.05) return;
    _trailAccumulator = 0;

    for (final note in noteComponents) {
      if (note.isHit || note.isMissed || note.position.y < -100) continue;
      add(NoteTrailComponent(
        life: 0.25,
        maxLife: 0.25,
        position: Vector2(note.position.x, note.position.y),
        size: Vector2(trackWidth - 8, 13),
        color: noteColor,
      ));
    }
  }

  void updateNoteColor(Color newColor) {
    noteColor = newColor;
    for (final note in noteComponents) {
      note.setColor(newColor);
    }
  }
}
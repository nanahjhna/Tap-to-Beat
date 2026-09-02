import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'pause_overlay.dart';
import '../services/stage_generator.dart';
import '../models/stage_model.dart';
import '../utils/app_texts.dart';

class RhythmNote {
  final int id;
  final int track; // 0..3 (D, F, J, K)
  final double targetTimeMs;
  bool isHit = false;
  bool isMissed = false;

  RhythmNote({
    required this.id,
    required this.track,
    required this.targetTimeMs,
  });
}

class GamePlayView extends StatefulWidget {
  const GamePlayView({super.key});

  @override
  State<GamePlayView> createState() => _GamePlayViewState();
}

class _GamePlayViewState extends State<GamePlayView>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  late final Stopwatch _stopwatch;
  late final Ticker _ticker;

  final List<RhythmNote> _notes = [];
  final List<bool> _keyActive = [false, false, false, false];

  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  double _life = 100.0;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _gameEnded = false;

  int _countPerfect = 0;
  int _countGood = 0;
  int _countBad = 0;
  int _countMiss = 0;

  String _currentJudge = '';
  Color _judgeColor = Colors.white;
  Timer? _judgeClearTimer;

  static const double _fallDurationMs = 1500.0;
  static const List<LogicalKeyboardKey> _keyCodes = [
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.keyF,
    LogicalKeyboardKey.keyJ,
    LogicalKeyboardKey.keyK,
  ];
  static const List<String> _keyLabels = ['D', 'F', 'J', 'K'];

  StageModel? _stageData;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _stopwatch = Stopwatch();
    _ticker = createTicker(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stageData == null) {
      final stageNum = ModalRoute.of(context)?.settings.arguments as int? ?? 1;
      _stageData = StageGenerator.generateStage(stageNum, stageNum);
      _initGame();
    }
  }

  void _initGame() {
    _notes.clear();
    final totalNotes = _stageData?.noteCount ?? 80;
    final random = Random(42 + (_stageData?.stageNumber ?? 1));

    double currentTime = 1500.0;
    for (int i = 0; i < totalNotes; i++) {
      final trackIdx = random.nextInt(4);
      _notes.add(RhythmNote(
        id: i,
        track: trackIdx,
        targetTimeMs: currentTime,
      ));
      final interval = (i % 4 == 0) ? 500.0 : 250.0;
      currentTime += interval;
    }

    _startGame();
  }

  Future<void> _startGame() async {
    _score = 0;
    _combo = 0;
    _maxCombo = 0;
    _life = 100.0;
    _countPerfect = 0;
    _countGood = 0;
    _countBad = 0;
    _countMiss = 0;
    _isPlaying = true;
    _isPaused = false;
    _gameEnded = false;

    try {
      final soundPath = _stageData?.audioPath ?? 'sounds/Mikoshi_Mayhem.mp3';
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      debugPrint('Audio playback error (fallback to internal timer): $e');
    }

    _stopwatch.reset();
    _stopwatch.start();
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (!_isPlaying || _isPaused || _gameEnded) return;

    final currentMs = _stopwatch.elapsedMilliseconds.toDouble();

    // 판정선 지나침 (Miss) 검사
    for (final note in _notes) {
      if (!note.isHit && !note.isMissed) {
        if (currentMs > note.targetTimeMs + 180.0) {
          note.isMissed = true;
          _handleMiss(isBad: false);
        }
      }
    }

    // 게임 종료 검사 (라이프 0 또는 곡 완료)
    final allProcessed = _notes.every((n) => n.isHit || n.isMissed);
    final isFinished = allProcessed &&
        (currentMs > (_notes.isNotEmpty ? _notes.last.targetTimeMs + 1500 : 3000));

    if (_life <= 0 || isFinished) {
      _finishGame(_life > 0);
      return;
    }

    setState(() {});
  }

  void _handleKeyPress(int trackIdx) {
    if (!_isPlaying || _isPaused || _gameEnded) return;

    setState(() {
      _keyActive[trackIdx] = true;
    });

    _judgeTrack(trackIdx);
  }

  void _handleKeyRelease(int trackIdx) {
    if (mounted) {
      setState(() {
        _keyActive[trackIdx] = false;
      });
    }
  }

  void _judgeTrack(int trackIdx) {
    final currentMs = _stopwatch.elapsedMilliseconds.toDouble();

    RhythmNote? targetNote;
    double minDiff = double.infinity;

    for (final note in _notes) {
      if (note.track == trackIdx && !note.isHit && !note.isMissed) {
        final diff = (currentMs - note.targetTimeMs).abs();
        if (diff < minDiff) {
          minDiff = diff;
          targetNote = note;
        }
      }
    }

    // 판정 범위: 200ms 이내
    if (targetNote != null && minDiff <= 200.0) {
      targetNote.isHit = true;

      if (minDiff <= 65.0) {
        _showJudgment('PERFECT', const Color(0xFF2ED573));
        _score += 300;
        _life = (_life + 3.0).clamp(0.0, 100.0);
        _countPerfect++;
        _addCombo();
      } else if (minDiff <= 125.0) {
        _showJudgment('GOOD', const Color(0xFF1E90FF));
        _score += 100;
        _life = (_life + 1.0).clamp(0.0, 100.0);
        _countGood++;
        _addCombo();
      } else {
        _showJudgment('BAD', const Color(0xFFFFA502));
        _score += 50;
        _countBad++;
        _handleMiss(isBad: true);
      }
      setState(() {});
    }
  }

  void _addCombo() {
    _combo++;
    if (_combo > _maxCombo) {
      _maxCombo = _combo;
    }
  }

  void _handleMiss({bool isBad = false}) {
    _combo = 0;
    if (!isBad) {
      _countMiss++;
      _showJudgment('MISS', const Color(0xFFFF4757));
      _life = (_life - 7.0).clamp(0.0, 100.0);
    } else {
      _life = (_life - 3.0).clamp(0.0, 100.0);
    }
    setState(() {});
  }

  void _showJudgment(String text, Color color) {
    _currentJudge = text;
    _judgeColor = color;
    _judgeClearTimer?.cancel();
    _judgeClearTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted && _currentJudge == text) {
        setState(() {
          _currentJudge = '';
        });
      }
    });
  }

  void _finishGame(bool victory) {
    if (_gameEnded) return;
    _gameEnded = true;
    _isPlaying = false;
    _ticker.stop();
    _stopwatch.stop();
    _audioPlayer.stop();

    Navigator.pushReplacementNamed(
      context,
      '/result',
      arguments: {
        'victory': victory,
        'stage': _stageData?.stageNumber ?? 1,
        'score': _score,
        'maxCombo': _maxCombo,
        'perfect': _countPerfect,
        'good': _countGood,
        'bad': _countBad,
        'miss': _countMiss,
        'totalNotes': _notes.length,
        'songTitle': _stageData?.title ?? 'Mikoshi Mayhem',
        'songArtist': _stageData?.artist ?? 'Matsuri Beats',
      },
    );
  }

  void _pauseGame() {
    if (_isPaused || !_isPlaying) return;
    setState(() => _isPaused = true);
    _ticker.stop();
    _stopwatch.stop();
    _audioPlayer.pause();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PauseOverlay(
        onPause: () {},
        onResume: _resumeGame,
      ),
    );
  }

  void _resumeGame() {
    if (!_isPaused || _gameEnded) return;
    setState(() => _isPaused = false);
    _audioPlayer.resume();
    _stopwatch.start();
    _ticker.start();
  }

  @override
  void dispose() {
    _judgeClearTimer?.cancel();
    _ticker.dispose();
    _stopwatch.stop();
    _audioPlayer.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (event) {
            for (int i = 0; i < _keyCodes.length; i++) {
              if (event.logicalKey == _keyCodes[i]) {
                if (event is KeyDownEvent) {
                  if (!_keyActive[i]) _handleKeyPress(i);
                } else if (event is KeyUpEvent) {
                  _handleKeyRelease(i);
                }
              }
            }
          },
          child: Column(
            children: [
              _buildTopUI(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final boardHeight = constraints.maxHeight;
                    const judgeLineFromBottom = 80.0;
                    final judgeLineY = boardHeight - judgeLineFromBottom;
                    final currentMs = _stopwatch.elapsedMilliseconds.toDouble();

                    return Stack(
                      children: [
                        // 4 레인 배경 및 탭 감지
                        Positioned.fill(
                          child: Row(
                            children: List.generate(4, (index) {
                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: (_) => _handleKeyPress(index),
                                  onTapUp: (_) => _handleKeyRelease(index),
                                  onTapCancel: () => _handleKeyRelease(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _keyActive[index]
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : (index % 2 == 0
                                              ? const Color(0xFF14141E)
                                              : const Color(0xFF1A1A26)),
                                      border: Border(
                                        right: BorderSide(
                                          color: index < 3
                                              ? Colors.white12
                                              : Colors.transparent,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        // 판정선 가이드 글로우 존
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 40,
                          height: 80,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    const Color(0xFFFFFA65).withValues(alpha: 0.15),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 판정선 (Judge Line)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: judgeLineFromBottom,
                          child: IgnorePointer(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFA65),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFFA65).withValues(alpha: 0.8),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFFF5252).withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 떨어지는 노트 렌더링
                        ..._buildVisibleNotes(
                          constraints.maxWidth,
                          judgeLineY,
                          currentMs,
                        ),

                        // 판정 및 콤보 이펙트 표시 영역
                        Positioned(
                          top: boardHeight * 0.32,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_currentJudge.isNotEmpty)
                                  AnimatedScale(
                                    scale: 1.1,
                                    duration: const Duration(milliseconds: 100),
                                    child: Text(
                                      _currentJudge,
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: _judgeColor,
                                        letterSpacing: 2,
                                        shadows: [
                                          Shadow(
                                            color: _judgeColor.withValues(alpha: 0.8),
                                            blurRadius: 16,
                                          ),
                                          const Shadow(
                                            color: Colors.black,
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                if (_combo > 1)
                                  Text(
                                    '$_combo COMBO',
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFFFA502),
                                      letterSpacing: 1.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          blurRadius: 10,
                                        ),
                                        Shadow(
                                          color: Color(0xFFFF8B00),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // 하단 4버튼 키 가이드 (D, F, J, K)
              _buildKeyGuide(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopUI() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        border: const Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stageData?.title ?? 'Mikoshi Mayhem',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD166),
                    ),
                  ),
                  Text(
                    '${AppTexts.get('score')}: $_score',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${AppTexts.get('maxCombo')}: $_maxCombo',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.pause_circle_filled,
                        color: Colors.white, size: 28),
                    onPressed: _pauseGame,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 라이프 게이지 바
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: double.infinity,
              height: 10,
              color: const Color(0xFF333333),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (_life / 100.0).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _life > 30
                          ? [const Color(0xFFFF4757), const Color(0xFFFF6B81)]
                          : [Colors.redAccent, Colors.deepOrange],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildVisibleNotes(
    double boardWidth,
    double judgeLineY,
    double currentMs,
  ) {
    final trackWidth = boardWidth / 4.0;
    final widgets = <Widget>[];

    for (final note in _notes) {
      if (note.isHit || note.isMissed) continue;

      final noteStartTime = note.targetTimeMs - _fallDurationMs;
      final progress = (currentMs - noteStartTime) / _fallDurationMs;

      // 아직 화면 밖이거나 이미 판정선을 훌쩍 넘긴 경우 생략
      if (progress < -0.2 || progress > 1.3) continue;

      final currentY = progress * judgeLineY;
      final x = note.track * trackWidth;

      widgets.add(
        Positioned(
          top: currentY,
          left: x + 4,
          width: trackWidth - 8,
          height: 18,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2ED573),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2ED573).withValues(alpha: 0.7),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildKeyGuide() {
    return Container(
      height: 76,
      color: Colors.black,
      child: Row(
        children: List.generate(4, (index) {
          final isActive = _keyActive[index];
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _handleKeyPress(index),
              onTapUp: (_) => _handleKeyRelease(index),
              onTapCancel: () => _handleKeyRelease(index),
              child: Container(
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.28)
                      : Colors.transparent,
                  border: Border(
                    top: BorderSide(
                      color: isActive
                          ? const Color(0xFFFFFA65)
                          : const Color(0xFF444444),
                      width: 2.5,
                    ),
                    right: BorderSide(
                      color: index < 3
                          ? const Color(0xFF333333)
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    _keyLabels[index],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : const Color(0xFF888888),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

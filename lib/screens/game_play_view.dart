import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'pause_overlay.dart';
import '../services/stage_generator.dart';
import '../models/stage_model.dart';
import '../models/effect_model.dart';
import '../providers/user_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_texts.dart';
import '../game/rhythm_game_world.dart';

class GamePlayView extends StatefulWidget {
  const GamePlayView({super.key});

  @override
  State<GamePlayView> createState() => _GamePlayViewState();
}

class _GamePlayViewState extends State<GamePlayView> with WidgetsBindingObserver, TickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  late final Stopwatch _stopwatch;
  late final AnimationController _judgeAnimController;
  late final Animation<double> _judgeScaleAnim;
  late final Animation<double> _judgeFadeAnim;
  late final AnimationController _laneFlashController;
  late final AnimationController _bgPulseController;
  late final AnimationController _comboPopController;
  late final Animation<double> _comboScaleAnim;

  final List<bool> _keyActive = [false, false, false, false];
  int _laneFlashIndex = -1;

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

  static const List<LogicalKeyboardKey> _keyCodes = [
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.keyF,
    LogicalKeyboardKey.keyJ,
    LogicalKeyboardKey.keyK,
  ];

  StageModel? _stageData;
  RhythmGameWorld? _gameWorld;
  final FocusNode _focusNode = FocusNode();

  String get _difficulty => _stageData?.difficulty ?? 'NORMAL';
  double get _fallDurationMs => StageGenerator.playValue(_difficulty, 'fallMs');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _stopwatch = Stopwatch();
    _judgeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _judgeScaleAnim = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(parent: _judgeAnimController, curve: Curves.easeOutBack),
    );
    _judgeFadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _judgeAnimController, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );
    _laneFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _bgPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _comboPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _comboScaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65,
      ),
    ]).animate(_comboPopController);

    // 📌 게임 도중 설정(볼륨 등) 변경 시 실시간 반영을 위한 리스너 등록
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SettingsProvider>().addListener(_onSettingsChanged);
      }
    });
  }

  // 📌 설정 변경 시 실시간 반영 콜백
  void _onSettingsChanged() {
    if (!mounted) return;
    final settingsProvider = context.read<SettingsProvider>();
    _audioPlayer.setVolume(settingsProvider.bgmVolume);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_isPlaying && !_isPaused && !_gameEnded && _stopwatch.isRunning) {
        _pauseGame();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stageData == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      int stageNum = 1;
      String difficulty = 'NORMAL';
      if (args is Map) {
        stageNum = args['stage'] as int? ?? 1;
        difficulty = StageGenerator.normalizeDifficulty(args['difficulty'] as String?);
      } else if (args is int) {
        stageNum = args;
      }
      _stageData = StageGenerator.generateStage(stageNum, difficulty: difficulty);
      _initGameWorld();
      _startGame();
    }
  }

  void _initGameWorld() {
    _gameWorld = RhythmGameWorld(
      stageData: _stageData!,
      fallDurationMs: _fallDurationMs,
      getEffectiveMs: _effectiveMs,
      noteColor: _notesColor(),
    );
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

    final userProvider = context.read<UserProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    if (mounted) {
      await userProvider.setLastPlayedStage(_stageData?.stageNumber ?? 1);
    }

    final soundPath = _stageData?.audioPath ?? 'sounds/MikoshiMayhem.mp3';

    try {
      await _audioPlayer.setVolume(settingsProvider.bgmVolume);

      // 오디오 버퍼링 지연 및 싱크 어긋남 방지를 위해 소스 선적재 후 재생
      await _audioPlayer.setSource(AssetSource(soundPath));
    } catch (e) {
      debugPrint('Audio load error: $e');
    }

    // 1초 대기 (시작 연출)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted || _isPaused || _gameEnded) return;

    try {
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }

    _stopwatch.reset();
    _stopwatch.start();

    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_isPlaying || _isPaused || _gameEnded) {
        if (_gameEnded) timer.cancel();
        return;
      }
      _checkGameTick();
    });
  }

  double _effectiveMs() {
    final offset = context.read<SettingsProvider>().timingOffset;
    return _stopwatch.elapsedMilliseconds.toDouble() - offset;
  }

  void _checkGameTick() {
    if (_gameWorld == null) return;
    final currentMs = _stopwatch.elapsedMilliseconds.toDouble();
    final judgeMs = _effectiveMs();
    final missGraceMs = StageGenerator.playValue(_difficulty, 'missGraceMs');

    for (final note in _gameWorld!.noteComponents) {
      if (!note.isHit && !note.isMissed) {
        if (judgeMs > note.targetTimeMs + missGraceMs) {
          note.isMissed = true;
          _handleMiss(isBad: false);
        }
      }
    }

    final allProcessed = _gameWorld!.noteComponents.every((n) => n.isHit || n.isMissed);
    final isFinished = allProcessed &&
        (currentMs > (_gameWorld!.noteComponents.isNotEmpty ? _gameWorld!.noteComponents.last.targetTimeMs + 1500 : 3000));

    if (_life <= 0 || isFinished) {
      _finishGame(_life > 0);
      return;
    }
    if (mounted) setState(() {});
  }

  Color _notesColor() {
    final userProvider = context.read<UserProvider>();
    const defaultColor = Color(0xFF2ED573);
    for (final skin in ShopData.noteSkins) {
      if (userProvider.isEffectEquipped(skin.id)) return skin.color;
    }
    for (final effect in ShopData.effects) {
      if (userProvider.isEffectEquipped(effect.id)) return effect.color;
    }
    return defaultColor;
  }

  Color _judgeLineColor() => _gameWorld?.judgeLineColor ?? Colors.white;

  void _handleKeyPress(int trackIdx) {
    if (!_isPlaying || _isPaused || _gameEnded) return;

    HapticFeedback.lightImpact();
    setState(() => _keyActive[trackIdx] = true);
    _judgeTrack(trackIdx);
  }

  void _handleKeyRelease(int trackIdx) {
    if (mounted) setState(() => _keyActive[trackIdx] = false);
  }

  void _judgeTrack(int trackIdx) {
    if (_gameWorld == null) return;
    final currentMs = _effectiveMs();

    RhythmNoteComponent? targetNote;
    double minDiff = double.infinity;

    for (final note in _gameWorld!.noteComponents) {
      if (note.track == trackIdx && !note.isHit && !note.isMissed) {
        final diff = (currentMs - note.targetTimeMs).abs();
        if (diff < minDiff) {
          minDiff = diff;
          targetNote = note;
        }
      }
    }

    final perfectMs = StageGenerator.playValue(_difficulty, 'perfectMs');
    final goodMs = StageGenerator.playValue(_difficulty, 'goodMs');
    final badMs = StageGenerator.playValue(_difficulty, 'badMs');
    final healPerfect = StageGenerator.playValue(_difficulty, 'healPerfect');
    final healGood = StageGenerator.playValue(_difficulty, 'healGood');

    if (targetNote != null && minDiff <= badMs) {
      targetNote.isHit = true;
      _gameWorld!.spawnHitParticles(targetNote.position);
      setState(() => _laneFlashIndex = trackIdx);
      _laneFlashController.forward(from: 0);

      if (minDiff <= perfectMs) {
        _showJudgment('PERFECT', const Color(0xFF2ED573));
        _gameWorld!.flashJudgeLine(
          const Color(0xFF2ED573),
          const Duration(milliseconds: 300),
        );
        _bgPulseController.forward(from: 0);
        _score += 300;
        _life = (_life + healPerfect).clamp(0.0, 100.0);
        _countPerfect++;
        _addCombo();
      } else if (minDiff <= goodMs) {
        _showJudgment('GOOD', const Color(0xFF1E90FF));
        _score += 100;
        _life = (_life + healGood).clamp(0.0, 100.0);
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
    if (_combo > _maxCombo) _maxCombo = _combo;
    _comboPopController.forward(from: 0);
  }

  ({double fontSize, Color color, String? label}) _comboStyle() {
    if (_combo >= 100) {
      return (fontSize: 64, color: const Color(0xFFFFD166), label: 'GODLIKE!');
    }
    if (_combo >= 50) {
      return (fontSize: 58, color: const Color(0xFF9B59B6), label: 'UNBELIEVABLE!');
    }
    if (_combo >= 25) {
      return (fontSize: 52, color: const Color(0xFFFF4757), label: 'AMAZING!');
    }
    if (_combo >= 10) {
      return (fontSize: 44, color: const Color(0xFFFF6B81), label: 'AWESOME!');
    }
    return (fontSize: 34, color: const Color(0xFFFFA502), label: null);
  }

  void _handleMiss({bool isBad = false}) {
    _gameWorld?.flashJudgeLine(
      const Color(0xFFFF4757),
      const Duration(milliseconds: 300),
    );
    _combo = 0;
    final missDmg = StageGenerator.playValue(_difficulty, 'missDmg');
    final badDmg = StageGenerator.playValue(_difficulty, 'badDmg');
    if (!isBad) {
      _countMiss++;
      _showJudgment('MISS', const Color(0xFFFF4757));
      _life = (_life - missDmg).clamp(0.0, 100.0);
    } else {
      _life = (_life - badDmg).clamp(0.0, 100.0);
    }
    setState(() {});
  }

  void _showJudgment(String text, Color color) {
    _currentJudge = text;
    _judgeColor = color;
    _judgeClearTimer?.cancel();
    _judgeAnimController
      ..reset()
      ..forward();
    _judgeClearTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted && _currentJudge == text) {
        setState(() => _currentJudge = '');
      }
    });
  }

  void _finishGame(bool victory) {
    if (_gameEnded) return;
    _gameEnded = true;
    _isPlaying = false;
    _stopwatch.stop();
    _audioPlayer.pause();

    Navigator.pushReplacementNamed(
      context,
      '/result',
      arguments: {
        'victory': victory,
        'stage': _stageData?.stageNumber ?? 1,
        'difficulty': _stageData?.difficulty ?? 'NORMAL',
        'score': _score,
        'maxCombo': _maxCombo,
        'perfect': _countPerfect,
        'good': _countGood,
        'bad': _countBad,
        'miss': _countMiss,
        'totalNotes': _gameWorld?.noteComponents.length ?? 0,
        'songTitle': _stageData?.title ?? 'Mikoshi Mayhem',
        'songArtist': _stageData?.artist ?? 'Matsuri Beats',
      },
    );
  }

  void _pauseGame() {
    if (_isPaused || !_isPlaying) return;
    setState(() => _isPaused = true);
    _stopwatch.stop();
    _audioPlayer.pause();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PauseOverlay(
        onResume: () {
          _resumeGame();
        },
        onRetry: () {
          _initGameWorld();
          _startGame();
        },
      ),
    );
  }

  void _resumeGame() {
    if (!_isPaused || _gameEnded) return;
    setState(() => _isPaused = false);
    _audioPlayer.resume();
    _stopwatch.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      context.read<SettingsProvider>().removeListener(_onSettingsChanged);
    } catch (_) {}

    _judgeClearTimer?.cancel();
    _stopwatch.stop();
    _judgeAnimController.dispose();
    _laneFlashController.dispose();
    _bgPulseController.dispose();
    _comboPopController.dispose();
    _audioPlayer.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _pauseGame();
        }
      },
      child: Scaffold(
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
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Row(
                          children: List.generate(4, (index) {
                            final laneColor = index == 0 || index == 2
                                ? const Color(0xFFFF6B81)
                                : const Color(0xFF70A1FF);

                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapDown: (_) => _handleKeyPress(index),
                                onTapUp: (_) => _handleKeyRelease(index),
                                onTapCancel: () => _handleKeyRelease(index),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: _keyActive[index]
                                            ? LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            laneColor.withValues(alpha: 0.7),
                                            laneColor.withValues(alpha: 0.2),
                                          ],
                                        )
                                            : LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            const Color(0xFF1E1E2C).withValues(alpha: 0.8),
                                            const Color(0xFF111118).withValues(alpha: 0.95),
                                          ],
                                        ),
                                        border: Border(
                                          right: BorderSide(
                                            color: Colors.white.withValues(alpha: 0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_laneFlashIndex == index)
                                      IgnorePointer(
                                        child: AnimatedBuilder(
                                          animation: _laneFlashController,
                                          builder: (context, _) {
                                            final v = 1 - _laneFlashController.value;
                                            return Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    laneColor.withValues(alpha: 0.8 * v),
                                                    Colors.white.withValues(alpha: 0.5 * v),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _bgPulseController,
                        builder: (context, _) {
                          final v = _bgPulseController.value;
                          final pulseAlpha = 0.16 * sin(pi * v);
                          final pulseColor = _gameWorld?.noteColor ?? const Color(0xFFFFFA65);
                          return Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: const Alignment(0, 0.25),
                                    radius: 1.0,
                                    colors: [
                                      pulseColor.withValues(alpha: pulseAlpha),
                                      pulseColor.withValues(alpha: pulseAlpha * 0.4),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.45, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      if (_gameWorld != null)
                        Positioned.fill(
                          child: GameWidget(game: _gameWorld!),
                        ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 80,
                        child: IgnorePointer(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: _judgeLineColor(),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: _judgeLineColor().withValues(alpha: 0.8),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: _judgeLineColor().withValues(alpha: 0.8),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_currentJudge.isNotEmpty)
                                AnimatedBuilder(
                                  animation: _judgeAnimController,
                                  builder: (context, child) => Opacity(
                                    opacity: _judgeFadeAnim.value,
                                    child: Transform.scale(
                                      scale: _judgeScaleAnim.value,
                                      child: child,
                                    ),
                                  ),
                                  child: ShaderMask(
                                    blendMode: BlendMode.srcATop,
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        Colors.white,
                                        _judgeColor,
                                        Colors.white,
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      _currentJudge,
                                      style: TextStyle(
                                        fontSize: _currentJudge == 'PERFECT' ? 34 : 26,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 3,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(color: _judgeColor.withValues(alpha: 0.9), blurRadius: 20),
                                          Shadow(color: _judgeColor.withValues(alpha: 0.7), blurRadius: 40),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 6),
                              if (_combo > 1)
                                AnimatedBuilder(
                                  animation: _comboPopController,
                                  builder: (context, _) {
                                    final style = _comboStyle();
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (style.label != null)
                                          Text(
                                            style.label!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: style.color,
                                              letterSpacing: 2,
                                              shadows: [
                                                Shadow(color: style.color.withValues(alpha: 0.7), blurRadius: 12),
                                              ],
                                            ),
                                          ),
                                        Transform.scale(
                                          scale: _comboScaleAnim.value,
                                          child: Text(
                                            '$_combo COMBO',
                                            style: TextStyle(
                                              fontSize: style.fontSize,
                                              fontWeight: FontWeight.w900,
                                              color: style.color,
                                              shadows: [
                                                Shadow(color: style.color.withValues(alpha: 0.9), blurRadius: 18),
                                                Shadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 8),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildKeyGuide(),
              ],
            ),
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
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFFFD166)),
                  ),
                  Text(
                    '${AppTexts.get('score')}: $_score',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 28),
                onPressed: _pauseGame,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: double.infinity,
              height: 10,
              color: const Color(0xFF333333),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (_life / 100.0).clamp(0.0, 1.0),
                child: Container(color: const Color(0xFFFF4757)),
              ),
            ),
          ),
        ],
      ),
    );
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
                  gradient: isActive && _gameWorld != null
                      ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _gameWorld!.noteColor.withValues(alpha: 0.7),
                      _gameWorld!.noteColor.withValues(alpha: 0.3),
                    ],
                  )
                      : null,
                  color: isActive && _gameWorld == null
                      ? Colors.white.withValues(alpha: 0.28)
                      : Colors.transparent,
                  border: Border(
                    top: BorderSide(
                      color: isActive
                          ? const Color(0xFFFFFA65)
                          : Colors.white.withValues(alpha: 0.35),
                      width: 2.5,
                    ),
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    left: index == 0
                        ? BorderSide.none
                        : BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    right: BorderSide.none,
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
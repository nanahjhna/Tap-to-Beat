import 'dart:async';
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

class _GamePlayViewState extends State<GamePlayView> with WidgetsBindingObserver {
  late final AudioPlayer _audioPlayer;
  late final AudioPlayer _sfxPlayer;
  late final Stopwatch _stopwatch;

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

  static const List<LogicalKeyboardKey> _keyCodes = [
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.keyF,
    LogicalKeyboardKey.keyJ,
    LogicalKeyboardKey.keyK,
  ];
  static const List<String> _keyLabels = ['D', 'F', 'J', 'K'];

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
    _sfxPlayer = AudioPlayer(playerId: 'hit_sfx')
      ..setPlayerMode(PlayerMode.lowLatency);
    _stopwatch = Stopwatch();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 앱이 백그라운드로 내려갈 때 (홈 버튼 등) 자동으로 일시정지
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_isPlaying && !_isPaused && !_gameEnded) {
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

    // 📌 화면이 열린 후 1초(1000ms) 동안 여유를 준 뒤 음악과 게임을 시작합니다.
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted || _isPaused || _gameEnded) return;

    try {
      await _audioPlayer.setVolume(settingsProvider.bgmVolume);
      await _sfxPlayer.setVolume(settingsProvider.sfxVolume);
      final soundPath = _stageData?.audioPath ?? 'sounds/basicmusic/MikoshiMayhem.mp3';
      await _audioPlayer.play(AssetSource(soundPath));
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
    }
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

  void _handleKeyPress(int trackIdx) {
    if (!_isPlaying || _isPaused || _gameEnded) return;

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

      if (minDiff <= perfectMs) {
        _showJudgment('PERFECT', const Color(0xFF2ED573));
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
      _playSfx();
      setState(() {});
    }
  }

  void _playSfx() {
    try {
      _sfxPlayer.play(AssetSource('sounds/hit.wav'), mode: PlayerMode.lowLatency);
    } catch (_) {}
  }

  void _addCombo() {
    _combo++;
    if (_combo > _maxCombo) _maxCombo = _combo;
  }

  void _handleMiss({bool isBad = false}) {
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
    _audioPlayer.stop();

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

    // 📌 PauseOverlay 호출 부분 수정
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PauseOverlay(
        onPause: () {
          // 일시정지 시 음악 멈춤
          _audioPlayer.pause();
        },
        onResume: () {
          // 카운트다운 끝난 후 이어서 재생 (`_resumeGame` 메서드 활용)
          _resumeGame();
        },
        onRetry: () {
          // 다시하기 시 음악을 처음으로 돌리고 게임을 처음부터 재시작
          _audioPlayer.stop();
          _initGameWorld(); // 게임 월드(노트 데이터) 재생성
          _startGame();     // 게임 상태 초기화 및 음악 처음부터 재생
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
    _judgeClearTimer?.cancel();
    _stopwatch.stop();
    _audioPlayer.dispose();
    _sfxPlayer.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 📌 PopScope를 통해 뒤로가기 버튼이나 제스처로 게임이 바로 닫히지 않고 일시정지창이 뜨도록 제어
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
                                        color: index < 3 ? Colors.white12 : Colors.transparent,
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
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFA65),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFFA65).withValues(alpha: 0.8),
                                  blurRadius: 15,
                                  spreadRadius: 2,
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
                                Text(
                                  _currentJudge,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: _judgeColor,
                                    shadows: [
                                      Shadow(color: _judgeColor.withValues(alpha: 0.8), blurRadius: 16),
                                    ],
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
                                  ),
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
                  color: isActive ? Colors.white.withValues(alpha: 0.28) : Colors.transparent,
                  border: Border(
                    top: BorderSide(
                      color: isActive ? const Color(0xFFFFFA65) : const Color(0xFF444444),
                      width: 2.5,
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
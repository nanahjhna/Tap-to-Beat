import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/stage_generator.dart';
import '../utils/app_texts.dart';

class ResultView extends StatefulWidget {
  const ResultView({super.key});

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> with SingleTickerProviderStateMixin {
  bool _rewardGiven = false;
  late final AnimationController _rankAnimController;
  late final Animation<double> _rankScaleAnim;
  late final Animation<double> _rankFadeAnim;

  @override
  void initState() {
    super.initState();
    _rankAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rankScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rankAnimController, curve: Curves.elasticOut),
    );
    _rankFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rankAnimController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );
    _rankAnimController.forward();
  }

  @override
  void dispose() {
    _rankAnimController.dispose();
    super.dispose();
  }

  String _calculateRank(bool won, int score, int totalNotes) {
    if (!won) return 'F';
    final maxScore = (totalNotes > 0 ? totalNotes : 80) * 300;
    final ratio = score / (maxScore > 0 ? maxScore : 1);
    if (ratio >= 0.90) return 'S';
    if (ratio >= 0.80) return 'A';
    if (ratio >= 0.65) return 'B';
    return 'C';
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case 'S':
        return const Color(0xFFFFD166);
      case 'A':
        return const Color(0xFF2ED573);
      case 'B':
        return const Color(0xFF1E90FF);
      case 'C':
        return const Color(0xFFFFA502);
      default:
        return const Color(0xFFFF4757);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)?.settings.arguments as Map? ?? {
      'victory': false,
      'stage': 1,
      'score': 0,
      'maxCombo': 0,
      'perfect': 0,
      'good': 0,
      'bad': 0,
      'miss': 0,
      'totalNotes': 80,
      'songTitle': 'Mikoshi Mayhem',
      'songArtist': 'Matsuri Beats',
    };

    final won = data['victory'] == true;
    final stage = data['stage'] as int? ?? 1;
    final difficulty =
        StageGenerator.normalizeDifficulty(data['difficulty'] as String?);
    final score = data['score'] as int? ?? 0;
    final maxCombo = data['maxCombo'] as int? ?? 0;
    final perfect = data['perfect'] as int? ?? 0;
    final good = data['good'] as int? ?? 0;
    final bad = data['bad'] as int? ?? 0;
    final miss = data['miss'] as int? ?? 0;
    final totalNotes = data['totalNotes'] as int? ?? (perfect + good + bad + miss);
    final songTitle = data['songTitle'] as String? ?? 'Mikoshi Mayhem';
    final songArtist = data['songArtist'] as String? ?? 'Matsuri Beats';

    final rank = _calculateRank(won, score, totalNotes);
    final rankColor = _getRankColor(rank);

    final hitNotes = perfect + good;
    final accuracy = totalNotes > 0 ? ((hitNotes / totalNotes) * 100).toStringAsFixed(1) : '0.0';

    // 코인 보상 처리 (한 번만)
    if (!_rewardGiven && mounted) {
      _rewardGiven = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userProvider = context.read<UserProvider>();
        // 클리어 기록 저장
        userProvider.saveStageResult(stage, score, maxCombo, perfect, good, bad, miss, rank, won);
        // 클리어 시 코인 지급
        if (won) {
          final stageData =
              StageGenerator.getStage(stage, difficulty: difficulty);
          userProvider.addCoins(stageData.rewardCoins);
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141226),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // 곡 정보 및 클리어 문구
              Text(
                won ? AppTexts.get('victory') : AppTexts.get('defeat'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: won ? const Color(0xFFFFD166) : const Color(0xFFFF4757),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$songTitle - $songArtist',
                style: const TextStyle(fontSize: 15, color: Colors.white70),
              ),
              Text(
                '${AppTexts.get('stage')} $stage',
                style: const TextStyle(fontSize: 13, color: Colors.white38),
              ),
              const SizedBox(height: 24),

              // 랭크 배지 & 스코어 (가로 배치)
              // 랭크 배지 & 스코어 (간격 및 정렬 조정)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝으로 배치하여 여백 확보
                children: [
                  // 📌 랭크 배지 (왼쪽에 여백을 주기 위해 Padding 추가)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: AnimatedBuilder(
                      animation: _rankAnimController,
                      builder: (context, child) => FadeTransition(
                        opacity: _rankFadeAnim,
                        child: Transform.scale(
                          scale: _rankScaleAnim.value,
                          child: child,
                        ),
                      ),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: rankColor.withValues(alpha: 0.15),
                          border: Border.all(color: rankColor, width: 3.5),
                          boxShadow: [
                            BoxShadow(
                              color: rankColor.withValues(alpha: 0.4),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            rank,
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              color: rankColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 📌 스코어 영역 (오른쪽 정렬)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end, // 오른쪽 정렬
                      children: [
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppTexts.get('score'),
                          style: const TextStyle(fontSize: 13, color: Colors.white54, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 상세 기록 카드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF221F42),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem(AppTexts.get('accuracy'), '$accuracy%'),
                    Container(width: 1, height: 36, color: Colors.white24),
                    _statItem(AppTexts.get('maxCombo'), '$maxCombo'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 판정 내역 카드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1836),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _judgeRow('PERFECT', perfect, const Color(0xFF2ED573)),
                    const Divider(color: Colors.white10, height: 16),
                    _judgeRow('GOOD', good, const Color(0xFF1E90FF)),
                    const Divider(color: Colors.white10, height: 16),
                    _judgeRow('BAD', bad, const Color(0xFFFFA502)),
                    const Divider(color: Colors.white10, height: 16),
                    _judgeRow('MISS', miss, const Color(0xFFFF4757)),
                  ],
                ),
              ),

              if (won)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Builder(
                    builder: (context) {
                      final stageData = StageGenerator.getStage(stage,
                          difficulty: difficulty);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD166).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.monetization_on, color: Color(0xFFFFD166), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '+${stageData.rewardCoins} ${AppTexts.get('coins')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFD166),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),

              // 동작 버튼들
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, '/gamePlay',
                      arguments: {'stage': stage, 'difficulty': difficulty}),
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(AppTexts.get('retry')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD166),
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/stageSelect'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(AppTexts.get('selectStage')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(AppTexts.get('lobby')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white60)),
      ],
    );
  }

  Widget _judgeRow(String title, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_texts.dart';
import '../services/stage_generator.dart';
import '../models/stage_model.dart';

class LobbyTab extends StatefulWidget {
  const LobbyTab({super.key, this.currentTabIndex = 0});
  final int currentTabIndex;

  @override
  State<LobbyTab> createState() => _LobbyTabState();
}

class _LobbyTabState extends State<LobbyTab> {
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF283593),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${AppTexts.get('language')} / Language',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLangButton(ctx, '한국어'),
            const SizedBox(height: 8),
            _buildLangButton(ctx, 'English'),
            const SizedBox(height: 8),
            _buildLangButton(ctx, '日本語'),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(BuildContext ctx, String langName) {
    final isSelected = AppTexts.currentLang == langName;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFFFFD166) : Colors.white12,
          foregroundColor: isSelected ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: () async {
          await AppTexts.setLanguage(langName);
          if (ctx.mounted) Navigator.pop(ctx);
          setState(() {});
        },
        child: Text(
          langName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1B183B), Color(0xFF110F24)],
            ),
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // 전체를 스크롤 가능하게 하거나, 높이를 강제하여 카드가 잘 보이도록 수정
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상단 재화 및 메뉴 영역
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Currency(icon: Icons.monetization_on_rounded, value: '${userProvider.coins}'),
                            Row(
                              children: [
                                _miniShortcut(
                                  context,
                                  Icons.bolt,
                                  AppTexts.get('quest'),
                                  route: '/quest',
                                ),
                                const SizedBox(width: 8),
                                _miniShortcut(
                                  context,
                                  Icons.campaign,
                                  AppTexts.get('notice'),
                                  route: '/notice',
                                ),
                                const SizedBox(width: 8),
                                _miniShortcut(
                                  context,
                                  Icons.language,
                                  AppTexts.get('language'),
                                  onTap: () => _showLanguageDialog(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 스테이지 선택 뷰가 고정된 높이를 가지고 보이도록 SizedBox로 감싸기
                      SizedBox(
                        height: constraints.maxHeight - 100, // 상단바 영역을 제외한 높이 확보
                        child: const StageSelectView(embedded: true),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

Widget _miniShortcut(
    BuildContext context,
    IconData icon,
    String label, {
      String? route,
      VoidCallback? onTap,
    }) => Tooltip(
  message: label,
  child: Material(
    color: const Color(0xFF2D2855),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap ?? (route != null ? () => Navigator.pushNamed(context, route) : null),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Icon(icon, color: const Color(0xFFFFD166), size: 20),
      ),
    ),
  ),
);

class _Currency extends StatelessWidget {
  const _Currency({required this.icon, required this.value});
  final IconData icon;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD166), size: 18),
        const SizedBox(width: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    ),
  );
}

// ---------------------------------------------------------
// StageSelectView 통합 코드 (withValues 예외 처리 포함)
// ---------------------------------------------------------
class StageSelectView extends StatefulWidget {
  const StageSelectView({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<StageSelectView> createState() => _StageSelectViewState();
}

class _StageSelectViewState extends State<StageSelectView> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _getDifficultyColor(String diff) {
    switch (diff.toUpperCase()) {
      case 'EASY':
        return const Color(0xFF2ED573);
      case 'NORMAL':
        return const Color(0xFF1E90FF);
      case 'HARD':
        return const Color(0xFFFFA502);
      case 'EXPERT':
        return const Color(0xFFFF4757);
      case 'MASTER':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFFFFD166);
    }
  }

  IconData _getTrackIcon(int stageNum) {
    const icons = [
      Icons.music_note_rounded,
      Icons.album_rounded,
      Icons.headphones_rounded,
      Icons.graphic_eq_rounded,
      Icons.audiotrack_rounded,
    ];
    return icons[(stageNum - 1) % icons.length];
  }

  Color _rankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'S':
        return const Color(0xFFFFD166);
      case 'A':
        return const Color(0xFF2ED573);
      case 'B':
        return const Color(0xFFFFA502);
      case 'C':
        return const Color(0xFF1E90FF);
      case 'F':
        return const Color(0xFFFF4757);
      default:
        return const Color(0xFF888888);
    }
  }

  String _formatScore(int score) {
    final s = score.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onStageTap(BuildContext context, StageModel stage, bool isOwned) {
    if (isOwned) {
      _showDifficultyPopup(context, stage);
    } else {
      _showLockPopup(context, stage);
    }
  }

  void _showDifficultyPopup(BuildContext context, StageModel stage) {
    const difficulties = ['EASY', 'NORMAL', 'HARD'];
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF201D3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stage.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('${stage.artist} • BPM ${stage.bpm}',
                style: const TextStyle(color: Colors.white60, fontSize: 13)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: difficulties.map((diff) {
            final preview = StageGenerator.generateStage(
              stage.stageNumber,
              difficulty: diff,
            );
            final color = _getDifficultyColor(diff);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pushNamed(
                      context,
                      '/gamePlay',
                      arguments: {
                        'stage': stage.stageNumber,
                        'difficulty': diff,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.withValues(alpha: 0.2),
                    foregroundColor: color,
                    side: BorderSide(color: color.withValues(alpha: 0.6)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    '$diff Lv.${preview.difficultyLevel} • ${preview.noteCount} NOTES • +${preview.rewardCoins}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppTexts.get('back'),
                style: const TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _showLockPopup(BuildContext context, StageModel stage) {
    final price = stage.rewardCoins * 3;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF201D3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock, color: Colors.white54, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(stage.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        content: Text(
          '$price ${AppTexts.get('coins')} + ${AppTexts.get('buyWithAd')}',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppTexts.get('back'),
                style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamed(context, '/shop');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD166),
              foregroundColor: Colors.black,
            ),
            child: Text(AppTexts.get('shop')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stages = StageGenerator.allStages;
    final userProvider = context.watch<UserProvider>();

    final content = Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: stages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final stage = stages[index];
              final isOwned = userProvider.isStageOwned(stage.stageNumber, stageTitle: stage.title);
              final best = userProvider.bestResultForStage(stage.stageNumber);
              final diffColor = _getDifficultyColor(stage.difficulty);

              return AnimatedScale(
                scale: _currentPage == index ? 1.0 : 0.9,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Card(
                    color: const Color(0xFF201D3D),
                    elevation: _currentPage == index ? 8 : 2,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isOwned
                            ? diffColor.withValues(alpha: 0.5)
                            : Colors.white12,
                        width: _currentPage == index ? 2 : 1,
                      ),
                    ),
                    child: Opacity(
                      opacity: isOwned ? 1.0 : 0.5,
                      child: InkWell(
                        onTap: () => _onStageTap(context, stage, isOwned),
                        child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 75,
                                    height: 75,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          diffColor.withValues(alpha: 0.35),
                                          const Color(0xFF141226),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: diffColor.withValues(alpha: 0.5),
                                        width: 2,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(
                                          _getTrackIcon(stage.stageNumber),
                                          size: 35,
                                          color: diffColor,
                                        ),
                                        if (best != null)
                                          Positioned(
                                            right: 6,
                                            top: 6,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _rankColor(best.bestRank),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                best.bestRank,
                                                style: TextStyle(
                                                  color: (best.bestRank == 'C' || best.bestRank == 'F')
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: diffColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: diffColor.withValues(alpha: 0.6), width: 1),
                                    ),
                                    child: Text(
                                      '${stage.difficulty} Lv.${stage.difficultyLevel}',
                                      style: TextStyle(
                                        color: diffColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    stage.title,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    stage.artist,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'BPM ${stage.bpm}  •  ${stage.noteCount} NOTES',
                                    style: const TextStyle(
                                      color: Color(0xFF69B8FF),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${AppTexts.get('reward')}: +${stage.rewardCoins} ${AppTexts.get('coins')}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (best != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.emoji_events_rounded,
                                            color: Color(0xFFFFD166), size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          'BEST ${_formatScore(best.bestScore)}',
                                          style: const TextStyle(
                                            color: Color(0xFFFFD166),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (!isOwned) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.lock, color: Colors.white54, size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${stage.rewardCoins * 3} ${AppTexts.get('coins')} + ${AppTexts.get('buyWithAd')}',
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (stages.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                stages.length,
                    (index) => Container(
                  width: _currentPage == index ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFFFFD166)
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        if (stages.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 4, 40, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _currentPage > 0
                      ? () => _goToPage(_currentPage - 1)
                      : null,
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: _currentPage > 0
                        ? const Color(0xFFFFD166)
                        : Colors.white24,
                    size: 24,
                  ),
                ),
                Text(
                  '${_currentPage + 1} / ${stages.length}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _currentPage < stages.length - 1
                      ? () => _goToPage(_currentPage + 1)
                      : null,
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: _currentPage < stages.length - 1
                        ? const Color(0xFFFFD166)
                        : Colors.white24,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    return widget.embedded
        ? content
        : Scaffold(
      backgroundColor: const Color(0xFF151329),
      body: SafeArea(
        child: content,
      ),
    );
  }
}
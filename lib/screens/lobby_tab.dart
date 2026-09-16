import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_texts.dart';
import '../services/stage_generator.dart';
import '../models/stage_model.dart';
import '../models/effect_model.dart';
import '../theme/app_theme.dart';
import '../widgets/currency_badge.dart';
import '../widgets/language_dialog.dart';
import '../widgets/round_icon_button.dart';

class LobbyTab extends StatefulWidget {
  const LobbyTab({super.key, this.currentTabIndex = 0});
  final int currentTabIndex;

  @override
  State<LobbyTab> createState() => _LobbyTabState();
}

class _LobbyTabState extends State<LobbyTab> {
  void _openLanguageDialog() {
    showLanguageDialog(context, onLanguageChanged: () => setState(() {}));
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
              colors: [AppColors.cardTop, AppColors.bgDeepest],
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              child: CurrencyBadge(
                                value: '${userProvider.coins}',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                RoundIconButton(
                                  icon: Icons.bolt,
                                  label: AppTexts.get('quest'),
                                  route: '/quest',
                                ),
                                const SizedBox(width: 8),
                                RoundIconButton(
                                  icon: Icons.campaign,
                                  label: AppTexts.get('notice'),
                                  route: '/notice',
                                ),
                                const SizedBox(width: 8),
                                RoundIconButton(
                                  icon: Icons.language,
                                  label: AppTexts.get('language'),
                                  onTap: _openLanguageDialog,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 스테이지 선택 뷰가 고정된 높이를 가지고 보이도록 SizedBox로 감싸기
                      SizedBox(
                        height: math.max(
                          constraints.maxHeight - 100,
                          220,
                        ), // 상단바 영역 제외, 최소 높이 보장
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stage.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${stage.artist} • BPM ${stage.bpm}',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: difficulties.map((diff) {
            final preview = StageGenerator.generateStage(
              stage.stageNumber,
              difficulty: diff,
            );
            final color = difficultyColor(diff);
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
                      borderRadius: BorderRadius.circular(12),
                    ),
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
            child: Text(
              AppTexts.get('back'),
              style: const TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  void _showLockPopup(BuildContext context, StageModel stage) {
    final song = ShopData.songByStage(stage.stageNumber);
    final price = song?.coinPrice ?? stage.rewardCoins * 3;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock, color: Colors.white54, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                stage.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '$price ${AppTexts.get('buyWithAd')}',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              AppTexts.get('back'),
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamed(context, '/shop');
            },
            style: appAccentButtonStyle,
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
              final isOwned = userProvider.isStageOwned(
                stage.stageNumber,
                stageTitle: stage.title,
              );
              final best = userProvider.bestResultForStage(stage.stageNumber);
              final diffColor = difficultyColor(stage.difficulty);

              return AnimatedScale(
                scale: _currentPage == index ? 1.0 : 0.9,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  child: Card(
                    color: AppColors.cardDark,
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
                              // 페이지 스와이프와의 제스처 경합을 줄이기 위해 기본 물리 적용
                              padding: const EdgeInsets.all(16),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight - 32,
                                ),
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
                                            AppColors.resultBg,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: diffColor.withValues(
                                            alpha: 0.5,
                                          ),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: rankColor(
                                                    best.bestRank,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  best.bestRank,
                                                  style: TextStyle(
                                                    color:
                                                        (best.bestRank == 'B' ||
                                                            best.bestRank ==
                                                                'C' ||
                                                            best.bestRank ==
                                                                'F')
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: diffColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: diffColor.withValues(
                                            alpha: 0.6,
                                          ),
                                          width: 1,
                                        ),
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
                                        color: AppColors.bpmBlue,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.emoji_events_rounded,
                                            color: AppColors.accent,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'BEST ${formatScore(best.bestScore)}',
                                            style: const TextStyle(
                                              color: AppColors.accent,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (!isOwned) ...[
                                      const SizedBox(height: 6),
                                      Builder(
                                        builder: (context) {
                                          final lockSong = ShopData.songByStage(
                                            stage.stageNumber,
                                          );
                                          final lockPrice =
                                              lockSong?.coinPrice ??
                                              stage.rewardCoins * 3;
                                          return Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.lock,
                                                  color: Colors.white54,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '$lockPrice ${AppTexts.get('buyWithAd')}',
                                                  style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
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
                        ? AppColors.accent
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
                        ? AppColors.accent
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
                        ? AppColors.accent
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
            backgroundColor: AppColors.bgDeep,
            body: SafeArea(child: content),
          );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_texts.dart';
import '../services/stage_generator.dart';
import '../models/stage_model.dart';

class StageSelectView extends StatefulWidget {
  const StageSelectView({super.key});

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

    return Scaffold(
      backgroundColor: const Color(0xFF151329),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          AppTexts.get('selectStage'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 가로 스와이프 PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: stages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final stage = stages[index];
                final isOwned = userProvider.ownsSong('stage_${stage.stageNumber}');
                final diffColor = _getDifficultyColor(stage.difficulty);

                return AnimatedScale(
                  scale: _currentPage == index ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
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
                          onTap: () =>
                              _onStageTap(context, stage, isOwned),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 앨범 아트
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        diffColor.withValues(alpha: 0.35),
                                        const Color(0xFF141226),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
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
                                        size: 50,
                                        color: diffColor,
                                      ),
                                      if (stage.rank != '-')
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFD166),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              stage.rank,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // 난이도 뱃지
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: diffColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: diffColor.withValues(alpha: 0.6), width: 1),
                                  ),
                                  child: Text(
                                    '${stage.difficulty} Lv.${stage.difficultyLevel}',
                                    style: TextStyle(
                                      color: diffColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // 곡 정보
                                Text(
                                  stage.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  stage.artist,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'BPM ${stage.bpm}  •  ${stage.noteCount} NOTES',
                                  style: const TextStyle(
                                    color: Color(0xFF69B8FF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${AppTexts.get('reward')}: +${stage.rewardCoins} ${AppTexts.get('coins')}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // 잠금 상태 표시
                                if (!isOwned)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.lock, color: Colors.white54, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${stage.rewardCoins * 3} ${AppTexts.get('coins')} + ${AppTexts.get('buyWithAd')}',
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 페이지 인디케이터 (dots) — 단일 곡일 때 숨김
          if (stages.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  stages.length,
                  (index) => Container(
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFFFFD166)
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

          // 좌우 화살표 버튼 — 단일 곡일 때 숨김
          if (stages.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 8, 40, 20),
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
                      size: 28,
                    ),
                  ),
                  Text(
                    '${_currentPage + 1} / ${stages.length}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
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
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

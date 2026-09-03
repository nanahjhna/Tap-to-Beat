import 'package:flutter/material.dart';
import '../utils/app_texts.dart';
import '../models/stage_model.dart';
import '../services/stage_generator.dart';
import '../widgets/game_bottom_navigation.dart';
import '../widgets/game_header.dart';

class StageSelectView extends StatefulWidget {
  const StageSelectView({super.key});

  @override
  State<StageSelectView> createState() => _StageSelectViewState();
}

class _StageSelectViewState extends State<StageSelectView> {
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

  @override
  Widget build(BuildContext context) {
    // StageGenerator에 등록된 모든 곡 리스트를 불러옵니다[cite: 1].
    final stages = StageGenerator.allStages;

    return Scaffold(
      backgroundColor: const Color(0xFF151329),
      appBar: const GameHeader(titleKey: 'selectStage'),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: stages.length,
        itemBuilder: (context, index) {
          final stageData = stages[index];

          return _trackCard(context, stageData);
        },
      ),
      bottomNavigationBar: const GameBottomNavigation(),
    );
  }

  Widget _trackCard(BuildContext context, StageModel stage) {
    final diffColor = _getDifficultyColor(stage.difficulty);

    return Card(
      color: const Color(0xFF201D3D),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: stage.isUnlocked ? diffColor.withValues(alpha: 0.3) : Colors.white12,
          width: 1.2,
        ),
      ),
      child: Opacity(
        opacity: stage.isUnlocked ? 1.0 : 0.45,
        child: InkWell(
          onTap: stage.isUnlocked
              ? () => Navigator.pushNamed(context, '/gamePlay', arguments: stage.stageNumber)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // 앨범 아트 느낌의 썸네일
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        diffColor.withValues(alpha: 0.35),
                        const Color(0xFF141226),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: diffColor.withValues(alpha: 0.5)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        _getTrackIcon(stage.stageNumber),
                        size: 38,
                        color: diffColor,
                      ),
                      if (stage.rank != '-')
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD166),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              stage.rank,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // 곡 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: diffColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: diffColor.withValues(alpha: 0.6), width: 0.8),
                            ),
                            child: Text(
                              '${stage.difficulty} Lv.${stage.difficultyLevel}',
                              style: TextStyle(
                                color: diffColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${AppTexts.get('stage')} ${stage.stageNumber}',
                            style: const TextStyle(
                              color: Color(0xFFFFD166),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stage.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stage.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'BPM ${stage.bpm}',
                            style: const TextStyle(
                              color: Color(0xFF69B8FF),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${AppTexts.get('reward')}: +${stage.rewardCoins} ${AppTexts.get('coins')}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 진입 또는 잠금 아이콘
                Icon(
                  stage.isUnlocked ? Icons.play_circle_fill : Icons.lock,
                  size: 32,
                  color: stage.isUnlocked ? const Color(0xFFFFD166) : Colors.white38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
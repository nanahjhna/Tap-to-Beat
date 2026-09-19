import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/effect_model.dart';
import '../models/stage_model.dart';
import '../services/stage_generator.dart';
import '../services/play_gate_helper.dart';
import '../widgets/game_bottom_navigation.dart';
import '../widgets/game_header.dart';
import '../utils/app_texts.dart';
import '../theme/app_theme.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  int _category = 0; // 0: 전체, 1: 곡, 2: 이펙트

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final content = SafeArea(
      top: widget.embedded,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(AppTexts.get('all'))),
                ButtonSegment(value: 1, label: Text(AppTexts.get('songs'))),
                ButtonSegment(value: 2, label: Text(AppTexts.get('effects'))),
              ],
              selected: {_category},
              onSelectionChanged: (v) => setState(() => _category = v.first),
              style: appSegmentedStyle,
            ),
          ),
          Expanded(child: _buildItemList(userProvider)),
        ],
      ),
    );

    return widget.embedded
        ? content
        : Scaffold(
            appBar: const GameHeader(titleKey: ''),
            body: content,
            bottomNavigationBar: const GameBottomNavigation(
              currentIndex: 2,
              showBanner: false,
            ),
          );
  }

  Widget _buildItemList(UserProvider userProvider) {
    final items = <_InventoryItemData>[];

    // 소유한 곡 추가
    if (_category == 0 || _category == 1) {
      // 1) Stage 기반 곡 (stage_1, stage_2, ...)
      for (final stage in StageGenerator.allStages) {
        final itemId = 'stage_${stage.stageNumber}';
        if (userProvider.ownsSong(itemId)) {
          items.add(
            _InventoryItemData(
              id: itemId,
              name: stage.title,
              desc: '${stage.artist} • ${stage.difficulty}',
              type: 'song',
              color: AppColors.blue,
              icon: Icons.music_note_rounded,
              isEquipped: userProvider.isSongEquipped(itemId),
            ),
          );
        }
      }

      // 2) Shop에서 구매한 음악 + 기본곡
      for (final item in ShopData.shopMusic) {
        if (item.stageNumber != 0) continue;
        if (userProvider.ownsSong(item.id)) {
          items.add(
            _InventoryItemData(
              id: item.id,
              name: item.name,
              desc: item.localizedDesc,
              type: 'song',
              color: item.color,
              icon: item.icon,
              isEquipped: false,
              isBasic: item.isBasic,
            ),
          );
        }
      }
    }

    // 소유한 이펙트 추가
    if (_category == 0 || _category == 2) {
      for (final effect in ShopData.effects) {
        if (userProvider.ownsEffect(effect.id)) {
          items.add(
            _InventoryItemData(
              id: effect.id,
              name: effect.name,
              desc: effect.localizedDesc,
              type: 'effect',
              color: effect.color,
              icon: effect.icon,
              isEquipped: userProvider.isEffectEquipped(effect.id),
            ),
          );
        }
      }
      for (final skin in ShopData.noteSkins) {
        if (userProvider.ownsEffect(skin.id)) {
          items.add(
            _InventoryItemData(
              id: skin.id,
              name: skin.name,
              desc: skin.localizedDesc,
              type: 'effect',
              color: skin.color,
              icon: skin.icon,
              isEquipped: userProvider.isEffectEquipped(skin.id),
            ),
          );
        }
      }
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(
              AppTexts.get('noItems'),
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _inventoryCard(userProvider, item);
      },
    );
  }

  Widget _inventoryCard(UserProvider userProvider, _InventoryItemData item) {
    final isSong = item.type == 'song';
    // 곡은 장착 개념 없음 → 테두리/문구 강조도 적용 안 함
    final highlight = !isSong && item.isEquipped;
    void onTap() {
      if (isSong) _showSongDetail(userProvider, item);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: highlight ? item.color.withValues(alpha: 0.8) : Colors.white12,
          width: highlight ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: isSong ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: item.color, width: 1.5),
          ),
          child: Icon(item.icon, color: item.color, size: 26),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          highlight ? '${AppTexts.get('equipped')} • ${item.desc}' : item.desc,
          style: TextStyle(
            fontSize: 12,
            color: highlight ? AppColors.accent : Colors.white60,
          ),
        ),
        trailing: isSong
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: item.isBasic
                          ? AppColors.green.withValues(alpha: 0.2)
                          : Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.isBasic
                          ? AppTexts.get('basicMusic')
                          : AppTexts.get('owned'),
                      style: TextStyle(
                        color: item.isBasic
                            ? AppColors.green
                            : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.white38),
                ],
              )
            : Switch(
                value: item.isEquipped,
                onChanged: (value) {
                  userProvider.toggleEquipEffect(item.id);
                },
                activeThumbColor: AppColors.accent,
                activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
                inactiveThumbColor: Colors.white54,
                inactiveTrackColor: Colors.white12,
              ),
        ),
      ),
    );
  }

  /// 곡 카드 탭 시 보여줄 상세 다이얼로그 (난이도/최고 기록 표시)
  void _showSongDetail(UserProvider userProvider, _InventoryItemData item) {
    String? stageNumber;
    if (item.id.startsWith('stage_')) {
      stageNumber = item.id.split('_').last;
    }

    StageModel? stageModel;
    if (stageNumber != null) {
      final num = int.tryParse(stageNumber);
      if (num != null) stageModel = StageGenerator.getStage(num);
    }

    final best = stageModel != null
        ? userProvider.bestResultForStage(stageModel.stageNumber)
        : null;

    // null-safety: 클로저 내에서 non-null 타입 보장을 위해 로컬 캡처
    final capturedStage = stageModel;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          item.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.desc,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            if (capturedStage != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: item.color.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      '${capturedStage.difficulty} Lv.${capturedStage.difficultyLevel}',
                      style: TextStyle(
                        color: item.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${capturedStage.noteCount} NOTES',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            if (best != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rankColor(best.bestRank).withValues(alpha: 0.15),
                      border: Border.all(color: rankColor(best.bestRank)),
                    ),
                    child: Center(
                      child: Text(
                        best.bestRank,
                        style: TextStyle(
                          color: rankColor(best.bestRank),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'BEST ${formatScore(best.bestScore)}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppTexts.get('back'),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          if (capturedStage != null)
            ElevatedButton(
              onPressed: () {
                final selStage = capturedStage.stageNumber;
                final selDiff = capturedStage.difficulty;
                Navigator.pop(ctx);
                tryStartGame(
                  context,
                  stage: selStage,
                  difficulty: selDiff,
                );
              },
              style: appAccentButtonStyle,
              child: Text(AppTexts.get('selectStage')),
            ),
        ],
      ),
    );
  }
}

class _InventoryItemData {
  final String id;
  final String name;
  final String desc;
  final String type;
  final Color color;
  final IconData icon;
  final bool isEquipped;
  final bool isBasic;

  const _InventoryItemData({
    required this.id,
    required this.name,
    required this.desc,
    required this.type,
    required this.color,
    required this.icon,
    required this.isEquipped,
    this.isBasic = false,
  });
}

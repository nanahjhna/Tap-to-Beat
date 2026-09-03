import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/effect_model.dart';
import '../services/stage_generator.dart';
import '../services/ad_reward_helper.dart';
import '../widgets/game_bottom_navigation.dart';
import '../widgets/game_header.dart';
import '../utils/app_texts.dart';

class ShopView extends StatefulWidget {
  const ShopView({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> {
  int _selectedTab = 0; // 0: 곡, 1: 이펙트

  @override
  void initState() {
    super.initState();
    AdRewardHelper.instance.loadAd();
  }

  void _showPurchaseDialog(String itemId, String itemName, int coinCost, bool requireAd) {
    final userProvider = context.read<UserProvider>();
    final canAfford = userProvider.coins >= coinCost;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF283593),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppTexts.get('confirmPurchase'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              itemName,
              style: const TextStyle(color: Color(0xFFFFD166), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFFFFD166), size: 20),
                const SizedBox(width: 4),
                Text(
                  '$coinCost ${AppTexts.get('coins')}',
                  style: TextStyle(
                    color: canAfford ? Colors.white : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (requireAd) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.play_circle_outline, color: Colors.white70, size: 20),
                  const SizedBox(width: 4),
                  const Text('+ 광고 1회', style: TextStyle(color: Colors.white70)),
                ],
              ],
            ),
            if (!canAfford)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  AppTexts.get('coinNotEnough'),
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppTexts.get('no'), style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: canAfford
                ? () {
                    Navigator.pop(ctx);
                    _purchaseItem(itemId, coinCost, requireAd);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD166),
              foregroundColor: Colors.black,
            ),
            child: Text(AppTexts.get('yes')),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseItem(String itemId, int coinCost, bool requireAd) async {
    final userProvider = context.read<UserProvider>();
    final isEffect = itemId.startsWith('effect_') || itemId.startsWith('skin_');

    if (requireAd) {
      final rewardEarned = await AdRewardHelper.instance.showAdAndGetReward();
      if (!rewardEarned) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppTexts.get('adFailed'))),
          );
        }
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTexts.get('adRewardGranted'))),
        );
      }
    }

    bool success;
    if (isEffect) {
      success = await userProvider.purchaseEffect(itemId, coinCost);
    } else {
      success = await userProvider.purchaseSong(itemId, coinCost);
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexts.get('coinNotEnough'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final content = SafeArea(
      top: widget.embedded,
      child: Column(
        children: [
          // 상단 코인 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD166), size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '${userProvider.coins}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 카테고리 탭
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(AppTexts.get('songs'))),
                ButtonSegment(value: 1, label: Text(AppTexts.get('effects'))),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (v) => setState(() => _selectedTab = v.first),
            ),
          ),

          const SizedBox(height: 8),

          // 아이템 목록
          Expanded(
            child: _selectedTab == 0 ? _buildSongList(userProvider) : _buildEffectList(userProvider),
          ),
        ],
      ),
    );

    return widget.embedded
        ? content
        : Scaffold(
            appBar: const GameHeader(titleKey: 'shop'),
            body: content,
            bottomNavigationBar: const GameBottomNavigation(currentIndex: 2),
          );
  }

  Widget _buildSongList(UserProvider userProvider) {
    final stages = StageGenerator.allStages;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: stages.length,
      itemBuilder: (context, index) {
        final stage = stages[index];
        final itemId = 'stage_${stage.stageNumber}';
        final isOwned = userProvider.ownsSong(itemId);
        final coinCost = stage.rewardCoins * 3;

        return _shopCard(
          name: stage.title,
          desc: '${stage.artist} • BPM ${stage.bpm} • ${stage.difficulty}',
          icon: Icons.music_note_rounded,
          color: const Color(0xFF1E90FF),
          coinPrice: coinCost,
          requireAd: true,
          isOwned: isOwned,
          onTap: isOwned
              ? null
              : () => _showPurchaseDialog(itemId, stage.title, coinCost, true),
        );
      },
    );
  }

  Widget _buildEffectList(UserProvider userProvider) {
    final allItems = [...ShopData.noteSkins, ...ShopData.effects];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        final isOwned = userProvider.ownsEffect(item.id);

        return _shopCard(
          name: item.name,
          desc: item.desc,
          icon: item.icon,
          color: item.color,
          coinPrice: item.coinPrice,
          requireAd: false,
          isOwned: isOwned,
          onTap: isOwned
              ? null
              : () => _showPurchaseDialog(item.id, item.name, item.coinPrice, false),
        );
      },
    );
  }

  Widget _shopCard({
    required String name,
    required String desc,
    required IconData icon,
    required Color color,
    required int coinPrice,
    required bool requireAd,
    required bool isOwned,
    VoidCallback? onTap,
  }) {
    return Card(
      color: const Color(0xFF221F42),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white60)),
        trailing: isOwned
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ED573).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppTexts.get('owned'),
                  style: const TextStyle(
                    color: Color(0xFF2ED573),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD166),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(70, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, size: 14),
                    const SizedBox(width: 4),
                    Text('$coinPrice', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    if (requireAd) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.play_circle_outline, size: 14),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

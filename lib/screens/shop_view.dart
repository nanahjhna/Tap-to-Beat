import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/effect_model.dart';
import '../services/ad_reward_helper.dart';
import '../widgets/game_bottom_navigation.dart';
import '../widgets/game_header.dart';
import '../widgets/top_status_bar.dart';
import '../utils/app_texts.dart';
import '../theme/app_theme.dart';

class ShopView extends StatefulWidget {
  const ShopView({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> {
  int _selectedTab = 0; // 0: 음악, 1: 이펙트

  @override
  void initState() {
    super.initState();
    AdRewardHelper.instance.loadAd();
  }

  void _showPurchaseDialog(
    String itemId,
    String itemName,
    int coinCost,
    bool requireAd,
  ) {
    final userProvider = context.read<UserProvider>();
    final canAfford = userProvider.coins >= coinCost;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppTexts.get('confirmPurchase'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              itemName,
              style: const TextStyle(
                color: Color(0xFFFFD166),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: AppColors.accent,
                  size: 20,
                ),
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
                  const Icon(
                    Icons.play_circle_outline,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppTexts.get('adWatchOnce'),
                    style: TextStyle(color: Colors.white70),
                  ),
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
            child: Text(
              AppTexts.get('no'),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: canAfford
                ? () {
                    Navigator.pop(ctx);
                    _purchaseItem(itemId, coinCost, requireAd);
                  }
                : null,
            style: appAccentButtonStyle,
            child: Text(AppTexts.get('yes')),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseItem(
    String itemId,
    int coinCost,
    bool requireAd,
  ) async {
    final userProvider = context.read<UserProvider>();
    final isEffect = itemId.startsWith('effect_') || itemId.startsWith('skin_');

    if (requireAd) {
      final rewardEarned = await AdRewardHelper.instance.showAdAndGetReward();
      if (!rewardEarned) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(AppTexts.get('adFailed'))));
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

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppTexts.get('purchaseSuccess'))));
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppTexts.get('coinNotEnough'))));
    }
  }

@override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final content = SafeArea(
      top: widget.embedded,
      child: Column(
        children: [
          // 상단 재화 표시 & 획득 수단 진입점 (로비와 동일)
          TopStatusBar(onLanguageChanged: () => setState(() {})),

          // 카테고리 탭 (음악, 이펙트)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(AppTexts.get('songs'))),
                ButtonSegment(value: 1, label: Text(AppTexts.get('effects'))),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (v) => setState(() => _selectedTab = v.first),
              style: appSegmentedStyle,
            ),
          ),

          const SizedBox(height: 8),

          // 아이템 목록
          Expanded(
            child: _selectedTab == 0
                ? _buildMusicList(userProvider)
                : _buildEffectList(userProvider),
          ),
        ],
      ),
    );

    return widget.embedded
        ? content
        : Scaffold(
            appBar: const GameHeader(titleKey: ''),
            body: content,
            bottomNavigationBar: const GameBottomNavigation(
              currentIndex: 1,
              showBanner: false,
            ),
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
          desc: item.localizedDesc,
          icon: item.icon,
          color: item.color,
          coinPrice: item.coinPrice,
          requireAd: false,
          isOwned: isOwned,
          isBasic: false,
          onTap: isOwned
              ? null
              : () => _showPurchaseDialog(
                  item.id,
                  item.name,
                  item.coinPrice,
                  false,
                ),
        );
      },
    );
  }

  Widget _buildMusicList(UserProvider userProvider) {
    // 이미 보유했거나 기본곡인 항목을 제외하고 필터링
    final allItems = ShopData.shopMusic.where((item) {
      return !userProvider.ownsSong(item.id);
    }).toList();

    if (allItems.isEmpty) {
      return Center(
        child: Text(
          AppTexts.get('allMusicOwned'),
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];

        return _shopCard(
          name: item.name,
          desc: item.localizedDesc,
          icon: item.icon,
          color: item.color,
          coinPrice: item.coinPrice,
          requireAd: item.requireAd,
          isOwned: false,
          isBasic: item.isBasic,
          onTap: () => _showPurchaseDialog(
            item.id,
            item.name,
            item.coinPrice,
            item.requireAd,
          ),
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
    required bool isBasic,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          desc,
          style: const TextStyle(fontSize: 12, color: Colors.white60),
        ),
        trailing: isOwned
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isBasic ? AppTexts.get('basicMusic') : AppTexts.get('owned'),
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(70, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$coinPrice',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
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

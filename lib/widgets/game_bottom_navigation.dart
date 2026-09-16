import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_texts.dart';
import '../widgets/ad_banner_widget.dart';

class GameBottomNavigation extends StatelessWidget {
  const GameBottomNavigation({
    super.key,
    this.currentIndex = 0,
    this.onTabSelected,
    this.showBanner = true,
  });
  final int currentIndex;
  final ValueChanged<int>? onTabSelected;

  /// 배너 노출 여부 (로비/메인 허브에서만 true 유지)
  final bool showBanner;

  // 📌 4개로 단축 (Lobby: 0, Shop: 1, Inventory: 2, Settings: 3)
  static const List<String> _routes = [
    '/main',
    '/shop',
    '/inventory',
    '/settings',
  ];

  List<BottomNavigationBarItem> get _items => [
    BottomNavigationBarItem(
      icon: const Icon(Icons.home),
      label: AppTexts.get('lobby'),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.shopping_bag),
      label: AppTexts.get('shop'),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.inventory_2),
      label: AppTexts.get('inventory'),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.settings),
      label: AppTexts.get('settings'),
    ),
  ];

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (showBanner) const AdBannerWidget(),
      BottomNavigationBar(
        // 만약 currentIndex가 4 이상(기존 Stage 탭 등)으로 들어올 경우 안전하게 0으로 보정
        currentIndex: currentIndex < _items.length ? currentIndex : 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardTop,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          if (onTabSelected != null) {
            onTabSelected!(index);
            return;
          }
          if (index == 0 || index != currentIndex) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              _routes[index],
              (route) => false,
            );
          }
        },
        items: _items,
      ),
    ],
  );
}

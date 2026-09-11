import 'package:flutter/material.dart';
import '../widgets/ad_banner_widget.dart';

class GameBottomNavigation extends StatelessWidget {
  const GameBottomNavigation({super.key, this.currentIndex = 0, this.onTabSelected});
  final int currentIndex;
  final ValueChanged<int>? onTabSelected;

  // 📌 4개로 단축 (Lobby: 0, Shop: 1, Inventory: 2, Settings: 3)
  static const List<String> _routes = ['/main', '/shop', '/inventory', '/settings'];

  static const List<BottomNavigationBarItem> _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Lobby'),
    BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shop'),
    BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Inventory'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const AdBannerWidget(),
      BottomNavigationBar(
        // 만약 currentIndex가 4 이상(기존 Stage 탭 등)으로 들어올 경우 안전하게 0으로 보정
        currentIndex: currentIndex < _items.length ? currentIndex : 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1B183B),
        selectedItemColor: const Color(0xFFFFD166),
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          if (onTabSelected != null) {
            onTabSelected!(index);
            return;
          }
          if (index == 0 || index != currentIndex) {
            Navigator.pushNamedAndRemoveUntil(context, _routes[index], (route) => false);
          }
        },
        items: _items,
      ),
    ],
  );
}
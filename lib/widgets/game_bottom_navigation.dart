import 'package:flutter/material.dart';
import '../utils/app_texts.dart';

class GameBottomNavigation extends StatelessWidget {
  const GameBottomNavigation({super.key, this.currentIndex = 0, this.onTabSelected});
  final int currentIndex;
  final ValueChanged<int>? onTabSelected;
  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    currentIndex: currentIndex,
    type: BottomNavigationBarType.fixed,
    backgroundColor: const Color(0xFF1B183B),
    selectedItemColor: const Color(0xFFFFD166),
    unselectedItemColor: Colors.white70,
    onTap: (index) {
      if (onTabSelected != null) {
        onTabSelected!(index);
        return;
      }
      const routes = ['/main', '/inventory', '/shop', '/character', '/settings'];
      if (index == 0 || index != currentIndex) {
        Navigator.pushNamedAndRemoveUntil(context, routes[index], (route) => false);
      }
    },
    items: [
      BottomNavigationBarItem(icon: const Icon(Icons.home), label: AppTexts.get('lobby')),
      BottomNavigationBarItem(icon: const Icon(Icons.inventory_2), label: AppTexts.get('inventory')),
      BottomNavigationBarItem(icon: const Icon(Icons.shopping_bag), label: AppTexts.get('shop')),
      BottomNavigationBarItem(icon: const Icon(Icons.person), label: AppTexts.get('character')),
      BottomNavigationBarItem(icon: const Icon(Icons.settings), label: AppTexts.get('settings')),
    ],
  );
}

import 'package:flutter/material.dart';
import 'lobby_tab.dart';
import 'shop_view.dart';
import 'settings_view.dart';
import 'inventory_view.dart';
import 'character_view.dart';
import '../utils/app_texts.dart';
import '../widgets/game_bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> get _tabs => const [
    LobbyTab(),
    InventoryView(embedded: true),
    ShopView(embedded: true),
    CharacterView(embedded: true),
    SettingsView(embedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppTexts.languageNotifier,
      builder: (context, currentLang, child) => Scaffold(
        body: KeyedSubtree(
          key: ValueKey(currentLang),
          child: IndexedStack(index: _currentIndex, children: _tabs),
        ),
        bottomNavigationBar: GameBottomNavigation(
          currentIndex: _currentIndex,
          onTabSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

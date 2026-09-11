import 'package:flutter/material.dart';
import 'lobby_tab.dart';
import 'shop_view.dart';
import 'settings_view.dart';
import 'inventory_view.dart';
import '../utils/app_texts.dart';
import '../widgets/game_bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.selectedTab = 0});
  final int selectedTab;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    // 📌 혹시라도 범위 밖의 인덱스가 들어오면 0으로 방어
    _currentIndex = widget.selectedTab < 4 ? widget.selectedTab : 0;
  }

  // 📌 4개 탭 매핑 (0: Lobby, 1: Shop, 2: Inventory, 3: Settings)
  List<Widget> get _tabs => [
    const LobbyTab(),
    const ShopView(embedded: true),
    const InventoryView(embedded: true),
    const SettingsView(embedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppTexts.languageNotifier,
      builder: (context, currentLang, child) => Scaffold(
        body: KeyedSubtree(
          key: ValueKey(currentLang),
          child: IndexedStack(
            index: _currentIndex < _tabs.length ? _currentIndex : 0,
            children: _tabs,
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameBottomNavigation(
              currentIndex: _currentIndex,
              onTabSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
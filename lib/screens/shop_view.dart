import 'package:flutter/material.dart';
import '../widgets/game_bottom_navigation.dart';
import '../widgets/game_header.dart';
import '../utils/app_texts.dart';

class ShopView extends StatelessWidget {
  const ShopView({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      top: embedded,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _item(
            AppTexts.get('musicPack'),
            AppTexts.get('musicPackDesc'),
            Icons.album_rounded,
            '₩3,300',
            const Color(0xFFFFD166),
          ),
          _item(
            AppTexts.get('starterCoins'),
            AppTexts.get('starterCoinsDesc'),
            Icons.monetization_on_rounded,
            '₩1,100',
            const Color(0xFF2ED573),
          ),
          _item(
            AppTexts.get('energyPack'),
            AppTexts.get('energyPackDesc'),
            Icons.bolt_rounded,
            '₩2,200',
            const Color(0xFF1E90FF),
          ),
          _item(
            AppTexts.get('removeAds'),
            AppTexts.get('removeAdsDesc'),
            Icons.block_rounded,
            '₩4,400',
            const Color(0xFFFF4757),
          ),
        ],
      ),
    );

    return embedded
        ? content
        : Scaffold(
            appBar: const GameHeader(titleKey: 'shop'),
            body: content,
            bottomNavigationBar: const GameBottomNavigation(currentIndex: 2),
          );
  }

  Widget _item(String title, String description, IconData icon, String price, Color accentColor) => Card(
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
          color: accentColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: accentColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(description, style: const TextStyle(fontSize: 12, color: Colors.white60)),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD166),
          foregroundColor: Colors.black,
          minimumSize: const Size(70, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {},
        child: Text(price, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    ),
  );
}

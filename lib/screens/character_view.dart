import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/game_bottom_navigation.dart';
import '../widgets/game_header.dart';

class CharacterView extends StatelessWidget {
  const CharacterView({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      top: embedded,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Consumer<UserProvider>(
              builder: (context, userProvider, child) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded,
                        color: Color(0xFFFFD166), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${userProvider.coins}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // DJ 아바타 원형 비주얼
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF4A3B9F), Color(0xFF1E1940)],
                ),
                border: Border.all(color: const Color(0xFFFFD166), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD166).withValues(alpha: 0.35),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.headphones_rounded,
                size: 70,
                color: Color(0xFFFFD166),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'DJ Beat Master',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              '#1024',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // DJ 프로필 설명 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF221F42),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: const Text(
                '뛰어난 리듬감과 정확한 타이밍으로 관중을 열광시키는 리듬 DJ입니다.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    return embedded
        ? content
        : Scaffold(
            appBar: const GameHeader(titleKey: 'character'),
            body: content,
            bottomNavigationBar: const GameBottomNavigation(currentIndex: 1),
          );
  }
}

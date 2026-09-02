import 'package:flutter/material.dart';
import '../utils/app_texts.dart';
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
              AppTexts.get('characterName'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              '${AppTexts.get('level')} 5  •  ${AppTexts.get('power')} 1,480 Groove',
              style: const TextStyle(color: Color(0xFF69B8FF), fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // DJ 프로필 설명 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF221F42),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTexts.get('characterIntro'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFFD166)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppTexts.get('characterDesc'),
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 리듬 스탯 그리드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1838),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _statRow(AppTexts.get('statAtk'), '98 / 100', 0.98, const Color(0xFF2ED573)),
                  const SizedBox(height: 12),
                  _statRow(AppTexts.get('statDef'), '85 / 100', 0.85, const Color(0xFF1E90FF)),
                  const SizedBox(height: 12),
                  _statRow(AppTexts.get('statSpd'), '92 / 100', 0.92, const Color(0xFFFFA502)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppTexts.get('equippedPerks'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _Perk(
                    icon: Icons.shield_rounded,
                    name: AppTexts.get('quickStrike'),
                    desc: 'BAD 판정을 3회 GOOD으로 보정',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Perk(
                    icon: Icons.bolt_rounded,
                    name: AppTexts.get('vitality'),
                    desc: '50 콤보 이상 시 스코어 1.5배',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/inventory'),
                icon: const Icon(Icons.style_rounded),
                label: Text(AppTexts.get('inventory')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD166),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    return embedded
        ? content
        : Scaffold(
            appBar: const GameHeader(titleKey: 'character'),
            body: content,
            bottomNavigationBar: const GameBottomNavigation(currentIndex: 3),
          );
  }

  Widget _statRow(String label, String valueText, double ratio, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
            Text(valueText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk({required this.icon, required this.name, required this.desc});
  final IconData icon;
  final String name;
  final String desc;

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF221F42),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Colors.white12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFFD166), size: 22),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(fontSize: 11, color: Colors.white60),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

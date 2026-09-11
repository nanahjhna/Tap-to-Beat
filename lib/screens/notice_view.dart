import 'package:flutter/material.dart';
import '../widgets/game_bottom_navigation.dart';
import '../widgets/game_header.dart';
import '../utils/app_texts.dart';

class NoticeView extends StatefulWidget {
  const NoticeView({super.key});

  @override
  State<NoticeView> createState() => _NoticeViewState();
}

class _NoticeViewState extends State<NoticeView> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  bool received = false;

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF151329),
    body: SafeArea(
      child: Column(
        children: [
          // 📌 titleKey 필수 파라미터 추가
          const GameHeader(titleKey: ''),

          Container(
            color: const Color(0xFF1B183B),
            child: TabBar(
              controller: _tab,
              labelColor: const Color(0xFFFFD166),
              unselectedLabelColor: Colors.white60,
              indicatorColor: const Color(0xFFFFD166),
              tabs: [
                Tab(text: AppTexts.get('notice')),
                Tab(text: AppTexts.get('attendance')),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [_notices(), _attendance()],
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: const GameBottomNavigation(),
  );

  Widget _notices() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          AppTexts.get('noItems'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ),
    );
  }

  Widget _attendance() => Padding(
    padding: const EdgeInsets.all(18),
    child: Column(
      children: [
        const SizedBox(height: 10),
        Text(
          AppTexts.get('attendance7Days'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 18),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: List.generate(
            7,
                (i) => Card(
              color: i == 0 ? const Color(0xFFFFD166) : const Color(0xFF2E266D),
              child: Center(
                child: Text(
                  '${i + 1}${AppTexts.get('dayUnit')}\n🎁',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: i == 0 ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD166),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: received ? null : () => setState(() => received = true),
            child: Text(
              received ? AppTexts.get('claimed') : AppTexts.get('claimTodayReward'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}
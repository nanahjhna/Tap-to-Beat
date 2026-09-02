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
    appBar: const GameHeader(titleKey: 'notice'),
    body: Column(
      children: [
        TabBar(
          controller: _tab,
          tabs: [
            Tab(text: AppTexts.get('notice')),
            Tab(text: AppTexts.get('attendance')),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [_notices(), _attendance()],
          ),
        ),
      ],
    ),
    bottomNavigationBar: const GameBottomNavigation(),
  );

  Widget _notices() {
    final noticesList = [
      AppTexts.get('noticeEvent1'),
      AppTexts.get('noticeUpdate1'),
      AppTexts.get('termsOfService'),
    ];
    return ListView(
      children: noticesList.map((title) => ExpansionTile(
        title: Text(title),
        subtitle: const Text('2026.08.29'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(AppTexts.get('noticeContent')),
          ),
        ],
      )).toList(),
    );
  }

  Widget _attendance() => Padding(
    padding: const EdgeInsets.all(18),
    child: Column(
      children: [
        Text(
          AppTexts.get('attendance7Days'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 4,
          children: List.generate(
            7,
            (i) => Card(
              color: i == 0 ? const Color(0xFFFFD166) : null,
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
            onPressed: received ? null : () => setState(() => received = true),
            child: Text(
              received ? AppTexts.get('claimed') : AppTexts.get('claimTodayReward'),
            ),
          ),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import '../widgets/game_bottom_navigation.dart';
import '../widgets/game_header.dart';
import '../utils/app_texts.dart';

class QuestView extends StatefulWidget {
  const QuestView({super.key});

  @override
  State<QuestView> createState() => _QuestViewState();
}

class _QuestViewState extends State<QuestView> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  final claimedDaily = <int>{0};
  final claimedAchieve = <int>{};

  static const List<Map<String, dynamic>> _dailyMissions = [
    {
      'title': '아무 트랙 1회 플레이',
      'desc': '비트 액션을 시작하세요!',
      'current': 1,
      'target': 1,
      'reward': 100,
    },
    {
      'title': 'PERFECT 판정 50회 기록',
      'desc': '정확한 타이밍으로 노트를 타격하세요.',
      'current': 50,
      'target': 50,
      'reward': 150,
    },
    {
      'title': '30 콤보 이상 달성',
      'desc': '리듬을 유지하여 콤보를 이어가세요.',
      'current': 22,
      'target': 30,
      'reward': 120,
    },
    {
      'title': 'Mikoshi Mayhem 트랙 완주',
      'desc': '대표 트랙을 끝까지 플레이하세요.',
      'current': 0,
      'target': 1,
      'reward': 200,
    },
  ];

  static const List<Map<String, dynamic>> _achievements = [
    {
      'title': '첫 풀콤보(FULL COMBO) 달성',
      'desc': 'MISS 없이 곡을 완주하세요.',
      'current': 1,
      'target': 1,
      'reward': 500,
    },
    {
      'title': 'S랭크 5회 달성',
      'desc': '최고 등급으로 곡들을 정복하세요.',
      'current': 3,
      'target': 5,
      'reward': 350,
    },
    {
      'title': '누적 PERFECT 판정 500회',
      'desc': '리듬 마스터의 길을 걸어가세요.',
      'current': 320,
      'target': 500,
      'reward': 400,
    },
    {
      'title': 'HARD 난이도 3곡 클리어',
      'desc': '고난도 비트에 도전하세요.',
      'current': 2,
      'target': 3,
      'reward': 600,
    },
  ];

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF151329),
    appBar: const GameHeader(titleKey: 'quest'),
    body: Column(
      children: [
        TabBar(
          controller: _tab,
          indicatorColor: const Color(0xFFFFD166),
          labelColor: const Color(0xFFFFD166),
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: AppTexts.get('dailyQuest')),
            Tab(text: AppTexts.get('achievement')),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _buildList(_dailyMissions, claimedDaily),
              _buildList(_achievements, claimedAchieve),
            ],
          ),
        ),
      ],
    ),
    bottomNavigationBar: const GameBottomNavigation(),
  );

  Widget _buildList(List<Map<String, dynamic>> items, Set<int> claimedSet) => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: items.length,
    itemBuilder: (_, i) {
      final item = items[i];
      final current = item['current'] as int;
      final target = item['target'] as int;
      final reward = item['reward'] as int;
      final ready = current >= target;
      final isClaimed = claimedSet.contains(i);

      return Card(
        color: const Color(0xFF221F42),
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: ready ? const Color(0xFFFFD166).withValues(alpha: 0.4) : Colors.white12,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD166).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+$reward ${AppTexts.get('coins')}',
                      style: const TextStyle(color: Color(0xFFFFD166), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item['desc'] as String,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (current / target).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ready ? const Color(0xFF2ED573) : const Color(0xFF1E90FF),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$current / $target',
                    style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
                  ),
                  if (isClaimed)
                    Text(
                      AppTexts.get('claimed'),
                      style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 13),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ready ? const Color(0xFFFFD166) : Colors.white12,
                        foregroundColor: ready ? Colors.black : Colors.white38,
                        minimumSize: const Size(80, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: ready
                          ? () {
                              setState(() => claimedSet.add(i));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('+$reward ${AppTexts.get('coins')} 획득!')),
                              );
                            }
                          : null,
                      child: Text(AppTexts.get('claimReward'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

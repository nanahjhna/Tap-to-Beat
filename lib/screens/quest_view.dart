import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/game_bottom_navigation.dart';
import '../widgets/game_header.dart';
import '../utils/app_texts.dart';

class QuestView extends StatefulWidget {
  const QuestView({super.key});

  @override
  State<QuestView> createState() => _QuestViewState();
}

class _QuestViewState extends State<QuestView> {
  int _clearedCount = 0;
  bool _hasRankS = false;
  final Set<String> _claimed = {};

  static const List<Map<String, dynamic>> _achievements = [
    {
      'id': 'first_clear',
      'titleKey': 'questFirstClear',
      'descKey': 'questFirstClearDesc',
      'target': 1,
      'reward': 100,
      'type': 'clear',
    },
    {
      'id': 'clear_5',
      'titleKey': 'questClear5',
      'descKey': 'questClear5Desc',
      'target': 5,
      'reward': 250,
      'type': 'clear',
    },
    {
      'id': 'clear_10',
      'titleKey': 'questClear10',
      'descKey': 'questClear10Desc',
      'target': 10,
      'reward': 500,
      'type': 'clear',
    },
    {
      'id': 'rank_s',
      'titleKey': 'questRankS',
      'descKey': 'questRankSDesc',
      'target': 1,
      'reward': 300,
      'type': 'rank',
    },
  ];

  int _currentFor(Map<String, dynamic> item) {
    if (item['type'] == 'rank') return _hasRankS ? 1 : 0;
    return _clearedCount;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userProvider = context.read<UserProvider>();
    final cleared = await userProvider.getClearedCount();
    final rankS = await userProvider.hasRankS();
    final claimed = <String>{};
    for (final item in _achievements) {
      if (await userProvider.isQuestClaimed(item['id'] as String)) {
        claimed.add(item['id'] as String);
      }
    }
    if (mounted) {
      setState(() {
        _clearedCount = cleared;
        _hasRankS = rankS;
        _claimed
          ..clear()
          ..addAll(claimed);
      });
    }
  }

  Future<void> _claim(Map<String, dynamic> item) async {
    final userProvider = context.read<UserProvider>();
    final questId = item['id'] as String;
    final reward = item['reward'] as int;
    await userProvider.claimQuest(questId);
    await userProvider.addCoins(reward);
    if (!mounted) return;
    setState(() => _claimed.add(questId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('+$reward ${AppTexts.get('coins')} ${AppTexts.get('coinsEarned')}')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bgDeep,
    appBar: const GameHeader(titleKey: ''),
    body: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _achievements.length,
      itemBuilder: (_, i) {
        final item = _achievements[i];
        final current = _currentFor(item);
        final target = item['target'] as int;
        final reward = item['reward'] as int;
        final ready = current >= target;
        final isClaimed = _claimed.contains(item['id']);

        return Card(
          color: AppColors.cardDark2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: ready ? AppColors.accent.withValues(alpha: 0.4) : Colors.white12,
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
                        AppTexts.get(item['titleKey'] as String),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+$reward ${AppTexts.get('coins')}',
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  AppTexts.get(item['descKey'] as String),
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
                      ready ? AppColors.green : AppColors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$current / $target',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white70,
                          fontWeight: FontWeight.w600),
                    ),
                    if (isClaimed)
                      Text(
                        AppTexts.get('claimed'),
                        style: const TextStyle(
                            color: Colors.white38,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ready ? AppColors.accent : Colors.white12,
                          foregroundColor: ready ? Colors.black : Colors.white38,
                          minimumSize: const Size(80, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: ready ? () => _claim(item) : null,
                        child: Text(
                          AppTexts.get('claimReward'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
    bottomNavigationBar: const GameBottomNavigation(showBanner: false),
  );
}

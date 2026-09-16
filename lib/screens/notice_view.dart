import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/game_bottom_navigation.dart';
import '../widgets/game_header.dart';
import '../utils/app_texts.dart';

class NoticeView extends StatefulWidget {
  const NoticeView({super.key});

  @override
  State<NoticeView> createState() => _NoticeViewState();
}

class _NoticeViewState extends State<NoticeView>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  static const List<int> _rewards = [50, 100, 150, 200, 250, 300, 500];
  final Set<String> _claimed = {};
  DateTime? _lastClaim;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadAttendance() async {
    final userProvider = context.read<UserProvider>();
    for (int i = 1; i <= 7; i++) {
      if (await userProvider.isQuestClaimed('attendance_$i')) {
        _claimed.add('attendance_$i');
      }
    }
    final last = await userProvider.getLastAttendanceClaimDate();
    if (!mounted) return;
    setState(() {
      _lastClaim = last;
      _loaded = true;
    });
  }

  // 연속 출석 기준으로 다음 청구 가능한 일차
  int get _nextDay {
    for (int i = 1; i <= 7; i++) {
      if (!_claimed.contains('attendance_$i')) return i;
    }
    return 8;
  }

  bool get _alreadyClaimedToday {
    final now = DateTime.now();
    final last = _lastClaim;
    return last != null &&
        last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
  }

  bool get _canClaimToday => _loaded && _nextDay <= 7 && !_alreadyClaimedToday;

  Future<void> _claimToday() async {
    final userProvider = context.read<UserProvider>();
    final day = _nextDay;
    final reward = _rewards[day - 1];
    await userProvider.claimQuest('attendance_$day');
    await userProvider.addCoins(reward);
    if (!mounted) return;
    setState(() {
      _claimed.add('attendance_$day');
      _lastClaim = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$day${AppTexts.get('dayUnit')} +$reward ${AppTexts.get('coins')}',
        ),
      ),
    );
  }

  String _buttonLabel() {
    if (!_loaded) return AppTexts.get('checking');
    if (_nextDay > 7) return AppTexts.get('claimed');
    if (_alreadyClaimedToday) return AppTexts.get('attendanceDoneToday');
    return AppTexts.get('claimTodayReward');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bgDeep,
    body: SafeArea(
      child: Column(
        children: [
          const GameHeader(titleKey: ''),
          Container(
            color: AppColors.cardTop,
            child: TabBar(
              controller: _tab,
              labelColor: AppColors.accent,
              unselectedLabelColor: Colors.white60,
              indicatorColor: AppColors.accent,
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
    bottomNavigationBar: const GameBottomNavigation(showBanner: false),
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_claimed.length} / 7',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.accent,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        // 7일을 한 줄에 표시 (비대칭 4+3 그리드 제거)
        SizedBox(
          height: 86,
          child: Row(
            children: List.generate(7, (i) {
              final day = i + 1;
              final claimed = _claimed.contains('attendance_$day');
              final isNext = day == _nextDay;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: claimed
                          ? AppColors.green.withValues(alpha: 0.25)
                          : isNext && _canClaimToday
                          ? AppColors.accent.withValues(alpha: 0.18)
                          : AppColors.cellDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: claimed
                            ? AppColors.green
                            : isNext && _canClaimToday
                            ? AppColors.accent.withValues(alpha: 0.7)
                            : Colors.white12,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day${AppTexts.get('dayUnit')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          claimed ? '✓' : '+${_rewards[i]}',
                          style: TextStyle(
                            color: claimed
                                ? AppColors.green
                                : isNext && _canClaimToday
                                ? AppColors.accent
                                : Colors.white54,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _canClaimToday
                  ? AppColors.accent
                  : Colors.white12,
              foregroundColor: _canClaimToday ? Colors.black : Colors.white38,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _canClaimToday ? _claimToday : null,
            child: Text(
              _buttonLabel(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}

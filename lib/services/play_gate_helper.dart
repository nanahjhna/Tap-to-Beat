import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_texts.dart';
import '../theme/app_theme.dart';
import 'ad_reward_helper.dart';

const int refillPlayAmount = 10;

/// 플레이 재화를 1차감 후 게임으로 진입시킨다.
/// 재화가 0이면 광고 시청 다이얼로그를 띄워 [refillPlayAmount] 만큼 충전 후 진입한다.
/// 게임에 진입했으면 true를 반환한다.
Future<bool> tryStartGame(
    BuildContext context, {
      required int stage,
      String difficulty = 'NORMAL',
      bool useReplacement = false,
    }) async {
  final userProvider = context.read<UserProvider>();

  // 1. 플레이 재화가 부족한 경우 광고 시청 처리
  if (userProvider.plays <= 0) {
    // 미리 광고 로드 시도
    AdRewardHelper.instance.loadAd();

    final watchAd = await _showPlayShortageDialog(context);
    if (watchAd != true || !context.mounted) return false;

    // 광고 로딩 indicator 표출 (중복 터치 방지)
    _showLoadingDialog(context);

    final rewardEarned = await AdRewardHelper.instance.showAdAndGetReward();

    if (!context.mounted) return false;
    // 로딩 다이얼로그 닫기
    Navigator.of(context, rootNavigator: true).pop();

    if (!rewardEarned) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTexts.get('adFailed'))),
        );
      }
      return false;
    }

    // 보상 지급 (+10)
    await userProvider.addPlays(refillPlayAmount);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexts.get('adRewardGranted'))),
      );
    }
  }

  // 2. 플레이 재화 1 차감
  final spent = await userProvider.spendPlay();
  if (!spent || !context.mounted) return false;

  // 3. 게임 화면으로 이동
  _navigateToGame(
    context,
    stage: stage,
    difficulty: difficulty,
    useReplacement: useReplacement,
  );
  return true;
}

/// 재화 부족 알림 다이얼로그
Future<bool?> _showPlayShortageDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        AppTexts.get('playNotEnough'),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: Text(
        AppTexts.get('watchAdForPlays'),
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(
            AppTexts.get('back'),
            style: const TextStyle(color: Colors.white54),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: appAccentButtonStyle,
          child: Text(AppTexts.get('watchAd')),
        ),
      ],
    ),
  );
}

/// 광고 표출 준비 중 다중 클릭을 방지하는 오버레이 로딩
void _showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const Center(
      child: CircularProgressIndicator(),
    ),
  );
}

/// 게임 화면 이동
void _navigateToGame(
    BuildContext context, {
      required int stage,
      required String difficulty,
      required bool useReplacement,
    }) {
  final arguments = {'stage': stage, 'difficulty': difficulty};
  if (useReplacement) {
    Navigator.pushReplacementNamed(context, '/gamePlay', arguments: arguments);
  } else {
    Navigator.pushNamed(context, '/gamePlay', arguments: arguments);
  }
}
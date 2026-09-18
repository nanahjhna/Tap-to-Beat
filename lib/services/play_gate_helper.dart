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

  if (userProvider.plays <= 0) {
    await AdRewardHelper.instance.loadAd();
    if (!context.mounted) return false;
    final watchAd = await _showPlayShortageDialog(context);
    if (watchAd != true) return false;
    if (!context.mounted) return false;

    final rewardEarned = await AdRewardHelper.instance.showAdAndGetReward();
    if (!rewardEarned || !context.mounted) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppTexts.get('adFailed'))));
      }
      return false;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexts.get('adRewardGranted'))),
      );
    }
    await userProvider.addPlays(refillPlayAmount);
  }

  final spent = await userProvider.spendPlay();
  if (!spent || !context.mounted) return false;

  _navigateToGame(context, stage: stage, difficulty: difficulty, useReplacement: useReplacement);
  return true;
}

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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_texts.dart';
import 'currency_badge.dart';
import 'language_dialog.dart';
import 'round_icon_button.dart';

/// 로비·상점 공용 상단 재화/메뉴 바 (배지 순서: 코인 → 플레이)
class TopStatusBar extends StatelessWidget {
  const TopStatusBar({super.key, this.onLanguageChanged});

  final VoidCallback? onLanguageChanged;

  void _openLanguageDialog(BuildContext context) {
    showLanguageDialog(context, onLanguageChanged: onLanguageChanged);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Flexible(
            child: Row(
              children: [
                Flexible(
                  child: CurrencyBadge(value: '${userProvider.coins}'),
                ),
                const SizedBox(width: 8),
                CurrencyBadge(
                  value: '${userProvider.plays}',
                  icon: Icons.sports_esports_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              RoundIconButton(
                icon: Icons.bolt,
                label: AppTexts.get('quest'),
                route: '/quest',
              ),
              const SizedBox(width: 8),
              RoundIconButton(
                icon: Icons.campaign,
                label: AppTexts.get('notice'),
                route: '/notice',
              ),
              const SizedBox(width: 8),
              RoundIconButton(
                icon: Icons.language,
                label: AppTexts.get('language'),
                onTap: () => _openLanguageDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
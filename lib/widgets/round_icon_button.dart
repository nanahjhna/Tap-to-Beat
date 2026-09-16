import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 원형 아이콘 바로가기 버튼 (로비/상점 공용)
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.route,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? route;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: AppColors.roundBtn,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap:
              onTap ??
              (route != null ? () => Navigator.pushNamed(context, route!) : null),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: AppColors.accent, size: 19),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 코인/재화 잔액 공용 배지 (로비·상점 상단 표시 공용)
class CurrencyBadge extends StatelessWidget {
  const CurrencyBadge({
    super.key,
    required this.value,
    this.icon = Icons.monetization_on_rounded,
    this.iconSize = 18,
    this.textSize = 16,
    this.decorated = true,
  });

  final String value;
  final IconData icon;
  final double iconSize;
  final double textSize;

  /// true면 배지(둥근 박스), false면 아이콘+숫자만 표시 (상점 헤더용)
  final bool decorated;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.accent, size: iconSize),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: textSize,
            ),
          ),
        ),
      ],
    );

    if (!decorated) return child;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }
}
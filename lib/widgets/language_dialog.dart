import 'package:flutter/material.dart';
import '../utils/app_texts.dart';
import '../theme/app_theme.dart';

/// 언어 선택 다이얼로그 공용 함수
/// onLanguageChanged: 언어 변경 후 호출되는 콜백 (setState 등에 사용)
Future<void> showLanguageDialog(
  BuildContext context, {
  VoidCallback? onLanguageChanged,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(borderRadius: appDialogRadius),
      title: Text(
        '${AppTexts.get('language')} / Language',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageButton(
            langName: '한국어',
            onSelected: () async {
              await AppTexts.setLanguage('한국어');
              if (ctx.mounted) Navigator.pop(ctx);
              onLanguageChanged?.call();
            },
          ),
          const SizedBox(height: 8),
          _LanguageButton(
            langName: 'English',
            onSelected: () async {
              await AppTexts.setLanguage('English');
              if (ctx.mounted) Navigator.pop(ctx);
              onLanguageChanged?.call();
            },
          ),
          const SizedBox(height: 8),
          _LanguageButton(
            langName: '日本語',
            onSelected: () async {
              await AppTexts.setLanguage('日本語');
              if (ctx.mounted) Navigator.pop(ctx);
              onLanguageChanged?.call();
            },
          ),
        ],
      ),
    ),
  );
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.langName, required this.onSelected});
  final String langName;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = AppTexts.currentLang == langName;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.accent : Colors.white12,
          foregroundColor: isSelected ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: onSelected,
        child: Text(
          langName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

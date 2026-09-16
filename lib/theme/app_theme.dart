import 'package:flutter/material.dart';

/// 앱 전역에서 사용하는 컬러 팔레트 (하드코딩 방지)
class AppColors {
  AppColors._();

  // 기본 배경 (로그인/타이틀/등)
  static const Color bgDeep = Color(0xFF151329);
  static const Color bgDeepest = Color(0xFF121024);
  static const Color bgGradientTop = Color(0xFF2A2460);

  // 카드 & 패널
  static const Color cardDark = Color(0xFF201D3D); // 다이얼로그 배경 등
  static const Color cardDark2 = Color(0xFF221F42); // 리스트 카드
  static const Color cardTop = Color(0xFF1B183B); // 헤더/탭 배경

  // 액센트
  static const Color accent = Color(0xFFFFD166); // 메인 브랜드 컬러 (노랑)
  static const Color accentOrange = Color(0xFFFF8B00);

  // 보조 UI
  static const Color bpmBlue = Color(0xFF69B8FF); // BPM/노트수 텍스트
  static const Color roundBtn = Color(0xFF2D2855); // 원형 바로가기 버튼 배경
  static const Color cellDark = Color(0xFF2E266D); // 출석 달력 셀 배경
  static const Color resultBg = Color(0xFF141226); // 리절트 화면 배경

  // 판정 / 난이도 / 랭크 공용 포인트 컬러
  static const Color green = Color(0xFF2ED573);
  static const Color blue = Color(0xFF1E90FF);
  static const Color orange = Color(0xFFFFA502);
  static const Color red = Color(0xFFFF4757);
  static const Color purple = Color(0xFF9B59B6);
}

/// 난이도별 컬러 매핑 (중복 로직 통합)
Color difficultyColor(String diff) {
  switch (diff.toUpperCase()) {
    case 'EASY':
      return AppColors.green;
    case 'NORMAL':
      return AppColors.blue;
    case 'HARD':
      return AppColors.orange;
    case 'EXPERT':
      return AppColors.red;
    case 'MASTER':
      return AppColors.purple;
    default:
      return AppColors.accent;
  }
}

/// 랭크별 컬러 매핑 (중복 로직 통합)
Color rankColor(String rank) {
  switch (rank.toUpperCase()) {
    case 'S':
      return AppColors.accent;
    case 'A':
      return AppColors.green;
    case 'B':
      return AppColors.blue;
    case 'C':
      return AppColors.orange;
    case 'F':
      return AppColors.red;
    default:
      return const Color(0xFF888888);
  }
}

/// 점수를 콤마 구분 문자열로 포맷 (예: 1,234,500)
String formatScore(int score) {
  final s = score.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// 액센트(골드) 고정 버튼 스타일 (구매/확인/시작 등 공용)
ButtonStyle get appAccentButtonStyle => ElevatedButton.styleFrom(
  backgroundColor: AppColors.accent,
  foregroundColor: Colors.black,
  minimumSize: const Size(0, 52),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  textStyle: const TextStyle(fontWeight: FontWeight.w800),
);

/// 상점/인벤토리 공용 SegmentedButton 스타일
ButtonStyle get appSegmentedStyle => SegmentedButton.styleFrom(
  backgroundColor: AppColors.cardTop,
  selectedBackgroundColor: AppColors.accent,
  selectedForegroundColor: Colors.black,
  foregroundColor: Colors.white70,
  side: const BorderSide(color: Colors.white12),
  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
  visualDensity: VisualDensity.compact,
);

/// 공용 카드 모서리
BorderRadius get appCardRadius => BorderRadius.circular(16);
BorderRadius get appDialogRadius => BorderRadius.circular(20);

/// 네온 테마의 앱 전역 ThemeData
class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5C48D3),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.bgDeep,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _NeonPageTransitionsBuilder(),
          TargetPlatform.iOS: _NeonPageTransitionsBuilder(),
          TargetPlatform.windows: _NeonPageTransitionsBuilder(),
          TargetPlatform.macOS: _NeonPageTransitionsBuilder(),
          TargetPlatform.linux: _NeonPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );

    // 공용 다이얼로그 다크 스타일
    return base.copyWith(
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: appDialogRadius,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark2,
        shape: RoundedRectangleBorder(
          borderRadius: appCardRadius,
          side: const BorderSide(color: Colors.white12),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Colors.white12),
    );
  }
}

/// 네온 감성의 Fade + Slide 전환 (상단에서 약하게 슬라이드)
class _NeonPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NeonPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import 'providers/user_provider.dart';
import 'providers/settings_provider.dart';
import 'services/stage_generator.dart';
import 'screens/title_view.dart';
import 'screens/main_screen.dart';
import 'screens/shop_view.dart';
import 'screens/settings_view.dart';
import 'screens/game_play_view.dart';
import 'screens/result_view.dart';
import 'screens/loading_view.dart';
import 'screens/login_view.dart';
import 'screens/account_link_view.dart';
import 'screens/inventory_view.dart';
import 'screens/quest_view.dart';
import 'screens/notice_view.dart';
import 'utils/app_texts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppTexts.loadLanguage();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await MobileAds.instance.initialize();
  }

  final userProvider = UserProvider();
  await userProvider.init();

  final settingsProvider = SettingsProvider();
  await settingsProvider.load();

  await StageGenerator.preloadCharts();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: const TapToBeatGameApp(),
    ),
  );
}

class TapToBeatGameApp extends StatelessWidget {
  const TapToBeatGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapToBeat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C48D3),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF151329),
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
      ),
      // 📌 2. builder 속성을 추가하여 앱 전체에서 UpgradeAlert이 작동하도록 설정
      builder: (context, child) {
        return UpgradeAlert(
          dialogStyle: UpgradeDialogStyle.material,
          upgrader: Upgrader(),
          child: child ?? const SizedBox(),
        );
      },
      initialRoute: '/loading',
      routes: {
        '/': (context) => const TitleView(),
        '/loading': (context) => const LoadingView(),
        '/login': (context) => const LoginView(),
        '/accountLink': (context) => const AccountLinkView(),
        '/main': (context) => const MainScreen(),
        '/shop': (context) => const ShopView(),
        '/settings': (context) => const SettingsView(),
        '/stageSelect': (context) => const MainScreen(selectedTab: 1),
        '/gamePlay': (context) => const GamePlayView(),
        '/result': (context) => const ResultView(),
        '/inventory': (context) => const InventoryView(),
        '/quest': (context) => const QuestView(),
        '/notice': (context) => const NoticeView(),
      },
    );
  }
}
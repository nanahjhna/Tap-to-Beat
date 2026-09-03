import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/app_texts.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({super.key});
  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. 앱 기동 시 pubspec.yaml의 버전 및 빌드 번호 가져오기
    final packageInfo = await PackageInfo.fromPlatform();
    final String version = packageInfo.version; // 예: "1.0.0"
    final String buildNumber = packageInfo.buildNumber; // 예: "4" (5로 올라가면 자동 반영)

    // TODO: 여기서 가져온 version과 buildNumber로 서버 버전 비교 또는 초기화 작업 수행 가능
    debugPrint('App Version: $version+$buildNumber');

    // 2. 최소 로딩 시간 보장 (900ms)
    await Future.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 18),
          Text(AppTexts.get('loading')),
        ],
      ),
    ),
  );
}
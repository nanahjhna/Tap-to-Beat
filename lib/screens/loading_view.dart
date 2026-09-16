import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/app_theme.dart';
import '../utils/app_texts.dart';
import '../widgets/app_version_text.dart';

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
    final String buildNumber =
        packageInfo.buildNumber; // 예: "8" (9로 올리면 스토어와 비교)

    debugPrint('App Version: $version+$buildNumber');

    // 2. 최소 로딩 시간 보장 (900ms) + 강제 업데이트 체크 병렬 수행
    final minDelay = Future.delayed(const Duration(milliseconds: 900));
    final needsUpdate = await _checkForForcedUpdate();
    await minDelay;

    if (!mounted) return;

    // 업데이트가 있으면 여기서 멈춤 (다이얼로그가 흐름 차단). 없으면 진입.
    if (!needsUpdate) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  /// Play스토어에 새 빌드(+9 등)가 있으면 true 반환 + 강제 업데이트 실행.
  /// false면 정상 진입. 체크 실패(오프라인/스토어 미설치 등)해도 false로 폴백.
  Future<bool> _checkForForcedUpdate() async {
    // Android 실기기 + Play스토어 환경에서만 동작. 그 외는 스킵.
    if (kIsWeb || !Platform.isAndroid) return false;

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      debugPrint(
        'InAppUpdate: available=${updateInfo.updateAvailability} '
        'code=${updateInfo.availableVersionCode} '
        'immediateAllowed=${updateInfo.immediateUpdateAllowed}',
      );

      if (updateInfo.updateAvailability != UpdateAvailability.updateAvailable) {
        return false;
      }

      // 강제 업데이트 (Immediate): Play 전체화면으로 전환, 완료 시 앱 재시작.
      if (updateInfo.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
        return true;
      }

      // Immediate가 허용되지 않은 드문 케이스: 닫기 불가 다이얼로그로 차단.
      if (mounted) {
        await _showForcedUpdateDialog();
      }
      return true;
    } catch (e) {
      // 에뮬레이터 / 사이드로드 APK / Play 미설치 / 오프라인 → 정상 진입 폴백
      debugPrint('InAppUpdate check failed (fallback to enter): $e');
      return false;
    }
  }

  Future<void> _showForcedUpdateDialog() async {
    var retrying = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: const Color(0xFF201D3D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              AppTexts.get('updateRequired'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Text(
              AppTexts.get('updateNeeded'),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            actions: [
              ElevatedButton(
                onPressed: retrying
                    ? null
                    : () async {
                        setState(() => retrying = true);
                        try {
                          await InAppUpdate.performImmediateUpdate();
                        } catch (e) {
                          debugPrint('Immediate update retry failed: $e');
                          setState(() => retrying = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD166),
                  foregroundColor: Colors.black,
                ),
                child: Text(
                  retrying ? AppTexts.get('checking') : AppTexts.get('update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bgDeep,
    body: Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.3,
          colors: [AppColors.bgGradientTop, AppColors.bgDeepest],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.headphones_rounded,
                        size: 52,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'TAP TO BEAT',
                      style: TextStyle(
                        letterSpacing: 4,
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(color: AppColors.accentOrange, blurRadius: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 18),
                    Text(
                      AppTexts.get('loading'),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const AppVersionText(
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}

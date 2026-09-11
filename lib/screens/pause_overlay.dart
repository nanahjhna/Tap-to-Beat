import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_texts.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, this.onResume, this.onPause, this.onRetry});
  final VoidCallback? onResume;
  final VoidCallback? onPause;
  final VoidCallback? onRetry; // 📌 다시하기 콜백 추가

  Future<void> _handleResume(BuildContext context) async {
    Navigator.pop(context); // 일시정지 팝업 닫기

    // 화면 중앙에 3, 2, 1 카운트다운 다이얼로그 띄우기
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => const _CountdownDialog(),
    );

    onResume?.call(); // 📌 카운트다운 끝난 후 음악 및 게임 재개
  }

  @override
  Widget build(BuildContext context) {
    onPause?.call(); // 팝업이 뜨는 순간 음악 정지
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 300,
        height: 410,
        decoration: BoxDecoration(
          color: const Color(0xFF1F1B40),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pause_circle_outline, color: Color(0xFFFFD166), size: 48),
            const SizedBox(height: 10),
            Text(
              AppTexts.get('pause'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFD166),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            // 계속하기
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD166),
                  foregroundColor: Colors.black,
                ),
                onPressed: () => _handleResume(context),
                child: Text(AppTexts.get('resume'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            // 📌 다시하기 버튼 (팝업 닫고 음악/게임 초기화 후 처음부터 재생)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(context); // 일시정지 팝업 닫기
                  onRetry?.call();        // 📌 다시하기 함수 호출
                },
                child: Text(AppTexts.get('retry')),
              ),
            ),
            const SizedBox(height: 8),
            // 설정
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
                child: Text(AppTexts.get('settings')),
              ),
            ),
            const SizedBox(height: 8),
            // 로비로 나가기
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4757).withValues(alpha: 0.85),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/main',
                        (route) => false,
                  );
                },
                child: Text(
                  AppTexts.get('quitToLobby'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownDialog extends StatefulWidget {
  const _CountdownDialog();

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  int _count = 3;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_count > 1) {
        setState(() {
          _count--;
        });
      } else {
        _timer.cancel();
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Text(
          '$_count',
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFD166),
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
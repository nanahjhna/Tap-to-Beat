import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_texts.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, this.onResume, this.onRetry});
  final VoidCallback? onResume;
  final VoidCallback? onRetry;

  Future<void> _handleResume(BuildContext context) async {
    Navigator.pop(context); // 일시정지 팝업 닫기

    if (!context.mounted) return;

    // 화면 중앙에 3, 2, 1 카운트다운 다이얼로그 띄우기
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => const _CountdownDialog(),
    );

    onResume?.call(); // 카운트다운 끝난 후 음악 및 게임 재개
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxWidth: 300,
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF201D3D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFD166).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── 상단 아이콘 + 일시정지 타이틀 가로 배치 ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.pause_circle_outline,
                    color: Color(0xFFFFD166),
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppTexts.get('pause'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD166),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── 볼륨 조절 패널 ──
              const _VolumePanel(),
              const SizedBox(height: 16),

              // ── 계속하기 버튼 ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD166),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _handleResume(context),
                  child: Text(
                    AppTexts.get('resume'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── 다시하기 버튼 ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onRetry?.call();
                  },
                  child: Text(AppTexts.get('retry')),
                ),
              ),
              const SizedBox(height: 8),

              // ── 로비로 나가기 버튼 ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red.withValues(alpha: 0.85),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 일시정지 중 노출되는 미니 볼륨 패널 (설정 이동 없이 실시간 반영)
class _VolumePanel extends StatelessWidget {
  const _VolumePanel();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _VolumeRow(
            icon: Icons.music_note,
            color: AppColors.accent,
            label: AppTexts.get('bgmVolume'),
            value: settings.bgmVolume,
            onChanged: settings.setBgmVolume,
          ),
          const SizedBox(height: 2),
          _VolumeRow(
            icon: Icons.volume_up,
            color: AppColors.green,
            label: AppTexts.get('sfxVolume'),
            value: settings.sfxVolume,
            onChanged: settings.setSfxVolume,
          ),
        ],
      ),
    );
  }
}

class _VolumeRow extends StatelessWidget {
  const _VolumeRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color color;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: value,
              activeColor: color,
              inactiveColor: Colors.white12,
              onChanged: onChanged,
            ),
          ),
        ),
        Text(
          '${(value * 100).toInt()}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _CountdownDialog extends StatefulWidget {
  const _CountdownDialog();

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog>
    with SingleTickerProviderStateMixin {
  int _count = 3;
  late final Timer _timer;
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = Tween<double>(
      begin: 1.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _animController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_count > 1) {
        setState(() {
          _count--;
        });
        _animController
          ..reset()
          ..forward();
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
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) => FadeTransition(
            opacity: _fadeAnim,
            child: Transform.scale(scale: _scaleAnim.value, child: child),
          ),
          child: Text(
            '$_count',
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFD166),
              shadows: [Shadow(color: Colors.black, blurRadius: 20)],
            ),
          ),
        ),
      ),
    );
  }
}
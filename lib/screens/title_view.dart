import 'package:flutter/material.dart';
import '../services/user_session.dart';
import '../utils/app_texts.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/app_version_text.dart';
import '../widgets/language_dialog.dart';

class TitleView extends StatefulWidget {
  const TitleView({super.key});

  @override
  State<TitleView> createState() => _TitleViewState();
}

class _TitleViewState extends State<TitleView> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _openLanguageDialog() {
    showLanguageDialog(context, onLanguageChanged: () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151329),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.2,
                colors: [Color(0xFF2A2460), Color(0xFF121024)],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + _pulseController.value * 0.08;
                    final blurRadius = 30.0 + _pulseController.value * 15.0;
                    final spreadRadius = 4.0 + _pulseController.value * 3.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFFFFD166,
                          ).withValues(alpha: 0.12),
                          border: Border.all(
                            color: const Color(
                              0xFFFFD166,
                            ).withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFFD166,
                              ).withValues(alpha: 0.3),
                              blurRadius: blurRadius,
                              spreadRadius: spreadRadius,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.headphones_rounded,
                          size: 64,
                          color: Color(0xFFFFD166),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment(
                            -1.0 + 2.0 * _shimmerController.value,
                            0,
                          ),
                          end: Alignment(
                            -0.5 + 2.0 * _shimmerController.value,
                            0,
                          ),
                          colors: const [
                            Color(0xFFFFD166),
                            Color(0xFFFFFFCC),
                            Color(0xFFFFD166),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds);
                      },
                      child: child,
                    );
                  },
                  child: const Text(
                    'TAP TO BEAT',
                    style: TextStyle(
                      letterSpacing: 4,
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(color: Color(0xFFFF8B00), blurRadius: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final provider = await UserSession.loginProvider();
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(
                          context,
                          provider == null ? '/login' : '/main',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD166),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        AppTexts.get('tapToStart'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 우측 상단 지구본 버튼
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Material(
                  color: const Color(0xFF2D2855),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _openLanguageDialog,
                    child: const Padding(
                      padding: EdgeInsets.all(11),
                      child: Icon(
                        Icons.language,
                        color: Color(0xFFFFD166),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 화면 최하단: 버전 텍스트 + 배너 (Column으로 겹침 방지)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: const AppVersionText(
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
                const AdBannerWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

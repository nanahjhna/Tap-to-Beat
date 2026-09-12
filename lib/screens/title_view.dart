import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/user_session.dart';
import '../utils/app_texts.dart';
import '../widgets/ad_banner_widget.dart';

class TitleView extends StatefulWidget {
  const TitleView({super.key});

  @override
  State<TitleView> createState() => _TitleViewState();
}

class _TitleViewState extends State<TitleView> with TickerProviderStateMixin {
  String _versionString = 'v1.0.0';
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _loadVersion();
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

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _versionString = 'v${packageInfo.version}+${packageInfo.buildNumber}';
      });
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF283593),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${AppTexts.get('language')} / Language',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLangButton(ctx, '한국어'),
            const SizedBox(height: 8),
            _buildLangButton(ctx, 'English'),
            const SizedBox(height: 8),
            _buildLangButton(ctx, '日本語'),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(BuildContext ctx, String langName) {
    final isSelected = AppTexts.currentLang == langName;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFFFFD166) : Colors.white12,
          foregroundColor: isSelected ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: () async {
          await AppTexts.setLanguage(langName);
          if (ctx.mounted) {
            Navigator.pop(ctx);
            setState(() {}); // 언어 변경 후 화면 갱신
          }
        },
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
                          color: const Color(0xFFFFD166).withValues(alpha: 0.12),
                          border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.5), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD166).withValues(alpha: 0.3),
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
                          begin: Alignment(-1.0 + 2.0 * _shimmerController.value, 0),
                          end: Alignment(-0.5 + 2.0 * _shimmerController.value, 0),
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
                        Shadow(
                          color: Color(0xFFFF8B00),
                          blurRadius: 16,
                        ),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        AppTexts.get('tapToStart'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
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
                    onTap: () => _showLanguageDialog(context),
                    child: const Padding(
                      padding: EdgeInsets.all(11),
                      child: Icon(Icons.language, color: Color(0xFFFFD166), size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 화면 최하단에 배치된 배너 위젯
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AdBannerWidget(),
          ),
          // 배너 위쪽에 위치하도록 조정된 버전 텍스트
          Positioned(
            bottom: 65,
            left: 0,
            right: 0,
            child: Text(
              _versionString,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
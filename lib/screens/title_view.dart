import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/user_session.dart';
import '../utils/app_texts.dart';

class TitleView extends StatefulWidget {
  const TitleView({super.key});

  @override
  State<TitleView> createState() => _TitleViewState();
}

class _TitleViewState extends State<TitleView> {
  String _versionString = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _versionString = 'v${packageInfo.version}+${packageInfo.buildNumber}';
      });
    }
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFD166).withValues(alpha: 0.12),
                    border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD166).withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.headphones_rounded,
                    size: 64,
                    color: Color(0xFFFFD166),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'TAP TO BEAT',
                  style: TextStyle(
                    letterSpacing: 4,
                    fontSize: 32,
                    color: Color(0xFFFFD166),
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(
                        color: Color(0xFFFF8B00),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mikoshi Mayhem Edition',
                  style: TextStyle(
                    letterSpacing: 2,
                    fontSize: 14,
                    color: Color(0xFF69B8FF),
                    fontWeight: FontWeight.w600,
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
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Text(
              '$_versionString',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
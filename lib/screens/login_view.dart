import 'package:flutter/material.dart';
import '../services/user_session.dart';
import '../utils/app_texts.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  Future<void> _handleLogin(
    BuildContext context,
    String provider,
    String label,
  ) async {
    await UserSession.saveLoginProvider(provider);
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label - ${AppTexts.get('loginSuccess')}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 2),
            Center(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD166).withValues(alpha: 0.12),
                  border: Border.all(
                    color: const Color(0xFFFFD166).withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.account_circle,
                  color: Color(0xFFFFD166),
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppTexts.get('login'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppTexts.get('loginGuideUpdated'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const Spacer(flex: 2),
            ElevatedButton.icon(
              onPressed: () =>
                  _handleLogin(context, 'guest', AppTexts.get('guest')),
              icon: const Icon(Icons.person_outline),
              label: Text(
                AppTexts.get('guest'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD166),
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.g_mobiledata),
              label: Text(
                AppTexts.get('comingSoon'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white38,
                disabledForegroundColor: Colors.white38,
                side: const BorderSide(color: Colors.white24),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );

    return Scaffold(
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
          content,
        ],
      ),
    );
  }
}

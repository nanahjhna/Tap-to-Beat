import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';
import '../services/user_session.dart';
import '../utils/app_texts.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isSigningIn = false;

  Future<void> _handleGuestLogin() async {
    await UserSession.saveLoginProvider('guest');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
    _showSnackBar('${AppTexts.get('guest')} - ${AppTexts.get('loginSuccess')}');
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isSigningIn = true);
    final result = await GoogleAuthService.instance.signIn();
    if (!mounted) return;
    setState(() => _isSigningIn = false);

    if (result.errorMessage != null) {
      _showSnackBar(
        result.errorMessage == 'cancelled'
            ? AppTexts.get('googleSignInCancelled')
            : AppTexts.get('googleSignInFailed'),
      );
      return;
    }

    await UserSession.saveLoginProvider('google');
    await UserSession.saveGoogleAccount(
      email: result.email,
      displayName: result.displayName,
    );
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
    _showSnackBar('${AppTexts.get('googleLogin')} - ${AppTexts.get('loginSuccess')}');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
              onPressed: _isSigningIn ? null : _handleGuestLogin,
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
              onPressed: _isSigningIn ? null : _handleGoogleLogin,
              icon: _isSigningIn
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.g_mobiledata),
              label: Text(
                _isSigningIn ? AppTexts.get('checking') : AppTexts.get('googleLogin'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
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
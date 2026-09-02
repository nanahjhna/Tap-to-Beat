import 'package:flutter/material.dart';
import '../services/user_session.dart';
import '../utils/app_texts.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  // TODO: 실제 프로젝트에서는 SharedPreferences나 secure_storage 등을 사용하여 로그인 상태 및 제공자(Google, Apple, Guest)를 로컬에 저장하세요.
  // 예시: final prefs = await SharedPreferences.getInstance(); await prefs.setString('login_provider', label);

  Future<void> _handleLogin(BuildContext context, String provider, String label) async {
    await UserSession.saveLoginProvider(provider);
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label - ${AppTexts.get('loginSuccess')}')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(automaticallyImplyLeading: false, title: Text(AppTexts.get('login'))),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Icon(Icons.account_circle, size: 90),
          const SizedBox(height: 16),
          Text(AppTexts.get('loginGuide'), textAlign: TextAlign.center),
          const SizedBox(height: 30),
          _button(context, 'google', AppTexts.get('googleLogin'), Icons.g_mobiledata),
          _button(context, 'apple', AppTexts.get('appleLogin'), Icons.apple),
          _button(context, 'guest', AppTexts.get('guest'), Icons.person_outline),
          const Spacer(),
        ],
      ),
    ),
  );

  Widget _button(BuildContext context, String provider, String label, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: ElevatedButton.icon(
      onPressed: () => _handleLogin(context, provider, label),
      icon: Icon(icon),
      label: Text(label),
    ),
  );
}

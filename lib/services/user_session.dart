import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static const _providerKey = 'login_provider';
  static const _googleEmailKey = 'google_email';
  static const _googleNameKey = 'google_display_name';

  static Future<String?> loginProvider() async =>
      (await SharedPreferences.getInstance()).getString(_providerKey);

  static Future<void> saveLoginProvider(String provider) async =>
      (await SharedPreferences.getInstance()).setString(_providerKey, provider);

  // ── Google 계정 정보 ──

  static Future<String?> googleEmail() async =>
      (await SharedPreferences.getInstance()).getString(_googleEmailKey);

  static Future<String?> googleDisplayName() async =>
      (await SharedPreferences.getInstance()).getString(_googleNameKey);

  static Future<void> saveGoogleAccount({
    String? email,
    String? displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (email != null) await prefs.setString(_googleEmailKey, email);
    if (displayName != null) await prefs.setString(_googleNameKey, displayName);
  }

  static Future<void> clearGoogleAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_googleEmailKey);
    await prefs.remove(_googleNameKey);
  }
}
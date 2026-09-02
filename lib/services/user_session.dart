import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static const _providerKey = 'login_provider';

  static Future<String?> loginProvider() async =>
      (await SharedPreferences.getInstance()).getString(_providerKey);

  static Future<void> saveLoginProvider(String provider) async =>
      (await SharedPreferences.getInstance()).setString(_providerKey, provider);

  static Future<void> logout() async =>
      (await SharedPreferences.getInstance()).remove(_providerKey);
}

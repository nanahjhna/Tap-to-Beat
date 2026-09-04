import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _bgmKey = 'settings_bgm_volume';
  static const _sfxKey = 'settings_sfx_volume';
  static const _offsetKey = 'settings_timing_offset';

  double _bgmVolume = 0.8;
  double _sfxVolume = 0.9;
  double _timingOffset = 0.0; // ms

  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  double get timingOffset => _timingOffset;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _bgmVolume = (prefs.getDouble(_bgmKey) ?? 0.8).clamp(0.0, 1.0);
    _sfxVolume = (prefs.getDouble(_sfxKey) ?? 0.9).clamp(0.0, 1.0);
    _timingOffset = prefs.getDouble(_offsetKey) ?? 0.0;
    notifyListeners();
  }

  Future<void> setBgmVolume(double value) async {
    _bgmVolume = value.clamp(0.0, 1.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_bgmKey, _bgmVolume);
  }

  Future<void> setSfxVolume(double value) async {
    _sfxVolume = value.clamp(0.0, 1.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sfxKey, _sfxVolume);
  }

  Future<void> setTimingOffset(double value) async {
    _timingOffset = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_offsetKey, _timingOffset);
  }
}

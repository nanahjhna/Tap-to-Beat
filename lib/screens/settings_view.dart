import 'package:flutter/material.dart';
import '../services/user_session.dart';
import '../widgets/game_bottom_navigation.dart';
import '../widgets/game_header.dart';
import '../utils/app_texts.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String? _provider;
  double _bgmVolume = 0.8;
  double _sfxVolume = 0.9;
  double _timingOffset = 0.0; // -100ms to +100ms

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  Future<void> _loadProvider() async {
    final value = await UserSession.loginProvider();
    if (mounted) setState(() => _provider = value);
  }

  Future<void> _logout() async {
    await UserSession.logout();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      top: widget.embedded,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // BGM 볼륨 카드
          Card(
            color: const Color(0xFF221F42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.music_note, color: Color(0xFFFFD166)),
                          const SizedBox(width: 8),
                          Text(AppTexts.get('bgmVolume'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text('${(_bgmVolume * 100).toInt()}%', style: const TextStyle(color: Color(0xFFFFD166), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _bgmVolume,
                    activeColor: const Color(0xFFFFD166),
                    inactiveColor: Colors.white12,
                    onChanged: (v) => setState(() => _bgmVolume = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // SFX 타격음 볼륨 카드
          Card(
            color: const Color(0xFF221F42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.volume_up, color: Color(0xFF2ED573)),
                          const SizedBox(width: 8),
                          Text(AppTexts.get('sfxVolume'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text('${(_sfxVolume * 100).toInt()}%', style: const TextStyle(color: Color(0xFF2ED573), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _sfxVolume,
                    activeColor: const Color(0xFF2ED573),
                    inactiveColor: Colors.white12,
                    onChanged: (v) => setState(() => _sfxVolume = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 판정 싱크 오프셋 (Timing Offset)
          Card(
            color: const Color(0xFF221F42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tune_rounded, color: Color(0xFF1E90FF)),
                          const SizedBox(width: 8),
                          Text(AppTexts.get('timingSync'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(
                        '${_timingOffset > 0 ? '+' : ''}${_timingOffset.toInt()} ms',
                        style: const TextStyle(color: Color(0xFF1E90FF), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppTexts.get('timingSyncDesc'),
                    style: const TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                  Slider(
                    value: _timingOffset,
                    min: -100.0,
                    max: 100.0,
                    divisions: 40,
                    activeColor: const Color(0xFF1E90FF),
                    inactiveColor: Colors.white12,
                    onChanged: (v) => setState(() => _timingOffset = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 계정 관리 카드
          Card(
            color: const Color(0xFF221F42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white12),
            ),
            child: ListTile(
              onTap: () => Navigator.pushNamed(context, '/accountLink'),
              title: Text(AppTexts.get('account')),
              subtitle: Text(_provider ?? AppTexts.get('checkingLogin')),
              leading: const Icon(Icons.link, color: Colors.white70),
              trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            ),
          ),
          if (_provider == 'guest')
            Card(
              color: const Color(0xFF221F42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white12),
              ),
              child: ListTile(
                onTap: () => Navigator.pushNamed(context, '/accountLink'),
                title: Text(AppTexts.get('linkGoogle')),
                subtitle: Text(AppTexts.get('currentGuest')),
                leading: const Icon(Icons.g_mobiledata, color: Colors.white70),
                trailing: const Icon(Icons.chevron_right, color: Colors.white70),
              ),
            ),
          if (_provider == 'google')
            Card(
              color: const Color(0xFF221F42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white12),
              ),
              child: ListTile(
                onTap: _logout,
                title: Text(AppTexts.get('logout')),
                subtitle: Text(AppTexts.get('logoutGuide')),
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                trailing: const Icon(Icons.chevron_right, color: Colors.white70),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'TapToBeat Rhythm v1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
          ),
        ],
      ),
    );
    return widget.embedded
        ? content
        : Scaffold(
            appBar: const GameHeader(titleKey: 'settings'),
            body: content,
            bottomNavigationBar: const GameBottomNavigation(currentIndex: 3),
          );
  }
}

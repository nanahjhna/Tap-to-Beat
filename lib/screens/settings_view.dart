import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';
import '../services/user_session.dart';
import '../widgets/game_bottom_navigation.dart';
import '../utils/app_texts.dart';
import 'package:package_info_plus/package_info_plus.dart';

Widget _getVersionString(BuildContext context) {
  return FutureBuilder<PackageInfo>(
    future: PackageInfo.fromPlatform(),
    builder: (context, snapshot) {
      String versionStr = 'TapToBeat Rhythm v1.0.0';
      if (snapshot.hasData) {
        final info = snapshot.data!;
        versionStr = 'TapToBeat Rhythm v${info.version}+${info.buildNumber}';
      }
      return Text(
        versionStr,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
      );
    },
  );
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String? _provider;

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

  Future<void> _convertToGoogle() async {
    await UserSession.saveLoginProvider('google');
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppTexts.get('loginSuccess'))),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
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
                      Text('${(settings.bgmVolume * 100).toInt()}%', style: const TextStyle(color: Color(0xFFFFD166), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: settings.bgmVolume,
                    activeColor: const Color(0xFFFFD166),
                    inactiveColor: Colors.white12,
                    onChanged: (v) => settings.setBgmVolume(v),
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
                      Text('${(settings.sfxVolume * 100).toInt()}%', style: const TextStyle(color: Color(0xFF2ED573), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: settings.sfxVolume,
                    activeColor: const Color(0xFF2ED573),
                    inactiveColor: Colors.white12,
                    onChanged: (v) => settings.setSfxVolume(v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 게스트 전용: Google 계정으로 전환 섹션
          if (_provider == 'guest') ...[
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
                            const Icon(Icons.g_mobiledata, color: Color(0xFF1E90FF)),
                            const SizedBox(width: 8),
                            Text(AppTexts.get('switchToGoogle'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                       ),
                        Text(
                           '+${AppTexts.get('coins')} ${AppTexts.get('bonus')}',
                          style: const TextStyle(color: Color(0xFFFFD166), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                      Text(
                      AppTexts.get('googleSyncDesc'),
                      style: const TextStyle(fontSize: 11, color: Colors.white60),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD166),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: _convertToGoogle,
                        child: Text(AppTexts.get('switchToGoogle'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // 정보 섹션: 크레딧 / 개인정보 처리방침
          Card(
            color: const Color(0xFF221F42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white12),
            ),
            child: Column(
              children: [
                _InfoTile(
                  icon: Icons.music_note_rounded,
                  iconColor: const Color(0xFF9B59B6),
                  label: AppTexts.get('credits'),
                  onTap: () => Navigator.pushNamed(context, '/credits'),
                ),
                const Divider(color: Colors.white12, height: 1),
                _InfoTile(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: const Color(0xFF2ED573),
                  label: AppTexts.get('privacyPolicy'),
                  onTap: () => _openUrl('https://hdevpolic.netlify.app/'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
    return widget.embedded
        ? content
        : Scaffold(
      body: content,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getVersionString(context),
          const GameBottomNavigation(currentIndex: 3),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../utils/app_texts.dart';

class LobbyTab extends StatelessWidget {
  const LobbyTab({super.key});

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
          if (ctx.mounted) Navigator.pop(ctx);
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
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B183B), Color(0xFF110F24)],
          ),
        ),
      ),
      SafeArea(
        top: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 재화 (에너지 제거) 및 정렬된 우측 메뉴 (지구본, 번개, 공지)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _Currency(icon: Icons.monetization_on_rounded, value: '1,250'),
                  Row(
                    children: [
                      _miniShortcut(
                        context,
                        Icons.language,
                        AppTexts.get('language'),
                        onTap: () => _showLanguageDialog(context),
                      ),
                      const SizedBox(width: 8),
                      _miniShortcut(
                        context,
                        Icons.bolt,
                        AppTexts.get('quest'),
                        route: '/quest',
                      ),
                      const SizedBox(width: 8),
                      _miniShortcut(
                        context,
                        Icons.campaign,
                        AppTexts.get('notice'),
                        route: '/notice',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 리듬 타이틀 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD166).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.music_note_rounded, color: Color(0xFFFFD166), size: 24),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTexts.get('nowPlaying'),
                        style: const TextStyle(color: Color(0xFFFFD166), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'TapToBeat: Mikoshi Mayhem',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 피처드 트랙 배너 (Mikoshi Mayhem)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E266D), Color(0xFF1C1842)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.35), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E266D).withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF141226),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.6)),
                          ),
                          child: const Icon(Icons.album_rounded, size: 38, color: Color(0xFFFFD166)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Mikoshi Mayhem',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Matsuri Sound Team',
                                style: TextStyle(fontSize: 13, color: Colors.white70),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'BPM 140  •  NORMAL Lv.3  •  80 NOTES',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF69B8FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/gamePlay', arguments: 1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD166),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 28),
                        label: const Text(
                          'QUICK PLAY (바로 시작)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 전체 트랙 선택 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/stageSelect'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFFFD166), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.queue_music_rounded, color: Color(0xFFFFD166)),
                  label: Text(
                    AppTexts.get('selectStage'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 플레이어 리듬 통계 요약
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF221F42),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _LobbyStat(title: 'DJ RANK', value: 'S-Class'),
                    _LobbyStat(title: 'MAX COMBO', value: '80'),
                    _LobbyStat(title: 'CLEARED', value: '5 Songs'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ],
  );
}

class _LobbyStat extends StatelessWidget {
  const _LobbyStat({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFFFD166))),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.white60)),
      ],
    );
  }
}

Widget _miniShortcut(
    BuildContext context,
    IconData icon,
    String label, {
      String? route,
      VoidCallback? onTap,
    }) => Tooltip(
  message: label,
  child: Material(
    color: const Color(0xFF2D2855),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap ?? (route != null ? () => Navigator.pushNamed(context, route) : null),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Icon(icon, color: const Color(0xFFFFD166), size: 20),
      ),
    ),
  ),
);

class _Currency extends StatelessWidget {
  const _Currency({required this.icon, required this.value});
  final IconData icon;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD166), size: 18),
        const SizedBox(width: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    ),
  );
}
import 'package:flutter/material.dart';
import '../utils/app_texts.dart';

class ShopItem {
  final String id;
  final String name;
  final String desc;
  final String? descKey;
  final int coinPrice;
  final bool requireAd;
  final Color color;
  final IconData icon;
  final String type; // 'song' or 'effect'
  final bool isBasic; // 기본음악 true, 상점음악 false
  final int stageNumber; // stage 매칭용 (song인 경우만 사용)
  final int? bpm;
  final String? artist;
  final String? audioPath;
  final String? chartPath;
  final int? baseRewardCoins;

  const ShopItem({
    required this.id,
    required this.name,
    required this.desc,
    this.descKey,
    required this.coinPrice,
    this.requireAd = false,
    required this.color,
    required this.icon,
    required this.type,
    this.isBasic = false,
    this.stageNumber = 0,
    this.bpm,
    this.artist,
    this.audioPath,
    this.chartPath,
    this.baseRewardCoins,
  });

  /// 현재 언어로 번역된 설명 (descKey가 없으면 기본 desc 사용)
  String get localizedDesc => descKey != null ? AppTexts.get(descKey!) : desc;
}

class ShopData {
  static const List<ShopItem> effects = [
    ShopItem(
      id: 'effect_spark',
      name: 'Matsuri Gold Spark',
      desc: '축제 분위기의 황금색 타격 파티클',
      descKey: 'effectSparkDesc',
      coinPrice: 300,
      color: Color(0xFFFFD166),
      icon: Icons.flare_rounded,
      type: 'effect',
    ),
    ShopItem(
      id: 'effect_cyan',
      name: 'Cyber Wave Cyan',
      desc: '미래지향적 사이버 블루 이펙트',
      descKey: 'effectCyanDesc',
      coinPrice: 300,
      color: Color(0xFF1E90FF),
      icon: Icons.waves_rounded,
      type: 'effect',
    ),
    ShopItem(
      id: 'effect_pink',
      name: 'Sakura Pulse Pink',
      desc: '벚꽃 테마의 화사한 핑크 이펙트',
      descKey: 'effectPinkDesc',
      coinPrice: 400,
      color: Color(0xFFFF6B81),
      icon: Icons.local_florist_rounded,
      type: 'effect',
    ),
    ShopItem(
      id: 'effect_thunder',
      name: 'Electric Thunder',
      desc: '콤보 폭발 시 전격 이펙트 발생',
      descKey: 'effectThunderDesc',
      coinPrice: 400,
      color: Color(0xFFFFA502),
      icon: Icons.flash_on_rounded,
      type: 'effect',
    ),
    ShopItem(
      id: 'effect_pixel',
      name: '8-Bit Retro Pixel',
      desc: '도트 그래픽 스타일의 아케이드 이펙트',
      descKey: 'effectPixelDesc',
      coinPrice: 350,
      color: Color(0xFF9B59B6),
      icon: Icons.grid_on_rounded,
      type: 'effect',
    ),
  ];

  static const List<ShopItem> noteSkins = [
    ShopItem(
      id: 'skin_neon',
      name: 'Classic Neon Green',
      desc: '프로토타입 오리지널 네온 그린 노트',
      descKey: 'skinNeonDesc',
      coinPrice: 0,
      color: Color(0xFF2ED573),
      icon: Icons.horizontal_rule_rounded,
      type: 'effect',
    ),
    ShopItem(
      id: 'skin_cyan',
      name: 'Cyber Wave Cyan',
      desc: '미래지향적 사이버 블루 노트 바',
      descKey: 'skinCyanDesc',
      coinPrice: 250,
      color: Color(0xFF1E90FF),
      icon: Icons.horizontal_rule_rounded,
      type: 'effect',
    ),
    ShopItem(
      id: 'skin_pink',
      name: 'Sakura Pulse Pink',
      desc: '벚꽃 테마의 화사한 핑크 노트',
      descKey: 'skinPinkDesc',
      coinPrice: 300,
      color: Color(0xFFFF6B81),
      icon: Icons.horizontal_rule_rounded,
      type: 'effect',
    ),
    ShopItem(
      id: 'skin_pixel',
      name: '8-Bit Retro Pixel',
      desc: '도트 그래픽 스타일의 아케이드 노트',
      descKey: 'skinPixelDesc',
      coinPrice: 350,
      color: Color(0xFF9B59B6),
      icon: Icons.horizontal_rule_rounded,
      type: 'effect',
    ),
  ];

  static const List<ShopItem> allSongs = [
    ShopItem(
      id: 'music_mikoshi_mayhem',
      name: 'Mikoshi Mayhem',
      desc: 'dova-s.jp',
      coinPrice: 0,
      color: Color(0xFF2ED573),
      icon: Icons.music_note_rounded,
      type: 'music',
      isBasic: true,
      stageNumber: 1,
      bpm: 0,
      artist: 'MFP【Marron Fields Production】',
      audioPath: 'sounds/MikoshiMayhem.mp3',
      chartPath: 'assets/charts/MikoshiMayhem.json',
      baseRewardCoins: 200,
    ),
    ShopItem(
      id: 'music_twilight_highway',
      name: 'Twilight Highway',
      desc: 'dova-s.jp',
      coinPrice: 0,
      color: Color(0xFF9B59B6),
      icon: Icons.music_note_rounded,
      type: 'music',
      isBasic: true,
      stageNumber: 2,
      bpm: 0,
      artist: '秦暁（ハタ アキラ）',
      audioPath: 'sounds/TwilightHighway.mp3',
      chartPath: 'assets/charts/TwilightHighway.json',
      baseRewardCoins: 200,
    ),
    ShopItem(
      id: 'music_Fighting_spirits',
      name: 'Fighting_spirits',
      desc: 'dova-s.jp',
      coinPrice: 1000,
      requireAd: true,
      color: Color(0xFF9B59B6),
      icon: Icons.music_note_rounded,
      type: 'music',
      isBasic: false,
      stageNumber: 3,
      bpm: 0,
      artist: 'Causality Sound（コーザリティ サウンド）',
      audioPath: 'sounds/FightingSpirits.mp3',
      chartPath: 'assets/charts/FightingSpirits.json',
      baseRewardCoins: 200,
    ),
  ];

  static List<ShopItem> get shopMusic => allSongs.where((s) => s.type == 'music').toList();

  /// 스테이지 번호로 상점 곡을 찾아 반환 (없으면 null)
  static ShopItem? songByStage(int stageNumber) {
    for (final s in allSongs) {
      if (s.type == 'music' && s.stageNumber == stageNumber) return s;
    }
    return null;
  }
}

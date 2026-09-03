import 'package:flutter/material.dart';

class EffectItem {
  final String id;
  final String name;
  final String desc;
  final int price;
  final Color color;
  final IconData icon;

  const EffectItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
    required this.color,
    required this.icon,
  });
}

class ShopItem {
  final String id;
  final String name;
  final String desc;
  final int coinPrice;
  final bool requireAd;
  final Color color;
  final IconData icon;
  final String type; // 'song' or 'effect'

  const ShopItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.coinPrice,
    this.requireAd = false,
    required this.color,
    required this.icon,
    required this.type,
  });
}

class ShopData {
  static const List<ShopItem> effects = [
    ShopItem(
      id: 'effect_spark',
      name: 'Matsuri Gold Spark',
      desc: '축제 분위기의 황금색 타격 파티클',
      coinPrice: 300,
      color: Color(0xFFFFD166),
      icon: Icons.flare_rounded,
      type: 'effect',
    ),
    ShopItem(
      id: 'effect_cyan',
      name: 'Cyber Wave Cyan',
      desc: '미래지향적 사이버 블루 이펙트',
      coinPrice: 300,
      color: Color(0xFF1E90FF),
      icon: Icons.waves_rounded,
      type: 'effect',
    ),
    ShopItem(
      id: 'effect_pink',
      name: 'Sakura Pulse Pink',
      desc: '벚꽃 테마의 화사한 핑크 이펙트',
      coinPrice: 400,
      color: Color(0xFFFF6B81),
      icon: Icons.local_florist_rounded,
      type: 'effect',
    ),
    ShopItem(
      id: 'effect_thunder',
      name: 'Electric Thunder',
      desc: '콤보 폭발 시 전격 이펙트 발생',
      coinPrice: 400,
      color: Color(0xFFFFA502),
      icon: Icons.flash_on_rounded,
      type: 'effect',
    ),
    ShopItem(
      id: 'effect_pixel',
      name: '8-Bit Retro Pixel',
      desc: '도트 그래픽 스타일의 아케이드 이펙트',
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
      coinPrice: 0,
      color: Color(0xFF2ED573),
      icon: Icons.horizontal_rule_rounded,
      type: 'effect',
    ),
    ShopItem(
      id: 'skin_cyan',
      name: 'Cyber Wave Cyan',
      desc: '미래지향적 사이버 블루 노트 바',
      coinPrice: 250,
      color: Color(0xFF1E90FF),
      icon: Icons.horizontal_rule_rounded,
      type: 'effect',
    ),
    ShopItem(
      id: 'skin_pink',
      name: 'Sakura Pulse Pink',
      desc: '벚꽃 테마의 화사한 핑크 노트',
      coinPrice: 300,
      color: Color(0xFFFF6B81),
      icon: Icons.horizontal_rule_rounded,
      type: 'effect',
    ),
    ShopItem(
      id: 'skin_pixel',
      name: '8-Bit Retro Pixel',
      desc: '도트 그래픽 스타일의 아케이드 노트',
      coinPrice: 350,
      color: Color(0xFF9B59B6),
      icon: Icons.horizontal_rule_rounded,
      type: 'effect',
    ),
  ];
}

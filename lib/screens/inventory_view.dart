import 'package:flutter/material.dart';
import '../widgets/game_bottom_navigation.dart';
import '../widgets/game_header.dart';
import '../utils/app_texts.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  int _category = 0;
  int? _selected;
  final _equipped = <int>{0, 2};

  static const List<Map<String, dynamic>> _customItems = [
    {
      'name': 'Classic Neon Green',
      'type': 1, // Note Skin
      'color': Color(0xFF2ED573),
      'desc': '프로토타입 오리지널 네온 그린 노트',
    },
    {
      'name': 'Matsuri Gold Spark',
      'type': 2, // Hit Effect
      'color': Color(0xFFFFD166),
      'desc': '축제 분위기의 황금색 타격 파티클',
    },
    {
      'name': 'Cyber Wave Cyan',
      'type': 1, // Note Skin
      'color': Color(0xFF1E90FF),
      'desc': '미래지향적 사이버 블루 노트 바',
    },
    {
      'name': 'Sakura Pulse Pink',
      'type': 1, // Note Skin
      'color': Color(0xFFFF6B81),
      'desc': '벚꽃 테마의 화사한 핑크 노트',
    },
    {
      'name': 'Electric Thunder',
      'type': 2, // Hit Effect
      'color': Color(0xFFFFA502),
      'desc': '콤보 폭발 시 전격 이펙트 발생',
    },
    {
      'name': '8-Bit Retro Pixel',
      'type': 1, // Note Skin
      'color': Color(0xFF9B59B6),
      'desc': '도트 그래픽 스타일의 아케이드 노트',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _customItems.asMap().entries.where((entry) {
      if (_category == 0) return true;
      return entry.value['type'] == _category;
    }).toList();

    final content = SafeArea(
      top: widget.embedded,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(AppTexts.get('all'))),
                ButtonSegment(value: 1, label: Text(AppTexts.get('equipment'))), // 노트 스킨
                ButtonSegment(value: 2, label: Text(AppTexts.get('consumable'))), // 타격 이펙트
              ],
              selected: {_category},
              onSelectionChanged: (v) => setState(() => _category = v.first),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final originalIndex = filtered[i].key;
                final itemData = filtered[i].value;
                return _item(originalIndex, itemData);
              },
            ),
          ),
          if (_selected != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _action,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD166),
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    _equipped.contains(_selected)
                        ? AppTexts.get('unequip')
                        : AppTexts.get('useItem'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return widget.embedded
        ? content
        : Scaffold(
            appBar: const GameHeader(titleKey: 'inventory'),
            body: content,
            bottomNavigationBar: const GameBottomNavigation(currentIndex: 1),
          );
  }

  Widget _item(int index, Map<String, dynamic> data) {
    final equipped = _equipped.contains(index);
    final color = data['color'] as Color;

    return Card(
      color: const Color(0xFF221F42),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: equipped ? color.withValues(alpha: 0.8) : Colors.white12,
          width: equipped ? 1.5 : 1.0,
        ),
      ),
      child: CheckboxListTile(
        value: _selected == index,
        onChanged: (_) => setState(() => _selected = _selected == index ? null : index),
        secondary: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Icon(
            data['type'] == 1 ? Icons.horizontal_rule_rounded : Icons.flare_rounded,
            color: color,
            size: 26,
          ),
        ),
        title: Text(
          data['name'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          equipped
              ? '${AppTexts.get('equipped')} • ${data['desc']}'
              : data['desc'] as String,
          style: TextStyle(
            fontSize: 12,
            color: equipped ? const Color(0xFFFFD166) : Colors.white60,
          ),
        ),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  void _action() {
    final item = _selected!;
    final willEquip = !_equipped.contains(item);
    setState(() {
      if (willEquip) {
        _equipped.add(item);
      } else {
        _equipped.remove(item);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          willEquip ? AppTexts.get('itemEquipped') : AppTexts.get('itemUnequipped'),
        ),
      ),
    );
  }
}
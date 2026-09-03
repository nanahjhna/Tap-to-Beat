import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/effect_model.dart';
import '../services/stage_generator.dart';
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
  int _category = 0; // 0: 전체, 1: 곡, 2: 이펙트

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final content = SafeArea(
      top: widget.embedded,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(AppTexts.get('all'))),
                ButtonSegment(value: 1, label: Text(AppTexts.get('songs'))),
                ButtonSegment(value: 2, label: Text(AppTexts.get('effects'))),
              ],
              selected: {_category},
              onSelectionChanged: (v) => setState(() => _category = v.first),
            ),
          ),
          Expanded(
            child: _buildItemList(userProvider),
          ),
        ],
      ),
    );

    return widget.embedded
        ? content
        : Scaffold(
            appBar: const GameHeader(titleKey: 'inventory'),
            body: content,
            bottomNavigationBar: const GameBottomNavigation(currentIndex: 3),
          );
  }

  Widget _buildItemList(UserProvider userProvider) {
    final items = <_InventoryItemData>[];

    // 소유한 곡 추가
    if (_category == 0 || _category == 1) {
      for (final stage in StageGenerator.allStages) {
        final itemId = 'stage_${stage.stageNumber}';
        if (userProvider.ownsSong(itemId)) {
          items.add(_InventoryItemData(
            id: itemId,
            name: stage.title,
            desc: '${stage.artist} • BPM ${stage.bpm} • ${stage.difficulty}',
            type: 'song',
            color: const Color(0xFF1E90FF),
            icon: Icons.music_note_rounded,
            isEquipped: userProvider.isSongEquipped(itemId),
          ));
        }
      }
    }

    // 소유한 이펙트 추가
    if (_category == 0 || _category == 2) {
      for (final effect in ShopData.effects) {
        if (userProvider.ownsEffect(effect.id)) {
          items.add(_InventoryItemData(
            id: effect.id,
            name: effect.name,
            desc: effect.desc,
            type: 'effect',
            color: effect.color,
            icon: effect.icon,
            isEquipped: userProvider.isEffectEquipped(effect.id),
          ));
        }
      }
      for (final skin in ShopData.noteSkins) {
        if (userProvider.ownsEffect(skin.id)) {
          items.add(_InventoryItemData(
            id: skin.id,
            name: skin.name,
            desc: skin.desc,
            type: 'effect',
            color: skin.color,
            icon: skin.icon,
            isEquipped: userProvider.isEffectEquipped(skin.id),
          ));
        }
      }
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(
              AppTexts.get('noItems'),
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _inventoryCard(userProvider, item);
      },
    );
  }

  Widget _inventoryCard(UserProvider userProvider, _InventoryItemData item) {
    return Card(
      color: const Color(0xFF221F42),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: item.isEquipped
              ? item.color.withValues(alpha: 0.8)
              : Colors.white12,
          width: item.isEquipped ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: item.color, width: 1.5),
          ),
          child: Icon(item.icon, color: item.color, size: 26),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          item.isEquipped
              ? '${AppTexts.get('equipped')} • ${item.desc}'
              : item.desc,
          style: TextStyle(
            fontSize: 12,
            color: item.isEquipped ? const Color(0xFFFFD166) : Colors.white60,
          ),
        ),
        trailing: Switch(
          value: item.isEquipped,
          onChanged: (value) {
            if (item.type == 'song') {
              userProvider.toggleEquipSong(item.id);
            } else {
              userProvider.toggleEquipEffect(item.id);
            }
          },
          activeThumbColor: const Color(0xFFFFD166),
          activeTrackColor: const Color(0xFFFFD166).withValues(alpha: 0.3),
          inactiveThumbColor: Colors.white54,
          inactiveTrackColor: Colors.white12,
        ),
      ),
    );
  }
}

class _InventoryItemData {
  final String id;
  final String name;
  final String desc;
  final String type;
  final Color color;
  final IconData icon;
  final bool isEquipped;

  const _InventoryItemData({
    required this.id,
    required this.name,
    required this.desc,
    required this.type,
    required this.color,
    required this.icon,
    required this.isEquipped,
  });
}

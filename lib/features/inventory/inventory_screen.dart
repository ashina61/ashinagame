import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';

enum ItemKind { resource, equipment, other }

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _tab = 0;

  static const _items = [
    (GameAssets.iconItemWood, 'Odun', 320, ItemKind.resource),
    (GameAssets.iconItemLeather, 'Deri', 180, ItemKind.resource),
    (GameAssets.iconIronOre, 'Demir Cevheri', 210, ItemKind.resource),
    (GameAssets.iconItemThread, 'İplik', 140, ItemKind.resource),
    (GameAssets.iconItemWheat, 'Buğday', 85, ItemKind.resource),
    (GameAssets.iconIronOre, 'Taş', 60, ItemKind.resource),
    (GameAssets.iconItemLeather, 'Kürk', 40, ItemKind.resource),
    (GameAssets.iconItemWool, 'Yün', 35, ItemKind.resource),
    (GameAssets.iconItemSalt, 'Tuz', 25, ItemKind.resource),
    (GameAssets.iconItemPotion, 'İksir', 12, ItemKind.other),
    (GameAssets.iconMedallionHorse, 'At', 3, ItemKind.other),
    (GameAssets.iconItemBow, 'Yay', 1, ItemKind.equipment),
    (GameAssets.iconItemArmor, 'Zırh', 1, ItemKind.equipment),
    (GameAssets.iconItemSword, 'Kılıç', 1, ItemKind.equipment),
    (GameAssets.iconItemShield, 'Kalkan', 1, ItemKind.equipment),
    (GameAssets.iconItemHelmet, 'Miğfer', 1, ItemKind.equipment),
  ];

  List<(String, String, int, ItemKind)> get _filtered {
    return switch (_tab) {
      1 => _items.where((i) => i.$4 == ItemKind.resource).toList(),
      2 => _items.where((i) => i.$4 == ItemKind.equipment).toList(),
      3 => _items.where((i) => i.$4 == ItemKind.other).toList(),
      _ => _items,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            const OrnateHeader(title: 'Envanter', showBack: true),
            OrnateTabs(
              tabs: const ['Tümü', 'Kaynaklar', 'Ekipman', 'Diğer'],
              index: _tab,
              onChanged: (value) => setState(() => _tab = value),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.74,
                children: [
                  for (final (asset, label, count, _) in _filtered)
                    ItemSlot(asset: asset, label: label, count: '$count'),
                ],
              ),
            ),
            Container(
              height: 42,
              margin: const EdgeInsets.fromLTRB(12, 2, 12, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(GameAssets.uiPanelField),
                  fit: BoxFit.fill,
                ),
              ),
              child: Row(
                children: [
                  const Text('Kapasite', style: AppTextStyles.section),
                  const Spacer(),
                  const Text('23/60', style: AppTextStyles.value),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '+',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

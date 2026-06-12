import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/utils/resource_visuals.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/craft_recipes.dart';
import '../../game/models/craft.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';
import '../atelier/atelier_screen.dart';

class _Entry {
  const _Entry(this.asset, this.label, this.count, this.kind);

  final String asset;
  final String label;
  final int count;
  final CraftKind? kind; // null marks raw resources
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _tab = 0;

  static const _carriedResources = [
    ResourceType.gold,
    ResourceType.food,
    ResourceType.wood,
    ResourceType.leather,
    ResourceType.horse,
  ];

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;

    final entries = <_Entry>[
      for (final type in _carriedResources)
        _Entry(
          ResourceVisuals.icon(type),
          type.label,
          state.resource(type),
          null,
        ),
      for (final recipe in CraftRecipes.all)
        if (state.craftedCount(recipe.id) > 0)
          _Entry(
            craftIcon(recipe.id),
            recipe.name,
            state.craftedCount(recipe.id),
            recipe.kind,
          ),
    ];

    final filtered = switch (_tab) {
      1 => entries.where((e) => e.kind == null).toList(),
      2 => entries.where((e) => e.kind == CraftKind.equipment).toList(),
      3 => entries.where((e) => e.kind == CraftKind.other).toList(),
      _ => entries,
    };

    final carried = entries.fold(0, (sum, e) => sum + e.count);

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
              child: filtered.isEmpty
                  ? Center(
                      child: OrnatePanel(
                        child: Text(
                          _tab == 2
                              ? 'Henüz ekipman yok. Atölyede üret.'
                              : 'Bu bölme şimdilik boş.',
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : GridView.count(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.74,
                      children: [
                        for (final entry in filtered)
                          ItemSlot(
                            asset: entry.asset,
                            label: entry.label,
                            labelAbove: true,
                            count: '${entry.count}',
                          ),
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
                  const Text('Taşınan', style: AppTextStyles.section),
                  const Spacer(),
                  Text('$carried birim', style: AppTextStyles.value),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

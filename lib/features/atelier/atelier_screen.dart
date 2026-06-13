import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/craft_recipes.dart';
import '../../game/models/craft.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';

/// Atlas icons for each workshop recipe.
String craftIcon(String recipeId) => switch (recipeId) {
      'wood_shield' => GameAssets.iconItemShieldWood,
      'composite_bow' => GameAssets.iconItemBow,
      'leather_armor' => GameAssets.iconItemArmor,
      'iron_sword' => GameAssets.iconItemSword,
      'saddle' => GameAssets.iconItemSaddle,
      'fur_cloak' => GameAssets.iconItemFur,
      _ => GameAssets.iconItemShield,
    };

class AtelierScreen extends StatefulWidget {
  const AtelierScreen({super.key});

  @override
  State<AtelierScreen> createState() => _AtelierScreenState();
}

class _AtelierScreenState extends State<AtelierScreen> {
  int _tab = 0;
  String _selectedId = CraftRecipes.all.first.id;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final selected = CraftRecipes.byId(_selectedId) ?? CraftRecipes.all.first;

    return OrnateScaffold(
      child: Column(
        children: [
          const OrnateHeader(title: 'Atölye'),
          OrnateTabs(
            tabs: const ['Üretim', 'Geliştirme', 'Tamir'],
            index: _tab,
            onChanged: (value) => setState(() => _tab = value),
          ),
          Expanded(
            child: _tab == 0
                ? ListView(
                    padding: const EdgeInsets.only(bottom: 8),
                    children: [
                      const SectionPlaque('ÜRETİM KUYRUĞU'),
                      for (final job in state.craftQueue) _QueueRow(job: job),
                      for (var i = state.craftQueue.length;
                          i < CraftRecipes.maxQueue;
                          i++)
                        OrnatePanel(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Kuyruk Boş',
                                style: AppTextStyles.meta.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SectionPlaque('ÜRETİLEBİLİR EŞYALAR'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.78,
                          children: [
                            for (final recipe in CraftRecipes.all)
                              ItemSlot(
                                asset: craftIcon(recipe.id),
                                label: recipe.name,
                                count: state.craftedCount(recipe.id) > 0
                                    ? 'x${state.craftedCount(recipe.id)}'
                                    : '${recipe.days}g',
                                selected: recipe.id == _selectedId,
                                onTap: () =>
                                    setState(() => _selectedId = recipe.id),
                              ),
                          ],
                        ),
                      ),
                      _RecipeDetail(recipe: selected),
                    ],
                  )
                : Center(
                    child: OrnatePanel(
                      child: Text(
                        _tab == 1
                            ? 'Geliştirme tezgâhı yakında açılacak.'
                            : 'Tamir tezgâhı yakında açılacak.',
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ),
          Container(
            height: 44,
            margin: const EdgeInsets.fromLTRB(10, 2, 10, 6),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(GameAssets.uiBarSlots),
                fit: BoxFit.fill,
              ),
            ),
            child: Row(
              children: [
                for (final (asset, type) in const [
                  (GameAssets.iconItemWood, ResourceType.wood),
                  (GameAssets.iconItemLeather, ResourceType.leather),
                  (GameAssets.iconCoinGold, ResourceType.gold),
                  (GameAssets.iconItemHorse, ResourceType.horse),
                ])
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(asset, width: 20, height: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${state.resource(type)}',
                          style: AppTextStyles.value.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({required this.job});

  final CraftJob job;

  @override
  Widget build(BuildContext context) {
    final recipe = CraftRecipes.byId(job.recipeId);
    if (recipe == null) {
      return const SizedBox.shrink();
    }
    final fraction = (recipe.days - job.daysLeft) / recipe.days;
    return OrnatePanel(
      child: Row(
        children: [
          Image.asset(craftIcon(recipe.id), height: 44),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.name, style: AppTextStyles.bodyStrong),
                const SizedBox(height: 4),
                StatBar(fraction: fraction, height: 10),
                const SizedBox(height: 3),
                Text(
                  '⏳ ${job.daysLeft} gün kaldı',
                  style: AppTextStyles.meta,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeDetail extends StatelessWidget {
  const _RecipeDetail({required this.recipe});

  final CraftRecipe recipe;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(recipe.name, style: AppTextStyles.bodyStrong),
          const SizedBox(height: 4),
          Text(
            'Süre: ${recipe.days} gün • Sefer başarısına +%'
            '${recipe.successBonus}',
            style: AppTextStyles.meta,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final entry in recipe.costs.entries) ...[
                Image.asset(
                  switch (entry.key) {
                    ResourceType.wood => GameAssets.iconItemWood,
                    ResourceType.leather => GameAssets.iconItemLeather,
                    ResourceType.stone ||
                    ResourceType.iron =>
                      GameAssets.iconItemStone,
                    _ => GameAssets.iconCoinGold,
                  },
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    '${entry.value}',
                    style: AppTextStyles.value.copyWith(
                      fontSize: 14,
                      color: state.resource(entry.key) >= entry.value
                          ? null
                          : const Color(0xFFC96A5A),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: 120,
                child: GoldButton(
                  label: 'ÜRET',
                  height: 38,
                  onPressed: () {
                    final result = controller.startCraft(recipe.id);
                    final message = switch (result) {
                      CraftStart.started =>
                        '${recipe.name} üretimi başladı (${recipe.days} gün).',
                      CraftStart.noResources =>
                        'Malzeme yetersiz. Pazardan tedarik et.',
                      CraftStart.queueFull =>
                        'Tezgâhlar dolu. Günü bitirerek bekle.',
                    };
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

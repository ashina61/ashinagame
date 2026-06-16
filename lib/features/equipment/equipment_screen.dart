import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/craft_recipes.dart';
import '../../game/data/equipment.dart';
import '../../game/state/game_scope.dart';
import '../atelier/atelier_screen.dart';

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);

    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            const OrnateHeader(title: 'Kuşam', showBack: true),
            OrnatePanel(
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Atölyede ürettiğin teçhizatı kuşan; kuşandığın her '
                      'parça sefer başarını artırır.',
                      style: AppTextStyles.body,
                    ),
                  ),
                  Column(
                    children: [
                      const Text('Sefer Bonusu', style: AppTextStyles.meta),
                      Text(
                        '+%${controller.equipmentBonus}',
                        style: AppTextStyles.value.copyWith(
                          color: AppColors.goldBright,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  for (final slot in EquipmentData.slots)
                    _SlotPanel(slotId: slot.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotPanel extends StatelessWidget {
  const _SlotPanel({required this.slotId});

  final String slotId;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final slot = EquipmentData.slots.firstWhere((s) => s.id == slotId);
    final equippedId = state.equippedIn(slotId);
    final owned = [
      for (final id in slot.recipeIds)
        if (state.craftedCount(id) > 0) id,
    ];

    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(slot.name, style: AppTextStyles.section),
              const Spacer(),
              if (equippedId != null)
                Text(
                  CraftRecipes.byId(equippedId)?.name ?? equippedId,
                  style: AppTextStyles.value.copyWith(fontSize: 14),
                )
              else
                const Text('Boş', style: AppTextStyles.meta),
            ],
          ),
          const SizedBox(height: 8),
          if (owned.isEmpty)
            const Text(
              'Bu yuva için eşya yok. Atölyede üret.',
              style: AppTextStyles.meta,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final id in owned)
                  GestureDetector(
                    onTap: () => controller.equipItem(id),
                    child: Container(
                      width: 64,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.leatherDeep.withValues(alpha: 0.6),
                        border: Border.all(
                          color: id == equippedId
                              ? AppColors.goldBright
                              : AppColors.goldDim.withValues(alpha: 0.4),
                          width: id == equippedId ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Image.asset(craftIcon(id), height: 32),
                          const SizedBox(height: 2),
                          Text(
                            '+%${CraftRecipes.byId(id)?.successBonus ?? 0}',
                            style: AppTextStyles.meta.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (equippedId != null)
                  GestureDetector(
                    onTap: () => controller.unequip(slotId),
                    child: Container(
                      width: 64,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.6),
                        ),
                      ),
                      child: const Text('Çıkar', style: AppTextStyles.meta),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

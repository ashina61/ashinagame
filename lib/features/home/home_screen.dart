import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/ashina_button.dart';
import '../../core/widgets/ashina_card.dart';
import '../../core/widgets/ashina_scaffold.dart';
import '../../core/widgets/asset_placeholder.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final event = state.currentEvent;
    final openQuests = state.quests
        .where((quest) => !quest.completed)
        .take(2)
        .toList();

    return AshinaScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          AssetPlaceholder(
            assetPath: GameAssets.bgSteppe,
            label: 'Bozkır Obası',
            icon: Icons.landscape_outlined,
          ),
          const SizedBox(height: 12),
          Text('Ashina: Bozkırda Bir Ömür', style: AppTextStyles.title),
          const SizedBox(height: 4),
          Text(
            '${state.profile.name} • ${state.profile.title}',
            style: AppTextStyles.body,
          ),
          Text(state.day.season.atmosphere, style: AppTextStyles.meta),
          const SizedBox(height: 12),
          AshinaCard(child: _ResourceWrap(resources: state.resources)),
          if (event != null)
            AshinaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: AppTextStyles.section),
                  const SizedBox(height: 6),
                  Text(event.description, style: AppTextStyles.body),
                  const SizedBox(height: 12),
                  for (final choice in event.choices)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton(
                        onPressed: () => controller.chooseEvent(choice),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _choiceSummary(
                              choice.label,
                              choice.resourceEffects,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          AshinaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ana Aksiyonlar', style: AppTextStyles.section),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AshinaButton(
                      label: 'Av gönder',
                      icon: Icons.architecture_rounded,
                      onPressed: () => controller.performCampAction(
                        'Avcılar',
                        const {
                          ResourceType.food: 8,
                          ResourceType.leather: 1,
                          ResourceType.morale: -1,
                        },
                      ),
                    ),
                    AshinaButton(
                      label: 'Odun topla',
                      icon: Icons.forest_rounded,
                      onPressed: () => controller.performCampAction(
                        'Odun toplama',
                        const {ResourceType.wood: 10, ResourceType.morale: -1},
                      ),
                    ),
                    AshinaButton(
                      label: 'Günü Bitir',
                      icon: Icons.nights_stay_rounded,
                      onPressed: controller.endDay,
                    ),
                  ],
                ),
              ],
            ),
          ),
          AshinaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kısa Görevler', style: AppTextStyles.section),
                const SizedBox(height: 8),
                for (final quest in openQuests)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      quest.title,
                      style: const TextStyle(color: AppColors.parchment),
                    ),
                    subtitle: Text(quest.rewardText, style: AppTextStyles.meta),
                    trailing: AshinaButton(
                      label: 'Tamamla',
                      onPressed: () => controller.completeQuest(quest.id),
                    ),
                  ),
              ],
            ),
          ),
          AshinaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Oba Günlüğü', style: AppTextStyles.section),
                for (final log in state.log)
                  Text('• $log', style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _choiceSummary(
  String label,
  Map<ResourceType, int> effects,
) {
  return '$label • ${Formatters.resourceDelta(effects)}';
}

class _ResourceWrap extends StatelessWidget {
  const _ResourceWrap({required this.resources});

  final Map<ResourceType, int> resources;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ResourceType.values.map((type) {
        return Chip(
          label: Text('${type.label}: ${resources[type] ?? 0}'),
          avatar: const Icon(Icons.circle, size: 10, color: AppColors.amber),
          backgroundColor: AppColors.deepNight,
          labelStyle: const TextStyle(
            color: AppColors.parchment,
            fontWeight: FontWeight.w700,
          ),
        );
      }).toList(),
    );
  }
}

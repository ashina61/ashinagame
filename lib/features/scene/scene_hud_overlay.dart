import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/utils/resource_visuals.dart';
import '../../core/widgets/info_sheet.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';
import 'floating_text.dart';

/// The HUD that floats over a scene: a thin resource strip, a day/season
/// chip, the action-point count and the "end the day" button. It reads like a
/// game overlay laid on the world — not a dashboard the world lives inside.
class SceneHudOverlay extends StatelessWidget {
  const SceneHudOverlay({
    this.resources = const [
      ResourceType.gold,
      ResourceType.food,
      ResourceType.wood,
      ResourceType.horse,
      ResourceType.reputation,
    ],
    this.production = const {},
    this.foodCap,
    super.key,
  });

  final List<ResourceType> resources;

  /// Per-day production, surfaced as small `+N` rates under each resource.
  final Map<ResourceType, int> production;

  /// When set, the food cell reads `stock/cap` so a full granary is obvious.
  final int? foodCap;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final day = state.day;
    return Column(
      children: [
        ResourceBar(
          entries: [
            for (final type in resources)
              (
                ResourceVisuals.icon(type),
                type == ResourceType.food && foodCap != null
                    ? '${state.resource(type)}/$foodCap'
                    : '${state.resource(type)}',
              ),
          ],
          rates: [for (final type in resources) production[type] ?? 0],
          onEntryTap: (i) => showResourceInfoSheet(
            context,
            resources[i],
            state.resource(resources[i]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: Row(
            children: [
              _Chip(
                icon: GameAssets.iconSunEmblem,
                label: 'Gün ${day.day} • ${day.season.label}',
              ),
              const SizedBox(width: 6),
              _Chip(
                icon: GameAssets.iconEnergyBolt,
                label:
                    '${state.dailyActionPoints}/${state.maxDailyActionPoints}',
              ),
              const Spacer(),
              GoldButton(
                label: 'GÜNÜ BİTİR',
                height: 34,
                onPressed: () {
                  controller.endDay();
                  AudioService.instance.playSfx('end_day');
                  final next = controller.state.day;
                  showDayTransition(
                    context,
                    'GÜN ${next.day}',
                    subtitle: next.season.label,
                  );
                  showDayReport(
                    context,
                    title: 'GÜN ${next.day}',
                    atmosphere: next.season.atmosphere,
                    lines: controller.state.log,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.goldDim.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            icon,
            width: 16,
            height: 16,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.value.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/camp_building.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';

class CampScreen extends StatelessWidget {
  const CampScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    return OrnateScaffold(
      child: Column(
        children: [
          const OrnateHeader(title: 'Oba'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              children: [
                OrnatePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Çadır ve Oba Yönetimi',
                          style: AppTextStyles.title),
                      const SizedBox(height: 6),
                      Text(
                        'Aksiyon ${state.dailyActionPoints}/${state.maxDailyActionPoints} • Nüfus ${state.resource(ResourceType.population)} • Moral ${state.resource(ResourceType.morale)}/100',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
                const SectionPlaque('KAM VE RİTÜELLER'),
                const _AdvisorPanel(),
                for (final ritual in state.rituals)
                  _RitualCard(ritualId: ritual.id),
                const SectionPlaque('YAPILAR'),
                for (final building in state.buildings)
                  _BuildingCard(building: building),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvisorPanel extends StatelessWidget {
  const _AdvisorPanel();

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final advisor = controller.state.spiritualAdvisor;
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${advisor.name} • ${advisor.role} Seviye ${advisor.level}',
              style: AppTextStyles.bodyStrong.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text(advisor.description, style: AppTextStyles.body),
          Text(advisor.effect,
              style: AppTextStyles.meta.copyWith(color: AppColors.goldBright)),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _AdvisorButton('Alamet Yorumlat', 'interpret_omen'),
              _AdvisorButton('Tören Hazırlat', 'prepare_ritual'),
              _AdvisorButton('Atalara Dua Et', 'ancestor_prayer'),
              _AdvisorButton('Moral Yükselt', 'raise_morale'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdvisorButton extends StatelessWidget {
  const _AdvisorButton(this.label, this.action);

  final String label;
  final String action;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    return SizedBox(
      width: 132,
      child: DarkButton(
        label: label,
        height: 32,
        onPressed: controller.state.dailyActionPoints > 0
            ? () {
                final ok = controller.consultAdvisor(action);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(ok
                          ? '$label tamamlandı.'
                          : 'Kam için cooldown/AP uygun değil.')),
                );
              }
            : null,
      ),
    );
  }
}

class _RitualCard extends StatelessWidget {
  const _RitualCard({required this.ritualId});

  final String ritualId;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final ritual = state.rituals.firstWhere((item) => item.id == ritualId);
    final last = state.ritualCooldowns[ritual.id] ?? -99;
    final cooldownLeft = (ritual.cooldownDays - (state.day.day - last))
        .clamp(0, ritual.cooldownDays)
        .toInt();
    final affordable = ritual.cost.entries
        .every((entry) => state.resource(entry.key) >= entry.value);
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ritual.name,
              style: AppTextStyles.bodyStrong.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text(ritual.description, style: AppTextStyles.body),
          if (ritual.seasonHint != null)
            Text(ritual.seasonHint!, style: AppTextStyles.meta),
          const SizedBox(height: 6),
          Text(ritual.effectDescription,
              style: AppTextStyles.meta.copyWith(color: AppColors.goldBright)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Maliyet: ${Formatters.resourceDelta({
                        for (final e in ritual.cost.entries) e.key: -e.value
                      })}${cooldownLeft > 0 ? ' • $cooldownLeft gün bekle' : ''}',
                  style: AppTextStyles.meta,
                ),
              ),
              SizedBox(
                width: 112,
                child: GoldButton(
                  label: 'TÖREN',
                  height: 34,
                  onPressed: state.dailyActionPoints >= ritual.actionCost &&
                          affordable &&
                          cooldownLeft == 0
                      ? () {
                          final ok = controller.performRitual(ritual.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(ok
                                    ? '${ritual.name} yapıldı.'
                                    : 'Tören koşulları uygun değil.')),
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BuildingCard extends StatelessWidget {
  const _BuildingCard({required this.building});

  final CampBuilding building;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final affordable = building.upgradeCost.entries.every(
      (entry) => state.resource(entry.key) >= entry.value,
    );
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${building.name}  Lv.${building.level}/${building.maxLevel}',
                  style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
                ),
              ),
              Text(building.category, style: AppTextStyles.meta),
            ],
          ),
          const SizedBox(height: 4),
          Text(building.description, style: AppTextStyles.body),
          const SizedBox(height: 6),
          Text(
            building.effectDescription,
            style: AppTextStyles.meta.copyWith(color: AppColors.goldBright),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  building.canUpgrade
                      ? 'Maliyet: ${Formatters.resourceDelta({
                              for (final e in building.upgradeCost.entries)
                                e.key: -e.value
                            })}'
                      : 'Azami seviyeye ulaştı',
                  style: AppTextStyles.meta,
                ),
              ),
              SizedBox(
                width: 112,
                child: GoldButton(
                  label: 'YÜKSELT',
                  height: 34,
                  onPressed: building.canUpgrade && affordable
                      ? () {
                          final ok = controller.upgradeBuilding(building.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok
                                  ? '${building.name} yükseltildi.'
                                  : 'Kaynak yetersiz.'),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

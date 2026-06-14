import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/faith_paths.dart';
import '../../game/data/tamgas.dart';
import '../../game/models/camp_building.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';
import '../atelier/atelier_screen.dart';
import '../boy/boy_screen.dart';
import '../khanate/khanate_screen.dart';
import '../npc/npc_screen.dart';
import '../quests/quests_screen.dart';

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
                const _ObaHeaderCard(),
                const _ObaScene(),
                const _ObaColumns(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: GoldButton(
                    label: 'OBA HALKI İLE KONUŞ',
                    height: 44,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NpcScreen(),
                      ),
                    ),
                  ),
                ),
                const SectionPlaque('İNANÇ YOLU'),
                const _FaithPathPanel(),
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

/// Banner, oba name/motto and a two-column live snapshot, as in the OBA mockup.
class _ObaHeaderCard extends StatelessWidget {
  const _ObaHeaderCard();

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                Tamgas.byId(state.tamga).asset,
                height: 92,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  GameAssets.uiBannerWolf,
                  height: 92,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(width: 56),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Oba Adı:', style: AppTextStyles.meta),
                    Text(
                      state.clan.name.toUpperCase(),
                      style: AppTextStyles.title.copyWith(fontSize: 20),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.clan.motto,
                      style: AppTextStyles.meta.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _ObaBar('Mutluluk', state.resource(ResourceType.morale),
                        100, AppColors.success),
                    _ObaBar(
                        'Halk', state.peopleApproval, 100, AppColors.info),
                    _ObaValue(GameAssets.iconItemHorse, 'Atlar',
                        '${state.resource(ResourceType.horse)}'),
                    _ObaValue(GameAssets.iconArmyEmblem, 'Savaşçılar',
                        '${controller.armyStrength}'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _ObaValue(GameAssets.iconPopulationEmblem, 'Nüfus',
                        '${state.resource(ResourceType.population)}'),
                    _ObaValue(GameAssets.iconFood, 'Erzak',
                        '${state.resource(ResourceType.food)}'),
                    _ObaValue(GameAssets.iconItemWood, 'Odun',
                        '${state.resource(ResourceType.wood)}'),
                    _ObaValue(GameAssets.iconItemStone, 'Demir',
                        '${state.resource(ResourceType.iron)}'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ObaBar extends StatelessWidget {
  const _ObaBar(this.label, this.value, this.max, this.color);

  final String label;
  final int value;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(label, style: AppTextStyles.body.copyWith(fontSize: 12)),
          ),
          Expanded(child: StatBar(fraction: value / max, height: 9, fill: color)),
          SizedBox(
            width: 46,
            child: Text(
              '$value/$max',
              textAlign: TextAlign.right,
              style: AppTextStyles.meta.copyWith(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _ObaValue extends StatelessWidget {
  const _ObaValue(this.icon, this.label, this.value);

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Image.asset(
            icon,
            width: 18,
            height: 18,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox(width: 18),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label, style: AppTextStyles.body.copyWith(fontSize: 12)),
          ),
          Text(value, style: AppTextStyles.value.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

/// Panoramic camp scene strip.
class _ObaScene extends StatelessWidget {
  const _ObaScene();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: Image.asset(
            GameAssets.bgSceneCampNight,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const ColoredBox(color: AppColors.leatherDeep),
          ),
        ),
      ),
    );
  }
}

/// Three management columns: tents, daily tasks and governance.
class _ObaColumns extends StatelessWidget {
  const _ObaColumns();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final buildings = state.buildings.take(3).toList();
    final quests = state.quests.take(3).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _ObaColumn(
                title: 'ÇADIRLAR',
                children: [
                  for (final b in buildings)
                    _ColTile(
                      icon: GameAssets.iconYurtGold,
                      label: b.name,
                      sub: 'Lv.${b.level}/${b.maxLevel}',
                    ),
                  if (buildings.isEmpty)
                    const _ColTile(
                      icon: GameAssets.iconYurtGold,
                      label: 'Çadır yok',
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ObaColumn(
                title: 'GÖREVLER',
                children: [
                  for (final q in quests)
                    _ColTile(
                      icon: GameAssets.iconScrollMedallion,
                      label: q.title,
                      sub: '${state.questProgress(q)}/${q.goalTarget}',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const QuestsScreen(),
                        ),
                      ),
                    ),
                  if (quests.isEmpty)
                    const _ColTile(
                      icon: GameAssets.iconScrollMedallion,
                      label: 'Görev yok',
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ObaColumn(
                title: 'YÖNETİM',
                children: [
                  _ColTile(
                    icon: GameAssets.iconPopulationEmblem,
                    label: 'Obayı Genişlet',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const BoyScreen()),
                    ),
                  ),
                  _ColTile(
                    icon: GameAssets.iconArmyEmblem,
                    label: 'Beyleri Topla',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const KhanateScreen(),
                      ),
                    ),
                  ),
                  _ColTile(
                    icon: GameAssets.iconGearEmblem,
                    label: 'Atölye',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AtelierScreen(),
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

class _ObaColumn extends StatelessWidget {
  const _ObaColumn({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return OrnatePanel(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.section.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

class _ColTile extends StatelessWidget {
  const _ColTile({
    required this.icon,
    required this.label,
    this.sub,
    this.onTap,
  });

  final String icon;
  final String label;
  final String? sub;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: 22,
              height: 22,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(width: 22),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyStrong.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sub != null)
                    Text(
                      sub!,
                      style: AppTextStyles.meta.copyWith(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class _FaithPathPanel extends StatelessWidget {
  const _FaithPathPanel();

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final current = FaithPaths.byId(controller.state.faithPath);
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            current == null ? 'Henüz bir yol seçilmedi' : current.name,
            style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            current?.description ??
                'Obanı bir inanç yoluna adamak faith dengeni güçlendirir.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final path in FaithPaths.all)
                SizedBox(
                  width: 150,
                  child: DarkButton(
                    label: path.id == controller.state.faithPath
                        ? '✓ ${path.name}'
                        : path.name,
                    height: 34,
                    onPressed: () {
                      final ok = controller.chooseFaithPath(path.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? '${path.name} yoluna girildi.'
                              : 'Bu yol zaten seçili.'),
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

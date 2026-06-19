import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_art.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/info_sheet.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/game_info.dart';
import '../scene/floating_text.dart';
import '../../game/data/companion_roles.dart';
import '../../game/data/faith_paths.dart';
import '../../game/data/tamgas.dart';
import '../../game/models/camp_building.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';
import '../npc/npc_screen.dart';
import '../scene/scene_atmosphere.dart';
import '../scene/scene_background.dart';
import '../scene/scene_detail_panel.dart';
import '../scene/scene_hotspot.dart';

/// "Oba" — the player's settlement, drawn as a living encampment rather than a
/// list of buildings. Each structure is a tappable pin over the camp scene; a
/// tap slides up its level, effect, cost and upgrade. A "Liste" toggle keeps
/// the full management view (faith, kam, rituals, buildings) as a fallback.
class CampScreen extends StatefulWidget {
  const CampScreen({super.key});

  @override
  State<CampScreen> createState() => _CampScreenState();
}

class _CampScreenState extends State<CampScreen> {
  bool _list = false;

  /// Each oba structure placed around the settlement scene.
  static const _spots =
      <(String id, String label, double x, double y, String icon)>[
    ('main_tent', 'Ana Çadır', 0.5, 0.3, GameArt.obaMainTent),
    ('watchtower', 'Gözcü Kulesi', 0.85, 0.22, GameArt.obaWatchtower),
    ('storage', 'Depo', 0.2, 0.46, GameArt.obaStorage),
    ('pen', 'Ağıl', 0.8, 0.48, GameArt.obaHorsePen),
    ('market_tent', 'Pazar Çadırı', 0.5, 0.56, GameArt.obaMarketTent),
    ('workshop', 'Atölye', 0.16, 0.72, GameArt.obaWorkshop),
    ('kam_tent', 'Kam Çadırı', 0.34, 0.78, GameArt.obaShamanTent),
    ('sacred_fire', 'Ritüel Ateşi', 0.66, 0.78, GameArt.obaRitualFire),
    ('healer', 'Şifacı Çadırı', 0.64, 0.66, GameArt.obaBigTent),
    ('training', 'Eğitim Alanı', 0.86, 0.74, GameAssets.iconSwordsCrossed),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final hotspots = [
      for (final (id, label, x, y, icon) in _spots)
        if (state.building(id) != null)
          SceneHotspot(
            id: id,
            title: label,
            x: x,
            y: y,
            icon: icon,
            onTap: () => _openBuilding(context, controller, id, label, icon),
          ),
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        const SceneBackground(
          asset: GameArt.obaSceneBg,
          fallback: GameAssets.bgSceneCampNight,
        ),
        const EmberGlow(center: Alignment(-0.1, 0.35), radius: 0.5),
        const RisingEmbers(origin: 0.45, spread: 0.3),
        SafeArea(
          child: Column(
            children: [
              OrnateHeader(
                title: 'Oba',
                onInfo: () => showHelpSheet(context, HelpId.oba),
              ),
              _IdentityBand(onToggle: () => setState(() => _list = !_list)),
              Expanded(
                child: _list
                    ? const _ObaList()
                    : LayoutBuilder(
                        builder: (context, c) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            for (final hot in hotspots)
                              Positioned(
                                left: hot.x * c.maxWidth - 28,
                                top: hot.y * (c.maxHeight - 56) - 28,
                                child: SceneHotspotWidget(hotspot: hot),
                              ),
                            const Positioned(
                              left: 12,
                              right: 12,
                              bottom: 8,
                              child: _SceneActionsBar(),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openBuilding(
    BuildContext context,
    GameController controller,
    String id,
    String label,
    String icon,
  ) {
    final b = controller.state.building(id);
    if (b == null) return;
    final affordable = b.upgradeCost.entries.every(
      (e) => controller.state.resource(e.key) >= e.value,
    );
    showSceneDetail(
      context,
      title: '$label • Lv.${b.level}/${b.maxLevel}',
      icon: icon,
      description: '${b.description}\n\n${b.effectDescription}',
      actions: [
        SceneAction(
          label: b.canUpgrade ? 'Yükselt' : 'Azami seviye',
          subtitle: b.canUpgrade
              ? 'Maliyet: ${Formatters.resourceDelta({
                      for (final e in b.upgradeCost.entries) e.key: -e.value
                    })}'
              : null,
          primary: true,
          enabled: b.canUpgrade && affordable,
          onTap: () {
            final ok = controller.upgradeBuilding(id);
            if (ok) {
              AudioService.instance.playSfx('craft');
              showFloatingGain(
                context,
                '$label ↑',
                color: AppColors.goldBright,
              );
            } else {
              AudioService.instance.playSfx('denied');
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Kaynak yetersiz.')));
            }
          },
        ),
      ],
    );
  }
}

/// Compact oba identity + stats strip with the scene/list toggle.
class _IdentityBand extends StatelessWidget {
  const _IdentityBand({required this.onToggle});

  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                Tamgas.byId(state.tamga).asset,
                width: 40,
                height: 40,
                errorBuilder: (_, __, ___) => const SizedBox(width: 40),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(state.clan.name, style: AppTextStyles.title),
              ),
              GestureDetector(
                onTap: onToggle,
                child: const Icon(Icons.list_alt, color: AppColors.goldBright),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _ObaStat('Nüfus', state.resource(ResourceType.population)),
              _ObaStat('Moral', state.resource(ResourceType.morale)),
              _ObaStat('Sadakat', state.peopleApproval),
              _ObaStat('Güvenlik', state.councilApproval),
              _ObaStat('Erzak', state.resource(ResourceType.food)),
              _ObaStat('At', state.resource(ResourceType.horse)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Buttons floating at the foot of the settlement scene.
class _SceneActionsBar extends StatelessWidget {
  const _SceneActionsBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GoldButton(
            label: 'OBA HALKI',
            height: 42,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const NpcScreen())),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DarkButton(
            label: 'İNANÇ & RİTÜEL',
            height: 42,
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => const _FaithRitualSheet(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet gathering faith path, the kam and the rituals.
class _FaithRitualSheet extends StatelessWidget {
  const _FaithRitualSheet();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView(
            children: [
              const SectionPlaque('İNANÇ YOLU'),
              const _FaithPathPanel(),
              const SectionPlaque('KAM VE RİTÜELLER'),
              const _AdvisorPanel(),
              for (final ritual in state.rituals)
                _RitualCard(ritualId: ritual.id),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the standing bonuses the leader's sworn followers grant in their
/// assigned roles.
class _CompanionBonusPanel extends StatelessWidget {
  const _CompanionBonusPanel();

  @override
  Widget build(BuildContext context) {
    final roles = GameScope.of(context).state.companionRoles.values;
    final seen = <String>{};
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final id in roles)
            if (seen.add(id) && CompanionRoles.byId(id) != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: AppColors.goldBright,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${CompanionRoles.byId(id)!.name} — '
                        '${CompanionRoles.byId(id)!.effect}',
                        style: AppTextStyles.meta,
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

/// Full management list — the fallback view behind the scene.
class _ObaList extends StatelessWidget {
  const _ObaList();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        if (state.companionRoles.isNotEmpty) ...[
          const SectionPlaque('YANDAŞ BONUSLARI'),
          const _CompanionBonusPanel(),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: GoldButton(
            label: 'OBA HALKI İLE KONUŞ',
            height: 44,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const NpcScreen())),
          ),
        ),
        const SectionPlaque('İNANÇ YOLU'),
        const _FaithPathPanel(),
        const SectionPlaque('KAM VE RİTÜELLER'),
        const _AdvisorPanel(),
        for (final ritual in state.rituals) _RitualCard(ritualId: ritual.id),
        const SectionPlaque('YAPILAR'),
        for (final building in state.buildings)
          _BuildingCard(building: building),
      ],
    );
  }
}

class _ObaStat extends StatelessWidget {
  const _ObaStat(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: AppTextStyles.meta.copyWith(color: AppColors.stone),
        ),
        Text(
          '$value',
          style: AppTextStyles.value.copyWith(color: AppColors.goldBright),
        ),
      ],
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
                          content: Text(
                            ok
                                ? '${path.name} yoluna girildi.'
                                : 'Bu yol zaten seçili.',
                          ),
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
          Text(
            '${advisor.name} • ${advisor.role} Seviye ${advisor.level}',
            style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(advisor.description, style: AppTextStyles.body),
          Text(
            advisor.effect,
            style: AppTextStyles.meta.copyWith(color: AppColors.goldBright),
          ),
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
                    content: Text(
                      ok
                          ? '$label tamamlandı.'
                          : 'Kam için cooldown/AP uygun değil.',
                    ),
                  ),
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
    final affordable = ritual.cost.entries.every(
      (entry) => state.resource(entry.key) >= entry.value,
    );
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ritual.name,
            style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(ritual.description, style: AppTextStyles.body),
          if (ritual.seasonHint != null)
            Text(ritual.seasonHint!, style: AppTextStyles.meta),
          const SizedBox(height: 6),
          Text(
            ritual.effectDescription,
            style: AppTextStyles.meta.copyWith(color: AppColors.goldBright),
          ),
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
                              content: Text(
                                ok
                                    ? '${ritual.name} yapıldı.'
                                    : 'Tören koşulları uygun değil.',
                              ),
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
                              content: Text(
                                ok
                                    ? '${building.name} yükseltildi.'
                                    : 'Kaynak yetersiz.',
                              ),
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

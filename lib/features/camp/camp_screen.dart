import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_art.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/resource_visuals.dart';
import '../../core/widgets/info_sheet.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/game_info.dart';
import '../../game/data/companion_roles.dart';
import '../../game/data/faith_paths.dart';
import '../../game/data/tamgas.dart';
import '../../game/models/camp_building.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';
import '../npc/npc_screen.dart';
import '../research/research_screen.dart';
import '../scene/floating_text.dart';
import '../scene/scene_atmosphere.dart';
import '../scene/scene_background.dart';
import '../scene/scene_hotspot.dart';
import '../scene/scene_hud_overlay.dart';

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

  /// Each oba structure placed around the settlement scene. Pins use clean,
  /// uniform glyphs (not the building art) so the map reads as a designed game
  /// board and stays consistent regardless of which PNGs are in flight.
  static const _spots =
      <(String id, String label, double x, double y, IconData icon)>[
    ('main_tent', 'Ana Çadır', 0.5, 0.3, Icons.festival),
    ('watchtower', 'Gözcü Kulesi', 0.85, 0.22, Icons.visibility),
    ('storage', 'Depo', 0.2, 0.46, Icons.warehouse),
    ('pen', 'Ağıl', 0.8, 0.48, Icons.pets),
    ('market_tent', 'Pazar Çadırı', 0.5, 0.56, Icons.storefront),
    ('workshop', 'Atölye', 0.16, 0.72, Icons.handyman),
    ('academy', 'Akademi', 0.3, 0.56, Icons.menu_book),
    ('kam_tent', 'Kam Çadırı', 0.34, 0.78, Icons.auto_awesome),
    ('sacred_fire', 'Ritüel Ateşi', 0.66, 0.78, Icons.local_fire_department),
    ('healer', 'Şifacı Çadırı', 0.64, 0.66, Icons.medical_services),
    ('training', 'Eğitim Alanı', 0.86, 0.74, Icons.shield),
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
            iconData: icon,
            level: state.building(id)!.level,
            onTap: () => _openBuilding(context, id, label, icon),
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
              SceneHudOverlay(
                resources: const [
                  ResourceType.gold,
                  ResourceType.food,
                  ResourceType.wood,
                  ResourceType.iron,
                  ResourceType.horse,
                ],
                production: controller.dailyProduction,
                foodCap: controller.storageCapacity,
              ),
              _ObaTitleStrip(
                onToggle: () => setState(() => _list = !_list),
                onInfo: () => showHelpSheet(context, HelpId.oba),
              ),
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
    String id,
    String label,
    IconData icon,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BuildingSheet(id: id, label: label, icon: icon),
    );
  }
}

/// A clean, framed building card: a gold medallion glyph, the level, and the
/// production / cost / build-time laid out as labelled icon rows — not a wall
/// of text. The single building interaction on the Oba hero screen.
class _BuildingSheet extends StatelessWidget {
  const _BuildingSheet({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final b = controller.state.building(id);
    if (b == null) return const SizedBox.shrink();
    final affordable = b.upgradeCost.entries.every(
      (e) => controller.state.resource(e.key) >= e.value,
    );
    final queued = controller.buildingQueued(id);
    final daysLeft = controller.buildDaysLeft(id);
    final days = (b.buildDays - controller.researchBonuses.buildDaysReduction)
        .clamp(1, 99);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: OrnatePanel(
          margin: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.ink.withValues(alpha: 0.6),
                      border: Border.all(color: AppColors.gold, width: 1.6),
                    ),
                    child: Icon(icon, color: AppColors.goldBright, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: AppTextStyles.title.copyWith(fontSize: 18)),
                        Text(
                          '${b.category} • Seviye ${b.level}/${b.maxLevel}',
                          style: AppTextStyles.meta,
                        ),
                      ],
                    ),
                  ),
                  _LevelDots(level: b.level, max: b.maxLevel),
                ],
              ),
              const SizedBox(height: 10),
              Text(b.description, style: AppTextStyles.body),
              const SizedBox(height: 4),
              Text(
                b.effectDescription,
                style: AppTextStyles.meta.copyWith(color: AppColors.goldBright),
              ),
              const Divider(height: 18, color: AppColors.goldDim),
              if (b.dailyYield.isNotEmpty)
                _StatRow(
                  icon: Icons.trending_up,
                  label: 'Üretim/gün',
                  child: _ResChips(b.dailyYield, positive: true),
                ),
              if (b.canUpgrade) ...[
                _StatRow(
                  icon: Icons.payments,
                  label: 'Yükseltme',
                  child: _ResChips(b.upgradeCost),
                ),
                _StatRow(
                  icon: Icons.schedule,
                  label: 'İnşa süresi',
                  child: Text('$days gün', style: AppTextStyles.value),
                ),
              ],
              const SizedBox(height: 12),
              if (id == 'academy') ...[
                GoldButton(
                  label: 'ARAŞTIRMA AĞACI '
                      '(${controller.state.researchPoints} puan)',
                  height: 42,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ResearchScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
              _UpgradeButton(
                id: id,
                label: label,
                queued: queued,
                daysLeft: daysLeft,
                days: days.toInt(),
                canUpgrade: b.canUpgrade,
                affordable: affordable,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row of small filled/empty pips showing a building's level out of its max.
class _LevelDots extends StatelessWidget {
  const _LevelDots({required this.level, required this.max});

  final int level;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < max; i++)
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Icon(
              i < level ? Icons.circle : Icons.circle_outlined,
              size: 9,
              color: i < level ? AppColors.goldBright : AppColors.goldDim,
            ),
          ),
      ],
    );
  }
}

/// A labelled stat line: glyph + label on the left, content on the right.
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.stone),
          const SizedBox(width: 6),
          SizedBox(
            width: 96,
            child: Text(label, style: AppTextStyles.meta),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// A wrap of resource icon + amount chips, used for production and cost lines.
class _ResChips extends StatelessWidget {
  const _ResChips(this.amounts, {this.positive = false});

  final Map<ResourceType, int> amounts;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: [
        for (final e in amounts.entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                ResourceVisuals.icon(e.key),
                width: 16,
                height: 16,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              const SizedBox(width: 3),
              Text(
                positive ? '+${e.value}' : '${e.value}',
                style: AppTextStyles.value.copyWith(
                  fontSize: 13,
                  color: positive ? AppColors.success : AppColors.parchment,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// The primary build/upgrade action, reflecting queue and affordability.
class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton({
    required this.id,
    required this.label,
    required this.queued,
    required this.daysLeft,
    required this.days,
    required this.canUpgrade,
    required this.affordable,
  });

  final String id;
  final String label;
  final bool queued;
  final int daysLeft;
  final int days;
  final bool canUpgrade;
  final bool affordable;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    if (queued) {
      return DarkButton(
        label: 'İNŞA EDİLİYOR • $daysLeft GÜN',
        height: 44,
        onPressed: null,
      );
    }
    if (!canUpgrade) {
      return const DarkButton(
        label: 'AZAMİ SEVİYE',
        height: 44,
        onPressed: null,
      );
    }
    return GoldButton(
      label: 'YÜKSELT ($days GÜN)',
      height: 44,
      onPressed: affordable
          ? () {
              final ok = controller.upgradeBuilding(id);
              Navigator.of(context).pop();
              if (ok) {
                AudioService.instance.playSfx('craft');
                showFloatingNote(
                  context,
                  '$label inşaatı başladı ($days gün)',
                );
              } else {
                AudioService.instance.playSfx('denied');
                showFloatingNote(context, 'Kaynak yetersiz.', good: false);
              }
            }
          : null,
    );
  }
}

/// Slim identity strip: tamga, clan name, the two stats that matter at a
/// glance (happiness and housing), a live build chip, and the scene/list and
/// info toggles — one tight row instead of a tall stat block.
class _ObaTitleStrip extends StatelessWidget {
  const _ObaTitleStrip({required this.onToggle, required this.onInfo});

  final VoidCallback onToggle;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final job = state.buildQueue.isEmpty ? null : state.buildQueue.first;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 2, 8, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC14100A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.goldDim.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Image.asset(
            Tamgas.byId(state.tamga).asset,
            width: 26,
            height: 26,
            errorBuilder: (_, __, ___) => const SizedBox(width: 26),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.clan.name,
              style: AppTextStyles.bodyStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _ObaChip(
            Icons.sentiment_satisfied_alt,
            '${controller.happiness}',
          ),
          _ObaChip(
            Icons.groups,
            '${state.resource(ResourceType.population)}/'
            '${controller.populationCapacity}',
          ),
          if (job != null)
            _ObaChip(
              Icons.construction,
              '${job.daysLeft}g',
              color: AppColors.goldBright,
            ),
          GestureDetector(
            onTap: onToggle,
            child: const Icon(Icons.list_alt,
                color: AppColors.goldBright, size: 22),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onInfo,
            child: const Icon(Icons.info_outline,
                color: AppColors.stone, size: 20),
          ),
        ],
      ),
    );
  }
}

/// A tiny icon + value pill used in the oba title strip.
class _ObaChip extends StatelessWidget {
  const _ObaChip(this.icon, this.value, {this.color});

  final IconData icon;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color ?? AppColors.stone),
          const SizedBox(width: 3),
          Text(
            value,
            style: AppTextStyles.meta.copyWith(
              color: color ?? AppColors.parchment,
              fontSize: 12,
            ),
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
                      showFloatingNote(
                        context,
                        ok
                            ? '${path.name} yoluna girildi.'
                            : 'Bu yol zaten seçili.',
                        good: ok,
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
                showFloatingNote(
                  context,
                  ok
                      ? '$label tamamlandı.'
                      : 'Kam için cooldown/AP uygun değil.',
                  good: ok,
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
                          final before = controller.state;
                          final ok = controller.performRitual(ritual.id);
                          if (ok) {
                            AudioService.instance.playSfx('reward');
                            showStateDelta(
                              context,
                              before,
                              controller.state,
                              fallback: '${ritual.name} yapıldı',
                            );
                          } else {
                            showFloatingNote(
                              context,
                              'Tören koşulları uygun değil',
                              good: false,
                            );
                          }
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
                          final before = controller.state;
                          final ok = controller.upgradeBuilding(building.id);
                          if (ok) {
                            AudioService.instance.playSfx('craft');
                            showStateDelta(
                              context,
                              before,
                              controller.state,
                              fallback: '${building.name} yükseltildi',
                            );
                          } else {
                            showFloatingNote(
                              context,
                              'Kaynak yetersiz',
                              good: false,
                            );
                          }
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

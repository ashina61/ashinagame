import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/expedition_sites.dart';
import '../../game/models/expedition.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';
import 'expedition_result_screen.dart';

class _Region {
  const _Region(this.name, this.risk, this.reward, this.effects);

  final String name;
  final String risk;
  final String reward;
  final Map<ResourceType, int> effects;
}

class ExpeditionsScreen extends StatefulWidget {
  const ExpeditionsScreen({super.key});

  @override
  State<ExpeditionsScreen> createState() => _ExpeditionsScreenState();
}

class _ExpeditionsScreenState extends State<ExpeditionsScreen> {
  int _tab = 0;
  String? _selectedId;

  static const _badges = [
    GameAssets.uiBadgeBanner1,
    GameAssets.uiBadgeBanner2,
    GameAssets.uiBadgeBanner3,
    GameAssets.uiBadgeBanner4,
  ];

  static const _forts = [
    GameAssets.iconFortOutpost,
    GameAssets.iconFortStone,
    GameAssets.iconFortRed,
    GameAssets.iconFortDark,
  ];

  // Scouting runs preserved from the old map screen; each applies its
  // resource effects through the controller.
  static const _regions = [
    _Region('Irmak Kıyısı', 'Orta', 'Odun / Moral', {
      ResourceType.wood: 6,
      ResourceType.morale: 1,
    }),
    _Region('Avlak', 'Orta', 'Erzak / Deri', {
      ResourceType.food: 12,
      ResourceType.leather: 2,
    }),
    _Region('Ormanlık Alan', 'Orta', 'Odun', {
      ResourceType.wood: 14,
      ResourceType.food: -2,
    }),
    _Region('Dağ Geçidi', 'Yüksek', 'İtibar', {
      ResourceType.reputation: 2,
      ResourceType.food: -4,
    }),
    _Region('Eski Yazıt', 'Düşük', 'Moral / İtibar', {
      ResourceType.reputation: 1,
      ResourceType.morale: 2,
    }),
    _Region('Ticaret Yolu', 'Orta', 'Takas', {
      ResourceType.food: 8,
      ResourceType.leather: -2,
    }),
  ];

  /// The tapped site if it is still attackable, else the first open one.
  ExpeditionSite? _effectiveTarget(GameController controller) {
    ExpeditionSite? firstOpen;
    for (final site in ExpeditionSites.all) {
      final open = controller.siteUnlocked(site) &&
          !controller.state.expeditionDone(site.id);
      if (open) {
        firstOpen ??= site;
        if (site.id == _selectedId) {
          return site;
        }
      }
    }
    return firstOpen;
  }

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final energy = controller.state.dailyActionPoints;
    return OrnateScaffold(
      child: Column(
        children: [
          const OrnateHeader(title: 'Seferler'),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 2),
            child: Row(
              children: [
                Image.asset(GameAssets.iconEnergyBolt, width: 16, height: 16),
                const SizedBox(width: 4),
                Text(
                  'Aksiyon $energy/${controller.state.maxDailyActionPoints}  •  '
                  'Keşif ${GameController.exploreCost}  •  '
                  'Sefer ${GameController.expeditionCost}',
                  style: AppTextStyles.meta.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Row(
              children: [
                for (final (i, asset) in const [
                  (0, GameAssets.uiTabHarita),
                  (1, GameAssets.uiTabSeferListesi),
                ])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: Container(
                        margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                        decoration: _tab == i
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x66EEC36A),
                                    blurRadius: 12,
                                  ),
                                ],
                              )
                            : null,
                        child: Opacity(
                          opacity: _tab == i ? 1 : 0.7,
                          child: Image.asset(asset, height: 36),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _tab == 0 ? _buildMap(controller) : _buildList()),
          if (_tab == 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 4, 40, 12),
              child: ImageButton(
                asset: GameAssets.uiButtonSefereCik,
                height: 56,
                onPressed: () => _embark(context, controller),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap(GameController controller) {
    final target = _effectiveTarget(controller);
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                GameAssets.bgMapParchment,
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.35),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        ListView(
          padding: const EdgeInsets.only(top: 4, bottom: 16),
          children: [
            for (var i = 0; i < ExpeditionSites.all.length; i++)
              _MapNode(
                site: ExpeditionSites.all[i],
                badge: _badges[i % _badges.length],
                fort: _forts[i % _forts.length],
                controller: controller,
                selected: ExpeditionSites.all[i].id == target?.id,
                showRoute: i < ExpeditionSites.all.length - 1,
                onTap: () =>
                    setState(() => _selectedId = ExpeditionSites.all[i].id),
              ),
          ],
        ),
        Positioned(
          left: 14,
          bottom: 10,
          child: Opacity(
            opacity: 0.9,
            child: Image.asset(GameAssets.uiCompassRoseNsew, width: 70),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    final controller = GameScope.of(context);
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        const SectionPlaque('KEŞİF BÖLGELERİ'),
        for (final region in _regions)
          OrnatePanel(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(region.name, style: AppTextStyles.bodyStrong),
                      Text(
                        'Risk: ${region.risk} • Ödül: ${region.reward}',
                        style: AppTextStyles.meta,
                      ),
                      Text(
                        Formatters.resourceDelta(region.effects),
                        style: AppTextStyles.meta.copyWith(
                          color: AppColors.goldBright,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                DarkButton(
                  label: 'KEŞFET',
                  onPressed: () {
                    final done =
                        controller.exploreRegion(region.name, region.effects);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          done
                              ? '${region.name} keşfi: '
                                  '${Formatters.resourceDelta(region.effects)}'
                              : 'Enerji tükendi. Günü bitirerek dinlen.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        const SectionPlaque('KUTSAL MEKÂNLAR'),
        for (final place in controller.state.sacredPlaces)
          OrnatePanel(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name, style: AppTextStyles.bodyStrong),
                      Text('Risk: ${place.risk} • Ödül: ${place.reward}',
                          style: AppTextStyles.meta),
                      Text(place.description,
                          style: AppTextStyles.body.copyWith(fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                DarkButton(
                  label: 'ZİYARET',
                  onPressed: controller.state.dailyActionPoints > 0
                      ? () {
                          final done = controller.visitSacredPlace(place.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(done
                                    ? '${place.name} ziyaret edildi.'
                                    : 'Ziyaret için cooldown/AP uygun değil.')),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _embark(BuildContext context, GameController controller) {
    final target = _effectiveTarget(controller);
    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tüm hedefler fethedildi. Bozkır senin!'),
        ),
      );
      return;
    }
    if (controller.state.dailyActionPoints < GameController.expeditionCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sefer için enerji yetmiyor. Günü bitirerek dinlen.'),
        ),
      );
      return;
    }
    final outcome = controller.embarkExpedition(target.id);
    if (outcome == null) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ExpeditionResultScreen(outcome: outcome),
      ),
    );
  }
}

class _MapNode extends StatelessWidget {
  const _MapNode({
    required this.site,
    required this.badge,
    required this.fort,
    required this.controller,
    required this.selected,
    this.showRoute = false,
    this.onTap,
  });

  final ExpeditionSite site;
  final String badge;
  final String fort;
  final GameController controller;
  final bool selected;
  final bool showRoute;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = controller.state.expeditionDone(site.id);
    final unlocked = controller.siteUnlocked(site);
    final (status, color) = done
        ? ('Fethedildi', AppColors.success)
        : !unlocked
            ? ('Kilitli', AppColors.lockedGrey)
            : (
                '${site.dangerLabel} • Başarı %'
                    '${controller.successChanceFor(site)}',
                site.baseChance >= 60 ? AppColors.info : AppColors.danger
              );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: done || !unlocked ? null : onTap,
            child: Opacity(
              opacity: unlocked || done ? 1 : 0.55,
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    height: 76,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(badge, fit: BoxFit.contain),
                        if (!unlocked && !done)
                          Image.asset(GameAssets.uiBadgeLocked, width: 24),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      foregroundDecoration: selected
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.goldBright,
                                width: 1.6,
                              ),
                            )
                          : null,
                      child: OrnatePanel(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Image.asset(fort, height: 54),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    site.name.toUpperCase(),
                                    style: AppTextStyles.section.copyWith(
                                      color: AppColors.parchment,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    status,
                                    style: AppTextStyles.meta.copyWith(
                                      color: color,
                                    ),
                                  ),
                                  if (unlocked && !done)
                                    Text(
                                      Formatters.resourceDelta(site.gains),
                                      style: AppTextStyles.meta.copyWith(
                                        color: AppColors.goldBright,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showRoute)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Image.asset(
                GameAssets.uiMapRoute,
                height: 30,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }
}

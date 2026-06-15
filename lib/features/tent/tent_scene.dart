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
import '../../game/logic/phase_logic.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';
import '../achievements/achievements_screen.dart';
import '../found_oba/found_oba_screen.dart';
import '../quests/quests_screen.dart';
import '../scene/floating_text.dart';
import '../scene/scene_atmosphere.dart';
import '../scene/scene_background.dart';
import '../scene/scene_detail_panel.dart';
import '../scene/scene_hotspot.dart';

/// "Çadırım" — the personal camp. Not a list of buildings but the player's own
/// patch of the steppe: the tent, the chest, the workbench and the horse line
/// are tappable, and a clear panel tracks the road to founding an oba.
class TentScreen extends StatelessWidget {
  const TentScreen({this.showBack = false, super.key});

  final bool showBack;

  /// The handful of personal-camp parts the early game surfaces, mapped to the
  /// underlying building ids and placed around the tent scene.
  static const _parts =
      <(String id, String label, double x, double y, String icon)>[
    ('main_tent', 'Ana Çadır', 0.5, 0.34, GameAssets.iconYurtMedallion),
    ('storage', 'Sandık', 0.24, 0.6, GameAssets.iconChestMedallion),
    ('workshop', 'Çalışma Tezgâhı', 0.16, 0.34, GameAssets.iconGearEmblem),
    ('horse_herd', 'At Bağı', 0.82, 0.4, GameAssets.iconMedallionHorse),
    ('healer', 'Korunak', 0.76, 0.66, GameAssets.iconHeartMedallion),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final hotspots = [
      for (final (id, label, x, y, icon) in _parts)
        SceneHotspot(
          id: id,
          title: label,
          x: x,
          y: y,
          icon: icon,
          onTap: () => _openPart(context, controller, id, label, icon),
        ),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // TODO(asset): tent_interior_bg — falls back to the night camp.
          const SceneBackground(
            asset: GameArt.tentInteriorBg,
            fallback: GameAssets.bgSceneCampNight,
          ),
          const EmberGlow(center: Alignment(0, -0.45)),
          SafeArea(
            child: Column(
              children: [
                OrnateHeader(
                  title: 'Çadırım',
                  showBack: showBack,
                  onInfo: () => showHelpSheet(context, HelpId.tent),
                ),
                SizedBox(
                  height: 240,
                  child: LayoutBuilder(
                    builder: (context, c) => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Kendi yolun, kendi çadırın',
                              style: AppTextStyles.meta,
                            ),
                          ),
                        ),
                        for (final hot in hotspots)
                          Positioned(
                            left: hot.x * c.maxWidth - 28,
                            top: hot.y * c.maxHeight - 28,
                            child: SceneHotspotWidget(hotspot: hot),
                          ),
                      ],
                    ),
                  ),
                ),
                const Expanded(child: _ObaPathPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openPart(
    BuildContext context,
    GameController controller,
    String id,
    String label,
    String icon,
  ) {
    final building = controller.state.building(id);
    if (building == null) return;
    final affordable = building.upgradeCost.entries.every(
      (e) => controller.state.resource(e.key) >= e.value,
    );
    showSceneDetail(
      context,
      title: '$label • Lv.${building.level}/${building.maxLevel}',
      icon: icon,
      description: building.effectDescription,
      actions: [
        SceneAction(
          label: building.canUpgrade ? 'Yükselt' : 'Azami seviye',
          subtitle: building.canUpgrade
              ? 'Maliyet: ${Formatters.resourceDelta({
                      for (final e in building.upgradeCost.entries)
                        e.key: -e.value
                    })}'
              : null,
          primary: true,
          enabled: building.canUpgrade && affordable,
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

class _ObaPathPanel extends StatelessWidget {
  const _ObaPathPanel();

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final reqs = PhaseLogic.foundingRequirements(state);
    final canFound = PhaseLogic.canFoundOba(state);

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        const SectionPlaque('OBA YOLU'),
        OrnatePanel(
          backgroundAsset: GameAssets.bgSceneCampNight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.obaFounded
                    ? '${state.clan.name} kuruldu. Bu çadır artık bir obanın '
                        'kalbi.'
                    : 'Yalnız bir yolcusun. Bu çadır bir gün obanın kalbi '
                        'olacak — yol şöyle:',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 6),
              Text(
                '${reqs.where((r) => r.met).length}/${reqs.length} adım tamam',
                style: AppTextStyles.meta.copyWith(color: AppColors.goldBright),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < reqs.length; i++)
                _MilestoneTile(
                  step: i + 1,
                  req: reqs[i],
                  last: i == reqs.length - 1,
                ),
            ],
          ),
        ),
        if (!state.obaFounded)
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 6, 40, 0),
            child: GoldButton(
              label: canFound ? 'OBANI KUR' : 'ŞARTLAR EKSİK',
              onPressed: canFound
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const FoundObaScreen(),
                        ),
                      )
                  : null,
            ),
          ),
        const SectionPlaque('KAYITLAR'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: DarkButton(
                  label: 'GÖREVLER',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const QuestsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DarkButton(
                  label: 'BAŞARIMLAR',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AchievementsScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One step on the road to founding an oba, drawn as a numbered medallion on a
/// vertical track: lit gold and checked when met, dim and locked when not — so
/// progress reads as a journey, not a checkbox list.
class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.step,
    required this.req,
    required this.last,
  });

  final int step;
  final FoundingRequirement req;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final met = req.met;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: met
                      ? AppColors.gold.withValues(alpha: 0.25)
                      : AppColors.ink.withValues(alpha: 0.6),
                  border: Border.all(
                    color: met ? AppColors.goldBright : AppColors.goldDim,
                    width: met ? 2 : 1,
                  ),
                  boxShadow: met
                      ? const [
                          BoxShadow(color: Color(0x66EEC36A), blurRadius: 10)
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: met
                    ? const Icon(Icons.check,
                        size: 16, color: AppColors.goldBright)
                    : Text(
                        '$step',
                        style: AppTextStyles.value.copyWith(
                          fontSize: 13,
                          color: AppColors.stone,
                        ),
                      ),
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: met
                        ? AppColors.goldDim
                        : AppColors.goldDim.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req.label,
                    style: AppTextStyles.bodyStrong.copyWith(
                      fontSize: 14,
                      color: met ? AppColors.parchment : AppColors.sand,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    req.progress,
                    style: AppTextStyles.meta.copyWith(
                      color: met ? AppColors.goldBright : AppColors.stone,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

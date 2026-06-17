import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_art.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/game_image.dart';
import '../../core/widgets/info_sheet.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/game_info.dart';
import '../../game/logic/phase_logic.dart';
import '../../game/logic/tent_upgrade_logic.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';
import '../../game/state/game_state.dart';
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
    ('main_tent', 'Ana Çadır', 0.5, 0.34, GameArt.playerTentLv1),
    ('storage', 'Sandık', 0.24, 0.6, GameArt.campChest),
    ('workshop', 'Çalışma Tezgâhı', 0.16, 0.34, GameArt.campWorkbench),
    ('horse_herd', 'At Bağı', 0.82, 0.4, GameArt.campHorseTie),
    ('healer', 'Korunak', 0.76, 0.66, GameAssets.iconHeartMedallion),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final tentLevel = PhaseLogic.tentLevel(controller.state);
    final hotspots = [
      for (final (id, label, x, y, icon) in _parts)
        SceneHotspot(
          id: id,
          title: label,
          x: x,
          y: y,
          // The main tent's marker grows with its level (lv1 → lv3 art).
          icon: id == 'main_tent' ? GameArt.playerTent(tentLevel) : icon,
          onTap: () => _openPart(context, controller, id, label, icon),
        ),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
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
    final isMainTent = id == 'main_tent';
    final tentTarget = isMainTent ? controller.tentUpgradeTarget() : null;
    final tentReasons = isMainTent
        ? controller.tentUpgradeBlockReasons()
        : const <String>[];
    final affordable = building.upgradeCost.entries.every(
      (e) => controller.state.resource(e.key) >= e.value,
    );
    showSceneDetail(
      context,
      title: isMainTent
          ? '$label • ${TentUpgradeLogic.tentName(building.level)} '
              '(Lv.${building.level})'
          : '$label • Lv.${building.level}/${building.maxLevel}',
      icon: icon,
      description: isMainTent
          ? 'Çadır yükseltmesi artık hedef, bedel ve sonuçla ilerler.'
          : building.effectDescription,
      extra: isMainTent && tentTarget != null
          ? _TentUpgradeDetails(target: tentTarget, blockReasons: tentReasons)
          : null,
      actions: [
        SceneAction(
          label: isMainTent
              ? tentTarget == null
                  ? 'Azami seviye'
                  : 'Yükselt: ${tentTarget.name}'
              : building.canUpgrade
                  ? 'Yükselt'
                  : 'Azami seviye',
          subtitle: isMainTent
              ? tentReasons.isEmpty
                  ? 'Maliyet hazır; yükseltme uygulanır.'
                  : tentReasons.first
              : building.canUpgrade
                  ? 'Maliyet: ${Formatters.resourceDelta({
                          for (final e in building.upgradeCost.entries)
                            e.key: -e.value
                        })}'
                  : null,
          primary: true,
          enabled: isMainTent
              ? tentTarget != null && tentReasons.isEmpty
              : building.canUpgrade && affordable,
          onTap: () {
            final ok = isMainTent
                ? controller.upgradeTent()
                : controller.upgradeBuilding(id);
            if (ok) {
              AudioService.instance.playSfx('craft');
              showFloatingGain(
                context,
                isMainTent
                    ? 'Çadırın ${tentTarget?.name ?? ''} seviyesine yükseldi.'
                    : '$label ↑',
                color: AppColors.goldBright,
              );
            } else {
              final reason =
                  controller.tentUpgradeBlockReason() ?? 'şartlar eksik.';
              AudioService.instance.playSfx('denied');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isMainTent
                        ? 'Yükseltme yapılamadı: $reason'
                        : 'Kaynak yetersiz.',
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class _TentUpgradeDetails extends StatelessWidget {
  const _TentUpgradeDetails({required this.target, required this.blockReasons});

  final TentUpgradeTarget target;
  final List<String> blockReasons;

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sonraki seviye: ${target.name}', style: AppTextStyles.bodyStrong),
        const SizedBox(height: 8),
        Text('Maliyet', style: AppTextStyles.section),
        const SizedBox(height: 4),
        for (final entry in target.cost.entries)
          _RequirementLine(
            text: '${entry.key.label}: '
                '${state.resource(entry.key)}/${entry.value}',
            ok: state.resource(entry.key) >= entry.value,
          ),
        const SizedBox(height: 8),
        Text('Şartlar', style: AppTextStyles.section),
        const SizedBox(height: 4),
        for (final req in target.requirements)
          _RequirementLine(text: req, ok: _requirementMet(state, req)),
        const SizedBox(height: 8),
        Text('Kazanılacak bonuslar', style: AppTextStyles.section),
        const SizedBox(height: 4),
        for (final bonus in target.bonuses)
          _RequirementLine(text: bonus, ok: true),
      ],
    );
  }

  bool _requirementMet(GameState state, String req) {
    if (req.contains('1 yoldaş')) return state.swornFollowers >= 1;
    if (req.contains('5 yoldaş')) return state.swornFollowers >= 5;
    if (req.contains('obanı kur')) return state.obaFounded;
    return blockReasons.isEmpty ||
        !blockReasons.any((reason) => reason.contains(req.split(' ').first));
  }
}

class _RequirementLine extends StatelessWidget {
  const _RequirementLine({required this.text, required this.ok});

  final String text;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        '${ok ? '✓' : '✗'} $text',
        style: AppTextStyles.meta.copyWith(
          color: ok ? AppColors.success : AppColors.danger,
        ),
      ),
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
              // A carved stone milestone medallion — bright when met, dimmed
              // and ghosted while still to come.
              SizedBox(
                width: 46,
                height: 46,
                child: Opacity(
                  opacity: met ? 1 : 0.4,
                  child: GameImage(
                    primary: GameArt.milestone(step - 1),
                    fallback: GameAssets.iconScrollMedallion,
                    fit: BoxFit.contain,
                    placeholderIcon: met ? Icons.check_circle : Icons.circle,
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

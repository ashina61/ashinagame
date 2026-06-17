import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_art.dart';
import '../../core/assets/game_assets.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/info_sheet.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/game_info.dart';
import '../../game/data/starter_game_data.dart' show GameActions;
import '../../game/data/survival_catalog.dart';
import '../../game/logic/phase_logic.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';
import '../atelier/atelier_screen.dart';
import '../character/character_screen.dart';
import '../inventory/inventory_screen.dart';
import '../journey/journey_scene.dart';
import '../market/market_screen.dart';
import '../people/nearby_people_scene.dart';
import '../scene/floating_text.dart';
import '../scene/scene_atmosphere.dart';
import '../scene/scene_detail_panel.dart';
import '../scene/scene_hotspot.dart';
import '../scene/scene_hud_overlay.dart';
import '../scene/scene_screen.dart';
import '../settings/settings_screen.dart';
import '../tent/tent_scene.dart';

/// The home screen is no longer a dashboard — it is the player's own camp at
/// night on the steppe. The tent, the fire, the chest, the tethered horse and
/// the road out are tappable places; resources and the day float over the
/// scene as a HUD; the day's work sits on big cards along the bottom.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static void push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final hasEvent = state.currentEvent != null;

    final hotspots = <SceneHotspot>[
      SceneHotspot(
        id: 'tent',
        title: 'Çadırım',
        x: 0.5,
        y: 0.38,
        icon: GameArt.playerTentLv1,
        onTap: () => push(context, const TentScreen(showBack: true)),
      ),
      SceneHotspot(
        id: 'fire',
        title: hasEvent ? 'Ateş Başı Olayı' : 'Ateş Ocağı',
        x: 0.66,
        y: 0.6,
        icon: GameArt.campFire,
        badge: hasEvent ? '!' : null,
        onTap: () => _openFire(context, controller),
      ),
      SceneHotspot(
        id: 'chest',
        title: 'Sandık',
        x: 0.28,
        y: 0.62,
        icon: GameArt.campChest,
        onTap: () => push(context, const InventoryScreen()),
      ),
      SceneHotspot(
        id: 'horse',
        title: 'At Bağı',
        x: 0.82,
        y: 0.4,
        icon: GameArt.campHorseTie,
        onTap: () => _openHorse(context, controller),
      ),
      SceneHotspot(
        id: 'workshop',
        title: 'Çalışma Tezgâhı',
        x: 0.16,
        y: 0.4,
        icon: GameArt.campWorkbench,
        onTap: () => push(context, const AtelierScreen()),
      ),
      SceneHotspot(
        id: 'road',
        title: 'Yakın Yol',
        x: 0.86,
        y: 0.74,
        icon: GameAssets.iconCompassStar,
        onTap: () => push(context, const JourneyScreen()),
      ),
    ];

    return SceneScreen(
      // Prefers produced camp art; falls back to the shipping night camp until
      // it lands (see assets/images/game/README.md).
      // TODO(asset): camp_night_bg.
      background: GameArt.campNightBg,
      backgroundFallback: GameAssets.bgSceneCampNight,
      atmosphere: const EmberGlow(center: Alignment(0.32, 0.25)),
      hud: const _HomeHud(),
      hotspots: hotspots,
      foreground: const _CampTitlePlate(),
      bottom: const _CampBottom(),
    );
  }

  void _openFire(BuildContext context, GameController controller) {
    final event = controller.state.currentEvent;
    showSceneDetail(
      context,
      title: event?.title ?? 'Ateş Ocağı',
      icon: GameAssets.iconMoraleEmblem,
      description:
          event?.description ??
          'Ocağın başında dinlenir, yorgunluğunu atarsın.',
      actions: event == null
          ? [
              SceneAction(
                label: 'Kampı Toparla (dinlen)',
                subtitle: 'Enerji +20, yorgunluk -15',
                primary: true,
                enabled: controller.state.dailyActionPoints > 0,
                onTap: () => controller.rest(),
              ),
            ]
          : [
              for (final choice in event.choices)
                SceneAction(
                  label: choice.label,
                  subtitle: choice.resourceEffects.isEmpty
                      ? choice.description
                      : Formatters.resourceDelta(choice.resourceEffects),
                  onTap: () => controller.chooseEvent(choice),
                ),
            ],
    );
  }

  void _openHorse(BuildContext context, GameController controller) {
    final horse = controller.state.horses.isEmpty
        ? null
        : controller.state.horses.first;
    final market = controller.horseMarket();
    final gold = controller.state.resource(ResourceType.gold);
    showSceneDetail(
      context,
      title: 'At Bağı',
      icon: GameAssets.iconMedallionHorse,
      description: horse == null
          ? 'Bağ boş. Pazarda at bakabilir, ilk yol arkadaşını seçebilirsin.'
          : '${horse.name} (${horse.breed}) • sağlık ${horse.health}, '
                'açlık ${horse.hunger}, sadakat ${horse.loyalty}, '
                'talim ${horse.training}.',
      actions: [
        if (horse != null) ...[
          SceneAction(
            label: 'Atı besle',
            subtitle: 'At açlığı +22, ruh hâli +4',
            onTap: () => controller.careForHorse(horse.id, 'feed'),
          ),
          SceneAction(
            label: 'Atı tımar et',
            subtitle: 'Temizlik +25, sadakat +2',
            onTap: () => controller.careForHorse(horse.id, 'clean'),
          ),
          SceneAction(
            label: 'At binme talimi',
            subtitle: 'Talim +8, yorgunluk +12',
            onTap: () => controller.careForHorse(horse.id, 'train'),
          ),
        ],
        for (final offer in market)
          SceneAction(
            label: 'Satın al: ${offer.name}',
            subtitle:
                '${offer.breed} • ${offer.rarity} • '
                '${offer.price} altın',
            enabled: offer.price <= gold,
            onTap: () => controller.buyHorse(offer),
          ),
      ],
    );
  }
}

class _HomeHud extends StatelessWidget {
  const _HomeHud();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 4, 0),
          child: Row(
            children: [
              const Expanded(
                child: Text('ASHINA', style: AppTextStyles.display),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline, color: AppColors.gold),
                tooltip: 'Yardım',
                onPressed: () => showHelpSheet(context, HelpId.camp),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: AppColors.gold),
                tooltip: 'Ayarlar',
                onPressed: () =>
                    HomeScreen.push(context, const SettingsScreen()),
              ),
            ],
          ),
        ),
        const SceneHudOverlay(),
        const _SurvivalStrip(),
      ],
    );
  }
}

class _SurvivalStrip extends StatelessWidget {
  const _SurvivalStrip();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final s = state.survival;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Wrap(
        spacing: 6,
        runSpacing: 2,
        children: [
          _StatChip('Açlık', s.hunger),
          _StatChip('Susuzluk', s.thirst),
          _StatChip('Yorgunluk', s.fatigue, dangerHigh: true),
          _StatChip('Sağlık', state.profile.health),
          _StatChip('Moral', state.resource(ResourceType.morale)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.label, this.value, {this.dangerHigh = false});

  final String label;
  final int value;
  final bool dangerHigh;

  @override
  Widget build(BuildContext context) {
    final healthScore = dangerHigh ? 100 - value : value;
    final color = healthScore >= 55
        ? AppColors.success
        : healthScore >= 30
        ? AppColors.gold
        : AppColors.danger;
    return Text(
      '$label $value',
      style: AppTextStyles.meta.copyWith(color: color, fontSize: 11),
    );
  }
}

/// A small status plate floating in the scene — name, title, and the three
/// stats that matter most — standing in for the old character card.
class _CampTitlePlate extends StatelessWidget {
  const _CampTitlePlate();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final profile = state.profile;
    return Positioned(
      left: 12,
      top: 6,
      child: GestureDetector(
        onTap: () =>
            HomeScreen.push(context, const CharacterScreen(showBack: true)),
        child: Container(
          width: 188,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.ink.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.goldDim.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${profile.name}, ${profile.age}',
                style: AppTextStyles.bodyStrong,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${profile.title} • Sv.${profile.level}',
                style: AppTextStyles.meta.copyWith(color: AppColors.goldBright),
              ),
              const SizedBox(height: 6),
              _MiniStat('Sağlık', profile.health),
              _MiniStat('Enerji', profile.energy),
              _MiniStat('İtibar', profile.reputation),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: AppTextStyles.meta.copyWith(fontSize: 11),
            ),
          ),
          Expanded(child: StatBar(fraction: value / 100, height: 7)),
        ],
      ),
    );
  }
}

/// Big action cards plus the next-milestone hint and locked goal chips.
class _CampBottom extends StatelessWidget {
  const _CampBottom();

  static const _jobs = [
    (
      GameAssets.sceneWoodcut2,
      GameActions.wood,
      'Odun Kes',
      {ResourceType.wood: 15, ResourceType.food: -2},
      12,
    ),
    (
      GameAssets.sceneHunt2,
      GameActions.hunt,
      'Avlan',
      {ResourceType.food: 20, ResourceType.leather: 2},
      18,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final objective =
        PhaseLogic.dailyTutorial(state) ?? PhaseLogic.nextObjective(state);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0xCC0B0B0B)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AmbientLine(day: state.day.day),
          if (state.raidLooming)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.leatherDeep.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.danger),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Düşman akını ${state.raidCountdown} gün sonra! '
                      'Ordunu güçlendir.',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        color: AppColors.danger,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          if (objective != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.leatherDeep.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.flag_circle,
                    size: 18,
                    color: AppColors.goldBright,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      objective,
                      style: AppTextStyles.body.copyWith(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const _BigGoalPanel(),
          const _OpportunityPanel(),
          Row(
            children: [
              for (final (asset, action, label, effects, xp) in _jobs)
                Expanded(
                  child: _ActionCard(
                    asset: asset,
                    label: label,
                    onTap: () {
                      final done = controller.performCampAction(
                        action,
                        label,
                        effects,
                        xp: xp,
                      );
                      if (done) {
                        showFloatingGain(
                          context,
                          Formatters.resourceDelta(effects),
                        );
                      } else {
                        _toast(context, 'Aksiyon hakkı bitti. Günü bitir.');
                      }
                    },
                  ),
                ),
              Expanded(
                child: _ActionCard(
                  asset: GameAssets.sceneMercenary,
                  label: 'Pazara Uğra',
                  onTap: () => HomeScreen.push(context, const MarketScreen()),
                ),
              ),
              Expanded(
                child: _ActionCard(
                  asset: GameAssets.bgSceneCampNight,
                  label: 'Kampı Toparla',
                  onTap: () {
                    final done = controller.rest();
                    if (done) {
                      showFloatingGain(
                        context,
                        'Dinlendin',
                        color: AppColors.success,
                      );
                    } else {
                      _toast(context, 'Aksiyon hakkı bitti. Günü bitir.');
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _SurvivalActionRail(),
          const _GoalChips(),
        ],
      ),
    );
  }

  static void _toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
  }
}

class _BigGoalPanel extends StatelessWidget {
  const _BigGoalPanel();

  @override
  Widget build(BuildContext context) {
    final goal = GameScope.of(context).nextBigGoal();
    if (goal == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.leatherDeep.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.goldDim),
      ),
      child: Text(
        'Sıradaki Büyük Hedef: ${goal.title} — ${goal.detail}',
        style: AppTextStyles.body.copyWith(fontSize: 12),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _OpportunityPanel extends StatelessWidget {
  const _OpportunityPanel();

  @override
  Widget build(BuildContext context) {
    final ops = GameScope.of(context).todaysOpportunities();
    if (ops.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.leatherDeep.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Bugünün fırsatları: ${ops.take(3).map((o) => o.title).join(' • ')}',
        style: AppTextStyles.meta,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _SurvivalActionRail extends StatelessWidget {
  const _SurvivalActionRail();

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final actions = SurvivalCatalog.actions.take(8).toList();
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final action = actions[index];
          final cooling = controller.state.actionCooldowns[action.id] ?? 0;
          return DarkButton(
            label: cooling > 0 ? '${action.name} ($cooling)' : action.name,
            onPressed: cooling > 0
                ? null
                : () {
                    final ok = controller.performSurvivalAction(action.id);
                    _CampBottom._toast(
                      context,
                      ok ? '${action.name} yapıldı.' : 'Bu iş bugün olmaz.',
                    );
                  },
          );
        },
      ),
    );
  }
}

/// A single drifting line of bozkır atmosphere above the day's work — sets the
/// scene's mood without a wall of text. Rotates slowly with the day.
class _AmbientLine extends StatelessWidget {
  const _AmbientLine({required this.day});

  final int day;

  static const _lines = [
    'Ateş sönmeden bir iş daha çıkar.',
    'Gök sonsuz, bozkır geniş — adın yavaş yavaş duyuluyor.',
    'Rüzgâr çadırın örtüsünü yokluyor; gece uzun.',
    'Uzakta bir kurt uluyor. Yalnızsın ama yılmadın.',
    'Bu çadır bir gün obanın kalbi olabilir.',
    'Toprak seni çağırıyor — vakit, emek vakti.',
    'Köz başında geçen her gün seni biraz büyütüyor.',
  ];

  @override
  Widget build(BuildContext context) {
    final line = _lines[day % _lines.length];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 14,
            color: AppColors.ember,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              line,
              style: AppTextStyles.meta.copyWith(
                color: AppColors.sand,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
          image: DecorationImage(
            image: AssetImage(asset),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(
              Color(0x55000000),
              BlendMode.darken,
            ),
          ),
        ),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          color: AppColors.ink.withValues(alpha: 0.6),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyStrong.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// Locked late-game goals shown as small chips — a constant reminder of where
/// the road leads without handing those systems over on day one.
class _GoalChips extends StatelessWidget {
  const _GoalChips();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final followersDone = state.swornFollowers >= PhaseLogic.followersToFound;
    final marriedDone = PhaseLogic.hasStrongBond(state);
    final canFound = PhaseLogic.canFoundOba(state);
    return Row(
      children: [
        Expanded(
          child: _Chip(
            label: 'Yandaş Topla',
            done: followersDone,
            onTap: () => HomeScreen.push(context, const NearbyPeopleScreen()),
          ),
        ),
        Expanded(
          child: _Chip(
            label: 'Evlilik',
            done: marriedDone,
            onTap: () => HomeScreen.push(context, const NearbyPeopleScreen()),
          ),
        ),
        Expanded(
          child: _Chip(
            label: 'Oba Kur',
            done: state.obaFounded,
            locked: !canFound && !state.obaFounded,
            onTap: () =>
                HomeScreen.push(context, const TentScreen(showBack: true)),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onTap,
    this.done = false,
    this.locked = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool done;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.ink.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: done
                ? AppColors.success
                : AppColors.goldDim.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              done
                  ? Icons.check_circle
                  : locked
                  ? Icons.lock
                  : Icons.flag,
              size: 13,
              color: done ? AppColors.success : AppColors.sand,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.meta.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

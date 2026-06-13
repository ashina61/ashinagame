import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/resource_visuals.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/achievements.dart';
import '../../game/data/expedition_sites.dart';
import '../../game/data/starter_game_data.dart';
import '../../game/logic/unlock_logic.dart';
import '../../game/models/event_choice.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';
import '../achievements/achievements_screen.dart';
import '../character/character_screen.dart';
import '../expeditions/expeditions_screen.dart';
import '../inventory/inventory_screen.dart';
import '../market/market_screen.dart';
import '../quests/quests_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;

    return OrnateScaffold(
      child: Column(
        children: [
          const SizedBox(height: 4),
          Stack(
            alignment: Alignment.center,
            children: [
              const _LogoHeader(),
              Positioned(
                right: 8,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.settings, color: AppColors.gold),
                  tooltip: 'Ayarlar',
                  onPressed: () => _push(context, const SettingsScreen()),
                ),
              ),
            ],
          ),
          ResourceBar(
            entries: [
              for (final type in const [
                ResourceType.gold,
                ResourceType.food,
                ResourceType.wood,
                ResourceType.horse,
                ResourceType.reputation,
              ])
                (ResourceVisuals.icon(type), '${state.resource(type)}'),
            ],
          ),
          const _DayStrip(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 6, bottom: 16),
              children: [
                const _CharacterCard(),
                const SectionPlaque('YAPILACAKLAR'),
                const _TodoPanel(),
                if (state.currentEvent != null) ...[
                  const SectionPlaque('OBA OLAYI'),
                  const _EventPanel(),
                ],
                const Row(
                  children: [
                    Expanded(child: _DailyGoalCard()),
                    Expanded(child: _SuggestedMoveCard()),
                  ],
                ),
                const SectionPlaque('GÜNLÜK İŞLER'),
                const _DailyJobsRow(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DarkButton(
                              label: 'ENVANTER',
                              onPressed: () =>
                                  _push(context, const InventoryScreen()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DarkButton(
                              label: 'PAZAR',
                              onPressed: () =>
                                  _push(context, const MarketScreen()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DarkButton(
                              label: 'GÖREVLER',
                              onPressed: () =>
                                  _push(context, const QuestsScreen()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DarkButton(
                        label: 'BAŞARIMLAR',
                        onPressed: () =>
                            _push(context, const AchievementsScreen()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => screen));
  }
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('ASHINA', style: AppTextStyles.display),
        Text(
          'BOZKIRDA BİR ÖMÜR',
          style: AppTextStyles.section.copyWith(letterSpacing: 4),
        ),
      ],
    );
  }
}

/// Day & season readout with the end-of-day action.
class _DayStrip extends StatelessWidget {
  const _DayStrip();

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final day = state.day;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(GameAssets.uiPanelPill),
                  fit: BoxFit.fill,
                ),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Image.asset(
                    GameAssets.iconSunEmblem,
                    width: 18,
                    height: 18,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Gün ${day.day} • ${day.season.label}',
                      style: AppTextStyles.value.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(GameAssets.uiPanelPill),
                fit: BoxFit.fill,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(GameAssets.iconEnergyBolt, width: 16, height: 16),
                const SizedBox(width: 4),
                Text(
                  'Aksiyon: ${state.dailyActionPoints}/${state.maxDailyActionPoints}',
                  style: AppTextStyles.value.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GoldButton(
            label: 'GÜNÜ BİTİR',
            height: 36,
            onPressed: () {
              controller.endDay();
              AudioService.instance.playSfx('end_day');
              final next = controller.state.day;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Gün ${next.day} başladı. ${next.season.atmosphere}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final profile = state.profile;
    final morale = state.resource(ResourceType.morale);
    final reputation = state.resource(ResourceType.reputation);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (_) => const CharacterScreen(showBack: true)),
      ),
      child: OrnatePanel(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 104,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.7),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 6),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.asset(
                  GameAssets.characterLeader,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.leatherDeep,
                    alignment: Alignment.center,
                    child: Image.asset(
                      GameAssets.iconPopulationMedallion,
                      width: 64,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${profile.name}, ${profile.age}',
                          style: AppTextStyles.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        state.clan.name,
                        style:
                            AppTextStyles.meta.copyWith(color: AppColors.gold),
                      ),
                    ],
                  ),
                  Text(profile.title, style: AppTextStyles.meta),
                  const SizedBox(height: 8),
                  _StatRow(
                    GameAssets.iconHeartMedallion,
                    'Moral',
                    morale,
                    100,
                  ),
                  _StatRow(
                    GameAssets.iconScrollMedallion,
                    'İtibar',
                    reputation,
                    100,
                  ),
                  _StatRow(
                    GameAssets.iconEnergyBolt,
                    'Sağlık',
                    profile.health,
                    100,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enerji ${profile.energy}/100 • Yorgunluk ${profile.fatigue}/100 — ${state.day.season.atmosphere}',
                    style: AppTextStyles.meta.copyWith(fontSize: 12),
                    maxLines: 2,
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

class _StatRow extends StatelessWidget {
  const _StatRow(this.icon, this.label, this.value, this.max);

  final String icon;
  final String label;
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Image.asset(icon, width: 16, height: 16),
          const SizedBox(width: 4),
          SizedBox(
            width: 56,
            child:
                Text(label, style: AppTextStyles.body.copyWith(fontSize: 13)),
          ),
          Expanded(child: StatBar(fraction: value / max, height: 9)),
          SizedBox(
            width: 52,
            child: Text(
              '$value/$max',
              textAlign: TextAlign.right,
              style: AppTextStyles.meta.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

/// Active steppe event with its branching choices.
/// A live checklist of what the player can do right now.
class _TodoPanel extends StatelessWidget {
  const _TodoPanel();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final items = <(IconData, String, Widget?)>[];

    // The ordered progression hint comes first, so a new player always knows
    // the next milestone to chase.
    final objective = UnlockLogic.nextObjective(state);
    if (objective != null) {
      items.add((Icons.flag_circle, objective, null));
    }

    final readyQuests = state.quests.where(state.questReady).length;
    if (readyQuests > 0) {
      items.add((
        Icons.emoji_events,
        '$readyQuests görev ödülü almaya hazır',
        const QuestsScreen(),
      ));
    }

    final readyAchievements =
        Achievements.all.where(state.achievementReady).length;
    if (readyAchievements > 0) {
      items.add((
        Icons.military_tech,
        '$readyAchievements başarım ödülü hazır',
        const AchievementsScreen(),
      ));
    }

    if (state.currentEvent != null) {
      items.add((Icons.campaign, 'Oba olayını karara bağla', null));
    }

    for (final site in ExpeditionSites.all) {
      if (!state.expeditionDone(site.id)) {
        items.add((
          Icons.flag,
          '${site.name} henüz fethedilmedi',
          const ExpeditionsScreen(),
        ));
        break;
      }
    }

    if (state.dailyActionPoints > 0) {
      items.add((
        Icons.bolt,
        '${state.dailyActionPoints} hamle hakkın var — işlere bak',
        null,
      ));
    }

    if (items.isEmpty) {
      items.add((Icons.bedtime, 'Bugünlük her şey tamam — günü bitir', null));
    }

    return OrnatePanel(
      child: Column(
        children: [
          for (final (icon, label, target) in items.take(4))
            GestureDetector(
              onTap: target == null
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => target),
                      ),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: AppColors.goldBright),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: AppTextStyles.body.copyWith(fontSize: 13),
                      ),
                    ),
                    if (target != null)
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.stone,
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

class _EventPanel extends StatelessWidget {
  const _EventPanel();

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final event = controller.state.currentEvent;
    if (event == null) {
      return const SizedBox.shrink();
    }
    return OrnatePanel(
      backgroundAsset: GameAssets.bgSceneCampNight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(event.description, style: AppTextStyles.body),
          const SizedBox(height: 10),
          for (final choice in event.choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _EventChoiceButton(choice: choice),
            ),
        ],
      ),
    );
  }
}

class _EventChoiceButton extends StatelessWidget {
  const _EventChoiceButton({required this.choice});

  final EventChoice choice;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    return GestureDetector(
      onTap: () {
        final ok = controller.chooseEvent(choice);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(ok
                  ? '${choice.label}: ${choice.description}'
                  : 'Bu karar için aksiyon hakkı yok.')),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(GameAssets.uiPanelField),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(choice.label, style: AppTextStyles.buttonDark),
            if (choice.resourceEffects.isNotEmpty)
              Text(
                Formatters.resourceDelta(choice.resourceEffects),
                style: AppTextStyles.meta.copyWith(
                  color: AppColors.goldBright,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final dailies = state.quests.where((q) => q.category == 'Günlük').toList();
    final done = dailies.where((q) => q.completed).length;
    final next = dailies.where((q) => !q.completed).toList();
    final ready = next.where(state.questReady).toList();
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const QuestsScreen()),
      ),
      child: OrnatePanel(
        margin: const EdgeInsets.fromLTRB(12, 0, 4, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GÜNLÜK HEDEFLER',
              style: AppTextStyles.section.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              next.isEmpty
                  ? 'Bugünün hedefleri tamam. $done/${dailies.length}'
                  : ready.isNotEmpty
                      ? '${ready.first.title} — ödül hazır!'
                      : '${next.first.title} '
                          '${state.questProgress(next.first)}'
                          '/${next.first.goalTarget}',
              style: AppTextStyles.body.copyWith(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Ödül:', style: AppTextStyles.meta),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    next.isEmpty ? '—' : next.first.rewardText,
                    style: AppTextStyles.value.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedMoveCard extends StatelessWidget {
  const _SuggestedMoveCard();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final (scene, hint) = state.currentEvent != null
        ? (GameAssets.sceneCraftNight, 'Obadaki olayı karara bağla.')
        : state.resource(ResourceType.food) < 40
            ? (GameAssets.sceneHunt2, 'Erzak azalıyor; avcıları gönder.')
            : (GameAssets.sceneCraft3, 'Atölyede yeni bir eşya üret.');
    return OrnatePanel(
      margin: const EdgeInsets.fromLTRB(4, 0, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ÖNERİLEN HAMLE',
            style: AppTextStyles.section.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  scene,
                  width: 56,
                  height: 42,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(width: 56, height: 42),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hint,
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyJobsRow extends StatelessWidget {
  const _DailyJobsRow();

  static const _jobs = [
    (
      GameAssets.sceneWoodcut2,
      GameActions.wood,
      'Odun Kes',
      {ResourceType.wood: 15, ResourceType.food: -2},
      10,
      8,
      12,
    ),
    (
      GameAssets.sceneFarm3,
      GameActions.farm,
      'Tarlada Çalış',
      {ResourceType.food: 12},
      8,
      6,
      10,
    ),
    (
      GameAssets.sceneHunt2,
      GameActions.hunt,
      'Avlan',
      {ResourceType.food: 20, ResourceType.leather: 2},
      15,
      10,
      18,
    ),
    (
      GameAssets.sceneRiders,
      GameActions.training,
      'Eğitim Yap',
      {ResourceType.reputation: 2, ResourceType.food: -5},
      12,
      9,
      16,
    ),
    (
      GameAssets.sceneMercenary,
      GameActions.trade,
      'Kervan Koru',
      {ResourceType.gold: 18, ResourceType.food: -4},
      12,
      8,
      14,
    ),
    (
      GameAssets.bgSceneCampNight,
      GameActions.rest,
      'Dinlen',
      <ResourceType, int>{},
      0,
      0,
      5,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _jobs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (asset, actionId, label, effects, energyCost, fatigueGain, xp) =
              _jobs[index];
          return GestureDetector(
            onTap: () {
              final done = actionId == GameActions.rest
                  ? controller.rest()
                  : controller.performCampAction(
                      actionId,
                      label,
                      effects,
                      energyCost: energyCost,
                      fatigueGain: fatigueGain,
                      xp: xp,
                    );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    done
                        ? '$label: ${Formatters.resourceDelta(effects)}'
                        : state.dailyActionPoints <= 0
                            ? 'Aksiyon hakkı bitti. Günü bitir.'
                            : 'Aksiyon yapılamadı.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              width: 104,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(GameAssets.uiCardTask),
                  fit: BoxFit.fill,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
              child: Column(
                children: [
                  Expanded(child: Image.asset(asset, fit: BoxFit.contain)),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyStrong.copyWith(fontSize: 11),
                  ),
                  Text(
                    'AP ${GameController.campActionCost} • '
                    '${Formatters.resourceDelta(effects)}',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.meta.copyWith(
                      color: state.dailyActionPoints > 0
                          ? AppColors.goldBright
                          : AppColors.stone,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

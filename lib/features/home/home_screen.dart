import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/resource_visuals.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/event_choice.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';
import '../character/character_screen.dart';
import '../expeditions/expeditions_screen.dart';
import '../inventory/inventory_screen.dart';
import '../market/market_screen.dart';
import '../quests/quests_screen.dart';

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
          const _LogoHeader(),
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
                const SectionPlaque('HANE ÖZETİ'),
                const _HouseholdPanel(),
                const SectionPlaque('BECERİLER'),
                const _SkillsPanel(),
                if (state.log.isNotEmpty) ...[
                  const SectionPlaque('OBA GÜNLÜĞÜ'),
                  const _LogPanel(),
                ],
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
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DarkButton(
                              label: 'GÖREVLER',
                              onPressed: () =>
                                  _push(context, const QuestsScreen()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DarkButton(
                              label: 'SEFERLER',
                              onPressed: () =>
                                  _push(context, const ExpeditionsScreen()),
                            ),
                          ),
                        ],
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
    final day = controller.state.day;
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
          GoldButton(
            label: 'GÜNÜ BİTİR',
            height: 36,
            onPressed: () {
              controller.endDay();
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
        MaterialPageRoute<void>(builder: (_) => const CharacterScreen()),
      ),
      child: OrnatePanel(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              height: 158,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  GameAssets.characterLeader,
                  fit: BoxFit.cover,
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
                    'Erzak',
                    state.resource(ResourceType.food),
                    200,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.day.season.atmosphere,
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
        controller.chooseEvent(choice);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${choice.label}: ${choice.description}')),
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
    final quests = state.quests;
    final done = quests.where((q) => q.completed).length;
    final next = quests.where((q) => !q.completed).toList();
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
                  ? 'Tüm görevler tamamlandı.'
                  : '${next.first.title}. $done/${quests.length}',
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
      'Odun Kes',
      {ResourceType.wood: 8, ResourceType.food: -2},
    ),
    (
      GameAssets.sceneFarm3,
      'Tarlada Çalış',
      {ResourceType.food: 10},
    ),
    (
      GameAssets.sceneHunt2,
      'Avlan',
      {ResourceType.food: 12, ResourceType.leather: 2},
    ),
    (
      GameAssets.sceneRiders,
      'Paralı Asker Topla',
      {ResourceType.reputation: 2, ResourceType.food: -5, ResourceType.gold: 6},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _jobs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (asset, label, effects) = _jobs[index];
          return GestureDetector(
            onTap: () {
              controller.performCampAction(label, effects);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$label: ${Formatters.resourceDelta(effects)}',
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
                    Formatters.resourceDelta(effects),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.meta.copyWith(
                      color: AppColors.goldBright,
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

class _HouseholdPanel extends StatelessWidget {
  const _HouseholdPanel();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    return OrnatePanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _KeyValue(
                  GameAssets.iconPopulationEmblem,
                  'Nüfus',
                  '${state.resource(ResourceType.population)}',
                ),
                _KeyValue(
                  GameAssets.iconMoraleEmblem,
                  'Moral',
                  '${state.resource(ResourceType.morale)}/100',
                ),
                _KeyValue(
                  GameAssets.iconMedallionHorse,
                  'At Sürüsü',
                  '${state.resource(ResourceType.horse)}',
                ),
                _KeyValue(
                  GameAssets.iconFarmEmblem,
                  'Erzak',
                  '${state.resource(ResourceType.food)}',
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _KeyValue(
                  GameAssets.iconCoinGold,
                  'Altın',
                  '${state.resource(ResourceType.gold)}',
                ),
                _KeyValue(
                  GameAssets.iconItemWood,
                  'Odun',
                  '${state.resource(ResourceType.wood)}',
                ),
                _KeyValue(
                  GameAssets.iconItemLeather,
                  'Deri',
                  '${state.resource(ResourceType.leather)}',
                ),
                _KeyValue(
                  GameAssets.iconScrollMedallion,
                  'İtibar',
                  '${state.resource(ResourceType.reputation)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillsPanel extends StatelessWidget {
  const _SkillsPanel();

  @override
  Widget build(BuildContext context) {
    final profile = GameScope.of(context).state.profile;
    final skills = [
      (GameAssets.iconSwordsCrossedGold, 'Cesaret', profile.courage),
      (GameAssets.iconScrollMedallion, 'Bilgelik', profile.wisdom),
      (GameAssets.iconArmyEmblem, 'Liderlik', profile.leadership),
      (GameAssets.iconShieldSwords, 'Dayanıklılık', profile.endurance),
    ];
    return OrnatePanel(
      child: Column(
        children: [
          for (final (icon, label, value) in skills)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Image.asset(icon, width: 18, height: 18),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 96,
                    child: Text(label, style: AppTextStyles.body),
                  ),
                  Expanded(
                    child: StatBar(fraction: value / 12, height: 10),
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '$value',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.value.copyWith(fontSize: 14),
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

class _LogPanel extends StatelessWidget {
  const _LogPanel();

  @override
  Widget build(BuildContext context) {
    final log = GameScope.of(context).state.log;
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in log)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '◆ ',
                    style: AppTextStyles.meta.copyWith(color: AppColors.gold),
                  ),
                  Expanded(
                    child: Text(
                      entry,
                      style: AppTextStyles.body.copyWith(fontSize: 13),
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

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.icon, this.label, this.value);

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Image.asset(icon, width: 18, height: 18),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(value, style: AppTextStyles.value),
        ],
      ),
    );
  }
}

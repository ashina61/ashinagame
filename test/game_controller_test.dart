import 'dart:convert';
import 'dart:math';

import 'package:ashinagame/game/data/achievements.dart';
import 'package:ashinagame/game/data/market_goods.dart';
import 'package:ashinagame/game/data/starter_game_data.dart';
import 'package:ashinagame/game/logic/market_logic.dart';
import 'package:ashinagame/game/models/faith.dart';
import 'package:ashinagame/game/models/game_day.dart';
import 'package:ashinagame/game/models/household.dart';
import 'package:ashinagame/game/models/resource.dart';
import 'package:ashinagame/game/models/season.dart';
import 'package:ashinagame/game/state/game_controller.dart';
import 'package:ashinagame/game/state/game_serializer.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedRandom implements Random {
  _FixedRandom(this._value);
  final int _value;
  @override
  int nextInt(int max) => _value % max;
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
}

void main() {
  const huntEffects = {ResourceType.food: 20, ResourceType.leather: 2};

  test('quest completion grants XP and can level up', () {
    final controller = GameController.starter();
    controller.performCampAction(GameActions.hunt, 'Avlan', huntEffects,
        xp: 90);
    final beforeLevel = controller.state.profile.level;
    final beforeXp = controller.state.profile.xp;
    controller.claimQuest('d_hunt');
    // Claiming grants XP; a level-up wraps XP, so accept either signal.
    final leveledUp = controller.state.profile.level > beforeLevel;
    expect(leveledUp || controller.state.profile.xp > beforeXp, isTrue);

    for (var i = 0; i < 4; i++) {
      controller.endDay();
      controller.performCampAction(GameActions.hunt, 'Avlan', huntEffects,
          xp: 80);
    }
    expect(controller.state.profile.level, greaterThan(1));
    expect(controller.state.profile.skillPoints, greaterThan(0));
  });

  test('skill point spending increases the selected stat', () {
    final controller = GameController(
      StarterGameData.create().copyWith(
        profile: StarterGameData.create().profile.copyWith(skillPoints: 1),
      ),
    );
    final before = controller.state.profile.trade;
    expect(controller.spendSkillPoint('trade'), isTrue);
    expect(controller.state.profile.trade, before + 1);
    expect(controller.state.profile.skillPoints, 0);
  });

  test('daily action points gate actions and renew at day end', () {
    final controller = GameController.starter();
    expect(controller.state.dailyActionPoints, 4);
    expect(
        controller.performCampAction(
            GameActions.farm, 'Tarla', const {ResourceType.food: 12}),
        isTrue);
    expect(controller.state.dailyActionPoints, 3);
    for (var i = 0; i < 3; i++) {
      expect(controller.rest(), isTrue);
    }
    expect(
        controller.performCampAction(
            GameActions.farm, 'Tarla', const {ResourceType.food: 12}),
        isFalse);
    controller.endDay();
    expect(controller.state.dailyActionPoints,
        controller.state.maxDailyActionPoints);
  });

  test('energy fatigue and health are affected by action and day cycle', () {
    final controller = GameController.starter();
    controller.performCampAction(
        GameActions.wood, 'Odun Kes', const {ResourceType.wood: 15},
        energyCost: 10, fatigueGain: 8);
    expect(controller.state.profile.energy, lessThan(100));
    expect(controller.state.profile.fatigue, greaterThan(0));
    controller.endDay();
    expect(controller.state.profile.energy, greaterThan(80));
  });

  test('building upgrade spends resources and insufficient resources fail', () {
    final controller = GameController.starter();
    expect(controller.upgradeBuilding('storage'), isTrue);
    expect(controller.state.building('storage')!.level, 2);
    expect(controller.state.resource(ResourceType.wood), 25);
    expect(controller.state.resource(ResourceType.stone), 10);
    expect(controller.upgradeBuilding('watchtower'), isFalse);
    expect(controller.state.building('watchtower')!.level, 1);
  });

  test('diplomacy action changes relation and consumes AP', () {
    final controller = GameController.starter();
    final before = controller.state.tribes.first.relation;
    expect(
        controller.performDiplomacy(controller.state.tribes.first.id, 'envoy'),
        isTrue);
    expect(controller.state.tribes.first.relation, isNot(before));
    expect(controller.state.dailyActionPoints, 3);
  });

  test('marriage requires conditions and then updates household', () {
    final controller = GameController.starter();
    expect(controller.proposeMarriage('aybuke'), isFalse);
    final boosted = controller.state.copyWith(
      resources: {
        ...controller.state.resources,
        ResourceType.gold: 600,
        ResourceType.reputation: 25,
      },
    );
    final ready = GameController(boosted);
    expect(ready.proposeMarriage('aybuke'), isTrue);
    expect(ready.state.household.spouseName, 'Aybüke');
    expect(ready.state.household.isMarried, isTrue);
    expect(ready.state.tribeByName('Kara Kurtlar')!.marriageTie, isTrue);
  });

  test('crafting, expeditions, market and serializer still work', () {
    final controller =
        GameController(StarterGameData.create(), random: _FixedRandom(0));
    expect(controller.startCraft('wood_shield'), CraftStart.started);
    controller.endDay();
    expect(controller.state.craftedCount('wood_shield'), 1);

    final outcome = controller.embarkExpedition('border_outpost');
    expect(outcome, isNotNull);
    expect(controller.state.expeditionDone('border_outpost'), isTrue);

    final salt = MarketGoods.byId('salt')!;
    final price = MarketLogic.priceFor(salt, controller.state.day.day);
    expect(controller.buyGood('salt'), isTrue);
    expect(controller.state.resource(ResourceType.gold),
        lessThan(250 - price + 100));

    final decoded =
        GameSerializer.decode(GameSerializer.encode(controller.state));
    expect(decoded, isNotNull);
    expect(decoded!.buildings.length, controller.state.buildings.length);
    expect(decoded.tribes.length, controller.state.tribes.length);
    expect(decoded.household.householdMorale,
        controller.state.household.householdMorale);

    final legacyMap = jsonDecode(GameSerializer.encode(controller.state))
        as Map<String, dynamic>;
    legacyMap
      ..remove('buildings')
      ..remove('tribes')
      ..remove('household')
      ..remove('marriageCandidates')
      ..remove('dailyActionPoints')
      ..remove('maxDailyActionPoints');
    final legacy = GameSerializer.decode(jsonEncode(legacyMap));
    expect(legacy, isNotNull);
    expect(legacy!.buildings.length, StarterGameData.campBuildings.length);
    expect(GameSerializer.decode('not-json'), isNull);
  });

  test('ritual spends resources and cooldown blocks repeat', () {
    final controller = GameController.starter();
    final beforeGold = controller.state.resource(ResourceType.gold);
    expect(controller.performRitual('sky_oath'), isTrue);
    expect(controller.state.resource(ResourceType.gold), beforeGold - 80);
    expect(controller.state.faithState.kut, 53);
    expect(controller.performRitual('sky_oath'), isFalse);
  });

  test('faith values stay clamped between zero and one hundred', () {
    final state = StarterGameData.create().copyWith(
      faithState: const FaithState().apply({
        'faith': 1000,
        'kut': -1000,
        'tore': 1000,
        'ancestorHonor': -1000,
      }),
    );
    expect(state.faithState.faith, 100);
    expect(state.faithState.kut, 0);
    expect(state.faithState.tore, 100);
    expect(state.faithState.ancestorHonor, 0);
  });

  test('end day can create an omen and kam consultation softens a bad omen',
      () {
    final controller =
        GameController(StarterGameData.create(), random: _FixedRandom(20));
    controller.endDay();
    expect(controller.state.faithState.hasOmen, isTrue);
    expect(controller.state.faithState.omenSeverity, OmenSeverity.bad);
    expect(controller.consultAdvisor('interpret_omen'), isTrue);
    expect(controller.state.faithState.omenSeverity, OmenSeverity.neutral);
    expect(controller.state.faithState.activeWarnings, isEmpty);
  });

  test('sacred place visit costs AP and energy while increasing faith state',
      () {
    final controller = GameController.starter();
    final beforeEnergy = controller.state.profile.energy;
    final beforeKut = controller.state.faithState.kut;
    expect(controller.visitSacredPlace('old_inscription'), isTrue);
    expect(controller.state.dailyActionPoints, 3);
    expect(controller.state.profile.energy, lessThan(beforeEnergy));
    expect(controller.state.faithState.kut, beforeKut + 2);
    expect(controller.visitSacredPlace('old_inscription'), isFalse);
  });

  test('tore event applies faith effects and tracks tore quest action', () {
    final controller = GameController.starter();
    final event = StarterGameData.events
        .firstWhere((item) => item.id == 'tore_herd_dispute');
    final choice = event.choices.first;
    final beforeTore = controller.state.faithState.tore;
    expect(controller.chooseEvent(choice), isTrue);
    expect(controller.state.faithState.tore, beforeTore + 4);
    final quest =
        controller.state.quests.firstWhere((item) => item.id == 's_tore_case');
    expect(quest.progress, 1);
  });

  test('recruitment adds people, scaled by reputation, for a cost', () {
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(
        resources: {...base.resources, ResourceType.gold: 500},
        profile: base.profile.copyWith(reputation: 40), // +2 bonus people
      ),
    );
    final pop = controller.state.resource(ResourceType.population);
    expect(controller.recruit('nomads'), isTrue); // base 5 + 2
    expect(controller.state.resource(ResourceType.population), pop + 7);
    expect(controller.state.resource(ResourceType.gold), 500 - 100);

    // No action points left -> recruiting fails.
    final drained = GameController(base.copyWith(dailyActionPoints: 0));
    expect(drained.recruit('refugees'), isFalse);
  });

  test('a married household grows the line over time', () {
    final base = StarterGameData.create();
    final married = base.copyWith(
      day: const GameDay(day: 19, season: Season.spring),
      household: const Household(spouseName: 'Aybüke'),
      resources: {...base.resources, ResourceType.food: 400},
    );
    final controller = GameController(married);
    final children = controller.state.household.childrenCount;
    final pop = controller.state.resource(ResourceType.population);

    controller.endDay(); // day 20 -> a child is born

    expect(controller.state.household.childrenCount, children + 1);
    expect(controller.state.resource(ResourceType.population), pop + 1);
  });

  test('conquest: diplomacy then peaceful annexation', () {
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(
        regionRelations: const {'otuken': 75},
        resources: {...base.resources, ResourceType.gold: 500},
      ),
    );
    expect(controller.annexRegion('otuken'), isFalse); // 75 < 80

    expect(controller.improveRegionRelation('otuken'), isTrue); // -> 87
    expect(controller.annexRegion('otuken'), isTrue);
    expect(controller.state.regionConquered('otuken'), isTrue);
    expect(controller.annexRegion('otuken'), isFalse); // already ours
  });

  test('conquest: war seizes a region on a winning roll', () {
    final base = StarterGameData.create();
    final winner = GameController(
      base.copyWith(
        resources: {...base.resources, ResourceType.population: 200},
        profile: base.profile.copyWith(warfare: 12),
      ),
      random: _FixedRandom(0),
    );
    expect(winner.attackRegion('otuken'), isTrue);
    expect(winner.state.regionConquered('otuken'), isTrue);

    final loser = GameController(base, random: _FixedRandom(99));
    final moraleBefore = loser.state.resource(ResourceType.morale);
    expect(loser.attackRegion('kasgar'), isFalse);
    expect(loser.state.regionConquered('kasgar'), isFalse);
    expect(
      loser.state.resource(ResourceType.morale),
      lessThan(moraleBefore),
    );
  });

  test('equipping crafted gear drives the expedition bonus', () {
    final controller = GameController.starter();
    expect(controller.equipmentBonus, 0);

    // Cannot equip what has not been crafted.
    expect(controller.equipItem('iron_sword'), isFalse);

    controller.startCraft('wood_shield');
    controller.endDay();
    expect(controller.state.craftedCount('wood_shield'), 1);

    expect(controller.equipItem('wood_shield'), isTrue);
    expect(controller.state.equippedIn('shield'), 'wood_shield');
    expect(controller.equipmentBonus, greaterThan(0));

    controller.unequip('shield');
    expect(controller.state.equippedIn('shield'), isNull);
    expect(controller.equipmentBonus, 0);
  });

  test('founding a new oba is gated behind tent level and reputation', () {
    final base = StarterGameData.create();
    final weak = GameController(base);
    expect(weak.canFoundNewOba, isFalse);

    final ready = GameController(
      base.copyWith(
        buildings: [
          for (final b in base.buildings)
            if (b.id == 'main_tent') b.copyWith(level: 2) else b,
        ],
        profile: base.profile.copyWith(reputation: 40),
      ),
    );
    expect(ready.canFoundNewOba, isTrue);
  });

  test('rename updates oba and leader, ignoring blanks', () {
    final controller = GameController.starter();
    controller.rename(obaName: 'Gökböri Obası', leaderName: '  ');
    expect(controller.state.clan.name, 'Gökböri Obası');
    expect(controller.state.profile.name, 'Bumin');

    controller.rename(leaderName: 'Tarkan');
    expect(controller.state.profile.name, 'Tarkan');
  });

  test('khanate duties shift standing and resources', () {
    final controller = GameController.starter();
    final standing = controller.state.khanateStanding;

    expect(controller.payTribute(), isTrue);
    expect(controller.state.khanateStanding, standing + 10);
    expect(controller.state.resource(ResourceType.gold), 250 - 120);

    expect(controller.attendDivan(), isTrue);
    expect(controller.state.dailyActionPoints, 3);
  });

  test('rebellion needs power and standing, and the throne is winnable', () {
    final base = StarterGameData.create();
    // Weak oba cannot rebel.
    final weak = GameController(base);
    expect(weak.canRebel, isFalse);
    expect(weak.attemptRebellion(), isFalse);

    // A strong, well-standing oba can, and with a lucky roll takes the throne.
    final strong = GameController(
      base.copyWith(
        khanateStanding: 80,
        vassalObas: 6,
        resources: {...base.resources, ResourceType.population: 120},
        profile: base.profile.copyWith(reputation: 60),
      ),
      random: _FixedRandom(0),
    );
    expect(strong.canRebel, isTrue);
    expect(strong.attemptRebellion(), isTrue);
    expect(strong.state.isKhan, isTrue);
    expect(strong.state.profile.title, 'Kağan');
  });

  test('founding a new oba resets the run with chosen name and tamga', () {
    final controller = GameController.starter();
    controller.endDay();
    controller.endDay();

    controller.foundNewOba('Gökböri Obası', 'war');

    expect(controller.state.clan.name, 'Gökböri Obası');
    expect(controller.state.tamga, 'war');
    expect(controller.state.generation, 1);
    expect(controller.state.day.day, 1);
    expect(controller.state.profile.age, 14);
    // Falls back to the default name when given blank input.
    controller.foundNewOba('   ', 'wolf');
    expect(controller.state.clan.name, isNotEmpty);
    expect(controller.state.tamga, 'wolf');
  });

  test('new meta fields survive a serializer round-trip', () {
    final controller = GameController.starter();
    controller.foundNewOba('Test Obası', 'yurt');
    controller.chooseFaithPath('atalar_kultu');

    final decoded =
        GameSerializer.decode(GameSerializer.encode(controller.state));
    expect(decoded, isNotNull);
    expect(decoded!.tamga, 'yurt');
    expect(decoded.faithPath, 'atalar_kultu');
    expect(decoded.khanateStanding, controller.state.khanateStanding);
  });

  test('choosing a faith path applies its lean once', () {
    final controller = GameController.starter();
    expect(controller.state.faithPath, '');
    final beforeKut = controller.state.faithState.kut;

    expect(controller.chooseFaithPath('gok_tengri'), isTrue);
    expect(controller.state.faithPath, 'gok_tengri');
    expect(controller.state.faithState.kut, beforeKut + 10);

    // Re-choosing the same path is a no-op.
    expect(controller.chooseFaithPath('gok_tengri'), isFalse);
  });

  test('achievements pay out once when their goal is met', () {
    final base = StarterGameData.create();
    final controller = GameController(base.copyWith(generation: 2));
    final dynasty = Achievements.all.firstWhere((a) => a.id == 'dynasty');

    expect(controller.state.achievementReady(dynasty), isTrue);
    final goldBefore = controller.state.resource(ResourceType.gold);
    expect(controller.claimAchievement('dynasty'), isTrue);
    expect(controller.state.resource(ResourceType.gold), goldBefore + 300);
    expect(controller.state.achievementClaimed('dynasty'), isTrue);

    expect(controller.claimAchievement('dynasty'), isFalse);
    expect(controller.claimAchievement('steppe_lord'), isFalse);
  });

  test('the leader ages and is retitled each year', () {
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(
        day: const GameDay(day: 40, season: Season.winter),
        profile: base.profile.copyWith(age: 24),
        resources: {...base.resources, ResourceType.food: 400},
      ),
    );

    controller.endDay();

    expect(controller.state.day.day, 41);
    expect(controller.state.profile.age, 25);
    expect(controller.state.profile.title, 'Genç Bey');
  });

  test('old age hands the realm to an heir instead of ending it', () {
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(
        day: const GameDay(day: 40, season: Season.winter),
        profile: base.profile.copyWith(age: 63),
        leaderLifespan: 64,
        resources: {...base.resources, ResourceType.food: 400},
      ),
    );

    controller.endDay();
    expect(controller.state.profile.age, 64);
    expect(controller.state.pendingSuccession, isTrue);
    expect(controller.state.gameOver, isFalse);

    controller.endDay();
    expect(controller.state.day.day, 41);

    final goldBefore = controller.state.resource(ResourceType.gold);
    controller.succeedWithHeir();
    expect(controller.state.pendingSuccession, isFalse);
    expect(controller.state.generation, 2);
    expect(controller.state.profile.age, lessThan(30));
    expect(
      controller.state.resource(ResourceType.gold),
      goldBefore - goldBefore ~/ 5,
    );
  });

  test('new state fields survive a serializer round-trip', () {
    final controller = GameController(
      StarterGameData.create().copyWith(generation: 3, leaderLifespan: 70),
    );
    controller.claimAchievement('dynasty');

    final decoded =
        GameSerializer.decode(GameSerializer.encode(controller.state));
    expect(decoded, isNotNull);
    expect(decoded!.generation, 3);
    expect(decoded.leaderLifespan, 70);
    expect(decoded.claimedAchievements, controller.state.claimedAchievements);
  });
}

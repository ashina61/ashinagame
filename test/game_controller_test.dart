import 'dart:convert';
import 'dart:math';

import 'package:ashinagame/game/data/achievements.dart';
import 'package:ashinagame/game/data/market_goods.dart';
import 'package:ashinagame/game/data/starter_game_data.dart';
import 'package:ashinagame/game/logic/market_logic.dart';
import 'package:ashinagame/game/logic/unlock_logic.dart';
import 'package:ashinagame/game/models/faith.dart';
import 'package:ashinagame/game/models/game_day.dart';
import 'package:ashinagame/game/data/nations.dart';
import 'package:ashinagame/game/data/npc_dialogues.dart';
import 'package:ashinagame/game/data/rare_offers.dart';
import 'package:ashinagame/game/logic/phase_logic.dart';
import 'package:ashinagame/game/models/household.dart';
import 'package:ashinagame/game/models/nation.dart';
import 'package:ashinagame/game/models/npc.dart';
import 'package:ashinagame/game/models/resource.dart';
import 'package:ashinagame/game/models/season.dart';
import 'package:ashinagame/game/state/game_controller.dart';
import 'package:ashinagame/game/state/game_serializer.dart';
import 'package:ashinagame/game/state/game_state.dart';
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

/// A state that satisfies every milestone for founding an oba: a name worth
/// 55 reputation, three sworn followers, a raised tent, a marriage, and
/// scouted land.
GameState _foundableState() {
  final base = StarterGameData.create();
  return base.copyWith(
    landScouted: true,
    household: const Household(spouseName: 'Aybüke'),
    npcRelations: const {'kaya_atabek': 80, 'alis_hatun': 85, 'bori_bey': 90},
    profile: base.profile.copyWith(reputation: 55),
    buildings: [
      for (final b in base.buildings)
        if (b.id == 'main_tent') b.copyWith(level: 2) else b,
    ],
  );
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
    final base = StarterGameData.create();
    // Exactly enough for the storage upgrade (wood 35, stone 20), leaving the
    // watchtower (wood 45, stone 15) unaffordable afterwards.
    final controller = GameController(
      base.copyWith(resources: {
        ...base.resources,
        ResourceType.wood: 35,
        ResourceType.stone: 20,
      }),
    );
    expect(controller.upgradeBuilding('storage'), isTrue);
    expect(controller.state.building('storage')!.level, 2);
    expect(controller.state.resource(ResourceType.wood), 0);
    expect(controller.state.resource(ResourceType.stone), 0);
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
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(resources: {...base.resources, ResourceType.gold: 200}),
    );
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

  test('battle casualties favour tougher units and fill a report', () {
    final base = StarterGameData.create();
    // Equal numbers of frail scouts (def 2) and stout heavy cavalry (def 10).
    final controller = GameController(
      base.copyWith(
        army: const {'scout': 20, 'heavy_cav': 20},
        resources: {...base.resources, ResourceType.population: 50},
      ),
      random: _FixedRandom(99), // force a loss: heavier casualties
    );

    expect(controller.attackRegion('otuken'), isFalse);
    final report = controller.lastBattle!;
    expect(report.won, isFalse);
    expect(report.castleName, 'Ötüken Yaylağı');

    // Frail scouts should bleed more than the armoured heavy cavalry.
    final scoutCasualties =
        (report.lost['scout'] ?? 0) + (report.wounded['scout'] ?? 0);
    final cavCasualties =
        (report.lost['heavy_cav'] ?? 0) + (report.wounded['heavy_cav'] ?? 0);
    expect(scoutCasualties, greaterThan(cavCasualties));
  });

  test('army defence lifts war strength', () {
    final base = StarterGameData.create();
    final plain = GameController(base.copyWith(army: const {}));
    final defended =
        GameController(base.copyWith(army: const {'spear': 10})); // def 8
    expect(defended.warStrength, greaterThan(plain.warStrength));
    expect(defended.armyDefense, 80);
  });

  test('a capital is sealed until its outer castles fall', () {
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(
        resources: {...base.resources, ResourceType.population: 400},
        profile: base.profile.copyWith(warfare: 20),
      ),
      random: _FixedRandom(0),
    );

    // The Oğuz capital cannot be touched while outer castles stand.
    final capital = Nations.byId('oguz')!.center;
    expect(controller.centerLocked(capital), isTrue);
    expect(controller.attackRegion(capital.id), isFalse);

    // Take all four outer castles; the capital then opens.
    for (final castle in Nations.byId('oguz')!.outerCastles) {
      expect(controller.attackRegion(castle.id), isTrue);
    }
    expect(controller.centerLocked(capital), isFalse);
  });

  test('taking a capital forces a governance verdict with lasting income', () {
    final base = StarterGameData.create();
    final oguz = Nations.byId('oguz')!;
    // Pre-seize the four outer castles so only the capital remains.
    final controller = GameController(
      base.copyWith(
        conqueredRegions: [for (final c in oguz.outerCastles) c.id],
        resources: {...base.resources, ResourceType.population: 600},
        profile: base.profile.copyWith(warfare: 30),
      ),
      random: _FixedRandom(0),
    );

    expect(controller.attackRegion(oguz.center.id), isTrue);
    expect(controller.pendingNation?.id, 'oguz');

    final goldBefore = controller.state.resource(ResourceType.gold);
    expect(controller.decideNationPolicy('oguz', NationPolicy.vali), isTrue);
    expect(controller.pendingNation, isNull);
    expect(controller.state.nationConquered('oguz'), isTrue);
    expect(controller.conqueredNations, 1);
    expect(
        controller.state.resource(ResourceType.gold), greaterThan(goldBefore));

    // A governed province pays tribute each day.
    final beforeDay = GameController(
      controller.state.copyWith(
        resources: {...controller.state.resources, ResourceType.food: 400},
      ),
    );
    final goldDayStart = beforeDay.state.resource(ResourceType.gold);
    beforeDay.endDay();
    expect(
        beforeDay.state.resource(ResourceType.gold), greaterThan(goldDayStart));
  });

  test('a neglected province loses loyalty and finally revolts', () {
    final base = StarterGameData.create();
    final oguz = Nations.byId('oguz')!;
    // A held province on the brink, run by a weak realm so loyalty only falls.
    final controller = GameController(
      base.copyWith(
        nationPolicies: const {'oguz': 'vassal'},
        nationLoyalty: const {'oguz': 1},
        conqueredRegions: [for (final c in oguz.castles) c.id],
        peopleApproval: 20,
        profile: base.profile.copyWith(reputation: 10),
        resources: {...base.resources, ResourceType.food: 400},
      ),
    );

    controller.endDay(); // loyalty 1 -2 = -1 -> revolt
    expect(controller.state.nationConquered('oguz'), isFalse);
    expect(controller.state.loyaltyOf('oguz'), 0);
    // The capital is freed, so it must be reconquered.
    expect(controller.state.regionConquered(oguz.center.id), isFalse);
  });

  test('reinforcing a province buys back loyalty', () {
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(
        nationPolicies: const {'oguz': 'vali'},
        nationLoyalty: const {'oguz': 30},
        resources: {...base.resources, ResourceType.gold: 300},
      ),
    );
    final gold = controller.state.resource(ResourceType.gold);
    expect(controller.reinforceProvince('oguz'), isTrue);
    expect(controller.state.loyaltyOf('oguz'), 55);
    expect(controller.state.resource(ResourceType.gold), gold - 60);
    expect(controller.state.dailyActionPoints, 3);
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

  test('founding an oba is gated behind the full early-game milestone set', () {
    final base = StarterGameData.create();
    final weak = GameController(base);
    expect(weak.canFoundNewOba, isFalse);

    // Reputation and a raised tent alone are not enough any more.
    final halfway = GameController(
      base.copyWith(
        buildings: [
          for (final b in base.buildings)
            if (b.id == 'main_tent') b.copyWith(level: 2) else b,
        ],
        profile: base.profile.copyWith(reputation: 55),
      ),
    );
    expect(halfway.canFoundNewOba, isFalse);

    final ready = GameController(_foundableState());
    expect(ready.canFoundNewOba, isTrue);
  });

  test('recruiting units builds army strength and costs resources', () {
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(
        resources: {
          ...base.resources,
          ResourceType.gold: 1000,
          ResourceType.horse: 20,
        },
      ),
    );
    expect(controller.armyStrength, 0);
    expect(controller.recruitUnit('foot_sword', 3), isTrue);
    expect(controller.state.unitCount('foot_sword'), 3);
    expect(controller.armyStrength, 18); // 3 x attack 6
    expect(controller.recruitUnit('horse_archer', 2), isTrue);
    expect(controller.armyStrength, 18 + 16); // +2 x attack 8
    expect(controller.state.resource(ResourceType.horse), 18); // 2 spent
  });

  test('war wounds soldiers and the healer mends them over time', () {
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(
        army: const {'foot_sword': 10},
        resources: {
          ...base.resources,
          ResourceType.food: 400,
          ResourceType.population: 300,
        },
      ),
      random: _FixedRandom(0),
    );

    expect(controller.attackRegion('otuken'), isTrue);
    // A win wounds about a tenth of the force.
    expect(controller.state.totalWounded, 1);
    expect(controller.state.unitCount('foot_sword'), 9);

    controller.endDay(); // healer mends the wounded back in
    expect(controller.state.totalWounded, 0);
    expect(controller.state.unitCount('foot_sword'), 10);
  });

  test('the market sells finished gear into the inventory', () {
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(resources: {...base.resources, ResourceType.gold: 600}),
    );
    expect(controller.state.craftedCount('iron_sword'), 0);
    expect(controller.buyGood('m_sword'), isTrue);
    expect(controller.state.craftedCount('iron_sword'), 1);
    expect(controller.buyGood('m_shield'), isTrue);
    expect(controller.state.craftedCount('wood_shield'), 1);
  });

  test('a thriving oba gains people on the growth cadence', () {
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(
        obaFounded: true, // a lone tent draws no one; an oba does
        day: const GameDay(day: 7, season: Season.spring),
        resources: {
          ...base.resources,
          ResourceType.morale: 80,
          ResourceType.food: 400,
          ResourceType.population: 40,
        },
      ),
    );
    controller.endDay(); // day 8 -> +2 population
    expect(controller.state.resource(ResourceType.population), 42);
  });

  test('a lone traveller draws no new people before founding an oba', () {
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(
        day: const GameDay(day: 7, season: Season.spring),
        resources: {
          ...base.resources,
          ResourceType.morale: 80,
          ResourceType.food: 400,
          ResourceType.population: 40,
        },
      ),
    );
    controller.endDay(); // no oba yet -> population holds
    expect(controller.state.resource(ResourceType.population), 40);
  });

  test('the council convenes on schedule and decisions shift approval', () {
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(
        obaFounded: true, // the council only convenes once there is an oba
        day: const GameDay(day: 9, season: Season.spring),
        resources: {...base.resources, ResourceType.food: 400},
      ),
      random: _FixedRandom(0),
    );

    controller.endDay(); // day 10 -> a kurultay convenes
    expect(controller.state.currentKurultay, isNotNull);

    // _FixedRandom(0) picks the first decision ('tax'); choice 0 raises the
    // council and lowers the people.
    controller.resolveKurultay(0);
    expect(controller.state.currentKurultay, isNull);
    expect(controller.state.peopleApproval, 60 - 12);
    expect(controller.state.councilApproval, 60 + 10);
  });

  test('kurultay verdicts shift bey bonds and trigger extreme consequences',
      () {
    final base = StarterGameData.create();
    // A council on the brink: a hostile verdict tips both estates over.
    final controller = GameController(
      base.copyWith(
        currentKurultay: 'justice',
        peopleApproval: 28,
        councilApproval: 26,
        vassalObas: 2,
        npcRelations: const {'bori_bey': 50, 'alis_hatun': 50},
        resources: {...base.resources, ResourceType.population: 60},
      ),
    );

    // 'justice' choice 1 (beyi kolla): people -12 -> 16 (<=20 triggers exodus),
    // council +12 -> 38; bonds shift toward Böri, away from Alış.
    final popBefore = controller.state.resource(ResourceType.population);
    controller.resolveKurultay(1);
    expect(controller.state.councilApproval, 38);
    expect(controller.state.peopleApproval, 16);
    expect(controller.state.relationWith('bori_bey'), 58);
    expect(controller.state.relationWith('alis_hatun'), 42);
    // The exodus from a furious populace bleeds population.
    expect(controller.state.resource(ResourceType.population),
        lessThan(popBefore));
  });

  test('a furious council costs a bound oba at the next verdict', () {
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(
        currentKurultay: 'justice',
        councilApproval: 26,
        vassalObas: 3,
        resources: {...base.resources, ResourceType.population: 80},
      ),
    );
    // 'justice' choice 0 (çobanı kolla): council -8 -> 18 (<=20), a bey leaves.
    controller.resolveKurultay(0);
    expect(controller.state.councilApproval, 18);
    expect(controller.state.vassalObas, 2);
  });

  test('onboarding names the oba and opens play', () {
    final controller = GameController(StarterGameData.create());
    expect(controller.state.onboarded, isFalse);

    controller.completeOnboarding(obaName: 'Gökböri', leaderName: 'Alp');
    expect(controller.state.onboarded, isTrue);
    expect(controller.state.clan.name, 'Gökböri');
    expect(controller.state.profile.name, 'Alp');
  });

  test('feature unlocks follow the intended progression', () {
    final base = StarterGameData.create();
    // Fresh leader: nothing past camp work is open yet.
    expect(UnlockLogic.tentUpgrade(base), isFalse);
    expect(UnlockLogic.expeditions(base), isFalse);
    expect(UnlockLogic.recruitment(base), isFalse);

    // Equipping a weapon and shield opens expeditions.
    final armed = base.copyWith(
      equipped: const {'weapon': 'iron_sword', 'shield': 'wood_shield'},
    );
    expect(UnlockLogic.expeditions(armed), isTrue);

    // A first campaign opens recruitment.
    final veteran =
        armed.copyWith(completedExpeditions: const ['border_outpost']);
    expect(UnlockLogic.recruitment(veteran), isTrue);
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
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(resources: {...base.resources, ResourceType.gold: 250}),
    );
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

  test('founding an oba keeps the founder and flips into the oba phase', () {
    final controller = GameController(_foundableState());
    expect(controller.state.obaFounded, isFalse);
    final ageBefore = controller.state.profile.age;
    final popBefore = controller.state.resource(ResourceType.population);

    controller.foundNewOba('Gökböri Obası', 'war');

    expect(controller.state.obaFounded, isTrue);
    expect(controller.state.clan.name, 'Gökböri Obası');
    expect(controller.state.tamga, 'war');
    // The same young founder carries on — no generational reset.
    expect(controller.state.profile.age, ageBefore);
    expect(controller.state.generation, 1);
    // Followers form the first households, so the camp gains people.
    expect(controller.state.resource(ResourceType.population),
        greaterThan(popBefore));
  });

  test('founding an oba does nothing while the milestones are unmet', () {
    final controller = GameController.starter();
    controller.foundNewOba('Erken Oba', 'war');
    expect(controller.state.obaFounded, isFalse);
    expect(controller.state.clan.name, isNot('Erken Oba'));
  });

  test('new meta fields survive a serializer round-trip', () {
    final controller = GameController(_foundableState());
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

  test('talking to an NPC spends an action and shifts the bond and approvals',
      () {
    final controller = GameController.starter();
    final dialogue = controller.dialogueFor('bori_bey');
    expect(dialogue, isNotNull);
    expect(controller.state.relationWith('bori_bey'), 50);

    final ap = controller.state.dailyActionPoints;
    final people = controller.state.peopleApproval;
    final council = controller.state.councilApproval;
    final choice = dialogue!.choices.first;

    expect(controller.talkTo('bori_bey', choice), isTrue);
    expect(controller.state.dailyActionPoints, ap - 1);
    expect(controller.state.relationWith('bori_bey'),
        (50 + choice.relationEffect).clamp(0, 100));
    expect(controller.state.peopleApproval, people + choice.peopleEffect);
    expect(controller.state.councilApproval, council + choice.councilEffect);
  });

  test('a dialogue can summon the council', () {
    final controller = GameController.starter();
    expect(controller.state.currentKurultay, isNull);
    const summon = DialogueChoice(
      label: 'Meclisi topla.',
      reply: '',
      triggersKurultay: 'war_council',
    );
    expect(controller.talkTo('kaya_atabek', summon), isTrue);
    expect(controller.state.currentKurultay, 'war_council');
  });

  test('a defiant dialogue launches a raid with a battle report', () {
    final base = StarterGameData.create();
    final controller = GameController(
      base.copyWith(
        army: const {'heavy_cav': 40},
        resources: {...base.resources, ResourceType.population: 300},
      ),
      random: _FixedRandom(0), // wins the raid
    );
    const raid = DialogueChoice(
      label: 'Bir karış bile vermem.',
      reply: '',
      raidPower: 120,
    );
    final goldBefore = controller.state.resource(ResourceType.gold);
    expect(controller.talkTo('tugan_bey', raid), isTrue);
    expect(controller.lastBattle, isNotNull);
    expect(controller.lastBattle!.won, isTrue);
    expect(
        controller.state.resource(ResourceType.gold), greaterThan(goldBefore));
  });

  test('npc relations survive a serializer round-trip', () {
    final controller = GameController.starter();
    final choice = NpcDialogues.forNpc('kaya_atabek').first.choices.first;
    controller.talkTo('kaya_atabek', choice);

    final decoded =
        GameSerializer.decode(GameSerializer.encode(controller.state));
    expect(decoded, isNotNull);
    expect(decoded!.relationWith('kaya_atabek'),
        controller.state.relationWith('kaya_atabek'));
  });

  test('talking with no action points left fails', () {
    final controller = GameController(
      StarterGameData.create().copyWith(dailyActionPoints: 0),
    );
    final choice = NpcDialogues.forNpc('alis_hatun').first.choices.first;
    expect(controller.talkTo('alis_hatun', choice), isFalse);
    expect(controller.state.relationWith('alis_hatun'), 50);
  });

  test('companion roles grant standing bonuses and survive a save', () {
    final controller = GameController(_foundableState());
    controller.foundNewOba(
      'Test Obası',
      'wolf',
      roles: const {'kaya_atabek': 'merchant', 'alis_hatun': 'hunter'},
    );
    expect(controller.state.companionRoles['kaya_atabek'], 'merchant');
    expect(controller.companionMarketDiscount, 15);
    final bonus = controller.companionDailyBonus;
    expect(bonus[ResourceType.gold], 6); // merchant
    expect(bonus[ResourceType.food], 5); // hunter

    final decoded =
        GameSerializer.decode(GameSerializer.encode(controller.state));
    expect(decoded, isNotNull);
    expect(decoded!.companionRoles['alis_hatun'], 'hunter');
  });

  test('a warleader companion lifts war strength', () {
    final base = _foundableState().copyWith(army: const {'foot_sword': 10});
    final plain = GameController(base.copyWith(obaFounded: true));
    final led = GameController(
      base.copyWith(obaFounded: true, companionRoles: const {'a': 'warleader'}),
    );
    expect(led.warStrength, greaterThan(plain.warStrength));
  });

  test('an enemy raid musters, counts down, and a strong host repels it', () {
    final base = _foundableState().copyWith(
      obaFounded: true,
      day: const GameDay(day: 11, season: Season.spring),
      army: const {'heavy_cav': 40},
      resources: {
        ...StarterGameData.create().resources,
        ResourceType.food: 800,
        ResourceType.population: 200,
      },
    );
    final c = GameController(base, random: _FixedRandom(0));
    c.endDay(); // day 12 -> a raid is mustered
    expect(c.state.raidLooming, isTrue);
    expect(c.state.raidCountdown, 3);
    expect(c.state.raidFrom, isNotEmpty);

    c.endDay(); // 2 days out
    c.endDay(); // 1 day out
    c.endDay(); // strikes -> repelled by the strong host
    expect(c.state.raidLooming, isFalse);
    expect(c.state.raidFrom, '');
  });

  test('a lone traveller faces no raids before founding an oba', () {
    final base = StarterGameData.create().copyWith(
      day: const GameDay(day: 11, season: Season.spring),
      resources: {
        ...StarterGameData.create().resources,
        ResourceType.food: 400,
      },
    );
    final c = GameController(base);
    c.endDay(); // day 12, but no oba -> no raid
    expect(c.state.raidLooming, isFalse);
  });

  test('a campaign marches over days and storms the castle on arrival', () {
    final fresh = StarterGameData.create();
    final base = fresh.copyWith(
      obaFounded: true,
      army: const {'heavy_cav': 60},
      profile: fresh.profile.copyWith(warfare: 20),
      resources: {
        ...fresh.resources,
        ResourceType.food: 800,
        ResourceType.population: 400,
      },
    );
    final c = GameController(base, random: _FixedRandom(0));
    expect(c.startMarch('otuken'), isTrue);
    expect(c.marchStatus, 'Yolda');
    expect(c.state.marchDaysLeft, 2);
    // Only one campaign at a time.
    expect(c.startMarch('orhun'), isFalse);

    c.endDay(); // one day closer
    expect(c.state.marchDaysLeft, 1);
    expect(c.state.marching, isTrue);

    c.endDay(); // arrives and storms the walls
    expect(c.state.marching, isFalse);
    expect(c.state.regionConquered('otuken'), isTrue);
  });

  test('province decisions raise loyalty; suppression scares the people', () {
    final base = StarterGameData.create().copyWith(
      obaFounded: true,
      nationPolicies: const {'oguz': 'vali'},
      nationLoyalty: const {'oguz': 20},
      peopleApproval: 60,
    );
    final c = GameController(base);
    expect(c.manageProvince('oguz', 'suppress'), isTrue);
    expect(c.state.loyaltyOf('oguz'), 40);
    expect(c.state.peopleApproval, 50);
  });

  test('an envoy can appease a looming raid', () {
    final fresh = StarterGameData.create();
    final base = fresh.copyWith(
      obaFounded: true,
      raidCountdown: 3,
      raidFrom: 'oguz',
      resources: {...fresh.resources, ResourceType.gold: 200},
    );
    final c =
        GameController(base, random: _FixedRandom(0)); // 0 < 55 -> appeased
    expect(c.state.raidLooming, isTrue);
    expect(c.respondToRaid('envoy'), isTrue);
    expect(c.state.raidLooming, isFalse);
  });

  test('rare market offers surface every few days', () {
    expect(RareOffers.forDay(3), isNull);
    expect(RareOffers.forDay(4), isNotNull);
    expect(RareOffers.forDay(8), isNotNull);
    expect(RareOffers.forDay(4)!.id, isNot(RareOffers.forDay(8)!.id));
  });

  test('the opening-month guide spans day 1 to 30 then stops', () {
    GameState onDay(int d) => StarterGameData.create()
        .copyWith(day: GameDay(day: d, season: Season.spring));
    expect(PhaseLogic.dailyTutorial(onDay(1)), isNotNull);
    expect(PhaseLogic.dailyTutorial(onDay(26)), isNotNull);
    expect(PhaseLogic.dailyTutorial(onDay(31)), isNull);
    expect(
      PhaseLogic.dailyTutorial(onDay(5).copyWith(obaFounded: true)),
      isNull,
    );
  });

  test('a han companion joins as a sworn follower in a role', () {
    final fresh = StarterGameData.create();
    final c = GameController(
      fresh.copyWith(resources: {...fresh.resources, ResourceType.gold: 400}),
    );
    final before = c.state.swornFollowers;
    expect(
      c.recruitCompanion('kaya_atabek', roleId: 'warleader', goldCost: 120),
      isTrue,
    );
    expect(c.state.swornFollowers, before + 1);
    expect(c.state.companionRoles['kaya_atabek'], 'warleader');
    expect(c.state.resource(ResourceType.gold), 280);
  });

  test('recruiting a han companion is denied without the gold', () {
    final fresh = StarterGameData.create();
    final c = GameController(
      fresh.copyWith(resources: {...fresh.resources, ResourceType.gold: 10}),
    );
    expect(
      c.recruitCompanion('kaya_atabek', roleId: 'warleader', goldCost: 120),
      isFalse,
    );
  });

  test('three han companions satisfy the follower founding milestone', () {
    final fresh = StarterGameData.create();
    final c = GameController(
      fresh.copyWith(resources: {...fresh.resources, ResourceType.gold: 600}),
    );
    c.recruitCompanion('kaya_atabek', roleId: 'warleader', goldCost: 120);
    c.recruitCompanion('bori_bey', roleId: 'kam', goldCost: 100);
    c.recruitCompanion('bezirgan', roleId: 'merchant', goldCost: 110);
    expect(c.state.swornFollowers, greaterThanOrEqualTo(3));
  });

  test('a campaign reports progress as the army nears the walls', () {
    final fresh = StarterGameData.create();
    final base = fresh.copyWith(
      obaFounded: true,
      army: const {'heavy_cav': 40},
      profile: fresh.profile.copyWith(warfare: 20),
      resources: {
        ...fresh.resources,
        ResourceType.food: 800,
        ResourceType.population: 300,
      },
    );
    final c = GameController(base, random: _FixedRandom(0));
    expect(c.startMarch('otuken'), isTrue);
    expect(c.marchProgress, 0.0);
    c.endDay();
    expect(c.marchProgress, greaterThan(0.0));
  });

  test('completing a craft reports it landed in the inventory', () {
    final c = GameController(StarterGameData.create(), random: _FixedRandom(0));
    expect(c.startCraft('wood_shield'), CraftStart.started);
    c.endDay();
    expect(c.state.craftedCount('wood_shield'), 1);
    expect(
      c.state.log.any((l) => l.contains('envantere eklendi')),
      isTrue,
    );
  });

  test('the merchant role discounts the market', () {
    final base = _foundableState().copyWith(
      obaFounded: true,
      resources: {
        ...StarterGameData.create().resources,
        ResourceType.gold: 600,
      },
    );
    final plain = GameController(base);
    final withMerchant =
        GameController(base.copyWith(companionRoles: const {'a': 'merchant'}));
    final goldA = plain.state.resource(ResourceType.gold);
    final goldB = withMerchant.state.resource(ResourceType.gold);
    expect(plain.buyGood('salt'), isTrue);
    expect(withMerchant.buyGood('salt'), isTrue);
    final spentPlain = goldA - plain.state.resource(ResourceType.gold);
    final spentMerchant =
        goldB - withMerchant.state.resource(ResourceType.gold);
    expect(spentMerchant, lessThan(spentPlain));
  });
}

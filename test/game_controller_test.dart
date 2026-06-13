import 'dart:convert';
import 'dart:math';

import 'package:ashinagame/game/data/market_goods.dart';
import 'package:ashinagame/game/data/starter_game_data.dart';
import 'package:ashinagame/game/logic/market_logic.dart';
import 'package:ashinagame/game/models/faith.dart';
import 'package:ashinagame/game/models/resource.dart';
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

  test('end day can create an omen and kam consultation softens a bad omen', () {
    final controller = GameController(StarterGameData.create(), random: _FixedRandom(20));
    controller.endDay();
    expect(controller.state.faithState.hasOmen, isTrue);
    expect(controller.state.faithState.omenSeverity, OmenSeverity.bad);
    expect(controller.consultAdvisor('interpret_omen'), isTrue);
    expect(controller.state.faithState.omenSeverity, OmenSeverity.neutral);
    expect(controller.state.faithState.activeWarnings, isEmpty);
  });

  test('sacred place visit costs AP and energy while increasing faith state', () {
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
    final event = StarterGameData.events.firstWhere((item) => item.id == 'tore_herd_dispute');
    final choice = event.choices.first;
    final beforeTore = controller.state.faithState.tore;
    expect(controller.chooseEvent(choice), isTrue);
    expect(controller.state.faithState.tore, beforeTore + 4);
    final quest = controller.state.quests.firstWhere((item) => item.id == 's_tore_case');
    expect(quest.progress, 1);
  });

}

void main() {
  const huntEffects = {ResourceType.food: 20, ResourceType.leather: 2};

  test('quest completion grants XP and can level up', () {
    final controller = GameController.starter();
    controller.performCampAction(GameActions.hunt, 'Avlan', huntEffects, xp: 90);
    final beforeClaimXp = controller.state.profile.xp;
    controller.claimQuest('d_hunt');
    expect(controller.state.profile.xp, greaterThan(beforeClaimXp));

    for (var i = 0; i < 4; i++) {
      controller.endDay();
      controller.performCampAction(GameActions.hunt, 'Avlan', huntEffects, xp: 80);
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
    expect(controller.performCampAction(GameActions.farm, 'Tarla', const {ResourceType.food: 12}), isTrue);
    expect(controller.state.dailyActionPoints, 3);
    for (var i = 0; i < 3; i++) {
      expect(controller.rest(), isTrue);
    }
    expect(controller.performCampAction(GameActions.farm, 'Tarla', const {ResourceType.food: 12}), isFalse);
    controller.endDay();
    expect(controller.state.dailyActionPoints, controller.state.maxDailyActionPoints);
  });

  test('energy fatigue and health are affected by action and day cycle', () {
    final controller = GameController.starter();
    controller.performCampAction(GameActions.wood, 'Odun Kes', const {ResourceType.wood: 15}, energyCost: 10, fatigueGain: 8);
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
    expect(controller.performDiplomacy(controller.state.tribes.first.id, 'envoy'), isTrue);
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
    final controller = GameController(StarterGameData.create(), random: _FixedRandom(0));
    expect(controller.startCraft('wood_shield'), CraftStart.started);
    controller.endDay();
    expect(controller.state.craftedCount('wood_shield'), 1);

    final outcome = controller.embarkExpedition('border_outpost');
    expect(outcome, isNotNull);
    expect(controller.state.expeditionDone('border_outpost'), isTrue);

    final salt = MarketGoods.byId('salt')!;
    final price = MarketLogic.priceFor(salt, controller.state.day.day);
    expect(controller.buyGood('salt'), isTrue);
    expect(controller.state.resource(ResourceType.gold), lessThan(250 - price + 100));

    final decoded = GameSerializer.decode(GameSerializer.encode(controller.state));
    expect(decoded, isNotNull);
    expect(decoded!.buildings.length, controller.state.buildings.length);
    expect(decoded.tribes.length, controller.state.tribes.length);
    expect(decoded.household.householdMorale, controller.state.household.householdMorale);

    final legacyMap = jsonDecode(GameSerializer.encode(controller.state)) as Map<String, dynamic>;
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

  test('end day can create an omen and kam consultation softens a bad omen', () {
    final controller = GameController(StarterGameData.create(), random: _FixedRandom(20));
    controller.endDay();
    expect(controller.state.faithState.hasOmen, isTrue);
    expect(controller.state.faithState.omenSeverity, OmenSeverity.bad);
    expect(controller.consultAdvisor('interpret_omen'), isTrue);
    expect(controller.state.faithState.omenSeverity, OmenSeverity.neutral);
    expect(controller.state.faithState.activeWarnings, isEmpty);
  });

  test('sacred place visit costs AP and energy while increasing faith state', () {
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
    final event = StarterGameData.events.firstWhere((item) => item.id == 'tore_herd_dispute');
    final choice = event.choices.first;
    final beforeTore = controller.state.faithState.tore;
    expect(controller.chooseEvent(choice), isTrue);
    expect(controller.state.faithState.tore, beforeTore + 4);
    final quest = controller.state.quests.firstWhere((item) => item.id == 's_tore_case');
    expect(quest.progress, 1);
  });

}

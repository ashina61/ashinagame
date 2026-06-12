import 'dart:convert';
import 'dart:math';

import 'package:ashinagame/game/data/market_goods.dart';
import 'package:ashinagame/game/data/starter_game_data.dart';
import 'package:ashinagame/game/logic/market_logic.dart';
import 'package:ashinagame/game/models/resource.dart';
import 'package:ashinagame/game/state/game_controller.dart';
import 'package:ashinagame/game/state/game_serializer.dart';
import 'package:ashinagame/game/state/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Forces deterministic expedition rolls.
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
  const huntEffects = {ResourceType.food: 12, ResourceType.leather: 2};

  test('camp actions consume energy and feed quest progress', () {
    final controller = GameController.starter();

    final done =
        controller.performCampAction(GameActions.hunt, 'Avlan', huntEffects);

    expect(done, isTrue);
    expect(
      controller.state.energy,
      GameState.maxEnergy - GameController.campActionCost,
    );
    expect(controller.state.resource(ResourceType.food), 112);

    final hunt =
        controller.state.quests.firstWhere((quest) => quest.id == 'd_hunt');
    expect(controller.state.questReady(hunt), isTrue);

    controller.claimQuest('d_hunt');
    expect(controller.state.resource(ResourceType.food), 112 + 14);
    expect(
      controller.state.quests
          .firstWhere((quest) => quest.id == 'd_hunt')
          .completed,
      isTrue,
    );
  });

  test('quest rewards cannot be claimed before the goal is met', () {
    final controller = GameController.starter();

    controller.claimQuest('d_hunt');

    expect(controller.state.resource(ResourceType.food), 100);
    expect(
      controller.state.quests
          .firstWhere((quest) => quest.id == 'd_hunt')
          .completed,
      isFalse,
    );
  });

  test('energy gates actions and a new day restores it', () {
    final controller = GameController.starter();

    const perDay = GameState.maxEnergy ~/ GameController.campActionCost;
    for (var i = 0; i < perDay; i++) {
      expect(
        controller.performCampAction(GameActions.farm, 'Tarla', const {
          ResourceType.food: 10,
        }),
        isTrue,
      );
    }
    expect(
      controller.performCampAction(GameActions.farm, 'Tarla', const {
        ResourceType.food: 10,
      }),
      isFalse,
    );

    controller.endDay();
    expect(controller.state.energy, GameState.maxEnergy);
  });

  test('daily quests rotate at the end of the day', () {
    final controller = GameController.starter();
    controller.performCampAction(GameActions.hunt, 'Avlan', huntEffects);

    controller.endDay();

    final dailies = controller.state.quests
        .where((quest) => quest.category == 'Günlük')
        .toList();
    expect(dailies.length, 3);
    expect(dailies.every((quest) => quest.progress == 0), isTrue);
    expect(
      controller.state.quests.any((quest) => quest.category == 'Hikâye'),
      isTrue,
    );
  });

  test('day and season progress every ten days', () {
    final controller = GameController.starter();
    for (var i = 0; i < 10; i++) {
      controller.endDay();
    }

    expect(controller.state.day.day, 11);
    expect(controller.state.day.season.label, 'Yaz');
  });

  test('starvation erodes the camp until the run collapses', () {
    final controller = GameController.starter();

    var days = 0;
    while (!controller.state.gameOver && days < 120) {
      controller.endDay();
      days++;
    }

    expect(controller.state.gameOver, isTrue);
    expect(controller.state.gameOverReason, isNotNull);
    expect(
      controller.state.resources.values.every((value) => value >= 0),
      isTrue,
    );
  });

  test('crafting pays costs up front and finishes after its days', () {
    final controller = GameController.starter();

    expect(controller.startCraft('wood_shield'), CraftStart.started);
    expect(controller.state.resource(ResourceType.wood), 60 - 12);
    expect(controller.state.craftQueue.length, 1);

    expect(controller.startCraft('leather_armor'), CraftStart.started);
    expect(controller.startCraft('fur_cloak'), CraftStart.queueFull);

    controller.endDay();
    expect(controller.state.craftedCount('wood_shield'), 1);
    expect(controller.state.craftQueue.length, 1);

    controller.endDay();
    expect(controller.state.craftedCount('leather_armor'), 1);
    expect(controller.state.craftQueue, isEmpty);
    expect(controller.equipmentBonus, 5 + 6);
  });

  test('crafting refuses to start without materials', () {
    final controller = GameController.starter();

    // Starter leather is 25; two armors fit, the third does not.
    expect(controller.startCraft('leather_armor'), CraftStart.started);
    expect(controller.startCraft('leather_armor'), CraftStart.started);
    controller.endDay();
    controller.endDay();
    expect(controller.startCraft('leather_armor'), CraftStart.noResources);
  });

  test('expeditions unlock in order and conquer on success', () {
    final controller = GameController(
      StarterGameData.create(),
      random: _FixedRandom(0),
    );

    expect(controller.embarkExpedition('yesit_fort'), isNull);

    final outcome = controller.embarkExpedition('border_outpost');
    expect(outcome, isNotNull);
    expect(outcome!.success, isTrue);
    expect(controller.state.expeditionDone('border_outpost'), isTrue);
    expect(controller.state.resource(ResourceType.gold), 250 + 30);
    expect(
      controller.state.energy,
      GameState.maxEnergy - GameController.expeditionCost,
    );

    // The next site in the chain is now open; a taken site is not.
    expect(controller.embarkExpedition('border_outpost'), isNull);
    expect(controller.embarkExpedition('steppe_pass'), isNotNull);
  });

  test('a failed expedition applies losses and keeps the site open', () {
    final controller = GameController(
      StarterGameData.create(),
      random: _FixedRandom(99),
    );

    final outcome = controller.embarkExpedition('border_outpost');
    expect(outcome, isNotNull);
    expect(outcome!.success, isFalse);
    expect(controller.state.expeditionDone('border_outpost'), isFalse);
    expect(controller.state.resource(ResourceType.morale), 70 - 3);
  });

  test('market purchases drain stock and gold until the day resets them', () {
    final controller = GameController.starter();
    final salt = MarketGoods.byId('salt')!;
    final price = MarketLogic.priceFor(salt, 1);

    for (var i = 0; i < salt.baseStock; i++) {
      expect(controller.buyGood('salt'), isTrue);
    }
    expect(controller.buyGood('salt'), isFalse);
    expect(controller.state.stockOf('salt'), 0);
    expect(
      controller.state.resource(ResourceType.gold),
      250 - price * salt.baseStock,
    );
    expect(
      controller.state.resource(ResourceType.food),
      100 + salt.amount * salt.baseStock,
    );

    controller.endDay();
    expect(controller.state.stockOf('salt'), salt.baseStock);
  });

  test('untradable goods are rejected', () {
    final controller = GameController.starter();
    expect(controller.buyGood('iron_ore'), isFalse);
  });

  test('serializer round-trips the run and rejects corrupt input', () {
    final controller = GameController.starter();
    controller.performCampAction(GameActions.hunt, 'Avlan', huntEffects);
    controller.endDay();

    final decoded = GameSerializer.decode(
      GameSerializer.encode(controller.state),
    );

    expect(decoded, isNotNull);
    expect(decoded!.day.day, controller.state.day.day);
    expect(decoded.energy, controller.state.energy);
    expect(decoded.resources, controller.state.resources);
    expect(decoded.eventIndex, controller.state.eventIndex);
    expect(decoded.quests.length, controller.state.quests.length);
    expect(decoded.currentEvent?.id, controller.state.currentEvent?.id);

    expect(GameSerializer.decode('not-json'), isNull);

    // A pre-P1 save without the newer keys still loads with defaults.
    final legacyMap = jsonDecode(GameSerializer.encode(controller.state))
        as Map<String, dynamic>;
    legacyMap
      ..remove('craftQueue')
      ..remove('craftedItems')
      ..remove('completedExpeditions')
      ..remove('marketStock');
    final legacy = GameSerializer.decode(jsonEncode(legacyMap));
    expect(legacy, isNotNull);
    expect(legacy!.craftQueue, isEmpty);
    expect(legacy.marketStock, MarketGoods.startingStock());
  });
}

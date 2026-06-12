import 'package:ashinagame/game/data/starter_game_data.dart';
import 'package:ashinagame/game/models/resource.dart';
import 'package:ashinagame/game/state/game_controller.dart';
import 'package:ashinagame/game/state/game_serializer.dart';
import 'package:ashinagame/game/state/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });
}

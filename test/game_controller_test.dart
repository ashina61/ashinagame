import 'package:ashinagame/game/models/resource.dart';
import 'package:ashinagame/game/state/game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quest completion updates resources and prevents negatives', () {
    final controller = GameController.starter();
    controller.completeQuest('hunt_steppe');

    expect(controller.state.resource(ResourceType.food), 114);
    expect(controller.state.quests.first.completed, isTrue);

    for (var i = 0; i < 50; i++) {
      controller.endDay();
    }

    expect(
      controller.state.resources.values.every((value) => value >= 0),
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
}

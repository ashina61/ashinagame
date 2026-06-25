import 'dart:math';

import 'package:ashinagame/models/metric.dart';
import 'package:ashinagame/state/game_state.dart';
import 'package:ashinagame/state/stats_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<StatsStore> _mockStats() async {
  SharedPreferences.setMockInitialValues({});
  return StatsStore.create();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts balanced with a card in play', () async {
    final game = GameState(await _mockStats(), rng: Random(1));
    for (final m in Metric.values) {
      expect(game.metrics[m], kStartValue);
    }
    expect(game.current, isNotNull);
    expect(game.reign, 1);
    expect(game.dead, isFalse);
  });

  test('a choice advances the year and keeps pillars in range', () async {
    final game = GameState(await _mockStats(), rng: Random(2));
    game.choose(true);
    expect(game.year, 1);
    for (final m in Metric.values) {
      expect(game.metrics[m]! >= 0 && game.metrics[m]! <= 100, isTrue);
    }
  });

  test('reign ends at an extreme and the heir resets the pillars', () async {
    final game = GameState(await _mockStats(), rng: Random(3));
    var guard = 0;
    while (!game.dead && guard < 1000) {
      game.choose(guard.isEven);
      guard++;
    }
    expect(game.dead, isTrue, reason: 'a reign should end within the guard');
    expect(game.deathCause, isNotEmpty);

    final reignBefore = game.reign;
    game.succeed();
    expect(game.reign, reignBefore + 1);
    expect(game.dead, isFalse);
    for (final m in Metric.values) {
      expect(game.metrics[m], kStartValue);
    }
  });
}

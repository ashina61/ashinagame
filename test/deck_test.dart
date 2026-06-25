import 'package:ashinagame/data/deck.dart';
import 'package:ashinagame/data/portraits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('card ids are unique', () {
    final ids = deck.map((c) => c.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('every speaker has a portrait mapping', () {
    for (final card in deck) {
      expect(portraitBySpeaker.containsKey(card.speaker), isTrue,
          reason: 'no portrait entry for "${card.speaker}"');
    }
  });

  test('every choice is well-formed', () {
    for (final card in deck) {
      for (final choice in [card.left, card.right]) {
        expect(choice.label.trim(), isNotEmpty,
            reason: 'empty label in ${card.id}');
        expect(choice.effects, isNotEmpty, reason: 'no effects in ${card.id}');
        for (final delta in choice.effects.values) {
          expect(delta, isNot(0), reason: 'zero delta in ${card.id}');
          expect(delta.abs() <= 20, isTrue, reason: 'huge delta in ${card.id}');
        }
      }
    }
  });
}

import 'package:ashinagame/data/deck.dart';
import 'package:ashinagame/data/deck_en.dart';
import 'package:ashinagame/data/portraits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('card ids are unique', () {
    final ids = deck.map((c) => c.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('every card has an English translation', () {
    for (final card in deck) {
      expect(deckEn.containsKey(card.id), isTrue,
          reason: 'no English translation for "${card.id}"');
    }
  });

  test('every speaker has a portrait mapping', () {
    for (final card in deck) {
      expect(portraitBySpeaker.containsKey(card.speaker), isTrue,
          reason: 'no portrait entry for "${card.speaker}"');
    }
  });

  test('enqueue ids exist and scheduled cards are reachable', () {
    final ids = {for (final c in deck) c.id};
    final enqueued = <String>{};
    for (final card in deck) {
      for (final choice in [card.left, card.right]) {
        if (choice.enqueue != null) {
          expect(ids.contains(choice.enqueue), isTrue,
              reason: 'enqueue target "${choice.enqueue}" missing');
          enqueued.add(choice.enqueue!);
        }
      }
    }
    for (final card in deck) {
      if (card.scheduledOnly) {
        expect(enqueued.contains(card.id), isTrue,
            reason: 'scheduled card "${card.id}" is never enqueued');
      }
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

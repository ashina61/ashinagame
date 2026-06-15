import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ashinagame/app/ashina_app.dart';
import 'package:ashinagame/features/character/character_screen.dart';
import 'package:ashinagame/game/data/starter_game_data.dart';
import 'package:ashinagame/game/models/resource.dart';
import 'package:ashinagame/game/state/game_controller.dart';
import 'package:ashinagame/game/state/game_scope.dart';

/// Fresh launches open on the naming screen; tap through it to reach the camp.
/// The camp scene runs a gentle, looping glow on its hotspots, so we advance
/// with timed pumps rather than [WidgetTester.pumpAndSettle], which never
/// settles against a repeating animation.
Future<void> _passOnboarding(WidgetTester tester) async {
  await tester.pumpWidget(const AshinaApp());
  expect(find.text('ASHINA'), findsOneWidget);
  final start = find.text('OCAĞI YAK');
  await tester.ensureVisible(start);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(start);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('onboarding leads into the personal camp scene', (tester) async {
    await _passOnboarding(tester);

    // The camp HUD and a day's-work card are present.
    expect(find.text('GÜNÜ BİTİR'), findsOneWidget);
    expect(find.text('Odun Kes'), findsOneWidget);
  });

  testWidgets('ending the day advances the calendar on screen', (tester) async {
    await _passOnboarding(tester);

    expect(find.textContaining('Gün 1 • İlkbahar'), findsOneWidget);

    await tester.tap(find.text('GÜNÜ BİTİR'));
    await tester.pump();

    expect(find.textContaining('Gün 2 • İlkbahar'), findsOneWidget);
  });

  testWidgets('the marriage proposal button weds a ready candidate',
      (tester) async {
    final fresh = StarterGameData.create();
    final controller = GameController(
      fresh.copyWith(
        resources: {
          ...fresh.resources,
          ResourceType.gold: 600,
          ResourceType.reputation: 25,
        },
        marriageCandidates: [
          for (final c in fresh.marriageCandidates)
            c.id == 'aybuke' ? c.copyWith(relation: 70) : c,
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: GameScope(controller: controller, child: const CharacterScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll the first candidate (Aybüke) into view, then tap her proposal.
    await tester.scrollUntilVisible(
      find.textContaining('Aybüke'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(find.text('TEKLİF').first);
    await tester.pumpAndSettle();

    // The result card confirms the wedding and the state reflects it.
    expect(find.textContaining('evlendin'), findsOneWidget);
    expect(controller.state.household.isMarried, isTrue);
  });
}

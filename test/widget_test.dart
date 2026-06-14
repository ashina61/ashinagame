import 'package:flutter_test/flutter_test.dart';

import 'package:ashinagame/app/ashina_app.dart';

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
}

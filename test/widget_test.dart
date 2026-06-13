import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ashinagame/app/ashina_app.dart';

/// Fresh launches open on the naming screen; tap through it to reach play.
Future<void> _passOnboarding(WidgetTester tester) async {
  await tester.pumpWidget(const AshinaApp());
  expect(find.text('ASHINA'), findsOneWidget);
  final start = find.text('OCAĞI YAK');
  await tester.ensureVisible(start);
  await tester.pumpAndSettle();
  await tester.tap(start);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('onboarding leads into the ornate home screen', (tester) async {
    await _passOnboarding(tester);

    expect(find.text('GÜNÜ BİTİR'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('GÜNLÜK İŞLER'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('GÜNLÜK İŞLER'), findsOneWidget);
  });

  testWidgets('ending the day advances the calendar on screen', (tester) async {
    await _passOnboarding(tester);

    expect(find.textContaining('Gün 1 • İlkbahar'), findsOneWidget);

    await tester.tap(find.text('GÜNÜ BİTİR'));
    await tester.pump();

    expect(find.textContaining('Gün 2 • İlkbahar'), findsOneWidget);
  });
}

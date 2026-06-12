import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ashinagame/app/ashina_app.dart';

void main() {
  testWidgets('app renders the ornate home screen', (tester) async {
    await tester.pumpWidget(const AshinaApp());

    expect(find.text('ASHINA'), findsOneWidget);
    expect(find.text('GÜNÜ BİTİR'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('GÜNLÜK İŞLER'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('GÜNLÜK İŞLER'), findsOneWidget);
  });

  testWidgets('ending the day advances the calendar on screen', (tester) async {
    await tester.pumpWidget(const AshinaApp());

    expect(find.textContaining('Gün 1 • İlkbahar'), findsOneWidget);

    await tester.tap(find.text('GÜNÜ BİTİR'));
    await tester.pump();

    expect(find.textContaining('Gün 2 • İlkbahar'), findsOneWidget);
  });
}

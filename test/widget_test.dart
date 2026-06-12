import 'package:flutter_test/flutter_test.dart';

import 'package:ashinagame/app/ashina_app.dart';

void main() {
  testWidgets('app renders the ornate home screen', (tester) async {
    await tester.pumpWidget(const AshinaApp());

    expect(find.text('ASHINA'), findsOneWidget);
    expect(find.text('GÜNLÜK İŞLER'), findsOneWidget);
  });
}

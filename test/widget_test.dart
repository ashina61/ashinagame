import 'package:ashinagame/main.dart';
import 'package:ashinagame/state/stats_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('home screen shows the title and play button', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final stats = await StatsStore.create();

    await tester.pumpWidget(AshinaApp(stats: stats));
    await tester.pumpAndSettle();

    expect(find.text('ASHINA'), findsOneWidget);
    expect(find.text('TAHTA ÇIK'), findsOneWidget);
  });
}

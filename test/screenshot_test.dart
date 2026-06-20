import 'dart:convert';

import 'package:ashinagame/features/camp/camp_screen.dart';
import 'package:ashinagame/features/research/research_screen.dart';
import 'package:ashinagame/game/data/starter_game_data.dart';
import 'package:ashinagame/game/models/resource.dart';
import 'package:ashinagame/game/state/game_controller.dart';
import 'package:ashinagame/game/state/game_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A local screenshot tool, not a CI assertion. Run it with
/// `flutter test --update-goldens test/screenshot_test.dart` to render the
/// hero screens to PNGs under test/screenshots/. It SKIPS during a normal
/// `flutter test` run (guarded by [autoUpdateGoldenFiles]) so it never adds a
/// flaky pixel-comparison or a plugin dependency to CI.

/// Loads every bundled font family (app fonts + MaterialIcons) from the asset
/// bundle so the render shows real glyphs instead of fallback boxes.
Future<void> _loadFonts() async {
  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final entry in manifest) {
    final family = entry['family'] as String;
    final loader = FontLoader(family);
    for (final font in entry['fonts'] as List) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

GameController _foundedController() => GameController(
      StarterGameData.create().copyWith(
        obaFounded: true,
        researchPoints: 60,
        resources: {
          ...StarterGameData.create().resources,
          ResourceType.gold: 240,
          ResourceType.food: 320,
          ResourceType.wood: 180,
          ResourceType.iron: 90,
          ResourceType.horse: 40,
        },
      ),
    );

Future<void> _shoot(WidgetTester tester, Widget screen, String path) async {
  tester.view.physicalSize = const Size(1170, 2200);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await _loadFonts();
  await tester.pumpWidget(
    GameScope(
      controller: _foundedController(),
      child: MaterialApp(debugShowCheckedModeBanner: false, home: screen),
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));
  await expectLater(find.byWidget(screen), matchesGoldenFile(path));
}

void main() {
  // Only render when explicitly updating goldens; stay out of CI runs.
  final skip = !autoUpdateGoldenFiles;

  testWidgets('oba screenshot', (tester) async {
    await _shoot(tester, const CampScreen(), 'screenshots/oba.png');
  }, skip: skip);

  testWidgets('research screenshot', (tester) async {
    await _shoot(tester, const ResearchScreen(), 'screenshots/research.png');
  }, skip: skip);
}

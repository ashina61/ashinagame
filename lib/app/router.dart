import 'package:flutter/material.dart';

import '../core/assets/game_assets.dart';
import '../core/widgets/ornate.dart';
import '../features/boy/boy_screen.dart';
import '../features/camp/camp_screen.dart';
import '../features/character/character_screen.dart';
import '../features/expeditions/expeditions_screen.dart';
import '../features/game_over/game_over_screen.dart';
import '../features/home/home_screen.dart';
import '../features/journey/journey_scene.dart';
import '../features/kurultay/kurultay_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/people/nearby_people_scene.dart';
import '../features/succession/succession_screen.dart';
import '../features/tent/tent_scene.dart';
import '../game/state/game_scope.dart';

class AshinaRouter extends StatefulWidget {
  const AshinaRouter({super.key});

  @override
  State<AshinaRouter> createState() => _AshinaRouterState();
}

class _AshinaRouterState extends State<AshinaRouter> {
  int _index = 0;

  // Lone-tent phase: the world is small and personal.
  static const _earlyScreens = [
    HomeScreen(),
    CharacterScreen(),
    TentScreen(),
    NearbyPeopleScreen(showBack: false),
    JourneyScreen(showBack: false),
  ];

  static const _earlyNav = [
    (GameAssets.navHome, 'Ana Sayfa'),
    (GameAssets.iconPopulationMedallion, 'Karakter'),
    (GameAssets.iconYurtMedallion, 'Çadırım'),
    (GameAssets.iconPeopleGroupGold, 'Yakınlar'),
    (GameAssets.iconCompassStar, 'Yolculuk'),
  ];

  // Oba phase: the settlement, the boys and the campaigns open up.
  static const _obaScreens = [
    HomeScreen(),
    CharacterScreen(),
    CampScreen(),
    BoyScreen(),
    ExpeditionsScreen(),
  ];

  static const _obaNav = [
    (GameAssets.navHome, 'Ana Sayfa'),
    (GameAssets.iconPopulationMedallion, 'Karakter'),
    (GameAssets.navAtelier, 'Oba'),
    (GameAssets.navBoy, 'Boylar'),
    (GameAssets.iconCompassStar, 'Seferler'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    if (!state.onboarded) {
      return const Scaffold(body: OnboardingScreen());
    }
    if (state.gameOver) {
      return const Scaffold(body: GameOverScreen());
    }
    if (state.pendingSuccession) {
      return const Scaffold(body: SuccessionScreen());
    }
    if (state.currentKurultay != null) {
      return const Scaffold(body: KurultayScreen());
    }

    final screens = state.obaFounded ? _obaScreens : _earlyScreens;
    final nav = state.obaFounded ? _obaNav : _earlyNav;
    final index = _index.clamp(0, screens.length - 1);

    return Scaffold(
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: OrnateNavBar(
        index: index,
        items: nav,
        onChanged: (value) => setState(() => _index = value),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../core/assets/game_assets.dart';
import '../core/widgets/ornate.dart';
import '../features/boy/boy_screen.dart';
import '../features/camp/camp_screen.dart';
import '../features/character/character_screen.dart';
import '../features/conquest/conquest_map_screen.dart';
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

  // One stable five-tab bar across the whole game. The icon and position of
  // each slot never move — only the label and the screen behind the three
  // world tabs evolve when an oba is founded (a single tent becomes a camp,
  // nearby folk become the boys, the local trail becomes great campaigns).
  // Keeping the slots fixed means a founded oba never costs the player their
  // muscle memory of where things live.
  static const _navIcons = [
    GameAssets.navHome,
    GameAssets.iconPopulationMedallion,
    GameAssets.iconYurtMedallion,
    GameAssets.iconPeopleGroupGold,
    GameAssets.iconCompassStar,
  ];

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    if (!state.onboarded) {
      return const Scaffold(body: OnboardingScreen());
    }
    if (state.gameOver) {
      return const GameOverScreen();
    }
    if (state.pendingSuccession) {
      return const SuccessionScreen();
    }
    if (state.currentKurultay != null) {
      return const Scaffold(body: KurultayScreen());
    }

    final founded = state.obaFounded;
    final screens = <Widget>[
      const HomeScreen(),
      const CharacterScreen(),
      founded ? const CampScreen() : const TentScreen(),
      founded ? const BoyScreen() : const NearbyPeopleScreen(showBack: false),
      founded
          ? const ConquestMapScreen()
          : const JourneyScreen(showBack: false),
    ];
    final labels = [
      'Ana Sayfa',
      'Karakter',
      founded ? 'Oba' : 'Çadırım',
      founded ? 'Boylar' : 'Yakınlar',
      founded ? 'Seferler' : 'Yolculuk',
    ];
    final nav = [
      for (var i = 0; i < _navIcons.length; i++) (_navIcons[i], labels[i]),
    ];
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

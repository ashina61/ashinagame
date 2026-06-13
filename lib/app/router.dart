import 'package:flutter/material.dart';

import '../core/widgets/ornate.dart';
import '../features/camp/camp_screen.dart';
import '../features/boy/boy_screen.dart';
import '../features/expeditions/expeditions_screen.dart';
import '../features/game_over/game_over_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/succession/succession_screen.dart';
import '../game/state/game_scope.dart';

class AshinaRouter extends StatefulWidget {
  const AshinaRouter({super.key});

  @override
  State<AshinaRouter> createState() => _AshinaRouterState();
}

class _AshinaRouterState extends State<AshinaRouter> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    BoyScreen(),
    CampScreen(),
    ExpeditionsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    if (state.gameOver) {
      return const Scaffold(body: GameOverScreen());
    }
    if (state.pendingSuccession) {
      return const Scaffold(body: SuccessionScreen());
    }
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: OrnateNavBar(
        index: _index,
        onChanged: (value) => setState(() => _index = value),
      ),
    );
  }
}

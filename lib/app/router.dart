import 'package:flutter/material.dart';

import '../core/widgets/ashina_bottom_nav.dart';
import '../features/camp/camp_screen.dart';
import '../features/character/character_screen.dart';
import '../features/home/home_screen.dart';
import '../features/map/map_screen.dart';
import '../features/quests/quests_screen.dart';

class AshinaRouter extends StatefulWidget {
  const AshinaRouter({super.key});

  @override
  State<AshinaRouter> createState() => _AshinaRouterState();
}

class _AshinaRouterState extends State<AshinaRouter> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    CampScreen(),
    MapScreen(),
    QuestsScreen(),
    CharacterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: AshinaBottomNav(
        index: _index,
        onChanged: (value) => setState(() => _index = value),
      ),
    );
  }
}

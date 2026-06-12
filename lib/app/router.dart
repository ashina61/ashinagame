import 'package:flutter/material.dart';

import '../core/widgets/ornate.dart';
import '../features/atelier/atelier_screen.dart';
import '../features/boy/boy_screen.dart';
import '../features/clan/clan_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';

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
    AtelierScreen(),
    ClanScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: OrnateNavBar(
        index: _index,
        onChanged: (value) => setState(() => _index = value),
      ),
    );
  }
}

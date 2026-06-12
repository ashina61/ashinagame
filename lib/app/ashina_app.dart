import 'package:flutter/material.dart';

import '../game/state/game_controller.dart';
import '../game/state/game_scope.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class AshinaApp extends StatefulWidget {
  const AshinaApp({super.key});

  @override
  State<AshinaApp> createState() => _AshinaAppState();
}

class _AshinaAppState extends State<AshinaApp> {
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController.starter();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScope(
      controller: _controller,
      child: MaterialApp(
        title: 'Ashina: Bozkırda Bir Ömür',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkSteppeTheme,
        home: const AshinaRouter(),
      ),
    );
  }
}

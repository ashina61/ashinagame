import 'package:flutter/material.dart';

import '../game/state/game_controller.dart';
import '../game/state/game_scope.dart';
import '../game/state/game_storage.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class AshinaApp extends StatefulWidget {
  const AshinaApp({this.storage, super.key});

  /// Optional so widget tests can run without platform storage.
  final GameStorage? storage;

  @override
  State<AshinaApp> createState() => _AshinaAppState();
}

class _AshinaAppState extends State<AshinaApp> {
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    final storage = widget.storage;
    _controller = storage == null
        ? GameController.starter()
        : GameController.restored(storage);
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

import 'package:flutter/widgets.dart';

import 'game_controller.dart';

class GameScope extends InheritedNotifier<GameController> {
  const GameScope({
    required GameController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static GameController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GameScope>();
    assert(scope != null, 'GameScope bulunamadı.');
    return scope!.notifier!;
  }
}

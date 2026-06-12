import 'package:flutter/material.dart';

import 'app/ashina_app.dart';
import 'game/state/game_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await GameStorage.create();
  runApp(AshinaApp(storage: storage));
}

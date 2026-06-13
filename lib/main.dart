import 'package:flutter/material.dart';

import 'app/ashina_app.dart';
import 'core/audio/audio_service.dart';
import 'game/state/game_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await GameStorage.create();
  await AudioService.instance.init();
  runApp(AshinaApp(storage: storage));
}

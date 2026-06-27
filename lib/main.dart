import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'state/audio_service.dart';
import 'state/settings.dart';
import 'state/stats_store.dart';
import 'theme/app_theme.dart';
import 'ui/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final stats = await StatsStore.create();
  await Settings.instance.init();
  await AudioService.instance.init();
  runApp(AshinaApp(stats: stats));
}

class AshinaApp extends StatelessWidget {
  const AshinaApp({super.key, required this.stats});

  final StatsStore stats;

  @override
  Widget build(BuildContext context) {
    // Rebuild the whole app when settings (e.g. language) change so text
    // re-localizes live.
    return ListenableBuilder(
      listenable: Settings.instance,
      builder: (context, _) => MaterialApp(
        title: 'Ashina',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: HomeScreen(stats: stats),
      ),
    );
  }
}

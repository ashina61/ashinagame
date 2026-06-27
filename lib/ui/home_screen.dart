import 'package:flutter/material.dart';

import '../l10n.dart';
import '../state/audio_service.dart';
import '../state/settings.dart';
import '../state/stats_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'widgets/gold_button.dart';
import 'widgets/steppe_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.stats});

  final StatsStore stats;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _play() async {
    AudioService.instance.tap();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameScreen(stats: widget.stats)),
    );
    if (mounted) setState(() {}); // refresh records after a run
  }

  Future<void> _playDaily() async {
    AudioService.instance.tap();
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => GameScreen(stats: widget.stats, seed: seed)),
    );
    if (mounted) setState(() {});
  }

  void _openStats() {
    AudioService.instance.tap();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StatsScreen(stats: widget.stats)),
    );
  }

  void _openSettings() {
    AudioService.instance.tap();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SettingsScreen(stats: widget.stats)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SteppeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 3),
                // Optional wordmark/emblem; falls back to the Cinzel title
                // when assets/images/ui/logo.png is absent.
                Image.asset(
                  'assets/images/ui/logo.png',
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => const Text(
                    'ASHINA',
                    style: AppTextStyles.display,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tr2('BOZKIRDA KAĞANLIK', 'KHANATE ON THE STEPPE'),
                  style: AppTextStyles.section,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  tr2(
                    'Halkı, orduyu, hazineyi ve töreyi dengede tut. '
                        'Kartı sağa ya da sola kaydırarak karar ver; biri tükenir '
                        'ya da taşarsa tahtını yitirirsin. Hanedanın ne kadar yaşar?',
                    'Keep the People, Army, Treasury and Tradition in balance. '
                        'Swipe the card left or right to decide; if one runs out '
                        'or overflows, you lose the throne. How long can your '
                        'dynasty last?',
                  ),
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 2),
                GoldButton(
                    label: tr2('TAHTA ÇIK', 'TAKE THE THRONE'),
                    icon: Icons.play_arrow_rounded,
                    onTap: _play),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _playDaily,
                  icon: const Icon(Icons.today_rounded,
                      color: AppColors.sand, size: 18),
                  label: Text(tr2('GÜNÜN KAĞANI', 'DAILY KHAN'),
                      style: AppTextStyles.buttonDark),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _openStats,
                      icon: const Icon(Icons.history_edu_rounded,
                          color: AppColors.sand, size: 18),
                      label: Text(tr2('GÜNCE', 'CHRONICLE'),
                          style: AppTextStyles.buttonDark),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings_rounded,
                          color: AppColors.sand, size: 18),
                      label: Text(tr2('AYARLAR', 'SETTINGS'),
                          style: AppTextStyles.buttonDark),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                Text(
                    tr2('En uzun saltanat: ${widget.stats.bestReign} yıl',
                        'Longest reign: ${widget.stats.bestReign} years'),
                    style: AppTextStyles.meta),
                Text(
                    '${tr2('Zorluk', 'Difficulty')}: '
                    '${difficultyLabel(Settings.instance.difficulty)}',
                    style: AppTextStyles.meta),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

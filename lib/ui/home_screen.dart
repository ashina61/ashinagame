import 'package:flutter/material.dart';

import '../state/audio_service.dart';
import '../state/stats_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'game_screen.dart';
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

  void _openStats() {
    AudioService.instance.tap();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StatsScreen(stats: widget.stats)),
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
                const Text('ASHINA',
                    style: AppTextStyles.display, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                const Text(
                  'BOZKIRDA KAĞANLIK',
                  style: AppTextStyles.section,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Halkı, orduyu, hazineyi ve töreyi dengede tut. '
                  'Kartı sağa ya da sola kaydırarak karar ver; biri tükenir '
                  'ya da taşarsa tahtını yitirirsin. Hanedanın ne kadar yaşar?',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 2),
                GoldButton(
                    label: 'TAHTA ÇIK',
                    icon: Icons.play_arrow_rounded,
                    onTap: _play),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: _openStats,
                  icon: const Icon(Icons.history_edu_rounded,
                      color: AppColors.sand, size: 18),
                  label: const Text('GÜNCE', style: AppTextStyles.buttonDark),
                ),
                const Spacer(flex: 2),
                Text('En uzun saltanat: ${widget.stats.bestReign} yıl',
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

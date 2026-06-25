import 'package:flutter/material.dart';

import '../state/stats_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'widgets/steppe_background.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.stats});

  final StatsStore stats;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      (Icons.timer_rounded, 'En uzun saltanat', '${stats.bestReign} yıl'),
      (Icons.account_balance_rounded, 'En uzun hanedan', '${stats.bestDynasty} yıl'),
      (Icons.history_edu_rounded, 'Toplam hüküm', '${stats.totalYears} yıl'),
      (Icons.flag_rounded, 'Oynanan hanedan', '${stats.gamesPlayed}'),
    ];

    return Scaffold(
      body: SteppeBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.sand),
                    ),
                    const SizedBox(width: 4),
                    Text('GÜNCE', style: AppTextStyles.header),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    for (final r in rows) _StatRow(icon: r.$1, label: r.$2, value: r.$3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.card,
        border: Border.all(color: AppColors.bronze),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: AppTextStyles.bodyStrong)),
          Text(value, style: AppTextStyles.value),
        ],
      ),
    );
  }
}

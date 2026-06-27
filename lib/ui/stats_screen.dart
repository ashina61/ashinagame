import 'package:flutter/material.dart';

import '../data/achievements.dart';
import '../models/metric.dart';
import '../state/stats_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'widgets/steppe_background.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.stats});

  final StatsStore stats;

  @override
  Widget build(BuildContext context) {
    final summary = <(IconData, String, String)>[
      (Icons.timer_rounded, 'En uzun saltanat', '${stats.bestReign} yıl'),
      (
        Icons.account_balance_rounded,
        'En uzun hanedan',
        '${stats.bestDynasty} yıl'
      ),
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
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.sand),
                    ),
                    const SizedBox(width: 4),
                    const Text('GÜNCE', style: AppTextStyles.header),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    for (final r in summary)
                      _StatRow(icon: r.$1, label: r.$2, value: r.$3),
                    const _Section('ÖLÜM GÜNCESİ'),
                    _DeathGallery(seen: stats.deathsSeen),
                    const _Section('BAŞARIMLAR'),
                    for (final a in achievements)
                      _AchievementRow(
                        a: a,
                        unlocked: stats.achievements.contains(a.id),
                      ),
                    const SizedBox(height: 24),
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

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
      child: Text(title, style: AppTextStyles.section),
    );
  }
}

class _DeathGallery extends StatelessWidget {
  const _DeathGallery({required this.seen});

  final Set<String> seen;

  @override
  Widget build(BuildContext context) {
    final entries = <Widget>[];
    for (final m in Metric.values) {
      for (final high in [false, true]) {
        final key = '${m.name}_${high ? 'high' : 'low'}';
        entries
            .add(_DeathCell(metric: m, high: high, seen: seen.contains(key)));
      }
    }
    return Column(children: entries);
  }
}

class _DeathCell extends StatelessWidget {
  const _DeathCell(
      {required this.metric, required this.high, required this.seen});

  final Metric metric;
  final bool high;
  final bool seen;

  @override
  Widget build(BuildContext context) {
    final title = '${metric.label} — ${high ? 'Taştı (100)' : 'Tükendi (0)'}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.card,
        border: Border.all(color: seen ? metric.color : AppColors.bronze),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(seen ? metric.icon : Icons.lock_rounded,
              color: seen ? metric.color : AppColors.stone, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seen ? title : '???', style: AppTextStyles.bodyStrong),
                const SizedBox(height: 2),
                Text(
                  seen ? metric.deathCause(high) : 'Henüz görülmedi.',
                  style: AppTextStyles.meta,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({required this.a, required this.unlocked});

  final Achievement a;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.card,
        border: Border.all(color: unlocked ? AppColors.gold : AppColors.bronze),
      ),
      child: Row(
        children: [
          Icon(unlocked ? a.icon : Icons.lock_rounded,
              color: unlocked ? AppColors.goldBright : AppColors.stone,
              size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.name, style: AppTextStyles.bodyStrong),
                Text(a.blurb, style: AppTextStyles.meta),
              ],
            ),
          ),
          if (unlocked)
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 18),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(
      {required this.icon, required this.label, required this.value});

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

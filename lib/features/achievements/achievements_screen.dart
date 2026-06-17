import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/audio/audio_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/achievements.dart';
import '../../game/models/achievement.dart';
import '../../game/state/game_scope.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            const OrnateHeader(title: 'Başarımlar', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  for (final achievement in Achievements.all)
                    _AchievementPanel(achievement: achievement),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementPanel extends StatelessWidget {
  const _AchievementPanel({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final progress =
        state.achievementProgress(achievement).clamp(0, achievement.target);
    final claimed = state.achievementClaimed(achievement.id);
    final ready = state.achievementReady(achievement);

    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(achievement.icon, width: 38, height: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(achievement.title, style: AppTextStyles.bodyStrong),
                    Text(achievement.description, style: AppTextStyles.meta),
                  ],
                ),
              ),
              if (claimed)
                const Icon(Icons.verified, color: AppColors.success, size: 22),
            ],
          ),
          const SizedBox(height: 8),
          StatBar(
            fraction: progress / achievement.target,
            height: 9,
            fill: claimed || ready ? AppColors.success : null,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '$progress/${achievement.target}',
                style: AppTextStyles.meta,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ödül: ${Formatters.resourceDelta(achievement.reward)}',
                  style: AppTextStyles.meta.copyWith(
                    color: AppColors.goldBright,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (claimed)
                Text(
                  'ALINDI',
                  style: AppTextStyles.buttonDark.copyWith(
                    color: AppColors.success,
                    fontSize: 12,
                  ),
                )
              else if (ready)
                SizedBox(
                  width: 120,
                  child: GoldButton(
                    label: 'ÖDÜLÜ AL',
                    height: 34,
                    onPressed: () {
                      controller.claimAchievement(achievement.id);
                      AudioService.instance.playSfx('reward');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${achievement.title} ödülü alındı.'),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/audio/audio_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/achievements.dart';
import '../../game/models/achievement.dart';
import '../../game/models/quest.dart';
import '../../game/state/game_scope.dart';

/// "Hedefler" — the player's goals in one place. Quests (the moment-to-moment
/// to-do list) and achievements (the long-haul milestones) used to live on two
/// near-identical screens; folding them into one tabbed surface removes a
/// redundant screen without losing anything.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({this.initialTab = 0, super.key});

  /// 0 = Görevler (quests), 1 = Başarımlar (achievements).
  final int initialTab;

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late int _tab = widget.initialTab.clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    final quests = GameScope.of(context).state.quests;

    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            const OrnateHeader(title: 'Hedefler', showBack: true),
            OrnateTabs(
              tabs: const ['Görevler', 'Başarımlar'],
              index: _tab,
              onChanged: (value) => setState(() => _tab = value),
            ),
            Expanded(
              child: _tab == 0
                  ? ListView(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      children: [
                        for (final category in const [
                          'Günlük',
                          'Hikâye',
                          'Oba',
                          'İnanç',
                        ]) ...[
                          SectionPlaque('${category.toUpperCase()} GÖREVLERİ'),
                          for (final quest in quests.where(
                            (q) => q.category == category,
                          ))
                            _QuestPanel(quest: quest),
                        ],
                      ],
                    )
                  : ListView(
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

class _QuestPanel extends StatelessWidget {
  const _QuestPanel({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final progress = state.questProgress(quest).clamp(0, quest.goalTarget);
    final ready = state.questReady(quest);
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                quest.completed ? '✓ ' : '◆ ',
                style: AppTextStyles.value.copyWith(
                  color: quest.completed ? AppColors.success : AppColors.gold,
                ),
              ),
              Expanded(
                child: Text(quest.title, style: AppTextStyles.bodyStrong),
              ),
              if (!quest.completed)
                Text(
                  '$progress/${quest.goalTarget}',
                  style: AppTextStyles.value.copyWith(
                    fontSize: 14,
                    color: ready ? AppColors.success : AppColors.goldBright,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(quest.description, style: AppTextStyles.body),
          const SizedBox(height: 6),
          if (!quest.completed)
            StatBar(
              fraction: progress / quest.goalTarget,
              height: 8,
              fill: ready ? AppColors.success : null,
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ödül: ${quest.rewardText}',
                  style: AppTextStyles.meta.copyWith(
                    color: AppColors.goldBright,
                  ),
                ),
              ),
              if (quest.completed)
                Text(
                  'TAMAMLANDI',
                  style: AppTextStyles.buttonDark.copyWith(
                    color: AppColors.success,
                    fontSize: 12,
                  ),
                )
              else if (ready)
                SizedBox(
                  width: 130,
                  child: GoldButton(
                    label: 'ÖDÜLÜ AL',
                    height: 34,
                    onPressed: () {
                      controller.claimQuest(quest.id);
                      AudioService.instance.playSfx('reward');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${quest.title} tamamlandı. '
                            'Ödül: ${quest.rewardText}',
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Text(
                  'DEVAM EDİYOR',
                  style: AppTextStyles.buttonDark.copyWith(
                    color: AppColors.stone,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
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

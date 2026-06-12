import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/quest.dart';
import '../../game/state/game_scope.dart';

class QuestsScreen extends StatelessWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final quests = controller.state.quests;

    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            const OrnateHeader(title: 'Görevler', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  for (final category in const ['Günlük', 'Hikâye', 'Oba', 'İnanç']) ...[
                    SectionPlaque('${category.toUpperCase()} GÖREVLERİ'),
                    for (final quest in _questsByCategory(quests, category))
                      _QuestPanel(quest: quest),
                  ],
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
                  style:
                      AppTextStyles.meta.copyWith(color: AppColors.goldBright),
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

Iterable<Quest> _questsByCategory(List<Quest> quests, String category) {
  return quests.where((item) => item.category == category);
}

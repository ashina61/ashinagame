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
                  for (final category in const ['Günlük', 'Hikâye', 'Oba']) ...[
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
            ],
          ),
          const SizedBox(height: 4),
          Text(quest.description, style: AppTextStyles.body),
          const SizedBox(height: 4),
          Text(
            'Ödül: ${quest.rewardText}',
            style: AppTextStyles.meta.copyWith(color: AppColors.goldBright),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: quest.completed
                ? Text(
                    'TAMAMLANDI',
                    style: AppTextStyles.buttonDark.copyWith(
                      color: AppColors.success,
                      fontSize: 12,
                    ),
                  )
                : SizedBox(
                    width: 140,
                    child: GoldButton(
                      label: 'TAMAMLA',
                      height: 36,
                      onPressed: () {
                        controller.completeQuest(quest.id);
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
                  ),
          ),
        ],
      ),
    );
  }
}

Iterable<Quest> _questsByCategory(List<Quest> quests, String category) {
  return quests.where((item) => item.category == category);
}

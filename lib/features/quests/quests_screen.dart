import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/ashina_button.dart';
import '../../core/widgets/ashina_card.dart';
import '../../core/widgets/ashina_scaffold.dart';
import '../../game/models/quest.dart';
import '../../game/state/game_scope.dart';

class QuestsScreen extends StatelessWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final quests = controller.state.quests;

    return AshinaScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Text('Görevler', style: AppTextStyles.title),
          const SizedBox(height: 8),
          for (final category in ['Günlük', 'Hikâye', 'Oba']) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text('$category Görevleri', style: AppTextStyles.section),
            ),
            for (final quest in _questsByCategory(quests, category))
              AshinaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          quest.completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: quest.completed
                              ? Colors.lightGreenAccent
                              : AppColors.amber,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            quest.title,
                            style: AppTextStyles.section,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(quest.description, style: AppTextStyles.body),
                    Text(
                      'Ödül: ${quest.rewardText}',
                      style: AppTextStyles.meta,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AshinaButton(
                        label: quest.completed ? 'Tamamlandı' : 'Tamamla',
                        onPressed: quest.completed
                            ? null
                            : () => controller.completeQuest(quest.id),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

Iterable<Quest> _questsByCategory(List<Quest> quests, String category) {
  return quests.where((item) => item.category == category);
}

import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';
import '../result/result_scaffold.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;

    return ResultScaffold(
      backgroundAsset: GameAssets.sceneBattlefieldDusk,
      title: 'OCAK SÖNDÜ',
      subtitle: 'BOZKIRDA BİR ÖMÜR SONA ERDİ',
      body: [
        OrnatePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.gameOverReason ?? 'Oba dağıldı.',
                style: AppTextStyles.body.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 12),
              ResultRow('Yaşanan Gün', '${state.day.day}'),
              ResultRow('Son Mevsim', state.day.season.label),
              ResultRow(
                'Bırakılan İtibar',
                '${state.resource(ResourceType.reputation)}',
              ),
              ResultRow(
                'Geride Kalan Halk',
                '${state.resource(ResourceType.population)}',
              ),
            ],
          ),
        ),
      ],
      actions: [
        GoldButton(label: 'YENİ ÖMÜR', onPressed: controller.resetGame),
      ],
    );
  }
}

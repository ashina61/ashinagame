import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;

    return OrnateScaffold(
      backgroundAsset: GameAssets.sceneBattlefieldDusk,
      child: Column(
        children: [
          const Spacer(),
          Center(
            child: Image.asset(
              GameAssets.uiBannerWolfTall,
              width: 110,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 10),
          Text('OCAK SÖNDÜ',
              style: AppTextStyles.display.copyWith(fontSize: 36)),
          Text(
            'BOZKIRDA BİR ÖMÜR SONA ERDİ',
            style: AppTextStyles.section.copyWith(letterSpacing: 3),
          ),
          const SizedBox(height: 14),
          OrnatePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.gameOverReason ?? 'Oba dağıldı.',
                  style: AppTextStyles.body.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 12),
                _SummaryRow('Yaşanan Gün', '${state.day.day}'),
                _SummaryRow('Son Mevsim', state.day.season.label),
                _SummaryRow(
                  'Bırakılan İtibar',
                  '${state.resource(ResourceType.reputation)}',
                ),
                _SummaryRow(
                  'Geride Kalan Halk',
                  '${state.resource(ResourceType.population)}',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 8, 48, 0),
            child: GoldButton(
              label: 'YENİ ÖMÜR',
              onPressed: controller.resetGame,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(
            value,
            style: AppTextStyles.value.copyWith(color: AppColors.goldBright),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/resource_visuals.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/expedition.dart';
import '../result/result_scaffold.dart';

class ExpeditionResultScreen extends StatelessWidget {
  const ExpeditionResultScreen({required this.outcome, super.key});

  final ExpeditionOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final gains = outcome.effects.entries.where((e) => e.value > 0).toList();
    final costs = outcome.effects.entries.where((e) => e.value < 0).toList();
    final success = outcome.success;

    return ResultScaffold(
      headerTitle: 'Sefer Sonucu',
      backgroundAsset: GameAssets.sceneBattlefieldDusk,
      bannerWidth: 120,
      title: success ? 'ZAFER!' : 'BOZGUN!',
      titleColor: success ? null : AppColors.danger,
      body: [
        Center(
          child: Text(
            outcome.site.name,
            style: AppTextStyles.body.copyWith(fontSize: 16),
          ),
        ),
        const SizedBox(height: 6),
        SectionPlaque(success ? 'KAZANÇLAR' : 'KAYIPLAR'),
        OrnatePanel(
          child: gains.isEmpty && costs.isEmpty
              ? Center(
                  child: Text(
                    'Sefer iz bırakmadan sona erdi.',
                    style: AppTextStyles.meta.copyWith(fontSize: 14),
                  ),
                )
              : Row(
                  children: [
                    for (final entry in success ? gains : costs)
                      Expanded(
                        child: Column(
                          children: [
                            Image.asset(
                              ResourceVisuals.icon(entry.key),
                              height: 42,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.signed(entry.value),
                              style: AppTextStyles.value.copyWith(
                                fontSize: 16,
                                color:
                                    entry.value < 0 ? AppColors.danger : null,
                              ),
                            ),
                            Text(
                              entry.key.label,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.meta.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const SectionPlaque('SEFER BİLGİSİ'),
        OrnatePanel(
          child: Column(
            children: [
              ResultRow('Hedef', outcome.site.name),
              ResultRow('Tehlike', outcome.site.dangerLabel),
              ResultRow(
                'Sonuç',
                success ? 'Hedef fethedildi' : 'Geri çekilme',
              ),
              if (success)
                for (final entry in costs)
                  ResultRow('${entry.key.label} Harcandı', '${-entry.value}'),
            ],
          ),
        ),
      ],
      actions: [
        ImageButton(
          asset: GameAssets.uiButtonDevamEt,
          height: 52,
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ],
    );
  }
}

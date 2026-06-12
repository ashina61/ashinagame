import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/resource_visuals.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/expedition.dart';

class ExpeditionResultScreen extends StatelessWidget {
  const ExpeditionResultScreen({required this.outcome, super.key});

  final ExpeditionOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final gains = outcome.effects.entries.where((e) => e.value > 0).toList();
    final costs = outcome.effects.entries.where((e) => e.value < 0).toList();
    final success = outcome.success;

    return Scaffold(
      body: OrnateScaffold(
        backgroundAsset: GameAssets.sceneBattlefieldDusk,
        child: Column(
          children: [
            const OrnateHeader(title: 'Sefer Sonucu', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 10, bottom: 16),
                children: [
                  Center(
                    child: Image.asset(GameAssets.uiBannerWolfTall, width: 120),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      success ? 'ZAFER!' : 'BOZGUN!',
                      style: AppTextStyles.display.copyWith(
                        fontSize: 34,
                        color: success ? null : AppColors.danger,
                      ),
                    ),
                  ),
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
                                          color: entry.value < 0
                                              ? AppColors.danger
                                              : null,
                                        ),
                                      ),
                                      Text(
                                        entry.key.label,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.meta.copyWith(
                                          fontSize: 11,
                                        ),
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
                        _DetailRow('Hedef', outcome.site.name),
                        _DetailRow('Tehlike', outcome.site.dangerLabel),
                        _DetailRow(
                          'Sonuç',
                          success ? 'Hedef fethedildi' : 'Geri çekilme',
                        ),
                        if (success)
                          for (final entry in costs)
                            _DetailRow(
                              '${entry.key.label} Harcandı',
                              '${-entry.value}',
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 4, 40, 12),
              child: ImageButton(
                asset: GameAssets.uiButtonDevamEt,
                height: 52,
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(value, style: AppTextStyles.value),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/resource_visuals.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/resource.dart';

class ExpeditionResultScreen extends StatelessWidget {
  const ExpeditionResultScreen({
    this.title = 'Sınır Karakolu',
    this.effects = const {
      ResourceType.gold: 30,
      ResourceType.reputation: 3,
      ResourceType.leather: 2,
    },
    super.key,
  });

  final String title;
  final Map<ResourceType, int> effects;

  @override
  Widget build(BuildContext context) {
    final gains = effects.entries.where((e) => e.value > 0).toList();
    final costs = effects.entries.where((e) => e.value < 0).toList();

    return Scaffold(
      body: OrnateScaffold(
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
                      'ZAFER!',
                      style: AppTextStyles.display.copyWith(fontSize: 34),
                    ),
                  ),
                  Center(
                    child: Text(
                      title,
                      style: AppTextStyles.body.copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const SectionPlaque('KAZANÇLAR'),
                  OrnatePanel(
                    child: gains.isEmpty
                        ? Center(
                            child: Text(
                              'Bu seferden ganimet çıkmadı.',
                              style: AppTextStyles.meta.copyWith(fontSize: 14),
                            ),
                          )
                        : Row(
                            children: [
                              for (final entry in gains)
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
                        _DetailRow('Hedef', title),
                        for (final entry in costs)
                          _DetailRow(
                            '${entry.key.label} Harcandı',
                            '${-entry.value}',
                          ),
                        const _DetailRow('Kayıplar', '0'),
                        const _DetailRow('Durum', 'Oba güvende'),
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

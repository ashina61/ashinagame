import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';

class ExpeditionResultScreen extends StatelessWidget {
  const ExpeditionResultScreen({super.key});

  static const _gains = [
    (GameAssets.iconCoinsGold, '3.000', 'Altın'),
    (GameAssets.iconScrollMedallion, '700', 'İtibar'),
    (GameAssets.iconSwordsCrossedGold, '2', 'Klan Puanı'),
    (GameAssets.iconChestLarge, '1', 'Nadir Sandık'),
  ];

  static const _details = [
    ('Süre', '02:15'),
    ('Yaralılar', '8'),
    ('Tecrübe', '+150 XP'),
    ('Kayıplar', '0'),
    ('Kalan Asker', '30'),
  ];

  @override
  Widget build(BuildContext context) {
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
                      'Sınır Karakolu',
                      style: AppTextStyles.body.copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const SectionPlaque('KAZANÇLAR'),
                  OrnatePanel(
                    child: Row(
                      children: [
                        for (final (asset, value, label) in _gains)
                          Expanded(
                            child: Column(
                              children: [
                                Image.asset(asset, height: 42),
                                const SizedBox(height: 4),
                                Text(
                                  value,
                                  style: AppTextStyles.value.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  label,
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
                        for (final (label, value) in _details)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    style: AppTextStyles.body,
                                  ),
                                ),
                                Text(value, style: AppTextStyles.value),
                              ],
                            ),
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

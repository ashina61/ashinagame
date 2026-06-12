import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';

class BoyScreen extends StatelessWidget {
  const BoyScreen({super.key});

  static const _members = [
    ('Togan', 'Lider', 92, GameAssets.portraitTogan),
    ('Bori', 'Avcı', 78, GameAssets.portraitBori),
    ('Kaya', 'Asker', 65, GameAssets.portraitKaya),
    ('Alis', 'Tüccar', 58, GameAssets.portraitAlis),
  ];

  @override
  Widget build(BuildContext context) {
    return OrnateScaffold(
      child: Column(
        children: [
          const OrnateHeader(title: 'Boy'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              children: [
                OrnatePanel(
                  backgroundAsset: GameAssets.bgSceneCampNight,
                  child: Row(
                    children: [
                      Image.asset(GameAssets.uiBannerWolf, height: 130),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('KARA KURTLAR', style: AppTextStyles.title),
                            SizedBox(height: 8),
                            _InfoRow('Lider', 'Togan'),
                            _InfoRow('Üyeler', '44/60'),
                            _InfoRow('Nüfus', '1.250'),
                            _InfoRow('Bölge', 'Sınır Karakolu'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SectionPlaque('BOY ÜYELERİ'),
                for (final (name, role, power, portrait) in _members)
                  OrnatePanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: ClipOval(
                                  child: Image.asset(
                                    portrait,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Image.asset(
                                  GameAssets.uiFramePortraitRound,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(name, style: AppTextStyles.bodyStrong),
                                  if (role == 'Lider')
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Text(
                                        '♛',
                                        style: AppTextStyles.value.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(role, style: AppTextStyles.meta),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Güç  $power',
                              style: AppTextStyles.value.copyWith(fontSize: 14),
                            ),
                            Text(
                              'Sadık',
                              style: AppTextStyles.meta.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DarkButton(
                          label: 'DİPLOMASİ',
                          onPressed: () => _soon(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DarkButton(
                          label: 'YARDIM GÖNDER',
                          onPressed: () => _soon(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DarkButton(
                          label: 'BOY YÖNETİMİ',
                          onPressed: () => _soon(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu özellik yakında geliyor.')),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text('$label:', style: AppTextStyles.meta),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyStrong)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';
import '../expeditions/expeditions_screen.dart';

class ClanScreen extends StatefulWidget {
  const ClanScreen({super.key});

  @override
  State<ClanScreen> createState() => _ClanScreenState();
}

class _ClanScreenState extends State<ClanScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return OrnateScaffold(
      child: Column(
        children: [
          const OrnateHeader(title: 'Klan'),
          OrnateTabs(
            tabs: const ['Genel Bakış', 'Üyeler', 'Savaşlar'],
            index: _tab,
            onChanged: (value) => setState(() => _tab = value),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                const SectionPlaque('KLAN BİLGİLERİ'),
                OrnatePanel(
                  backgroundAsset: GameAssets.bgSceneFortressNight,
                  child: Row(
                    children: [
                      Image.asset(GameAssets.uiEmblemWolfRound, width: 96),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow('Lider', 'Tugan Han'),
                            _InfoRow('Üyeler', '28/50'),
                            _InfoRow('Güç', '12.450'),
                            _InfoRow('Puan', '34.680'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SectionPlaque('DUYURU'),
                const OrnatePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yarın akşam sefere çıkıyoruz.',
                        style: AppTextStyles.body,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text('– Tugan Han', style: AppTextStyles.bodyStrong),
                          Spacer(),
                          Text('2 saat önce', style: AppTextStyles.meta),
                        ],
                      ),
                    ],
                  ),
                ),
                const SectionPlaque('YAKINDAKİ SAVAŞ'),
                OrnatePanel(
                  child: Row(
                    children: [
                      Image.asset(GameAssets.iconSwordsCrossed, width: 52),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sınır Çatışması',
                              style: AppTextStyles.bodyStrong,
                            ),
                            Text(
                              'Rakip: Demir Kartallar',
                              style: AppTextStyles.body.copyWith(fontSize: 13),
                            ),
                            const Text(
                              'Başlangıç: 12:30:45',
                              style: AppTextStyles.meta,
                            ),
                          ],
                        ),
                      ),
                      ImageButton(
                        asset: GameAssets.uiButtonHazirlik,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const ExpeditionsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SectionPlaque('KLAN SANDIĞI'),
                OrnatePanel(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatBar(fraction: 6250 / 10000, height: 14),
                            SizedBox(height: 6),
                            Text(
                              '6.250 / 10.000',
                              style: AppTextStyles.value,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Image.asset(GameAssets.iconChest, width: 72),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ImageButton(
                          asset: GameAssets.uiButtonYardimIste,
                          onPressed: () => _soon(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ImageButton(
                          asset: GameAssets.uiButtonKlanMagazasi,
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
              width: 70, child: Text('$label:', style: AppTextStyles.meta)),
          Expanded(child: Text(value, style: AppTextStyles.bodyStrong)),
        ],
      ),
    );
  }
}

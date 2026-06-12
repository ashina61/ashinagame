import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';

class AtelierScreen extends StatefulWidget {
  const AtelierScreen({super.key});

  @override
  State<AtelierScreen> createState() => _AtelierScreenState();
}

class _AtelierScreenState extends State<AtelierScreen> {
  int _tab = 0;
  int _selected = 2;

  static const _craftables = [
    (GameAssets.iconItemSword, 'Demir Kılıç', '30 dk.'),
    (GameAssets.iconItemArmor, 'Deri Zırh', '45 dk.'),
    (GameAssets.iconItemBow, 'Kompozit Yay', '60 dk.'),
    (GameAssets.iconMedallionHorse, 'Ata Koşum', '90 dk.'),
    (GameAssets.iconItemLeather, 'Kürk Pelerin', '45 dk.'),
    (GameAssets.iconItemShield, 'Ahşap Kalkan', '20 dk.'),
  ];

  static const _costs = [
    (GameAssets.iconItemWood, 'Odun', '320'),
    (GameAssets.iconItemLeather, 'Deri', '180'),
    (GameAssets.iconIronOre, 'Demir', '210'),
    (GameAssets.iconItemThread, 'İplik', '140'),
  ];

  @override
  Widget build(BuildContext context) {
    return OrnateScaffold(
      child: Column(
        children: [
          const OrnateHeader(title: 'Atölye'),
          OrnateTabs(
            tabs: const ['Üretim', 'Geliştirme', 'Tamir'],
            index: _tab,
            onChanged: (value) => setState(() => _tab = value),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                const SectionPlaque('ÜRETİM KUYRUĞU'),
                OrnatePanel(
                  child: Row(
                    children: [
                      Image.asset(GameAssets.iconItemBow, height: 44),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kompozit Yay',
                              style: AppTextStyles.bodyStrong,
                            ),
                            SizedBox(height: 4),
                            StatBar(fraction: 0.4, height: 10),
                            SizedBox(height: 3),
                            Text('⏳ 01:15:30', style: AppTextStyles.meta),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      DarkButton(
                        label: 'HIZLANDIR ⚡',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                OrnatePanel(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Kuyruk Boş',
                        style: AppTextStyles.meta.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SectionPlaque('ÜRETİLEBİLİR EŞYALAR'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.78,
                    children: [
                      for (var i = 0; i < _craftables.length; i++)
                        ItemSlot(
                          asset: _craftables[i].$1,
                          label: _craftables[i].$2,
                          count: _craftables[i].$3,
                          selected: i == _selected,
                          onTap: () => setState(() => _selected = i),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 44,
            margin: const EdgeInsets.fromLTRB(10, 2, 10, 6),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(GameAssets.uiBarSlots),
                fit: BoxFit.fill,
              ),
            ),
            child: Row(
              children: [
                for (final (asset, label, value) in _costs)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(asset, width: 20, height: 20),
                        const SizedBox(width: 4),
                        Text(
                          '$label $value',
                          style: AppTextStyles.value.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
}

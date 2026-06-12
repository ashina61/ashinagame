import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  int _tab = 0;
  int _category = 0;

  static const _categories = [
    'Tümü',
    'Kaynaklar',
    'Gıda',
    'Malzemeler',
    'Ekipman',
    'At ve Binicilik',
    'Diğer',
  ];

  static const _goods = [
    (GameAssets.iconItemWheat, 'Buğday', 18, 120, 2),
    (GameAssets.iconItemWood, 'Odun', 16, 85, 1),
    (GameAssets.iconIronOre, 'Demir Cevheri', 35, 60, 3),
    (GameAssets.iconItemLeather, 'Deri', 22, 40, 3),
    (GameAssets.iconItemWool, 'Yün', 24, 35, 1),
    (GameAssets.iconItemSalt, 'Tuz', 30, 25, 2),
    (GameAssets.iconItemHorse, 'At', 350, 3, 5),
    (GameAssets.iconItemBow, 'Kompozit Yay', 280, 2, 4),
  ];

  static const _categoryOf = {
    'Buğday': 2,
    'Odun': 1,
    'Demir Cevheri': 1,
    'Deri': 3,
    'Yün': 3,
    'Tuz': 2,
    'At': 5,
    'Kompozit Yay': 4,
  };

  List<(String, String, int, int, int)> get _filtered {
    if (_category == 0) return _goods;
    return _goods.where((g) => _categoryOf[g.$2] == _category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            const OrnateHeader(title: 'Pazar', showBack: true),
            const ResourceBar(
              entries: [
                (GameAssets.iconCoinGold, '7.101'),
                (GameAssets.iconCoinsMedallion, '813'),
                (GameAssets.iconFood, '5.740'),
                (GameAssets.iconItemWood, '320'),
                (GameAssets.iconItemLeather, '180'),
              ],
            ),
            OrnateTabs(
              tabs: const ['Satın Al', 'Sat', 'Teklifler'],
              index: _tab,
              onChanged: (value) => setState(() => _tab = value),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 104,
                    child: ListView(
                      padding: const EdgeInsets.only(left: 10, bottom: 8),
                      children: [
                        for (var i = 0; i < _categories.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: GestureDetector(
                              onTap: () => setState(() => _category = i),
                              child: Container(
                                height: 34,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: i == _category
                                      ? AppColors.bronze.withValues(alpha: 0.55)
                                      : AppColors.leatherDeep.withValues(
                                          alpha: 0.75,
                                        ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: i == _category
                                        ? AppColors.gold
                                        : AppColors.goldDim.withValues(
                                            alpha: 0.4,
                                          ),
                                  ),
                                ),
                                child: Text(
                                  _categories[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.buttonDark.copyWith(
                                    fontSize: 10,
                                    color: i == _category
                                        ? AppColors.goldBright
                                        : AppColors.sand,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(8, 0, 12, 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('ÜRÜN', style: AppTextStyles.meta),
                              ),
                              SizedBox(
                                width: 56,
                                child: Text(
                                  'FİYAT',
                                  textAlign: TextAlign.right,
                                  style: AppTextStyles.meta,
                                ),
                              ),
                              SizedBox(
                                width: 56,
                                child: Text(
                                  'MEVCUT',
                                  textAlign: TextAlign.right,
                                  style: AppTextStyles.meta,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(
                              right: 12,
                              left: 4,
                              bottom: 8,
                            ),
                            children: [
                              for (final (asset, name, price, stock, _)
                                  in _filtered)
                                OrnatePanel(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(asset, width: 30, height: 30),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: AppTextStyles.bodyStrong
                                              .copyWith(fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 56,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Image.asset(
                                              GameAssets.iconCoinGold,
                                              width: 13,
                                              height: 13,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              '$price',
                                              style: AppTextStyles.value
                                                  .copyWith(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 56,
                                        child: Text(
                                          'x$stock',
                                          textAlign: TextAlign.right,
                                          style: AppTextStyles.meta,
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
                  ),
                ],
              ),
            ),
            Container(
              height: 42,
              margin: const EdgeInsets.fromLTRB(12, 2, 12, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(GameAssets.uiPanelField),
                  fit: BoxFit.fill,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pazar Yenilenmesine: 01:30:45',
                      style: AppTextStyles.meta.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DarkButton(
                    label: 'YENİLE  ⦿10',
                    height: 30,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';

class _Good {
  const _Good(
    this.asset,
    this.name,
    this.price,
    this.stock,
    this.category, {
    this.buyEffects,
  });

  final String asset;
  final String name;
  final int price;
  final int stock;
  final int category;

  /// Resource delta applied on purchase (gold cost added separately).
  final Map<ResourceType, int>? buyEffects;
}

class _SellLot {
  const _SellLot(this.type, this.amount, this.price);

  final ResourceType type;
  final int amount;
  final int price;
}

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
    _Good(GameAssets.iconItemWheat, 'Buğday', 18, 120, 2,
        buyEffects: {ResourceType.food: 10}),
    _Good(GameAssets.iconItemWood, 'Odun', 16, 85, 1,
        buyEffects: {ResourceType.wood: 10}),
    _Good(GameAssets.iconIronOre, 'Demir Cevheri', 35, 60, 1),
    _Good(GameAssets.iconItemLeather, 'Deri', 22, 40, 3,
        buyEffects: {ResourceType.leather: 5}),
    _Good(GameAssets.iconItemWool, 'Yün', 24, 35, 3),
    _Good(GameAssets.iconItemSalt, 'Tuz', 30, 25, 2,
        buyEffects: {ResourceType.food: 6}),
    _Good(GameAssets.iconItemHorse, 'At', 120, 3, 5,
        buyEffects: {ResourceType.horse: 1}),
    _Good(GameAssets.iconItemBow, 'Kompozit Yay', 280, 2, 4),
  ];

  static const _sellLots = [
    _SellLot(ResourceType.food, 10, 14),
    _SellLot(ResourceType.wood, 10, 12),
    _SellLot(ResourceType.leather, 5, 18),
    _SellLot(ResourceType.horse, 1, 90),
  ];

  List<_Good> get _filtered {
    if (_category == 0) return _goods;
    return _goods.where((g) => g.category == _category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final gold = controller.state.resource(ResourceType.gold);

    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            const OrnateHeader(title: 'Pazar', showBack: true),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 34,
                margin: const EdgeInsets.fromLTRB(12, 2, 0, 4),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(GameAssets.uiPanelPill),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(GameAssets.iconCoinGold, width: 18, height: 18),
                    const SizedBox(width: 6),
                    Text('$gold', style: AppTextStyles.value),
                  ],
                ),
              ),
            ),
            OrnateTabs(
              tabs: const ['Satın Al', 'Sat', 'Teklifler'],
              index: _tab,
              onChanged: (value) => setState(() => _tab = value),
            ),
            Expanded(
              child: switch (_tab) {
                1 => _buildSell(),
                2 => _buildOffers(),
                _ => _buildBuy(),
              },
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
                    onPressed: () => _notify(
                      context,
                      'Pazar tezgâhları zamanı gelince yenilenecek.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuy() {
    return Row(
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
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == _category
                            ? AppColors.bronze.withValues(alpha: 0.55)
                            : AppColors.leatherDeep.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: i == _category
                              ? AppColors.gold
                              : AppColors.goldDim.withValues(alpha: 0.4),
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
                    Expanded(child: Text('ÜRÜN', style: AppTextStyles.meta)),
                    SizedBox(
                      width: 52,
                      child: Text(
                        'FİYAT',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.meta,
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: Text(
                        'MEVCUT',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.meta,
                      ),
                    ),
                    SizedBox(width: 46),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(right: 12, left: 4, bottom: 8),
                  children: [
                    for (final good in _filtered) _BuyRow(good: good),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSell() {
    final controller = GameScope.of(context);
    final state = controller.state;
    return ListView(
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      children: [
        for (final lot in _sellLots)
          OrnatePanel(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Image.asset(
                  switch (lot.type) {
                    ResourceType.food => GameAssets.iconItemWheat,
                    ResourceType.wood => GameAssets.iconItemWood,
                    ResourceType.leather => GameAssets.iconItemLeather,
                    _ => GameAssets.iconItemHorse,
                  },
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${lot.amount} ${lot.type.label}',
                        style: AppTextStyles.bodyStrong.copyWith(fontSize: 14),
                      ),
                      Text(
                        'Depoda: ${state.resource(lot.type)}',
                        style: AppTextStyles.meta.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Image.asset(
                      GameAssets.iconCoinGold,
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+${lot.price}',
                      style: AppTextStyles.value.copyWith(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                DarkButton(
                  label: 'SAT',
                  height: 32,
                  onPressed: () {
                    final done = controller.tryTrade(
                      '${lot.amount} ${lot.type.label} satışı',
                      {lot.type: -lot.amount, ResourceType.gold: lot.price},
                    );
                    _notify(
                      context,
                      done
                          ? '${lot.amount} ${lot.type.label} satıldı, '
                              '+${lot.price} altın.'
                          : 'Depoda yeterli ${lot.type.label.toLowerCase()} '
                              'yok.',
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOffers() {
    return ListView(
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      children: const [
        OrnatePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kervan Teklifi', style: AppTextStyles.bodyStrong),
              SizedBox(height: 4),
              Text(
                'Batıdan gelen kervan yün ve tuz karşılığında at arıyor. '
                'Teklifler pazar yenilenince güncellenir.',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
        OrnatePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Demirci Loncası', style: AppTextStyles.bodyStrong),
              SizedBox(height: 4),
              Text(
                'Lonca, demir cevheri getirene kılıç başına indirim '
                'sözü veriyor.',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _BuyRow extends StatelessWidget {
  const _BuyRow({required this.good});

  final _Good good;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    return OrnatePanel(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Image.asset(good.asset, width: 30, height: 30),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              good.name,
              style: AppTextStyles.bodyStrong.copyWith(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(GameAssets.iconCoinGold, width: 13, height: 13),
                const SizedBox(width: 3),
                Text(
                  '${good.price}',
                  style: AppTextStyles.value.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              'x${good.stock}',
              textAlign: TextAlign.right,
              style: AppTextStyles.meta,
            ),
          ),
          const SizedBox(width: 6),
          DarkButton(
            label: 'AL',
            height: 30,
            onPressed: () {
              final effects = good.buyEffects;
              if (effects == null) {
                _MarketScreenState._notify(
                  context,
                  '${good.name} için takas yakında açılacak.',
                );
                return;
              }
              final done = controller.tryTrade('${good.name} alımı', {
                ...effects,
                ResourceType.gold: -good.price,
              });
              _MarketScreenState._notify(
                context,
                done
                    ? '${good.name} satın alındı (-${good.price} altın).'
                    : 'Yeterli altın yok.',
              );
            },
          ),
        ],
      ),
    );
  }
}

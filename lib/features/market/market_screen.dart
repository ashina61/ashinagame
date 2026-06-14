import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/market_goods.dart';
import '../../game/logic/market_logic.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';

/// Atlas icons for market goods.
String goodIcon(String goodId) => switch (goodId) {
      'wheat' => GameAssets.iconItemWheat,
      'wood' => GameAssets.iconItemWood,
      'iron_ore' => GameAssets.iconIronOre,
      'leather' => GameAssets.iconItemLeather,
      'wool' => GameAssets.iconItemWool,
      'salt' => GameAssets.iconItemSalt,
      'horse' => GameAssets.iconItemHorse,
      'bow' => GameAssets.iconItemBow,
      'm_sword' => GameAssets.iconItemSword,
      'm_shield' => GameAssets.iconItemShieldWood,
      'm_armor' => GameAssets.iconItemArmor,
      _ => GameAssets.iconItemWheat,
    };

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

/// A small bazaar flavour strip: the day's featured good and a rotating trader
/// quote, so the market feels staffed rather than static.
class _TraderBanner extends StatelessWidget {
  const _TraderBanner({required this.day});

  final int day;

  static const _quotes = [
    'Bezirgân: "Yollar tozlu ama mal taze, bey’im."',
    'Bezirgân: "Bugün kalkan demiri ucuza geldi."',
    'Bezirgân: "İyi at, iyi yol açar — al derim."',
    'Bezirgân: "Tuz bitiyor, acele et."',
    'Bezirgân: "Kervan sağ salim döndü, stok bol."',
  ];

  @override
  Widget build(BuildContext context) {
    const goods = MarketGoods.all;
    final featured = goods.isEmpty ? null : goods[day % goods.length];
    final quote = _quotes[day % _quotes.length];
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.leatherDeep.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.goldDim.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, size: 16, color: AppColors.goldBright),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (featured != null)
                  Text('Günün teklifi: ${featured.name}',
                      style: AppTextStyles.meta
                          .copyWith(color: AppColors.goldBright)),
                Text(quote, style: AppTextStyles.meta),
              ],
            ),
          ),
        ],
      ),
    );
  }
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

  /// Lots the player can sell back, tied to the matching market good so
  /// their prices follow the same daily wobble.
  static const _sellLots = [
    (ResourceType.food, 10, 'wheat'),
    (ResourceType.wood, 10, 'wood'),
    (ResourceType.leather, 5, 'leather'),
    (ResourceType.horse, 1, 'horse'),
  ];

  List<MarketGood> get _filtered {
    if (_category == 0) return MarketGoods.all;
    return MarketGoods.all.where((g) => g.category == _category).toList();
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
            _TraderBanner(day: controller.state.day.day),
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
                      'Fiyatlar ve stok her gün yenilenir.',
                      style: AppTextStyles.meta.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Gün ${controller.state.day.day}',
                    style: AppTextStyles.value.copyWith(fontSize: 13),
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
                      width: 44,
                      child: Text(
                        'STOK',
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
    final day = state.day.day;
    return ListView(
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      children: [
        for (final (type, amount, goodId) in _sellLots)
          OrnatePanel(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Image.asset(goodIcon(goodId), width: 30, height: 30),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$amount ${type.label}',
                        style: AppTextStyles.bodyStrong.copyWith(fontSize: 14),
                      ),
                      Text(
                        'Depoda: ${state.resource(type)}',
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
                      '+${MarketLogic.sellPriceFor(MarketGoods.byId(goodId)!, day)}',
                      style: AppTextStyles.value.copyWith(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                DarkButton(
                  label: 'SAT',
                  height: 32,
                  onPressed: () {
                    final price = MarketLogic.sellPriceFor(
                      MarketGoods.byId(goodId)!,
                      day,
                    );
                    final done = controller.tryTrade(
                      '$amount ${type.label} satışı',
                      {type: -amount, ResourceType.gold: price},
                    );
                    AudioService.instance.playSfx(done ? 'coin' : 'denied');
                    _notify(
                      context,
                      done
                          ? '$amount ${type.label} satıldı, +$price altın.'
                          : 'Depoda yeterli ${type.label.toLowerCase()} yok.',
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
      children: [
        OrnatePanel(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  GameAssets.portraitMerchant,
                  width: 72,
                  height: 92,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kervan Teklifi', style: AppTextStyles.bodyStrong),
                    SizedBox(height: 4),
                    Text(
                      'Batıdan gelen kervan yün ve tuz karşılığında at '
                      'arıyor. Teklifler pazar yenilenince güncellenir.',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const OrnatePanel(
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

  final MarketGood good;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final price = MarketLogic.priceFor(good, state.day.day);
    final stock = state.stockOf(good.id);
    return OrnatePanel(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Image.asset(goodIcon(good.id), width: 30, height: 30),
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
                  '$price',
                  style: AppTextStyles.value.copyWith(
                    fontSize: 14,
                    color: price > good.basePrice
                        ? AppColors.danger
                        : price < good.basePrice
                            ? AppColors.success
                            : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              stock > 0 ? 'x$stock' : '—',
              textAlign: TextAlign.right,
              style: AppTextStyles.meta.copyWith(
                color: stock > 0 ? null : AppColors.danger,
              ),
            ),
          ),
          const SizedBox(width: 6),
          DarkButton(
            label: 'AL',
            height: 30,
            onPressed: () {
              if (good.grants == null && good.grantsItem == null) {
                _MarketScreenState._notify(
                  context,
                  '${good.name} için takas yakında açılacak.',
                );
                return;
              }
              if (stock <= 0) {
                _MarketScreenState._notify(
                  context,
                  'Tezgâh boş. Yarın yeniden stoklanır.',
                );
                return;
              }
              final done = controller.buyGood(good.id);
              AudioService.instance.playSfx(done ? 'coin' : 'denied');
              _MarketScreenState._notify(
                context,
                done
                    ? '${good.name} satın alındı (-$price altın).'
                    : 'Yeterli altın yok.',
              );
            },
          ),
        ],
      ),
    );
  }
}

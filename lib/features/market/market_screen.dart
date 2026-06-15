import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/info_sheet.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/companion_roles.dart';
import '../../game/data/game_info.dart';
import '../../game/data/han_offers.dart';
import '../../game/data/market_goods.dart';
import '../../game/data/rare_offers.dart';
import '../../game/models/npc.dart';
import '../../game/models/unit_type.dart';
import '../../game/logic/market_logic.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';
import '../scene/floating_text.dart';

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

/// A would-be follower at the han; winning them over binds a sworn follower in
/// their role and counts toward founding an oba.
class _CompanionOffer extends StatelessWidget {
  const _CompanionOffer({required this.companion});

  final HanCompanion companion;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final joined = state.relationWith(companion.npcId) >= 75;
    final name = NpcCharacters.byId(companion.npcId)?.name ?? companion.name;
    final role = CompanionRoles.byId(companion.roleId);
    final canAfford = state.resource(ResourceType.gold) >= companion.goldCost &&
        state.dailyActionPoints > 0;
    return OrnatePanel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name — ${role?.name ?? companion.roleId}',
                  style: AppTextStyles.bodyStrong,
                ),
                Text(
                  role?.effect ?? '',
                  style: AppTextStyles.meta.copyWith(
                    color: AppColors.goldBright,
                  ),
                ),
                Text(
                  'Bedel: ${companion.goldCost} altın',
                  style: AppTextStyles.meta,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: DarkButton(
              label: joined ? 'Yoldaşın' : 'KATIL',
              height: 34,
              onPressed: joined || !canAfford
                  ? null
                  : () {
                      final ok = controller.recruitCompanion(
                        companion.npcId,
                        roleId: companion.roleId,
                        goldCost: companion.goldCost,
                      );
                      AudioService.instance.playSfx(ok ? 'reward' : 'denied');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? '$name obana katıldı.'
                                : 'Altın ya da aksiyon yetersiz.',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }
}

/// A sword for hire that joins the army at once for gold (and a horse if it
/// rides).
class _MercenaryOffer extends StatelessWidget {
  const _MercenaryOffer({required this.mercenary});

  final HanMercenary mercenary;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final unit = UnitTypes.byId(mercenary.unitId);
    final canAfford = state.resource(ResourceType.gold) >= mercenary.goldCost &&
        (!mercenary.needsHorse || state.resource(ResourceType.horse) >= 1) &&
        state.dailyActionPoints > 0;
    return OrnatePanel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mercenary.name, style: AppTextStyles.bodyStrong),
                Text(
                  'Saldırı ${unit?.attack ?? 0} • Savunma ${unit?.defense ?? 0}'
                  '${mercenary.needsHorse ? ' • At gerekir' : ''}',
                  style: AppTextStyles.meta,
                ),
                Text(
                  'Bedel: ${mercenary.goldCost} altın',
                  style: AppTextStyles.meta,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: DarkButton(
              label: 'KİRALA',
              height: 34,
              onPressed: !canAfford
                  ? null
                  : () {
                      final ok = controller.recruitUnit(mercenary.unitId, 1);
                      AudioService.instance.playSfx(ok ? 'coin' : 'denied');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? '${mercenary.name} orduya katıldı.'
                                : 'Altın/at ya da aksiyon yetersiz.',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }
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
    final rare = RareOffers.forDay(day);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.leatherDeep.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: rare != null
              ? AppColors.goldBright.withValues(alpha: 0.8)
              : AppColors.goldDim.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Icon(
            rare != null ? Icons.auto_awesome : Icons.local_offer,
            size: 16,
            color: AppColors.goldBright,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rare != null)
                  Text(
                    'Nadir teklif: ${rare.title} — ${rare.note}',
                    style: AppTextStyles.meta.copyWith(
                      color: AppColors.goldBright,
                    ),
                  )
                else if (featured != null)
                  Text(
                    'Günün teklifi: ${featured.name}',
                    style: AppTextStyles.meta.copyWith(
                      color: AppColors.goldBright,
                    ),
                  ),
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
            OrnateHeader(
              title: 'Pazar',
              showBack: true,
              onInfo: () => showHelpSheet(context, HelpId.market),
            ),
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
                  children: [for (final good in _filtered) _BuyRow(good: good)],
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
                    Image.asset(GameAssets.iconCoinGold, width: 14, height: 14),
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
                    if (done) {
                      // A light floating gain instead of stacked snackbars, so
                      // rapid sales feel like coins dropping, not a log spam.
                      showFloatingGain(
                        context,
                        '+$price Altın',
                        color: AppColors.success,
                      );
                    } else {
                      _notify(
                        context,
                        'Depoda yeterli ${type.label.toLowerCase()} yok.',
                      );
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// The han: where wandering swords, would-be followers and rumours gather.
  Widget _buildOffers() {
    final controller = GameScope.of(context);
    final state = controller.state;
    return ListView(
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      children: [
        OrnatePanel(
          child: Row(
            children: [
              const Icon(Icons.campaign, color: AppColors.goldBright),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  HanOffers.rumorForDay(state.day.day),
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
        ),
        const SectionPlaque('YOLDAŞ ADAYLARI'),
        for (final c in HanOffers.companions) _CompanionOffer(companion: c),
        const SectionPlaque('PARALI SAVAŞÇILAR'),
        for (final m in HanOffers.mercenaries) _MercenaryOffer(mercenary: m),
      ],
    );
  }

  static void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
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
              if (done) {
                showFloatingGain(
                  context,
                  '${good.name}  -$price Altın',
                  color: AppColors.goldBright,
                );
              } else {
                _MarketScreenState._notify(context, 'Yeterli altın yok.');
              }
            },
          ),
        ],
      ),
    );
  }
}

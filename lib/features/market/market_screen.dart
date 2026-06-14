import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/market_goods.dart';
import '../../game/logic/market_logic.dart';
import '../../game/models/resource.dart';
import '../../game/models/unit_type.dart';
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
  const MarketScreen({this.isTab = false, super.key});

  /// True when shown as the bottom-nav "Han" tab (no back button).
  final bool isTab;

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;

    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            OrnateHeader(
              title: 'Han',
              subtitle: 'Tüccarlar, Askerler ve Söylentiler',
              showBack: !widget.isTab,
            ),
            ResourceBar(
              entries: [
                (GameAssets.iconCoinGold, '${state.resource(ResourceType.gold)}'),
                (GameAssets.iconFood, '${state.resource(ResourceType.food)}'),
                (GameAssets.iconItemHorse,
                    '${state.resource(ResourceType.horse)}'),
                (GameAssets.iconArmyEmblem, '${controller.armyStrength}'),
                (GameAssets.iconScrollMedallion,
                    '${state.resource(ResourceType.reputation)}'),
              ],
            ),
            OrnateTabs(
              tabs: const ['Pazar', 'Askere Al', 'Söylentiler'],
              index: _tab,
              onChanged: (value) => setState(() => _tab = value),
            ),
            Expanded(
              child: switch (_tab) {
                1 => _buildRecruit(),
                2 => _buildRumors(),
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
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 18, 6),
          child: Row(
            children: [
              Expanded(child: Text('ÜRÜN', style: AppTextStyles.meta)),
              SizedBox(
                width: 56,
                child: Text('FİYAT',
                    textAlign: TextAlign.right, style: AppTextStyles.meta),
              ),
              SizedBox(
                width: 46,
                child: Text('MEVCUT',
                    textAlign: TextAlign.right, style: AppTextStyles.meta),
              ),
              SizedBox(width: 46),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(right: 12, left: 4, bottom: 8),
            children: [
              for (final good in MarketGoods.all) _BuyRow(good: good),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecruit() {
    final controller = GameScope.of(context);
    final state = controller.state;
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 18, 6),
          child: Row(
            children: [
              Expanded(child: Text('BİRİM', style: AppTextStyles.meta)),
              SizedBox(
                width: 64,
                child: Text('MALİYET',
                    textAlign: TextAlign.right, style: AppTextStyles.meta),
              ),
              SizedBox(
                width: 48,
                child: Text('MEVCUT',
                    textAlign: TextAlign.right, style: AppTextStyles.meta),
              ),
              SizedBox(width: 46),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(right: 12, left: 8, bottom: 8),
            children: [
              for (final unit in UnitTypes.all)
                OrnatePanel(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Image.asset(
                        _unitIcon(unit.id),
                        width: 30,
                        height: 30,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(width: 30),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          unit.name,
                          style:
                              AppTextStyles.bodyStrong.copyWith(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 64,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(GameAssets.iconCoinGold,
                                    width: 12, height: 12),
                                const SizedBox(width: 2),
                                Text('${unit.goldCost}',
                                    style: AppTextStyles.value
                                        .copyWith(fontSize: 12)),
                              ],
                            ),
                            if (unit.requiresHorse)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(GameAssets.iconItemHorse,
                                      width: 12, height: 12),
                                  const SizedBox(width: 2),
                                  Text('1',
                                      style: AppTextStyles.meta
                                          .copyWith(fontSize: 11)),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(
                          '${state.unitCount(unit.id)}',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.meta,
                        ),
                      ),
                      const SizedBox(width: 6),
                      DarkButton(
                        label: 'AL',
                        height: 30,
                        onPressed: () {
                          final done = controller.recruitUnit(unit.id, 1);
                          AudioService.instance
                              .playSfx(done ? 'coin' : 'denied');
                          _notify(
                            context,
                            done
                                ? '${unit.name} saflarına katıldı.'
                                : 'Altın, at ya da aksiyon yetersiz.',
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRumors() {
    final state = GameScope.of(context).state;
    final rumors = state.log.reversed.take(12).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
      children: [
        OrnatePanel(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  GameAssets.portraitMerchant,
                  width: 64,
                  height: 80,
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
                    Text('Tüccarın Kulağı', style: AppTextStyles.bodyStrong),
                    SizedBox(height: 4),
                    Text(
                      'Hana gelen kervanlar bozkırın haberlerini taşır.',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (rumors.isEmpty)
          const OrnatePanel(
            margin: EdgeInsets.zero,
            child: Text(
              'Henüz söylenti yok. Bozkır şimdilik sessiz.',
              style: AppTextStyles.meta,
            ),
          )
        else
          for (final line in rumors)
            OrnatePanel(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.campaign,
                      size: 16, color: AppColors.goldBright),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line,
                      style: AppTextStyles.body.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  String _unitIcon(String id) => switch (id) {
        'horse_archer' => GameAssets.iconItemBow,
        'foot_sword' || 'horse_sword' => GameAssets.iconItemSword,
        'spear' => GameAssets.iconShieldSwords,
        _ => GameAssets.iconMedallionHorse,
      };

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

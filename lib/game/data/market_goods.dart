import '../models/resource.dart';

class MarketGood {
  const MarketGood({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.baseStock,
    required this.category,
    this.grants,
    this.amount = 0,
    this.grantsItem,
  });

  final String id;
  final String name;
  final int basePrice;
  final int baseStock;

  /// Index into the market category sidebar.
  final int category;

  /// Resource added per purchase; null goods are not tradable yet.
  final ResourceType? grants;
  final int amount;

  /// Crafted-item recipe id granted per purchase (finished gear sold ready).
  final String? grantsItem;
}

class MarketGoods {
  const MarketGoods._();

  static const all = <MarketGood>[
    MarketGood(
      id: 'wheat',
      name: 'Buğday',
      basePrice: 18,
      baseStock: 12,
      category: 2,
      grants: ResourceType.food,
      amount: 10,
    ),
    MarketGood(
      id: 'wood',
      name: 'Odun',
      basePrice: 16,
      baseStock: 10,
      category: 1,
      grants: ResourceType.wood,
      amount: 10,
    ),
    MarketGood(
      id: 'iron_ore',
      name: 'Demir Cevheri',
      basePrice: 35,
      baseStock: 6,
      category: 1,
    ),
    MarketGood(
      id: 'leather',
      name: 'Deri',
      basePrice: 22,
      baseStock: 8,
      category: 3,
      grants: ResourceType.leather,
      amount: 5,
    ),
    MarketGood(
      id: 'wool',
      name: 'Yün',
      basePrice: 24,
      baseStock: 6,
      category: 3,
    ),
    MarketGood(
      id: 'salt',
      name: 'Tuz',
      basePrice: 30,
      baseStock: 5,
      category: 2,
      grants: ResourceType.food,
      amount: 6,
    ),
    MarketGood(
      id: 'horse',
      name: 'At',
      basePrice: 120,
      baseStock: 3,
      category: 5,
      grants: ResourceType.horse,
      amount: 1,
    ),
    MarketGood(
      id: 'bow',
      name: 'Kompozit Yay',
      basePrice: 240,
      baseStock: 2,
      category: 4,
      grantsItem: 'composite_bow',
    ),
    MarketGood(
      id: 'm_sword',
      name: 'Demir Kılıç',
      basePrice: 200,
      baseStock: 2,
      category: 4,
      grantsItem: 'iron_sword',
    ),
    MarketGood(
      id: 'm_shield',
      name: 'Ahşap Kalkan',
      basePrice: 90,
      baseStock: 3,
      category: 4,
      grantsItem: 'wood_shield',
    ),
    MarketGood(
      id: 'm_armor',
      name: 'Deri Zırh',
      basePrice: 160,
      baseStock: 2,
      category: 4,
      grantsItem: 'leather_armor',
    ),
  ];

  static MarketGood? byId(String id) {
    for (final good in all) {
      if (good.id == id) {
        return good;
      }
    }
    return null;
  }

  static Map<String, int> startingStock() =>
      {for (final good in all) good.id: good.baseStock};
}

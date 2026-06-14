import '../models/resource.dart';

/// A role a sworn follower can take in the oba. Each grants a small but real
/// mechanical bonus, assigned during the founding rite and shown in the oba's
/// "Yandaş Bonusları" panel.
class CompanionRole {
  const CompanionRole({
    required this.id,
    required this.name,
    required this.effect,
    this.warPercent = 0,
    this.goldPerDay = 0,
    this.foodPerDay = 0,
    this.moralePerDay = 0,
    this.marketDiscountPercent = 0,
    this.craftDiscountPercent = 0,
    this.calmsOmens = false,
  });

  final String id;
  final String name;

  /// Short, player-facing description of the bonus.
  final String effect;

  /// Percent added to war/expedition strength.
  final int warPercent;

  /// Extra daily treasury income.
  final int goldPerDay;

  /// Extra daily food brought in.
  final int foodPerDay;

  /// Extra daily morale.
  final int moralePerDay;

  /// Percent shaved off market prices.
  final int marketDiscountPercent;

  /// Percent shaved off workshop costs.
  final int craftDiscountPercent;

  /// Whether the role steadies the camp against bad omens.
  final bool calmsOmens;
}

class CompanionRoles {
  const CompanionRoles._();

  static const warleader = CompanionRole(
    id: 'warleader',
    name: 'Savaşçı Başı',
    effect: 'Sefer ve savaş gücü +%10',
    warPercent: 10,
  );
  static const hearthMother = CompanionRole(
    id: 'hearth_mother',
    name: 'Ocak Anası',
    effect: 'Her gün moral +2',
    moralePerDay: 2,
  );
  static const kam = CompanionRole(
    id: 'kam',
    name: 'Kam',
    effect: 'Kötü alamet riskini yatıştırır',
    calmsOmens: true,
  );
  static const merchant = CompanionRole(
    id: 'merchant',
    name: 'Tüccar',
    effect: 'Pazar fiyatları -%15, günlük +6 altın',
    goldPerDay: 6,
    marketDiscountPercent: 15,
  );
  static const hunter = CompanionRole(
    id: 'hunter',
    name: 'Avcı Başı',
    effect: 'Her gün erzak +5',
    foodPerDay: 5,
  );
  static const artisan = CompanionRole(
    id: 'artisan',
    name: 'Zanaatkâr',
    effect: 'Üretim maliyeti -%20',
    craftDiscountPercent: 20,
  );

  static const all = <CompanionRole>[
    warleader,
    hearthMother,
    kam,
    merchant,
    hunter,
    artisan,
  ];

  static CompanionRole? byId(String id) {
    for (final r in all) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Role ids keyed for the founding-rite chips, in display order.
  static List<String> get ids => [for (final r in all) r.id];

  /// Daily resource bonus for a set of assigned roles.
  static Map<ResourceType, int> dailyBonus(Iterable<String> roleIds) {
    var gold = 0;
    var food = 0;
    var morale = 0;
    for (final id in roleIds) {
      final r = byId(id);
      if (r == null) continue;
      gold += r.goldPerDay;
      food += r.foodPerDay;
      morale += r.moralePerDay;
    }
    return {
      if (gold > 0) ResourceType.gold: gold,
      if (food > 0) ResourceType.food: food,
      if (morale > 0) ResourceType.morale: morale,
    };
  }
}

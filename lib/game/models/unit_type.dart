import 'resource.dart';

/// A kind of soldier the oba can raise. Strength in war is the sum of the
/// army's attack; defence softens casualties.
class UnitType {
  const UnitType({
    required this.id,
    required this.name,
    required this.attack,
    required this.defense,
    required this.goldCost,
    required this.requiresHorse,
  });

  final String id;
  final String name;
  final int attack;
  final int defense;
  final int goldCost;
  final bool requiresHorse;
}

class UnitTypes {
  const UnitTypes._();

  static const all = <UnitType>[
    UnitType(
      id: 'scout',
      name: 'İzci',
      attack: 2,
      defense: 2,
      goldCost: 30,
      requiresHorse: true,
    ),
    UnitType(
      id: 'foot_sword',
      name: 'Kılıçlı Piyade',
      attack: 6,
      defense: 5,
      goldCost: 50,
      requiresHorse: false,
    ),
    UnitType(
      id: 'spear',
      name: 'Mızraklı Piyade',
      attack: 5,
      defense: 8,
      goldCost: 55,
      requiresHorse: false,
    ),
    UnitType(
      id: 'horse_archer',
      name: 'Atlı Okçu',
      attack: 8,
      defense: 4,
      goldCost: 90,
      requiresHorse: true,
    ),
    UnitType(
      id: 'horse_sword',
      name: 'Atlı Kılıçlı',
      attack: 9,
      defense: 6,
      goldCost: 110,
      requiresHorse: true,
    ),
    UnitType(
      id: 'heavy_cav',
      name: 'Ağır Süvari',
      attack: 12,
      defense: 10,
      goldCost: 160,
      requiresHorse: true,
    ),
  ];

  static UnitType? byId(String id) {
    for (final u in all) {
      if (u.id == id) return u;
    }
    return null;
  }

  /// Resource cost to raise [qty] of a unit.
  static Map<ResourceType, int> recruitCost(UnitType unit, int qty) => {
    ResourceType.gold: unit.goldCost * qty,
    if (unit.requiresHorse) ResourceType.horse: qty,
  };
}

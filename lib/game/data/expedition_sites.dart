import '../models/expedition.dart';
import '../models/resource.dart';

/// Ordered conquest chain; a site unlocks once the previous one is taken.
class ExpeditionSites {
  const ExpeditionSites._();

  static const all = <ExpeditionSite>[
    ExpeditionSite(
      id: 'border_outpost',
      name: 'Sınır Karakolu',
      dangerLabel: 'Kolay',
      baseChance: 80,
      gains: {
        ResourceType.gold: 30,
        ResourceType.reputation: 2,
        ResourceType.food: -4,
      },
      losses: {ResourceType.morale: -3, ResourceType.food: -6},
    ),
    ExpeditionSite(
      id: 'steppe_pass',
      name: 'Bozkır Geçidi',
      dangerLabel: 'Orta',
      baseChance: 65,
      gains: {
        ResourceType.gold: 50,
        ResourceType.reputation: 3,
        ResourceType.leather: 4,
        ResourceType.food: -8,
      },
      losses: {
        ResourceType.morale: -4,
        ResourceType.food: -10,
        ResourceType.horse: -1,
      },
    ),
    ExpeditionSite(
      id: 'yesit_fort',
      name: 'Yeşit Kalesi',
      dangerLabel: 'Tehlikeli',
      baseChance: 45,
      gains: {
        ResourceType.gold: 90,
        ResourceType.reputation: 5,
        ResourceType.food: -12,
      },
      losses: {
        ResourceType.morale: -6,
        ResourceType.food: -14,
        ResourceType.horse: -1,
      },
    ),
    ExpeditionSite(
      id: 'chin_border',
      name: 'Çin Hududu',
      dangerLabel: 'Ölümcül',
      baseChance: 30,
      gains: {
        ResourceType.gold: 160,
        ResourceType.reputation: 8,
        ResourceType.food: -16,
      },
      losses: {
        ResourceType.morale: -8,
        ResourceType.food: -18,
        ResourceType.horse: -2,
      },
    ),
  ];

  static ExpeditionSite? byId(String id) {
    for (final site in all) {
      if (site.id == id) {
        return site;
      }
    }
    return null;
  }
}

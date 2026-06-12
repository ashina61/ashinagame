import '../models/craft.dart';
import '../models/resource.dart';

class CraftRecipes {
  const CraftRecipes._();

  static const maxQueue = 2;

  static const all = <CraftRecipe>[
    CraftRecipe(
      id: 'wood_shield',
      name: 'Ahşap Kalkan',
      kind: CraftKind.equipment,
      costs: {ResourceType.wood: 12},
      days: 1,
      successBonus: 5,
    ),
    CraftRecipe(
      id: 'composite_bow',
      name: 'Kompozit Yay',
      kind: CraftKind.equipment,
      costs: {ResourceType.wood: 8, ResourceType.leather: 6},
      days: 2,
      successBonus: 8,
    ),
    CraftRecipe(
      id: 'leather_armor',
      name: 'Deri Zırh',
      kind: CraftKind.equipment,
      costs: {ResourceType.leather: 12},
      days: 2,
      successBonus: 6,
    ),
    CraftRecipe(
      id: 'iron_sword',
      name: 'Demir Kılıç',
      kind: CraftKind.equipment,
      costs: {ResourceType.gold: 40, ResourceType.wood: 4},
      days: 3,
      successBonus: 8,
    ),
    CraftRecipe(
      id: 'saddle',
      name: 'Ata Koşum',
      kind: CraftKind.other,
      costs: {ResourceType.leather: 10, ResourceType.wood: 4},
      days: 2,
      successBonus: 4,
    ),
    CraftRecipe(
      id: 'fur_cloak',
      name: 'Kürk Pelerin',
      kind: CraftKind.other,
      costs: {ResourceType.leather: 8, ResourceType.gold: 10},
      days: 1,
      successBonus: 3,
    ),
  ];

  static CraftRecipe? byId(String id) {
    for (final recipe in all) {
      if (recipe.id == id) {
        return recipe;
      }
    }
    return null;
  }
}

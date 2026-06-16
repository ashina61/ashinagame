/// Equipment slots the leader can fill with crafted gear. Each slot accepts
/// certain workshop recipes; an equipped piece lends its expedition bonus.
class EquipSlot {
  const EquipSlot({
    required this.id,
    required this.name,
    required this.recipeIds,
  });

  final String id;
  final String name;
  final List<String> recipeIds;
}

class EquipmentData {
  const EquipmentData._();

  static const slots = <EquipSlot>[
    EquipSlot(
      id: 'weapon',
      name: 'Silah',
      recipeIds: ['iron_sword', 'composite_bow'],
    ),
    EquipSlot(id: 'armor', name: 'Zırh', recipeIds: ['leather_armor']),
    EquipSlot(id: 'shield', name: 'Kalkan', recipeIds: ['wood_shield']),
    EquipSlot(id: 'mount', name: 'Koşum', recipeIds: ['saddle']),
    EquipSlot(id: 'cloak', name: 'Pelerin', recipeIds: ['fur_cloak']),
  ];

  /// The slot a recipe can be equipped into, or null if it is not gear.
  static EquipSlot? slotForRecipe(String recipeId) {
    for (final slot in slots) {
      if (slot.recipeIds.contains(recipeId)) return slot;
    }
    return null;
  }
}

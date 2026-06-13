/// A region on the conquest map, held by an NPC bey until you ally with or
/// conquer it. The steppe is unified once every region is yours.
class ConquestRegion {
  const ConquestRegion({
    required this.id,
    required this.name,
    required this.holder,
    required this.power,
    required this.baseRelation,
    required this.rewardGold,
    required this.rewardReputation,
  });

  final String id;
  final String name;

  /// Name of the NPC bey currently holding the region.
  final String holder;

  /// Garrison strength; war success is weighed against this.
  final int power;

  /// Starting diplomatic relation (0–100).
  final int baseRelation;

  /// Spoils granted when the region becomes yours.
  final int rewardGold;
  final int rewardReputation;
}

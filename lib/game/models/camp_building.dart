import 'resource.dart';

class CampBuilding {
  const CampBuilding({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.maxLevel,
    required this.category,
    required this.upgradeCost,
    required this.effectDescription,
    this.production = const {},
    this.buildDays = 2,
    this.storagePerLevel = 0,
    this.isUnlocked = true,
  });

  final String id;
  final String name;
  final String description;
  final int level;
  final int maxLevel;
  final String category;
  final Map<ResourceType, int> upgradeCost;
  final String effectDescription;

  /// Resources this building yields per day, per level. The daily tick adds
  /// [production] × [level] to the granary (up to storage capacity).
  final Map<ResourceType, int> production;

  /// Days an upgrade spends in the build queue before it takes effect.
  final int buildDays;

  /// Extra storage capacity each level grants (a warehouse raises the cap).
  final int storagePerLevel;

  final bool isUnlocked;

  bool get canUpgrade => isUnlocked && level < maxLevel;

  /// What this building produces per day at its current level.
  Map<ResourceType, int> get dailyYield => {
        for (final e in production.entries) e.key: e.value * level,
      };

  CampBuilding copyWith({int? level}) => CampBuilding(
        id: id,
        name: name,
        description: description,
        level: level ?? this.level,
        maxLevel: maxLevel,
        category: category,
        upgradeCost: upgradeCost,
        effectDescription: effectDescription,
        production: production,
        buildDays: buildDays,
        storagePerLevel: storagePerLevel,
        isUnlocked: isUnlocked,
      );
}

/// One queued building upgrade, counting down to completion on each day tick —
/// the same shape as a workshop [CraftJob], so construction reads as a timed
/// queue rather than an instant level-up.
class BuildJob {
  const BuildJob({required this.buildingId, required this.daysLeft});

  final String buildingId;
  final int daysLeft;

  BuildJob tick() => BuildJob(buildingId: buildingId, daysLeft: daysLeft - 1);
}

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
  final bool isUnlocked;

  bool get canUpgrade => isUnlocked && level < maxLevel;

  CampBuilding copyWith({int? level}) => CampBuilding(
    id: id,
    name: name,
    description: description,
    level: level ?? this.level,
    maxLevel: maxLevel,
    category: category,
    upgradeCost: upgradeCost,
    effectDescription: effectDescription,
    isUnlocked: isUnlocked,
  );
}

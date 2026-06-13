class PlayerProfile {
  const PlayerProfile({
    required this.name,
    required this.title,
    required this.age,
    this.level = 1,
    this.xp = 0,
    this.xpToNextLevel = 100,
    this.skillPoints = 0,
    this.health = 100,
    this.energy = 100,
    this.fatigue = 0,
    this.reputation = 10,
    required this.courage,
    required this.wisdom,
    required this.leadership,
    required this.endurance,
    this.trade = 4,
    this.craft = 4,
    this.archery = 5,
    this.warfare = 5,
    this.familyStatus = 'Bekâr hane',
    this.marriageStatus = 'Bekâr',
  });

  final String name;
  final String title;
  final int age;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int skillPoints;
  final int health;
  final int energy;
  final int fatigue;
  final int reputation;
  final int courage;
  final int wisdom;
  final int leadership;
  final int endurance;
  final int trade;
  final int craft;
  final int archery;
  final int warfare;
  final String familyStatus;
  final String marriageStatus;

  PlayerProfile copyWith({
    String? name,
    String? title,
    int? age,
    int? level,
    int? xp,
    int? xpToNextLevel,
    int? skillPoints,
    int? health,
    int? energy,
    int? fatigue,
    int? reputation,
    int? courage,
    int? wisdom,
    int? leadership,
    int? endurance,
    int? trade,
    int? craft,
    int? archery,
    int? warfare,
    String? familyStatus,
    String? marriageStatus,
  }) {
    return PlayerProfile(
      name: name ?? this.name,
      title: title ?? this.title,
      age: age ?? this.age,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      skillPoints: skillPoints ?? this.skillPoints,
      health: (health ?? this.health).clamp(0, 100).toInt(),
      energy: (energy ?? this.energy).clamp(0, 100).toInt(),
      fatigue: (fatigue ?? this.fatigue).clamp(0, 100).toInt(),
      reputation: (reputation ?? this.reputation).clamp(0, 100).toInt(),
      courage: courage ?? this.courage,
      wisdom: wisdom ?? this.wisdom,
      leadership: leadership ?? this.leadership,
      endurance: endurance ?? this.endurance,
      trade: trade ?? this.trade,
      craft: craft ?? this.craft,
      archery: archery ?? this.archery,
      warfare: warfare ?? this.warfare,
      familyStatus: familyStatus ?? this.familyStatus,
      marriageStatus: marriageStatus ?? this.marriageStatus,
    );
  }
}

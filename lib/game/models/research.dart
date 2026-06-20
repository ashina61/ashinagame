/// A single technology in the academy's research tree. Techs are unlocked by
/// spending accumulated research points once their prerequisites are met —
/// İkariam-style: the academy produces points each day, the player chooses
/// what to invest them in.
class ResearchTech {
  const ResearchTech({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.cost,
    required this.effectDescription,
    this.requires = const [],
  });

  final String id;
  final String name;
  final String description;

  /// Tree column / theme: 'Ekonomi', 'Altyapı', 'Bilim'.
  final String category;

  /// Research points needed to unlock.
  final int cost;

  /// Tech ids that must be researched first.
  final List<String> requires;

  final String effectDescription;
}

/// The passive bonuses unlocked research grants. All of these hook into the
/// village-economy systems (production, storage, build speed, research rate),
/// so the tree can deepen the management loop without touching battle code.
class ResearchBonuses {
  const ResearchBonuses({
    this.foodMult = 1.0,
    this.goldMult = 1.0,
    this.craftMult = 1.0,
    this.horseMult = 1.0,
    this.allMult = 1.0,
    this.storageBonus = 0,
    this.buildDaysReduction = 0,
    this.researchMult = 1.0,
  });

  /// Multiplier on food production (Tarım).
  final double foodMult;

  /// Multiplier on gold production (Ticaret).
  final double goldMult;

  /// Multiplier on workshop output — iron & leather (Demircilik).
  final double craftMult;

  /// Multiplier on horse production (Hayvancılık).
  final double horseMult;

  /// Multiplier on every resource's production (Lonca capstone).
  final double allMult;

  /// Flat extra storage capacity (Taşçılık).
  final int storageBonus;

  /// Days shaved off every upgrade's build time, floored at 1 (Mühendislik).
  final int buildDaysReduction;

  /// Multiplier on daily research output (Üniversite).
  final double researchMult;
}

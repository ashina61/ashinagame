class Household {
  const Household({
    this.spouseName,
    this.spouseBonus = 'Yok',
    this.householdMorale = 50,
    this.childrenCount = 0,
    this.familyPrestige = 0,
  });

  final String? spouseName;
  final String spouseBonus;
  final int householdMorale;
  final int childrenCount;
  final int familyPrestige;

  bool get isMarried => spouseName != null;

  Household copyWith({
    String? spouseName,
    String? spouseBonus,
    int? householdMorale,
    int? childrenCount,
    int? familyPrestige,
  }) =>
      Household(
        spouseName: spouseName ?? this.spouseName,
        spouseBonus: spouseBonus ?? this.spouseBonus,
        householdMorale:
            (householdMorale ?? this.householdMorale).clamp(0, 100).toInt(),
        childrenCount: childrenCount ?? this.childrenCount,
        familyPrestige: familyPrestige ?? this.familyPrestige,
      );
}

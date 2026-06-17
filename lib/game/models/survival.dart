class SurvivalStats {
  const SurvivalStats({
    this.hunger = 80,
    this.thirst = 80,
    this.fatigue = 10,
    this.warmth = 70,
  });

  final int hunger;
  final int thirst;
  final int fatigue;
  final int warmth;

  SurvivalStats copyWith({
    int? hunger,
    int? thirst,
    int? fatigue,
    int? warmth,
  }) => SurvivalStats(
    hunger: (hunger ?? this.hunger).clamp(0, 100).toInt(),
    thirst: (thirst ?? this.thirst).clamp(0, 100).toInt(),
    fatigue: (fatigue ?? this.fatigue).clamp(0, 100).toInt(),
    warmth: (warmth ?? this.warmth).clamp(0, 100).toInt(),
  );

  Map<String, int> toJson() => {
    'hunger': hunger,
    'thirst': thirst,
    'fatigue': fatigue,
    'warmth': warmth,
  };

  static SurvivalStats fromJson(Map<String, dynamic>? json) => SurvivalStats(
    hunger: json?['hunger'] as int? ?? 80,
    thirst: json?['thirst'] as int? ?? 80,
    fatigue: json?['fatigue'] as int? ?? 10,
    warmth: json?['warmth'] as int? ?? 70,
  );
}

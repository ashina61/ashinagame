import 'resource.dart';

class FaithState {
  const FaithState({
    this.faith = 60,
    this.kut = 45,
    this.tore = 70,
    this.ancestorHonor = 55,
    this.omen = 'Alamet yok',
    this.omenSeverity = OmenSeverity.neutral,
    this.lastRitualDay = -99,
    this.ritualCooldownDays = 3,
    this.activeBlessings = const [],
    this.activeWarnings = const [],
    this.visitedSacredPlaces = const {},
  });

  final int faith;
  final int kut;
  final int tore;
  final int ancestorHonor;
  final String omen;
  final OmenSeverity omenSeverity;
  final int lastRitualDay;
  final int ritualCooldownDays;
  final List<String> activeBlessings;
  final List<String> activeWarnings;
  final Map<String, int> visitedSacredPlaces;

  bool get hasOmen => omen != 'Alamet yok';
  bool get hasBadOmen => omenSeverity == OmenSeverity.bad;

  FaithState copyWith({
    int? faith,
    int? kut,
    int? tore,
    int? ancestorHonor,
    String? omen,
    OmenSeverity? omenSeverity,
    int? lastRitualDay,
    int? ritualCooldownDays,
    List<String>? activeBlessings,
    List<String>? activeWarnings,
    Map<String, int>? visitedSacredPlaces,
  }) {
    return FaithState(
      faith: (faith ?? this.faith).clamp(0, 100).toInt(),
      kut: (kut ?? this.kut).clamp(0, 100).toInt(),
      tore: (tore ?? this.tore).clamp(0, 100).toInt(),
      ancestorHonor: (ancestorHonor ?? this.ancestorHonor)
          .clamp(0, 100)
          .toInt(),
      omen: omen ?? this.omen,
      omenSeverity: omenSeverity ?? this.omenSeverity,
      lastRitualDay: lastRitualDay ?? this.lastRitualDay,
      ritualCooldownDays: ritualCooldownDays ?? this.ritualCooldownDays,
      activeBlessings: activeBlessings ?? this.activeBlessings,
      activeWarnings: activeWarnings ?? this.activeWarnings,
      visitedSacredPlaces: visitedSacredPlaces ?? this.visitedSacredPlaces,
    );
  }

  FaithState apply(Map<String, int> effects) => copyWith(
    faith: faith + (effects['faith'] ?? 0),
    kut: kut + (effects['kut'] ?? 0),
    tore: tore + (effects['tore'] ?? 0),
    ancestorHonor: ancestorHonor + (effects['ancestorHonor'] ?? 0),
  );
}

enum OmenSeverity { good, neutral, bad }

class SpiritualAdvisor {
  const SpiritualAdvisor({
    required this.id,
    required this.name,
    required this.role,
    required this.level,
    required this.effect,
    required this.cooldownDays,
    required this.description,
    this.lastConsultDay = -99,
  });

  final String id;
  final String name;
  final String role;
  final int level;
  final String effect;
  final int cooldownDays;
  final String description;
  final int lastConsultDay;

  SpiritualAdvisor copyWith({int? level, int? lastConsultDay}) =>
      SpiritualAdvisor(
        id: id,
        name: name,
        role: role,
        level: level ?? this.level,
        effect: effect,
        cooldownDays: cooldownDays,
        description: description,
        lastConsultDay: lastConsultDay ?? this.lastConsultDay,
      );
}

class Ritual {
  const Ritual({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.cooldownDays,
    required this.faithEffects,
    required this.effectDescription,
    this.resourceEffects = const {},
    this.statEffects = const {},
    this.energyEffect = 0,
    this.healthEffect = 0,
    this.actionCost = 1,
    this.bonusDurationDays = 3,
    this.seasonHint,
  });

  final String id;
  final String name;
  final String description;
  final Map<ResourceType, int> cost;
  final int cooldownDays;
  final Map<String, int> faithEffects;
  final Map<ResourceType, int> resourceEffects;
  final Map<String, int> statEffects;
  final int energyEffect;
  final int healthEffect;
  final int actionCost;
  final int bonusDurationDays;
  final String effectDescription;
  final String? seasonHint;
}

class SacredPlace {
  const SacredPlace({
    required this.id,
    required this.name,
    required this.description,
    required this.risk,
    required this.reward,
    required this.faithEffects,
    this.resourceEffects = const {},
    this.xpReward = 12,
    this.energyCost = 8,
    this.visitCooldownDays = 4,
    this.isUnlocked = true,
  });

  final String id;
  final String name;
  final String description;
  final String risk;
  final String reward;
  final Map<String, int> faithEffects;
  final Map<ResourceType, int> resourceEffects;
  final int xpReward;
  final int energyCost;
  final int visitCooldownDays;
  final bool isUnlocked;
}

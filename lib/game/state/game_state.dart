import '../models/achievement.dart';
import '../models/camp_building.dart';
import '../models/clan.dart';
import '../models/craft.dart';
import '../models/event_choice.dart';
import '../models/faith.dart';
import '../models/game_day.dart';
import '../models/household.dart';
import '../models/marriage_candidate.dart';
import '../models/player_profile.dart';
import '../models/quest.dart';
import '../models/resource.dart';
import '../models/tribe_relation.dart';

class GameState {
  const GameState({
    required this.profile,
    required this.clan,
    required this.day,
    required this.resources,
    required this.quests,
    required this.currentEvent,
    required this.eventIndex,
    required this.log,
    this.dailyActionPoints = baseDailyActionPoints,
    this.maxDailyActionPoints = baseDailyActionPoints,
    this.energy = baseDailyActionPoints,
    this.collapseDays = 0,
    this.gameOver = false,
    this.gameOverReason,
    this.craftQueue = const [],
    this.craftedItems = const {},
    this.completedExpeditions = const [],
    this.marketStock = const {},
    this.buildings = const [],
    this.tribes = const [],
    this.household = const Household(),
    this.marriageCandidates = const [],
    this.faithState = const FaithState(),
    this.spiritualAdvisor = const SpiritualAdvisor(
      id: 'aruk_kam',
      name: 'Aruk Kam',
      role: 'Kam',
      level: 1,
      effect: 'Alametleri yorumlar, kötü olay riskini azaltır.',
      cooldownDays: 1,
      description:
          'Gök, ateş ve rüzgâr işaretlerini obaya sade bir dille açıklar.',
    ),
    this.rituals = const [],
    this.sacredPlaces = const [],
    this.ritualCooldowns = const {},
    this.generation = 1,
    this.pendingSuccession = false,
    this.leaderLifespan = 64,
    this.claimedAchievements = const [],
    this.faithPath = '',
    this.tamga = 'wolf',
    this.khanateStanding = 20,
    this.isKhan = false,
    this.vassalObas = 0,
    this.equipped = const {},
    this.regionRelations = const {},
    this.conqueredRegions = const [],
    this.onboarded = false,
    this.peopleApproval = 60,
    this.councilApproval = 60,
    this.currentKurultay,
    this.lastKurultayDay = 0,
    this.army = const {},
    this.wounded = const {},
  });

  static const baseDailyActionPoints = 4;
  static const maxEnergy = baseDailyActionPoints;

  final PlayerProfile profile;
  final Clan clan;
  final GameDay day;
  final Map<ResourceType, int> resources;
  final List<Quest> quests;
  final GameEvent? currentEvent;
  final int eventIndex;
  final List<String> log;
  final int dailyActionPoints;
  final int maxDailyActionPoints;

  /// Legacy AP alias kept for older screens/tests during the systems upgrade.
  final int energy;

  final int collapseDays;
  final bool gameOver;
  final String? gameOverReason;
  final List<CraftJob> craftQueue;
  final Map<String, int> craftedItems;
  final List<String> completedExpeditions;
  final Map<String, int> marketStock;
  final List<CampBuilding> buildings;
  final List<TribeRelation> tribes;
  final Household household;
  final List<MarriageCandidate> marriageCandidates;
  final FaithState faithState;
  final SpiritualAdvisor spiritualAdvisor;
  final List<Ritual> rituals;
  final List<SacredPlace> sacredPlaces;
  final Map<String, int> ritualCooldowns;

  /// How many leaders have ruled this clan, the founder counted as one.
  final int generation;

  /// True once the leader has died of old age and an heir awaits the seat.
  final bool pendingSuccession;

  /// Age at which the current leader dies of old age.
  final int leaderLifespan;

  /// Ids of achievements whose reward has been collected.
  final List<String> claimedAchievements;

  /// Chosen belief path id, empty until the leader commits to one.
  final String faithPath;

  /// Seal/banner id marking the oba (see [Tamgas]).
  final String tamga;

  /// Standing within the khanate the oba is bound to (0–100).
  final int khanateStanding;

  /// True once the leader has overthrown the khan and taken the throne.
  final bool isKhan;

  /// Number of nearby obas rallied under this banner.
  final int vassalObas;

  /// Equipped gear keyed by slot id (see [EquipmentData]); value is recipe id.
  final Map<String, String> equipped;

  /// Per-region diplomatic relation overrides (id → relation).
  final Map<String, int> regionRelations;

  /// Ids of conquest regions now under your banner.
  final List<String> conqueredRegions;

  /// False until the player has named the oba and seen the opening.
  final bool onboarded;

  /// Approval of the common folk and of the council beys (0–100).
  final int peopleApproval;
  final int councilApproval;

  /// Id of the kurultay decision awaiting a verdict, or null when none.
  final String? currentKurultay;

  /// Day the last council convened, to space them out.
  final int lastKurultayDay;

  /// Battle-ready soldiers and those recovering from wounds, by unit id.
  final Map<String, int> army;
  final Map<String, int> wounded;

  int resource(ResourceType type) => resources[type] ?? 0;

  int unitCount(String id) => army[id] ?? 0;
  int woundedCount(String id) => wounded[id] ?? 0;
  int get totalSoldiers => army.values.fold(0, (s, n) => s + n);
  int get totalWounded => wounded.values.fold(0, (s, n) => s + n);

  String? equippedIn(String slotId) => equipped[slotId];

  bool regionConquered(String id) => conqueredRegions.contains(id);

  bool achievementClaimed(String id) => claimedAchievements.contains(id);

  /// The live figure an achievement measures.
  int achievementProgress(Achievement achievement) =>
      switch (achievement.metric) {
        AchievementMetric.population => resource(ResourceType.population),
        AchievementMetric.gold => resource(ResourceType.gold),
        AchievementMetric.conquered => completedExpeditions.length,
        AchievementMetric.crafted =>
          craftedItems.values.fold(0, (sum, n) => sum + n),
        AchievementMetric.generation => generation,
        AchievementMetric.reputation => profile.reputation,
        AchievementMetric.daysSurvived => day.day,
      };

  bool achievementReady(Achievement achievement) =>
      !achievementClaimed(achievement.id) &&
      achievementProgress(achievement) >= achievement.target;
  int craftedCount(String recipeId) => craftedItems[recipeId] ?? 0;
  int stockOf(String goodId) => marketStock[goodId] ?? 0;
  bool expeditionDone(String siteId) => completedExpeditions.contains(siteId);
  CampBuilding? building(String id) {
    for (final b in buildings) {
      if (b.id == id) return b;
    }
    return null;
  }

  TribeRelation? tribeByName(String name) {
    for (final tribe in tribes) {
      if (tribe.name == name) return tribe;
    }
    return null;
  }

  int questProgress(Quest quest) => switch (quest.goalType) {
        QuestGoalType.action => quest.progress,
        QuestGoalType.resource => resource(quest.goalResource!),
      };

  bool questReady(Quest quest) =>
      !quest.completed && questProgress(quest) >= quest.goalTarget;

  GameState copyWith({
    PlayerProfile? profile,
    Clan? clan,
    GameDay? day,
    Map<ResourceType, int>? resources,
    List<Quest>? quests,
    GameEvent? currentEvent,
    bool clearEvent = false,
    int? eventIndex,
    List<String>? log,
    int? dailyActionPoints,
    int? maxDailyActionPoints,
    int? energy,
    int? collapseDays,
    bool? gameOver,
    String? gameOverReason,
    List<CraftJob>? craftQueue,
    Map<String, int>? craftedItems,
    List<String>? completedExpeditions,
    Map<String, int>? marketStock,
    List<CampBuilding>? buildings,
    List<TribeRelation>? tribes,
    Household? household,
    List<MarriageCandidate>? marriageCandidates,
    FaithState? faithState,
    SpiritualAdvisor? spiritualAdvisor,
    List<Ritual>? rituals,
    List<SacredPlace>? sacredPlaces,
    Map<String, int>? ritualCooldowns,
    int? generation,
    bool? pendingSuccession,
    int? leaderLifespan,
    List<String>? claimedAchievements,
    String? faithPath,
    String? tamga,
    int? khanateStanding,
    bool? isKhan,
    int? vassalObas,
    Map<String, String>? equipped,
    Map<String, int>? regionRelations,
    List<String>? conqueredRegions,
    bool? onboarded,
    int? peopleApproval,
    int? councilApproval,
    String? currentKurultay,
    bool clearKurultay = false,
    int? lastKurultayDay,
    Map<String, int>? army,
    Map<String, int>? wounded,
  }) {
    final nextMax = maxDailyActionPoints ?? this.maxDailyActionPoints;
    final nextAp = (dailyActionPoints ?? energy ?? this.dailyActionPoints)
        .clamp(0, nextMax)
        .toInt();
    return GameState(
      profile: profile ?? this.profile,
      clan: clan ?? this.clan,
      day: day ?? this.day,
      resources: resources ?? this.resources,
      quests: quests ?? this.quests,
      currentEvent: clearEvent ? null : currentEvent ?? this.currentEvent,
      eventIndex: eventIndex ?? this.eventIndex,
      log: log ?? this.log,
      dailyActionPoints: nextAp,
      maxDailyActionPoints: nextMax,
      energy: nextAp,
      collapseDays: collapseDays ?? this.collapseDays,
      gameOver: gameOver ?? this.gameOver,
      gameOverReason: gameOverReason ?? this.gameOverReason,
      craftQueue: craftQueue ?? this.craftQueue,
      craftedItems: craftedItems ?? this.craftedItems,
      completedExpeditions: completedExpeditions ?? this.completedExpeditions,
      marketStock: marketStock ?? this.marketStock,
      buildings: buildings ?? this.buildings,
      tribes: tribes ?? this.tribes,
      household: household ?? this.household,
      marriageCandidates: marriageCandidates ?? this.marriageCandidates,
      faithState: faithState ?? this.faithState,
      spiritualAdvisor: spiritualAdvisor ?? this.spiritualAdvisor,
      rituals: rituals ?? this.rituals,
      sacredPlaces: sacredPlaces ?? this.sacredPlaces,
      ritualCooldowns: ritualCooldowns ?? this.ritualCooldowns,
      generation: generation ?? this.generation,
      pendingSuccession: pendingSuccession ?? this.pendingSuccession,
      leaderLifespan: leaderLifespan ?? this.leaderLifespan,
      claimedAchievements: claimedAchievements ?? this.claimedAchievements,
      faithPath: faithPath ?? this.faithPath,
      tamga: tamga ?? this.tamga,
      khanateStanding:
          (khanateStanding ?? this.khanateStanding).clamp(0, 100).toInt(),
      isKhan: isKhan ?? this.isKhan,
      vassalObas: vassalObas ?? this.vassalObas,
      equipped: equipped ?? this.equipped,
      regionRelations: regionRelations ?? this.regionRelations,
      conqueredRegions: conqueredRegions ?? this.conqueredRegions,
      onboarded: onboarded ?? this.onboarded,
      peopleApproval:
          (peopleApproval ?? this.peopleApproval).clamp(0, 100).toInt(),
      councilApproval:
          (councilApproval ?? this.councilApproval).clamp(0, 100).toInt(),
      currentKurultay:
          clearKurultay ? null : currentKurultay ?? this.currentKurultay,
      lastKurultayDay: lastKurultayDay ?? this.lastKurultayDay,
      army: army ?? this.army,
      wounded: wounded ?? this.wounded,
    );
  }
}

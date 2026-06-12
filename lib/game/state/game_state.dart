import '../models/clan.dart';
import '../models/craft.dart';
import '../models/event_choice.dart';
import '../models/game_day.dart';
import '../models/player_profile.dart';
import '../models/quest.dart';
import '../models/resource.dart';

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
    this.energy = maxEnergy,
    this.collapseDays = 0,
    this.gameOver = false,
    this.gameOverReason,
    this.craftQueue = const [],
    this.craftedItems = const {},
    this.completedExpeditions = const [],
    this.marketStock = const {},
  });

  static const maxEnergy = 10;

  final PlayerProfile profile;
  final Clan clan;
  final GameDay day;
  final Map<ResourceType, int> resources;
  final List<Quest> quests;
  final GameEvent? currentEvent;
  final int eventIndex;
  final List<String> log;

  /// Action points left for the current day.
  final int energy;

  /// Consecutive days the camp spent at zero morale.
  final int collapseDays;
  final bool gameOver;
  final String? gameOverReason;

  /// Workshop jobs currently in production.
  final List<CraftJob> craftQueue;

  /// Finished workshop items by recipe id.
  final Map<String, int> craftedItems;

  /// Conquered expedition site ids, in order.
  final List<String> completedExpeditions;

  /// Remaining market stock by good id; restocked daily.
  final Map<String, int> marketStock;

  int resource(ResourceType type) => resources[type] ?? 0;

  int craftedCount(String recipeId) => craftedItems[recipeId] ?? 0;

  int stockOf(String goodId) => marketStock[goodId] ?? 0;

  bool expeditionDone(String siteId) => completedExpeditions.contains(siteId);

  /// Live progress of a quest (resource goals read the stockpile).
  int questProgress(Quest quest) => switch (quest.goalType) {
        QuestGoalType.action => quest.progress,
        QuestGoalType.resource => resource(quest.goalResource!),
      };

  /// Whether a quest's goal is met and its reward can be claimed.
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
    int? energy,
    int? collapseDays,
    bool? gameOver,
    String? gameOverReason,
    List<CraftJob>? craftQueue,
    Map<String, int>? craftedItems,
    List<String>? completedExpeditions,
    Map<String, int>? marketStock,
  }) {
    return GameState(
      profile: profile ?? this.profile,
      clan: clan ?? this.clan,
      day: day ?? this.day,
      resources: resources ?? this.resources,
      quests: quests ?? this.quests,
      currentEvent: clearEvent ? null : currentEvent ?? this.currentEvent,
      eventIndex: eventIndex ?? this.eventIndex,
      log: log ?? this.log,
      energy: energy ?? this.energy,
      collapseDays: collapseDays ?? this.collapseDays,
      gameOver: gameOver ?? this.gameOver,
      gameOverReason: gameOverReason ?? this.gameOverReason,
      craftQueue: craftQueue ?? this.craftQueue,
      craftedItems: craftedItems ?? this.craftedItems,
      completedExpeditions: completedExpeditions ?? this.completedExpeditions,
      marketStock: marketStock ?? this.marketStock,
    );
  }
}

import '../models/clan.dart';
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
  });

  final PlayerProfile profile;
  final Clan clan;
  final GameDay day;
  final Map<ResourceType, int> resources;
  final List<Quest> quests;
  final GameEvent? currentEvent;
  final int eventIndex;
  final List<String> log;

  int resource(ResourceType type) => resources[type] ?? 0;

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
    );
  }
}

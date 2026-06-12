import 'dart:convert';

import '../data/starter_game_data.dart';
import '../models/clan.dart';
import '../models/game_day.dart';
import '../models/player_profile.dart';
import '../models/quest.dart';
import '../models/resource.dart';
import '../models/season.dart';
import 'game_state.dart';

/// JSON round-trip for [GameState]. Returns null on any malformed input so
/// the game can fall back to a fresh start instead of crashing.
class GameSerializer {
  const GameSerializer._();

  static String encode(GameState state) => jsonEncode({
        'profile': {
          'name': state.profile.name,
          'title': state.profile.title,
          'age': state.profile.age,
          'courage': state.profile.courage,
          'wisdom': state.profile.wisdom,
          'leadership': state.profile.leadership,
          'endurance': state.profile.endurance,
        },
        'clan': {'name': state.clan.name, 'motto': state.clan.motto},
        'day': {'day': state.day.day, 'season': state.day.season.name},
        'resources': {
          for (final entry in state.resources.entries)
            entry.key.name: entry.value,
        },
        'quests': [
          for (final quest in state.quests)
            {
              'id': quest.id,
              'progress': quest.progress,
              'completed': quest.completed,
            },
        ],
        'eventId': state.currentEvent?.id,
        'eventIndex': state.eventIndex,
        'log': state.log,
        'energy': state.energy,
        'collapseDays': state.collapseDays,
        'gameOver': state.gameOver,
        'gameOverReason': state.gameOverReason,
      });

  static GameState? decode(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final profile = json['profile'] as Map<String, dynamic>;
      final clan = json['clan'] as Map<String, dynamic>;
      final day = json['day'] as Map<String, dynamic>;
      final eventId = json['eventId'] as String?;
      return GameState(
        profile: PlayerProfile(
          name: profile['name'] as String,
          title: profile['title'] as String,
          age: profile['age'] as int,
          courage: profile['courage'] as int,
          wisdom: profile['wisdom'] as int,
          leadership: profile['leadership'] as int,
          endurance: profile['endurance'] as int,
        ),
        clan: Clan(
          name: clan['name'] as String,
          motto: clan['motto'] as String,
        ),
        day: GameDay(
          day: day['day'] as int,
          season: Season.values.byName(day['season'] as String),
        ),
        resources: {
          for (final entry
              in (json['resources'] as Map<String, dynamic>).entries)
            ResourceType.values.byName(entry.key): entry.value as int,
        },
        quests: _decodeQuests(json['quests'] as List<dynamic>),
        currentEvent: eventId == null
            ? null
            : StarterGameData.events.firstWhere((e) => e.id == eventId),
        eventIndex: json['eventIndex'] as int,
        log: (json['log'] as List<dynamic>).cast<String>(),
        energy: json['energy'] as int,
        collapseDays: json['collapseDays'] as int,
        gameOver: json['gameOver'] as bool,
        gameOverReason: json['gameOverReason'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  /// Quests are stored as id + progress and rebuilt from the catalog, so
  /// quest definitions can evolve without breaking old saves.
  static List<Quest> _decodeQuests(List<dynamic> entries) {
    final catalog = {
      for (final quest in StarterGameData.dailyQuestPool) quest.id: quest,
      for (final quest in StarterGameData.storyQuests) quest.id: quest,
    };
    return [
      for (final entry in entries.cast<Map<String, dynamic>>())
        if (catalog.containsKey(entry['id']))
          catalog[entry['id']]!.copyWith(
            progress: entry['progress'] as int,
            completed: entry['completed'] as bool,
          ),
    ];
  }
}

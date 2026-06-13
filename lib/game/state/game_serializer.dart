import 'dart:convert';

import '../data/market_goods.dart';
import '../data/starter_game_data.dart';
import '../models/camp_building.dart';
import '../models/clan.dart';
import '../models/craft.dart';
import '../models/faith.dart';
import '../models/game_day.dart';
import '../models/household.dart';
import '../models/marriage_candidate.dart';
import '../models/player_profile.dart';
import '../models/quest.dart';
import '../models/resource.dart';
import '../models/season.dart';
import '../models/tribe_relation.dart';
import 'game_state.dart';

class GameSerializer {
  const GameSerializer._();

  static String encode(GameState state) => jsonEncode({
        'profile': {
          'name': state.profile.name,
          'title': state.profile.title,
          'age': state.profile.age,
          'level': state.profile.level,
          'xp': state.profile.xp,
          'xpToNextLevel': state.profile.xpToNextLevel,
          'skillPoints': state.profile.skillPoints,
          'health': state.profile.health,
          'energy': state.profile.energy,
          'fatigue': state.profile.fatigue,
          'reputation': state.profile.reputation,
          'courage': state.profile.courage,
          'wisdom': state.profile.wisdom,
          'leadership': state.profile.leadership,
          'endurance': state.profile.endurance,
          'trade': state.profile.trade,
          'craft': state.profile.craft,
          'archery': state.profile.archery,
          'warfare': state.profile.warfare,
          'familyStatus': state.profile.familyStatus,
          'marriageStatus': state.profile.marriageStatus,
        },
        'clan': {'name': state.clan.name, 'motto': state.clan.motto},
        'day': {'day': state.day.day, 'season': state.day.season.name},
        'resources': {
          for (final e in state.resources.entries) e.key.name: e.value
        },
        'quests': [
          for (final q in state.quests)
            {'id': q.id, 'progress': q.progress, 'completed': q.completed}
        ],
        'eventId': state.currentEvent?.id,
        'eventIndex': state.eventIndex,
        'log': state.log,
        'dailyActionPoints': state.dailyActionPoints,
        'maxDailyActionPoints': state.maxDailyActionPoints,
        'energy': state.energy,
        'collapseDays': state.collapseDays,
        'gameOver': state.gameOver,
        'gameOverReason': state.gameOverReason,
        'craftQueue': [
          for (final j in state.craftQueue)
            {'recipeId': j.recipeId, 'daysLeft': j.daysLeft}
        ],
        'craftedItems': state.craftedItems,
        'completedExpeditions': state.completedExpeditions,
        'marketStock': state.marketStock,
        'buildings': [
          for (final b in state.buildings) {'id': b.id, 'level': b.level}
        ],
        'tribes': [
          for (final t in state.tribes)
            {
              'id': t.id,
              'relation': t.relation,
              'tradeOpen': t.tradeOpen,
              'marriageTie': t.marriageTie
            }
        ],
        'household': {
          'spouseName': state.household.spouseName,
          'spouseBonus': state.household.spouseBonus,
          'householdMorale': state.household.householdMorale,
          'childrenCount': state.household.childrenCount,
          'familyPrestige': state.household.familyPrestige,
        },
        'marriageCandidates': [
          for (final c in state.marriageCandidates)
            {
              'id': c.id,
              'relation': c.relation,
              'isAvailable': c.isAvailable,
              'isMarriedToPlayer': c.isMarriedToPlayer
            }
        ],
        'faithState': {
          'faith': state.faithState.faith,
          'kut': state.faithState.kut,
          'tore': state.faithState.tore,
          'ancestorHonor': state.faithState.ancestorHonor,
          'omen': state.faithState.omen,
          'omenSeverity': state.faithState.omenSeverity.name,
          'lastRitualDay': state.faithState.lastRitualDay,
          'ritualCooldownDays': state.faithState.ritualCooldownDays,
          'activeBlessings': state.faithState.activeBlessings,
          'activeWarnings': state.faithState.activeWarnings,
          'visitedSacredPlaces': state.faithState.visitedSacredPlaces,
        },
        'spiritualAdvisor': {
          'lastConsultDay': state.spiritualAdvisor.lastConsultDay,
          'level': state.spiritualAdvisor.level,
        },
        'ritualCooldowns': state.ritualCooldowns,
        'generation': state.generation,
        'pendingSuccession': state.pendingSuccession,
        'leaderLifespan': state.leaderLifespan,
        'claimedAchievements': state.claimedAchievements,
        'faithPath': state.faithPath,
        'tamga': state.tamga,
        'khanateStanding': state.khanateStanding,
        'isKhan': state.isKhan,
        'vassalObas': state.vassalObas,
        'equipped': state.equipped,
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
          level: profile['level'] as int? ?? 1,
          xp: profile['xp'] as int? ?? 0,
          xpToNextLevel: profile['xpToNextLevel'] as int? ?? 100,
          skillPoints: profile['skillPoints'] as int? ?? 0,
          health: profile['health'] as int? ?? 100,
          energy: profile['energy'] as int? ?? 100,
          fatigue: profile['fatigue'] as int? ?? 0,
          reputation: profile['reputation'] as int? ?? 10,
          courage: profile['courage'] as int,
          wisdom: profile['wisdom'] as int,
          leadership: profile['leadership'] as int,
          endurance: profile['endurance'] as int,
          trade: profile['trade'] as int? ?? 4,
          craft: profile['craft'] as int? ?? 4,
          archery: profile['archery'] as int? ?? 5,
          warfare: profile['warfare'] as int? ?? 5,
          familyStatus: profile['familyStatus'] as String? ?? 'Bekâr hane',
          marriageStatus: profile['marriageStatus'] as String? ?? 'Bekâr',
        ),
        clan:
            Clan(name: clan['name'] as String, motto: clan['motto'] as String),
        day: GameDay(
            day: day['day'] as int,
            season: Season.values.byName(day['season'] as String)),
        resources: {
          for (final e in (json['resources'] as Map<String, dynamic>).entries)
            ResourceType.values.byName(e.key): e.value as int
        },
        quests: _decodeQuests(json['quests'] as List<dynamic>),
        currentEvent: eventId == null
            ? null
            : StarterGameData.events.firstWhere((e) => e.id == eventId),
        eventIndex: json['eventIndex'] as int,
        log: (json['log'] as List<dynamic>).cast<String>(),
        dailyActionPoints: json['dailyActionPoints'] as int? ??
            json['energy'] as int? ??
            GameState.baseDailyActionPoints,
        maxDailyActionPoints: json['maxDailyActionPoints'] as int? ??
            GameState.baseDailyActionPoints,
        energy: json['energy'] as int? ?? GameState.baseDailyActionPoints,
        collapseDays: json['collapseDays'] as int,
        gameOver: json['gameOver'] as bool,
        gameOverReason: json['gameOverReason'] as String?,
        craftQueue: [
          for (final job in (json['craftQueue'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>())
            CraftJob(
                recipeId: job['recipeId'] as String,
                daysLeft: job['daysLeft'] as int)
        ],
        craftedItems: (json['craftedItems'] as Map<String, dynamic>? ?? {})
            .cast<String, int>(),
        completedExpeditions:
            (json['completedExpeditions'] as List<dynamic>? ?? [])
                .cast<String>(),
        marketStock: switch (
            (json['marketStock'] as Map<String, dynamic>? ?? {})
                .cast<String, int>()) {
          final stock when stock.isEmpty => MarketGoods.startingStock(),
          final stock => stock
        },
        buildings: _decodeBuildings(json['buildings'] as List<dynamic>?),
        tribes: _decodeTribes(json['tribes'] as List<dynamic>?),
        household: _decodeHousehold(json['household'] as Map<String, dynamic>?),
        marriageCandidates:
            _decodeCandidates(json['marriageCandidates'] as List<dynamic>?),
        faithState:
            _decodeFaithState(json['faithState'] as Map<String, dynamic>?),
        spiritualAdvisor: StarterGameData.spiritualAdvisor.copyWith(
          level: (json['spiritualAdvisor'] as Map<String, dynamic>?)?['level']
              as int?,
          lastConsultDay: (json['spiritualAdvisor']
              as Map<String, dynamic>?)?['lastConsultDay'] as int?,
        ),
        rituals: StarterGameData.rituals,
        sacredPlaces: StarterGameData.sacredPlaces,
        ritualCooldowns:
            (json['ritualCooldowns'] as Map<String, dynamic>? ?? {})
                .cast<String, int>(),
        generation: json['generation'] as int? ?? 1,
        pendingSuccession: json['pendingSuccession'] as bool? ?? false,
        leaderLifespan: json['leaderLifespan'] as int? ?? 64,
        claimedAchievements:
            (json['claimedAchievements'] as List<dynamic>? ?? [])
                .cast<String>(),
        faithPath: json['faithPath'] as String? ?? '',
        tamga: json['tamga'] as String? ?? 'wolf',
        khanateStanding: json['khanateStanding'] as int? ?? 20,
        isKhan: json['isKhan'] as bool? ?? false,
        vassalObas: json['vassalObas'] as int? ?? 0,
        equipped: (json['equipped'] as Map<String, dynamic>? ?? {})
            .cast<String, String>(),
      );
    } catch (_) {
      return null;
    }
  }

  static List<Quest> _decodeQuests(List<dynamic> entries) {
    final catalog = {
      for (final q in StarterGameData.dailyQuestPool) q.id: q,
      for (final q in StarterGameData.storyQuests) q.id: q
    };
    return [
      for (final e in entries.cast<Map<String, dynamic>>())
        if (catalog.containsKey(e['id']))
          catalog[e['id']]!.copyWith(
              progress: e['progress'] as int, completed: e['completed'] as bool)
    ];
  }

  static List<CampBuilding> _decodeBuildings(List<dynamic>? entries) {
    final levels = {
      for (final e in (entries ?? []).cast<Map<String, dynamic>>())
        e['id'] as String: e['level'] as int
    };
    return [
      for (final b in StarterGameData.campBuildings)
        b.copyWith(level: levels[b.id] ?? b.level)
    ];
  }

  static List<TribeRelation> _decodeTribes(List<dynamic>? entries) {
    final data = {
      for (final e in (entries ?? []).cast<Map<String, dynamic>>())
        e['id'] as String: e
    };
    return [
      for (final t in StarterGameData.tribes)
        t.copyWith(
            relation: data[t.id]?['relation'] as int? ?? t.relation,
            tradeOpen: data[t.id]?['tradeOpen'] as bool? ?? t.tradeOpen,
            marriageTie: data[t.id]?['marriageTie'] as bool? ?? t.marriageTie)
    ];
  }

  static Household _decodeHousehold(Map<String, dynamic>? h) => h == null
      ? const Household()
      : Household(
          spouseName: h['spouseName'] as String?,
          spouseBonus: h['spouseBonus'] as String? ?? 'Yok',
          householdMorale: h['householdMorale'] as int? ?? 50,
          childrenCount: h['childrenCount'] as int? ?? 0,
          familyPrestige: h['familyPrestige'] as int? ?? 0);

  static List<MarriageCandidate> _decodeCandidates(List<dynamic>? entries) {
    final data = {
      for (final e in (entries ?? []).cast<Map<String, dynamic>>())
        e['id'] as String: e
    };
    return [
      for (final c in StarterGameData.marriageCandidates)
        c.copyWith(
            relation: data[c.id]?['relation'] as int? ?? c.relation,
            isAvailable: data[c.id]?['isAvailable'] as bool? ?? c.isAvailable,
            isMarriedToPlayer: data[c.id]?['isMarriedToPlayer'] as bool? ??
                c.isMarriedToPlayer)
    ];
  }

  static FaithState _decodeFaithState(Map<String, dynamic>? data) {
    if (data == null) return const FaithState();
    return FaithState(
      faith: data['faith'] as int? ?? 60,
      kut: data['kut'] as int? ?? 45,
      tore: data['tore'] as int? ?? 70,
      ancestorHonor: data['ancestorHonor'] as int? ?? 55,
      omen: data['omen'] as String? ?? 'Alamet yok',
      omenSeverity: OmenSeverity.values.byName(
        data['omenSeverity'] as String? ?? OmenSeverity.neutral.name,
      ),
      lastRitualDay: data['lastRitualDay'] as int? ?? -99,
      ritualCooldownDays: data['ritualCooldownDays'] as int? ?? 3,
      activeBlessings:
          (data['activeBlessings'] as List<dynamic>? ?? []).cast<String>(),
      activeWarnings:
          (data['activeWarnings'] as List<dynamic>? ?? []).cast<String>(),
      visitedSacredPlaces:
          (data['visitedSacredPlaces'] as Map<String, dynamic>? ?? {})
              .cast<String, int>(),
    );
  }
}

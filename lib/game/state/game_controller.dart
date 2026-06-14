import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/achievements.dart';
import '../data/conquest_regions.dart';
import '../data/craft_recipes.dart';
import '../data/equipment.dart';
import '../data/expedition_sites.dart';
import '../data/faith_paths.dart';
import '../data/kurultay_decisions.dart';
import '../data/market_goods.dart';
import '../data/npc_dialogues.dart';
import '../data/recruitment.dart';
import '../data/starter_game_data.dart';
import '../logic/event_logic.dart';
import '../logic/life_logic.dart';
import '../logic/market_logic.dart';
import '../logic/progression_logic.dart';
import '../logic/resource_logic.dart';
import '../logic/season_logic.dart';
import '../models/achievement.dart';
import '../models/clan.dart';
import '../models/conquest_region.dart';
import '../models/craft.dart';
import '../models/event_choice.dart';
import '../models/faith.dart';
import '../models/expedition.dart';
import '../models/npc.dart';
import '../models/quest.dart';
import '../models/resource.dart';
import '../models/unit_type.dart';
import 'game_state.dart';
import 'game_storage.dart';

enum CraftStart { started, noResources, queueFull }

class GameController extends ChangeNotifier {
  GameController(this._state, {GameStorage? storage, Random? random})
      : _storage = storage,
        _random = random ?? Random();

  factory GameController.starter() => GameController(StarterGameData.create());

  /// Restores the saved run, or starts a fresh one.
  factory GameController.restored(GameStorage storage) =>
      GameController(storage.load() ?? StarterGameData.create(),
          storage: storage);

  static const campActionCost = 1;
  static const exploreCost = 1;
  static const expeditionCost = 1;

  final GameStorage? _storage;
  final Random _random;
  GameState _state;
  GameState get state => _state;

  /// Percent added to expedition rolls by gear the leader has equipped.
  int get equipmentBonus {
    var bonus = 0;
    for (final recipeId in _state.equipped.values) {
      bonus += CraftRecipes.byId(recipeId)?.successBonus ?? 0;
    }
    return bonus;
  }

  /// Equips an owned crafted item into its slot. Returns false if the item
  /// is not gear or none have been crafted.
  bool equipItem(String recipeId) {
    final slot = EquipmentData.slotForRecipe(recipeId);
    if (slot == null || _state.craftedCount(recipeId) <= 0) {
      return false;
    }
    _commit(_state.copyWith(
      equipped: {..._state.equipped, slot.id: recipeId},
      log: _prependLog(
        '${CraftRecipes.byId(recipeId)?.name ?? recipeId} kuşanıldı.',
      ),
    ));
    return true;
  }

  /// Clears the gear in [slotId].
  void unequip(String slotId) {
    if (!_state.equipped.containsKey(slotId)) {
      return;
    }
    final next = Map<String, String>.from(_state.equipped)..remove(slotId);
    _commit(_state.copyWith(equipped: next));
  }

  /// Final success chance for a site, clamped to 5–95 percent.
  int successChanceFor(ExpeditionSite site) {
    final chance = site.baseChance +
        _state.profile.courage +
        _state.profile.warfare * 2 +
        equipmentBonus;
    return chance.clamp(5, 95).toInt();
  }

  /// A site opens once every earlier site in the chain has been taken.
  bool siteUnlocked(ExpeditionSite site) {
    for (final other in ExpeditionSites.all) {
      if (other.id == site.id) {
        return true;
      }
      if (!_state.expeditionDone(other.id)) {
        return false;
      }
    }
    return false;
  }

  void _commit(GameState next) {
    _state = next;
    _storage?.save(next);
    notifyListeners();
  }

  /// Claims a quest reward once its goal is met.
  void claimQuest(String id) {
    Quest? quest;
    for (final item in _state.quests) {
      if (item.id == id) {
        quest = item;
        break;
      }
    }
    if (quest == null || !_state.questReady(quest)) {
      return;
    }
    final quests = _state.quests
        .map((item) => item.id == id ? item.copyWith(completed: true) : item)
        .toList();
    _commit(_state.copyWith(
      quests: quests,
      resources: ResourceLogic.apply(_state.resources, quest.resourceRewards),
      profile: ProgressionLogic.addXp(
        ProgressionLogic.applyStats(_state.profile, quest.statRewards),
        quest.xpReward,
      ),
      log: _prependLog('Görev tamamlandı: ${quest.title}. ${quest.rewardText}'),
    ));
  }

  /// Daily camp job; returns false when action points run short.
  bool performCampAction(
    String actionId,
    String title,
    Map<ResourceType, int> effects, {
    int energyCost = 10,
    int fatigueGain = 6,
    int xp = 10,
  }) {
    if (_state.dailyActionPoints < campActionCost) {
      return false;
    }
    final enduranceDiscount = (_state.profile.endurance / 4).floor();
    final winterTax = _state.day.season.name == 'winter' ? 3 : 0;
    final adjustedEnergy =
        (energyCost + winterTax - enduranceDiscount).clamp(3, 30).toInt();
    final profile = ProgressionLogic.addXp(
      _state.profile.copyWith(
        energy: _state.profile.energy - adjustedEnergy,
        fatigue: _state.profile.fatigue + fatigueGain,
      ),
      xp,
    );
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - campActionCost,
      resources: ResourceLogic.apply(_state.resources, effects),
      profile: profile,
      quests: _trackAction(actionId),
      log: _prependLog('$title: AP -1, enerji -$adjustedEnergy, XP +$xp.'),
    ));
    return true;
  }

  bool rest() {
    if (_state.dailyActionPoints < 1) return false;
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      profile: ProgressionLogic.addXp(
        _state.profile.copyWith(
          energy: _state.profile.energy + 20,
          fatigue: _state.profile.fatigue - 15,
          health: _state.profile.health + 3,
        ),
        5,
      ),
      quests: _trackAction(GameActions.rest),
      log: _prependLog('Dinlenildi: enerji toparlandı, yorgunluk azaldı.'),
    ));
    return true;
  }

  /// Scouting run from the expedition list; returns false without energy.
  bool exploreRegion(String title, Map<ResourceType, int> effects) {
    if (_state.dailyActionPoints < exploreCost) {
      return false;
    }
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - exploreCost,
      profile: ProgressionLogic.addXp(
          _state.profile.copyWith(
              energy: _state.profile.energy - 12,
              fatigue: _state.profile.fatigue + 8),
          16),
      resources: ResourceLogic.apply(_state.resources, effects),
      quests: _trackAction(GameActions.explore),
      log: _prependLog('$title keşfi tamamlandı.'),
    ));
    return true;
  }

  /// Rolls an expedition against [siteId]. Returns null when the site is
  /// unknown, still locked, already taken, or energy runs short.
  ExpeditionOutcome? embarkExpedition(String siteId) {
    final site = ExpeditionSites.byId(siteId);
    if (site == null ||
        !siteUnlocked(site) ||
        _state.expeditionDone(site.id) ||
        _state.dailyActionPoints < expeditionCost) {
      return null;
    }
    final success = _random.nextInt(100) < successChanceFor(site);
    final effects = success ? site.gains : site.losses;
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - expeditionCost,
      profile: ProgressionLogic.addXp(
          _state.profile.copyWith(
              energy: _state.profile.energy - 18,
              fatigue: _state.profile.fatigue + 12),
          success ? 28 : 12),
      resources: ResourceLogic.apply(_state.resources, effects),
      quests: _trackAction(GameActions.expedition),
      completedExpeditions: success
          ? [..._state.completedExpeditions, site.id]
          : _state.completedExpeditions,
      faithState: _state.faithState.apply({
        'kut': success ? 3 : -2,
        'faith': success ? 1 : 0,
      }),
      log: _prependLog(
        success
            ? '${site.name} fethedildi!'
            : '${site.name} seferi bozgunla döndü.',
      ),
    ));
    return ExpeditionOutcome(site: site, success: success, effects: effects);
  }

  /// Queues a workshop recipe, paying its costs up front.
  CraftStart startCraft(String recipeId) {
    final recipe = CraftRecipes.byId(recipeId);
    if (recipe == null || _state.craftQueue.length >= CraftRecipes.maxQueue) {
      return CraftStart.queueFull;
    }
    for (final entry in recipe.costs.entries) {
      if (_state.resource(entry.key) < entry.value) {
        return CraftStart.noResources;
      }
    }
    _commit(_state.copyWith(
      resources: ResourceLogic.apply(_state.resources, {
        for (final entry in recipe.costs.entries) entry.key: -entry.value,
      }),
      craftQueue: [
        ..._state.craftQueue,
        CraftJob(recipeId: recipe.id, daysLeft: recipe.days),
      ],
      log: _prependLog('${recipe.name} üretimi başladı.'),
    ));
    return CraftStart.started;
  }

  /// Buys one lot of a market good; returns false when the stall is empty,
  /// the good is not tradable, or gold runs short.
  bool buyGood(String goodId) {
    final good = MarketGoods.byId(goodId);
    // Tradable goods grant either a resource or a finished crafted item.
    if (good == null ||
        (good.grants == null && good.grantsItem == null) ||
        _state.stockOf(good.id) <= 0) {
      return false;
    }
    final price = MarketLogic.priceFor(good, _state.day.day);
    if (_state.resource(ResourceType.gold) < price) {
      return false;
    }
    final crafted = good.grantsItem == null
        ? _state.craftedItems
        : {
            ..._state.craftedItems,
            good.grantsItem!: (_state.craftedItems[good.grantsItem!] ?? 0) + 1,
          };
    _commit(_state.copyWith(
      resources: ResourceLogic.apply(_state.resources, {
        ResourceType.gold: -price,
        if (good.grants != null) good.grants!: good.amount,
      }),
      craftedItems: crafted,
      marketStock: {
        ..._state.marketStock,
        good.id: _state.stockOf(good.id) - 1,
      },
      profile: ProgressionLogic.addXp(_state.profile, 6),
      quests: _trackAction(GameActions.trade),
      log: _prependLog('${good.name} satın alındı.'),
    ));
    return true;
  }

  /// Applies a trade if no resource would drop below zero.
  bool tryTrade(String title, Map<ResourceType, int> effects) {
    for (final entry in effects.entries) {
      if (entry.value < 0 && _state.resource(entry.key) + entry.value < 0) {
        return false;
      }
    }
    _commit(_state.copyWith(
      resources: ResourceLogic.apply(_state.resources, effects),
      profile: ProgressionLogic.addXp(_state.profile, 8),
      quests: _trackAction(GameActions.trade),
      log: _prependLog('$title takası yapıldı.'),
    ));
    return true;
  }

  void endDay() {
    if (_state.pendingSuccession) {
      return;
    }
    final nextDay = _state.day.nextDay();
    final dailyCost = SeasonLogic.dailyCost(
      nextDay.season,
      _state.resource(ResourceType.population),
    );
    var resources = ResourceLogic.apply(_state.resources, dailyCost);
    var log = _prependLog(
      'Gün ${nextDay.day} başladı. ${nextDay.season.label} '
      'etkileri uygulandı.',
    );

    // Starvation bites once the granary is empty.
    if ((resources[ResourceType.food] ?? 0) <= 0) {
      resources = ResourceLogic.apply(resources, const {
        ResourceType.morale: -5,
        ResourceType.population: -1,
      });
      log = ['Açlık obayı kırıyor: moral ve nüfus azaldı.', ...log]
          .take(6)
          .toList();
    }

    // Three days at zero morale scatters the camp.
    final collapseDays = (resources[ResourceType.morale] ?? 0) <= 0
        ? _state.collapseDays + 1
        : 0;
    final gameOver = collapseDays >= 3;

    // Rotate the daily quest slate; keep persistent quests as they are.
    final quests = [
      ...StarterGameData.dailyQuestsFor(nextDay.day),
      ..._state.quests.where((q) => q.category != 'Günlük'),
    ];

    // The workshop hammers through the night.
    final crafted = Map<String, int>.from(_state.craftedItems);
    final queue = <CraftJob>[];
    for (final job in _state.craftQueue) {
      final ticked = job.tick();
      if (ticked.daysLeft <= 0) {
        crafted[job.recipeId] = (crafted[job.recipeId] ?? 0) + 1;
        final recipe = CraftRecipes.byId(job.recipeId);
        log = ['${recipe?.name ?? job.recipeId} üretimi tamamlandı.', ...log]
            .take(6)
            .toList();
      } else {
        queue.add(ticked);
      }
    }

    // The leader ages a year each time the seasons come full circle.
    var profile = _recoverProfile(resources);
    var pendingSuccession = false;
    if (LifeLogic.isYearBoundary(nextDay.day)) {
      final agedTo = profile.age + 1;
      profile = profile.copyWith(
        age: agedTo,
        title: LifeLogic.titleForAge(agedTo),
      );
      log = ['${profile.name} bir yaş aldı: $agedTo. ${profile.title}.', ...log]
          .take(6)
          .toList();
      if (agedTo >= _state.leaderLifespan && !gameOver) {
        pendingSuccession = true;
        log = [
          '${profile.name}, $agedTo yaşında göçtü. Mirasçı bekleniyor.',
          ...log,
        ].take(6).toList();
      }
    }

    // A married leader's household steadies the camp and, in time, grows
    // the line — each child adds a mouth and a hand to the oba.
    var household = _state.household;
    if (household.isMarried) {
      resources = ResourceLogic.apply(resources, const {
        ResourceType.morale: 1,
      });
      if (nextDay.day % 20 == 0 &&
          household.childrenCount < 8 &&
          (resources[ResourceType.food] ?? 0) >= 30) {
        household = household.copyWith(
          childrenCount: household.childrenCount + 1,
          familyPrestige: household.familyPrestige + 2,
        );
        resources = ResourceLogic.apply(resources, const {
          ResourceType.population: 1,
        });
        log = ['Obaya bir çocuk doğdu; soy büyüyor.', ...log].take(6).toList();
      }
    }

    // A content, well-fed oba steadily draws and raises new people.
    final growMorale = resources[ResourceType.morale] ?? 0;
    final growFood = resources[ResourceType.food] ?? 0;
    final growPop = resources[ResourceType.population] ?? 0;
    if (growMorale >= 55 &&
        growFood >= 40 &&
        growPop < 220 &&
        nextDay.day % 8 == 0) {
      resources = ResourceLogic.apply(resources, const {
        ResourceType.population: 2,
      });
      log =
          ['Oba büyüyor: yeni canlar ocağa katıldı.', ...log].take(6).toList();
    }

    // Discontent at the bottom or top of the camp gnaws at it daily.
    if (_state.peopleApproval < 30) {
      resources = ResourceLogic.apply(resources, const {
        ResourceType.morale: -3,
      });
    }

    // The healer's çadırı mends the wounded back into the ranks.
    var army = _state.army;
    var wounded = _state.wounded;
    if (_state.totalWounded > 0) {
      var cap = healCapacity;
      final a = Map<String, int>.from(army);
      final w = Map<String, int>.from(wounded);
      for (final id in w.keys.toList()) {
        if (cap <= 0) break;
        final heal = w[id]!.clamp(0, cap).toInt();
        w[id] = w[id]! - heal;
        if (w[id]! <= 0) w.remove(id);
        a[id] = (a[id] ?? 0) + heal;
        cap -= heal;
      }
      army = a;
      wounded = w;
      log = ['Şifacı çadırında yaralılar iyileşiyor.', ...log].take(6).toList();
    }

    // The council convenes on a fixed cadence when one is not already due.
    var kurultayId = _state.currentKurultay;
    var lastKurultay = _state.lastKurultayDay;
    if (kurultayId == null &&
        !pendingSuccession &&
        nextDay.day - lastKurultay >= KurultayDecisions.period) {
      final pool = [
        for (final d in KurultayDecisions.all)
          if (!d.khanate || _state.isKhan) d,
      ];
      kurultayId = pool[_random.nextInt(pool.length)].id;
      lastKurultay = nextDay.day;
      log =
          ['Kurultay toplandı; bir karar bekleniyor.', ...log].take(6).toList();
    }

    final eventIndex = _state.eventIndex + 1;
    final omenState = _rollOmen(resources);
    _commit(_state.copyWith(
      day: nextDay,
      resources: resources,
      dailyActionPoints: _dailyActionLimit(resources),
      profile: profile,
      household: household,
      faithState: omenState,
      collapseDays: collapseDays,
      gameOver: gameOver,
      gameOverReason: gameOver
          ? 'Moral günlerce sıfırda kaldı; oba dağıldı ve halk '
              'başka beyliklere göçtü.'
          : null,
      pendingSuccession: pendingSuccession,
      currentKurultay: kurultayId,
      lastKurultayDay: lastKurultay,
      army: army,
      wounded: wounded,
      quests: quests,
      craftQueue: queue,
      craftedItems: crafted,
      marketStock: MarketGoods.startingStock(),
      currentEvent: pendingSuccession ? null : EventLogic.nextEvent(eventIndex),
      clearEvent: pendingSuccession,
      eventIndex: eventIndex,
      log: log,
    ));
  }

  bool chooseEvent(EventChoice choice) {
    if (_state.dailyActionPoints < choice.actionPointCost) {
      return false;
    }
    final actionId = choice.faithEffects.containsKey('tore')
        ? GameActions.toreCase
        : GameActions.event;
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - choice.actionPointCost,
      resources: ResourceLogic.apply(_state.resources, choice.resourceEffects),
      faithState: _state.faithState.apply(choice.faithEffects),
      profile: ProgressionLogic.addXp(
        ProgressionLogic.applyStats(
          _state.profile.copyWith(
            health: _state.profile.health + choice.healthEffect,
            energy: _state.profile.energy + choice.energyEffect,
            fatigue: _state.profile.fatigue + choice.fatigueEffect,
          ),
          choice.statEffects,
        ),
        choice.xpReward,
      ),
      quests: _trackAction(actionId),
      clearEvent: true,
      log: _prependLog('Olay seçimi: ${choice.label}. ${choice.description}'),
    ));
    return true;
  }

  bool performRitual(String ritualId) {
    final ritual = _ritualById(ritualId);
    if (ritual == null || _state.dailyActionPoints < ritual.actionCost) {
      return false;
    }
    final lastDay = _state.ritualCooldowns[ritual.id] ?? -99;
    if (_state.day.day - lastDay < ritual.cooldownDays) {
      return false;
    }
    for (final entry in ritual.cost.entries) {
      if (_state.resource(entry.key) < entry.value) return false;
    }
    final resources = ResourceLogic.apply(_state.resources, {
      for (final entry in ritual.cost.entries) entry.key: -entry.value,
      ...ritual.resourceEffects,
    });
    final household = ritual.id == 'ancestor_honor'
        ? _state.household.copyWith(
            householdMorale: _state.household.householdMorale + 4,
            familyPrestige: _state.household.familyPrestige + 1,
          )
        : _state.household;
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - ritual.actionCost,
      resources: resources,
      household: household,
      faithState: _state.faithState.apply(ritual.faithEffects).copyWith(
            lastRitualDay: _state.day.day,
            ritualCooldownDays: ritual.cooldownDays,
            activeBlessings: [
              '${ritual.name} (${ritual.bonusDurationDays} gün)',
              ..._state.faithState.activeBlessings,
            ].take(4).toList(),
          ),
      ritualCooldowns: {..._state.ritualCooldowns, ritual.id: _state.day.day},
      profile: ProgressionLogic.addXp(
        ProgressionLogic.applyStats(
          _state.profile.copyWith(
            energy: _state.profile.energy + ritual.energyEffect,
            health: _state.profile.health + ritual.healthEffect,
          ),
          ritual.statEffects,
        ),
        16,
      ),
      quests: _trackAction(GameActions.ritual),
      log: _prependLog(
          '${ritual.name} tamamlandı: ${ritual.effectDescription}.'),
    ));
    return true;
  }

  bool consultAdvisor(String action) {
    final advisor = _state.spiritualAdvisor;
    if (_state.dailyActionPoints < 1 ||
        _state.day.day - advisor.lastConsultDay < advisor.cooldownDays) {
      return false;
    }
    final isBadOmen = _state.faithState.hasBadOmen;
    final effects = switch (action) {
      'prepare_ritual' => {'faith': 3, 'kut': 1},
      'ancestor_prayer' => {'ancestorHonor': 5, 'faith': 2},
      'raise_morale' => {'kut': 2, 'tore': 1},
      'bad_dream' => {'faith': 2, 'kut': isBadOmen ? 3 : 1},
      _ => {'faith': 2, 'kut': isBadOmen ? 4 : 1},
    };
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      spiritualAdvisor: advisor.copyWith(lastConsultDay: _state.day.day),
      resources: ResourceLogic.apply(_state.resources, {
        ResourceType.morale: isBadOmen ? 3 : 1,
      }),
      faithState: _state.faithState.apply(effects).copyWith(
            omen:
                isBadOmen ? 'Kam alameti yatıştırdı.' : _state.faithState.omen,
            omenSeverity: isBadOmen
                ? OmenSeverity.neutral
                : _state.faithState.omenSeverity,
            activeWarnings:
                isBadOmen ? const [] : _state.faithState.activeWarnings,
            activeBlessings: [
              '${advisor.name} yorumu',
              ..._state.faithState.activeBlessings,
            ].take(4).toList(),
          ),
      profile: ProgressionLogic.addXp(_state.profile, 12),
      quests: _trackAction(GameActions.advisor),
      log: _prependLog('${advisor.name} alameti yorumladı.'),
    ));
    return true;
  }

  bool visitSacredPlace(String placeId) {
    final place = _sacredPlaceById(placeId);
    if (place == null || !place.isUnlocked || _state.dailyActionPoints < 1) {
      return false;
    }
    final lastVisit = _state.faithState.visitedSacredPlaces[place.id] ?? -99;
    if (_state.day.day - lastVisit < place.visitCooldownDays) {
      return false;
    }
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      resources: ResourceLogic.apply(_state.resources, place.resourceEffects),
      faithState: _state.faithState.apply(place.faithEffects).copyWith(
        visitedSacredPlaces: {
          ..._state.faithState.visitedSacredPlaces,
          place.id: _state.day.day,
        },
      ),
      profile: ProgressionLogic.addXp(
        _state.profile.copyWith(
          energy: _state.profile.energy - place.energyCost,
          fatigue: _state.profile.fatigue + 4,
        ),
        place.xpReward,
      ),
      quests: _trackAction(GameActions.sacredVisit),
      log: _prependLog('${place.name} ziyaret edildi: ${place.reward}.'),
    ));
    return true;
  }

  bool spendSkillPoint(String stat) {
    final next = ProgressionLogic.spendSkillPoint(_state.profile, stat);
    if (identical(next, _state.profile) ||
        next.skillPoints == _state.profile.skillPoints) {
      return false;
    }
    _commit(_state.copyWith(
      profile: next,
      log: _prependLog('Beceri puanı harcandı: $stat +1.'),
    ));
    return true;
  }

  bool upgradeBuilding(String id) {
    final building = _state.building(id);
    if (building == null || !building.canUpgrade) return false;
    final craftDiscount =
        id == 'workshop' ? (_state.profile.craft / 5).floor() : 0;
    final cost = {
      for (final entry in building.upgradeCost.entries)
        entry.key: (entry.value - craftDiscount).clamp(1, 9999).toInt(),
    };
    for (final entry in cost.entries) {
      if (_state.resource(entry.key) < entry.value) return false;
    }
    final buildings = [
      for (final item in _state.buildings)
        item.id == id ? item.copyWith(level: item.level + 1) : item,
    ];
    final resources = ResourceLogic.apply(_state.resources, {
      for (final entry in cost.entries) entry.key: -entry.value,
      ResourceType.morale: id == 'main_tent' ? 2 : 1,
    });
    _commit(_state.copyWith(
      buildings: buildings,
      resources: resources,
      maxDailyActionPoints: _dailyActionLimit(resources, buildings: buildings),
      profile: ProgressionLogic.addXp(_state.profile, 20),
      log: _prependLog('${building.name} seviye ${building.level + 1} oldu.'),
    ));
    return true;
  }

  bool performDiplomacy(String tribeId, String action) {
    final tribe = _tribeById(tribeId);
    if (tribe == null || _state.dailyActionPoints < 1) return false;
    var resourceCost = const <ResourceType, int>{};
    var delta = 0;
    var tradeOpen = tribe.tradeOpen;
    switch (action) {
      case 'gift':
        resourceCost = const {ResourceType.gold: -100};
        delta = 8 +
            (_state.profile.trade / 5).floor() +
            (_state.faithState.kut / 35).floor();
        break;
      case 'trade':
        resourceCost = const {ResourceType.gold: -60};
        delta = 10;
        tradeOpen = true;
        break;
      case 'envoy':
        delta = _state.profile.wisdom +
                    _state.profile.trade +
                    (_state.faithState.kut / 25).floor() >=
                10
            ? 5
            : -3;
        break;
      case 'aid':
        resourceCost = const {ResourceType.food: -20};
        delta = 6;
        break;
      case 'war':
        resourceCost = const {ResourceType.food: -10, ResourceType.gold: -40};
        delta = -6;
        break;
      case 'marriage':
        resourceCost = const {ResourceType.gold: -80};
        delta = 12;
        break;
      default:
        return false;
    }
    for (final entry in resourceCost.entries) {
      if (_state.resource(entry.key) + entry.value < 0) return false;
    }
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      resources: ResourceLogic.apply(_state.resources, {
        ...resourceCost,
        ResourceType.reputation: action == 'gift' ? 1 : 0,
      }),
      tribes: [
        for (final item in _state.tribes)
          item.id == tribeId
              ? item.copyWith(
                  relation: item.relation + delta, tradeOpen: tradeOpen)
              : item,
      ],
      profile: ProgressionLogic.addXp(
          _state.profile.copyWith(reputation: _state.profile.reputation + 1),
          14),
      quests: _trackAction(GameActions.diplomacy),
      log: _prependLog(
          '${tribe.name}: diplomasi ($action), ilişki ${delta >= 0 ? '+' : ''}$delta.'),
    ));
    return true;
  }

  bool meetCandidate(String candidateId) {
    if (_state.dailyActionPoints < 1) return false;
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      marriageCandidates: [
        for (final c in _state.marriageCandidates)
          c.id == candidateId ? c.copyWith(relation: c.relation + 8) : c,
      ],
      profile: ProgressionLogic.addXp(_state.profile, 8),
      log: _prependLog('Hane görüşmesi yapıldı; adayla ilişki güçlendi.'),
    ));
    return true;
  }

  bool proposeMarriage(String candidateId) {
    final candidate = _candidateById(candidateId);
    if (candidate == null ||
        !candidate.isAvailable ||
        _state.household.isMarried ||
        _state.dailyActionPoints < 1) {
      return false;
    }
    final tribe = _state.tribeByName(candidate.tribeName);
    if (_state.resource(ResourceType.reputation) < 20 ||
        _state.resource(ResourceType.gold) < 300 ||
        (tribe?.relation ?? -100) + (_state.faithState.kut / 25).floor() < 10) {
      return false;
    }
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      resources: ResourceLogic.apply(_state.resources, const {
        ResourceType.gold: -300,
        ResourceType.morale: 8,
        ResourceType.reputation: 3,
      }),
      household: _state.household.copyWith(
        spouseName: candidate.name,
        spouseBonus: candidate.bonusType,
        householdMorale: _state.household.householdMorale + 25,
        familyPrestige:
            (_state.household.familyPrestige + candidate.diplomaticValue)
                .toInt(),
      ),
      profile: ProgressionLogic.addXp(
          _state.profile.copyWith(
              familyStatus: 'Kurulu hane',
              marriageStatus: '${candidate.name} ile evli'),
          40),
      marriageCandidates: [
        for (final c in _state.marriageCandidates)
          c.id == candidateId
              ? c.copyWith(isAvailable: false, isMarriedToPlayer: true)
              : c.copyWith(isAvailable: false),
      ],
      tribes: [
        for (final t in _state.tribes)
          t.name == candidate.tribeName
              ? t.copyWith(relation: t.relation + 18, marriageTie: true)
              : t,
      ],
      log: _prependLog('${candidate.name} ile evlilik bağı kuruldu.'),
    ));
    return true;
  }

  int _dailyActionLimit(Map<ResourceType, int> resources, {List? buildings}) {
    final source = buildings ?? _state.buildings;
    final main = _buildingById(source, 'main_tent');
    var max =
        GameState.baseDailyActionPoints + ((main?.level ?? 1) >= 3 ? 1 : 0);
    if (_state.profile.fatigue >= 75) {
      max -= 1;
    }
    if ((resources[ResourceType.morale] ?? 0) >= 80 &&
        _state.profile.leadership >= 8) {
      max += 1;
    }
    return max.clamp(2, 6).toInt();
  }

  dynamic _recoverProfile(Map<ResourceType, int> resources) {
    final morale = resources[ResourceType.morale] ?? 0;
    final healer = _state.building('healer')?.level ?? 1;
    final householdMorale = _state.household.isMarried ? 2 : 0;
    final energyGain = 28 + (morale >= 60 ? 6 : -4) + householdMorale;
    final healthLoss = _state.profile.fatigue > 80 ? -4 : 0;
    return _state.profile.copyWith(
      energy: _state.profile.energy + energyGain,
      fatigue: _state.profile.fatigue - 22,
      health: _state.profile.health + healer + healthLoss,
    );
  }

  /// Collects an achievement reward once its goal is met.
  bool claimAchievement(String id) {
    Achievement? achievement;
    for (final item in Achievements.all) {
      if (item.id == id) {
        achievement = item;
        break;
      }
    }
    if (achievement == null || !_state.achievementReady(achievement)) {
      return false;
    }
    _commit(_state.copyWith(
      resources: ResourceLogic.apply(_state.resources, achievement.reward),
      claimedAchievements: [..._state.claimedAchievements, achievement.id],
      log: _prependLog('Başarım kazanıldı: ${achievement.title}.'),
    ));
    return true;
  }

  /// Seats the late leader's heir, carrying the clan and legacy forward.
  void succeedWithHeir() {
    if (!_state.pendingSuccession) {
      return;
    }
    final heir = LifeLogic.heirOf(_state.profile, _random);
    // The heir inherits the realm, but the funeral spends a fifth of the
    // treasury and the interregnum shakes morale.
    final resources = ResourceLogic.apply(_state.resources, {
      ResourceType.gold: -(_state.resource(ResourceType.gold) ~/ 5),
      ResourceType.morale: -10,
    });
    _commit(_state.copyWith(
      profile: heir,
      resources: resources,
      generation: _state.generation + 1,
      leaderLifespan: 60 + _random.nextInt(13),
      pendingSuccession: false,
      log: _prependLog(
        '${heir.name} obanın başına geçti. ${_state.generation + 1}. nesil '
        'başladı.',
      ),
    ));
  }

  /// Commits the oba to a belief path, applying its one-time faith lean.
  /// Re-choosing the same path does nothing; switching applies the new lean.
  bool chooseFaithPath(String pathId) {
    final path = FaithPaths.byId(pathId);
    if (path == null || _state.faithPath == pathId) {
      return false;
    }
    _commit(_state.copyWith(
      faithPath: pathId,
      faithState: _state.faithState.apply(path.lean),
      log: _prependLog('İnanç yolu seçildi: ${path.name}.'),
    ));
    return true;
  }

  /// Military and political weight behind the oba, used to gauge whether a
  /// rebellion against the khan can succeed.
  int get khanatePower {
    var allies = 0;
    for (final tribe in _state.tribes) {
      if (tribe.relation >= 60) allies++;
    }
    return _state.resource(ResourceType.population) +
        _state.profile.reputation * 2 +
        _state.completedExpeditions.length * 15 +
        _state.vassalObas * 25 +
        allies * 12;
  }

  /// Power needed before the throne can realistically be challenged.
  static const rebellionPowerThreshold = 220;

  bool get canRebel =>
      !_state.isKhan &&
      khanatePower >= rebellionPowerThreshold &&
      _state.khanateStanding >= 50;

  /// Pays tribute to the khan: gold for standing.
  bool payTribute() {
    if (_state.resource(ResourceType.gold) < 120) {
      return false;
    }
    _commit(_state.copyWith(
      resources: ResourceLogic.apply(_state.resources, const {
        ResourceType.gold: -120,
      }),
      khanateStanding: _state.khanateStanding + 10,
      log: _prependLog('Kağana haraç ödendi; bağlılık arttı.'),
    ));
    return true;
  }

  /// Answers the khan's call to war: action point and food for standing,
  /// reputation and plunder.
  bool joinKhanCampaign() {
    if (_state.dailyActionPoints < 1 ||
        _state.resource(ResourceType.food) < 20) {
      return false;
    }
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      resources: ResourceLogic.apply(_state.resources, const {
        ResourceType.food: -20,
        ResourceType.gold: 50,
      }),
      profile: ProgressionLogic.addXp(
        _state.profile.copyWith(
          reputation: _state.profile.reputation + 3,
          fatigue: _state.profile.fatigue + 8,
        ),
        24,
      ),
      khanateStanding: _state.khanateStanding + 6,
      log: _prependLog(
          'Kağanın seferine katılındı; itibar ve ganimet kazanıldı.'),
    ));
    return true;
  }

  /// Sits at the khan's divan: an action point for standing and wisdom.
  bool attendDivan() {
    if (_state.dailyActionPoints < 1) {
      return false;
    }
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      profile: ProgressionLogic.addXp(
        ProgressionLogic.applyStats(_state.profile, const {'wisdom': 1}),
        18,
      ),
      khanateStanding: _state.khanateStanding + 4,
      log: _prependLog('Divana katılındı; söz sahibi olundu.'),
    ));
    return true;
  }

  /// Rallies a nearby oba under the banner, raising power.
  bool rallyObas() {
    if (_state.resource(ResourceType.gold) < 200 ||
        _state.profile.reputation < 25) {
      return false;
    }
    _commit(_state.copyWith(
      resources: ResourceLogic.apply(_state.resources, const {
        ResourceType.gold: -200,
      }),
      vassalObas: _state.vassalObas + 1,
      khanateStanding: _state.khanateStanding + 5,
      log: _prependLog('Bir oba senin tamganın altına girdi.'),
    ));
    return true;
  }

  /// Stakes everything on overthrowing the khan. Success seats you on the
  /// throne; failure scatters followers and burns standing.
  bool attemptRebellion() {
    if (!canRebel) {
      return false;
    }
    final chance =
        (40 + (khanatePower - rebellionPowerThreshold) ~/ 4).clamp(20, 90);
    final success = _random.nextInt(100) < chance;
    if (success) {
      _commit(_state.copyWith(
        isKhan: true,
        khanateStanding: 100,
        resources: ResourceLogic.apply(_state.resources, const {
          ResourceType.gold: 600,
          ResourceType.reputation: 20,
          ResourceType.morale: 15,
        }),
        profile: _state.profile.copyWith(
          title: 'Kağan',
          reputation: _state.profile.reputation + 20,
        ),
        log: _prependLog(
            'İSYAN ZAFERLE BİTTİ! Kağan devrildi, tahta sen geçtin.'),
      ));
    } else {
      _commit(_state.copyWith(
        khanateStanding: (_state.khanateStanding - 30).clamp(0, 100).toInt(),
        vassalObas: 0,
        resources: ResourceLogic.apply(_state.resources, const {
          ResourceType.morale: -20,
          ResourceType.population: -8,
          ResourceType.gold: -200,
        }),
        log: _prependLog('İsyan bastırıldı; oba ağır kayıp verdi.'),
      ));
    }
    return success;
  }

  /// Combined attack of every battle-ready unit.
  int get armyStrength {
    var total = 0;
    for (final entry in _state.army.entries) {
      total += (UnitTypes.byId(entry.key)?.attack ?? 0) * entry.value;
    }
    return total;
  }

  /// How many wounded the healer's çadırı mends each day.
  int get healCapacity => 2 + ((_state.building('healer')?.level ?? 1) - 1) * 2;

  /// Raises [qty] soldiers of a type, paying gold (and horses for riders).
  bool recruitUnit(String unitId, int qty) {
    final unit = UnitTypes.byId(unitId);
    if (unit == null || qty <= 0 || _state.dailyActionPoints < 1) {
      return false;
    }
    final cost = UnitTypes.recruitCost(unit, qty);
    for (final entry in cost.entries) {
      if (_state.resource(entry.key) < entry.value) {
        return false;
      }
    }
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      resources: ResourceLogic.apply(_state.resources, {
        for (final entry in cost.entries) entry.key: -entry.value,
      }),
      army: {..._state.army, unitId: _state.unitCount(unitId) + qty},
      log: _prependLog('$qty ${unit.name} saflara katıldı.'),
    ));
    return true;
  }

  /// Moves a fraction of each unit type to the wounded pool, losing a
  /// smaller fraction outright. Returns the new army and wounded maps.
  (Map<String, int>, Map<String, int>) _battleCasualties(
    double woundFrac,
    double lostFrac,
  ) {
    final army = <String, int>{};
    final wounded = Map<String, int>.from(_state.wounded);
    for (final entry in _state.army.entries) {
      final hurt = (entry.value * woundFrac).round();
      final lost = (entry.value * lostFrac).round();
      final left = (entry.value - hurt - lost).clamp(0, entry.value).toInt();
      if (left > 0) army[entry.key] = left;
      if (hurt > 0) wounded[entry.key] = (wounded[entry.key] ?? 0) + hurt;
    }
    return (army, wounded);
  }

  /// Military weight thrown behind a regional war.
  int get warStrength =>
      armyStrength * 4 +
      _state.resource(ResourceType.population) +
      _state.profile.warfare * 8 +
      _state.profile.courage * 3 +
      equipmentBonus * 3 +
      _state.completedExpeditions.length * 10 +
      _state.vassalObas * 20 +
      (_state.isKhan ? 50 : 0);

  /// Current relation with a conquest region.
  int regionRelation(ConquestRegion region) =>
      _state.regionRelations[region.id] ?? region.baseRelation;

  /// War success chance against a region, 10–90 percent.
  int warChanceFor(ConquestRegion region) {
    final s = warStrength;
    return (s * 100 / (s + region.power)).round().clamp(10, 90);
  }

  bool canAnnex(ConquestRegion region) =>
      !_state.regionConquered(region.id) &&
      regionRelation(region) >= ConquestRegions.annexRelation;

  /// Diplomacy: gold and an action point to warm a region toward you.
  bool improveRegionRelation(String regionId) {
    final region = ConquestRegions.byId(regionId);
    if (region == null ||
        _state.regionConquered(regionId) ||
        _state.dailyActionPoints < 1 ||
        _state.resource(ResourceType.gold) < 80) {
      return false;
    }
    final next = (regionRelation(region) + 12).clamp(0, 100).toInt();
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      resources: ResourceLogic.apply(_state.resources, const {
        ResourceType.gold: -80,
      }),
      regionRelations: {..._state.regionRelations, regionId: next},
      log: _prependLog('${region.name} ile ilişkiler ısındı ($next/100).'),
    ));
    return true;
  }

  /// Annex a friendly region peacefully once relations are high enough.
  bool annexRegion(String regionId) {
    final region = ConquestRegions.byId(regionId);
    if (region == null || !canAnnex(region)) {
      return false;
    }
    _commit(_state.copyWith(
      conqueredRegions: [..._state.conqueredRegions, regionId],
      vassalObas: _state.vassalObas + 1,
      resources: ResourceLogic.apply(_state.resources, {
        ResourceType.reputation: region.rewardReputation,
        ResourceType.gold: region.rewardGold ~/ 2,
      }),
      log: _prependLog('${region.name} barışla tamganın altına girdi.'),
    ));
    return true;
  }

  /// Wage war for a region. Win to seize it, lose and bleed for it.
  bool attackRegion(String regionId) {
    final region = ConquestRegions.byId(regionId);
    if (region == null ||
        _state.regionConquered(regionId) ||
        _state.dailyActionPoints < 1) {
      return false;
    }
    final success = _random.nextInt(100) < warChanceFor(region);
    // Winning costs fewer soldiers; a rout wounds and kills many more.
    final (army, wounded) =
        _battleCasualties(success ? 0.10 : 0.25, success ? 0.04 : 0.12);
    if (success) {
      _commit(_state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        conqueredRegions: [..._state.conqueredRegions, regionId],
        vassalObas: _state.vassalObas + 1,
        army: army,
        wounded: wounded,
        resources: ResourceLogic.apply(_state.resources, {
          ResourceType.gold: region.rewardGold,
          ResourceType.reputation: region.rewardReputation,
          ResourceType.morale: 6,
          ResourceType.food: -15,
        }),
        log: _prependLog('${region.name} kılıçla fethedildi!'),
      ));
    } else {
      _commit(_state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        army: army,
        wounded: wounded,
        resources: ResourceLogic.apply(_state.resources, const {
          ResourceType.morale: -10,
          ResourceType.population: -5,
          ResourceType.food: -15,
        }),
        log:
            _prependLog('${region.name} kuşatması püskürtüldü; kayıp verildi.'),
      ));
    }
    return success;
  }

  /// Reputation and tent level required before a new oba may be founded.
  static const foundObaReputation = 30;
  static const foundObaTentLevel = 2;

  /// You may only strike out on your own once your tent and name carry
  /// weight: a raised main tent and enough reputation.
  bool get canFoundNewOba =>
      (_state.building('main_tent')?.level ?? 1) >= foundObaTentLevel &&
      _state.profile.reputation >= foundObaReputation;

  /// Gathers new people into the oba from a recruitment source. A respected
  /// bey (reputation) draws extra followers. Returns false without an action
  /// point or the resources to pay.
  bool recruit(String sourceId) {
    final source = Recruitment.byId(sourceId);
    if (source == null || _state.dailyActionPoints < 1) {
      return false;
    }
    for (final entry in source.cost.entries) {
      if (_state.resource(entry.key) < entry.value) {
        return false;
      }
    }
    final bonus = _state.profile.reputation ~/ 20;
    final people = source.basePeople + bonus;
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      resources: ResourceLogic.apply(_state.resources, {
        for (final entry in source.cost.entries) entry.key: -entry.value,
        ...source.extraEffects,
        ResourceType.population: people,
      }),
      log: _prependLog('${source.name}: obaya $people kişi katıldı.'),
    ));
    return true;
  }

  /// Founds a brand-new oba under a chosen name and tamga, bound to the
  /// khanate. A fresh young founder takes over; a small share of the old
  /// treasury carries forward as a founding legacy.
  void foundNewOba(String name, String tamgaId) {
    final fresh = StarterGameData.create();
    final trimmed = name.trim();
    final legacyGold = _state.resource(ResourceType.gold) ~/ 10;
    _commit(fresh.copyWith(
      clan: Clan(
        name: trimmed.isEmpty ? fresh.clan.name : trimmed,
        motto: fresh.clan.motto,
      ),
      tamga: tamgaId,
      resources: ResourceLogic.apply(
        fresh.resources,
        {ResourceType.gold: legacyGold},
      ),
      log: [
        '${trimmed.isEmpty ? fresh.clan.name : trimmed} obası kuruldu, '
            'kağanlığa bağlandı.',
      ],
    ));
  }

  /// Renames the oba and/or its leader; blank fields are left unchanged.
  void rename({String? obaName, String? leaderName}) {
    final oba = obaName?.trim() ?? '';
    final leader = leaderName?.trim() ?? '';
    if (oba.isEmpty && leader.isEmpty) {
      return;
    }
    _commit(_state.copyWith(
      clan:
          oba.isEmpty ? _state.clan : Clan(name: oba, motto: _state.clan.motto),
      profile: leader.isEmpty
          ? _state.profile
          : _state.profile.copyWith(name: leader),
      log: _prependLog('İsimler güncellendi.'),
    ));
  }

  /// Records the council's verdict, shifting the favour of people and beys.
  void resolveKurultay(int choiceIndex) {
    final decision = KurultayDecisions.byId(_state.currentKurultay ?? '');
    if (decision == null ||
        choiceIndex < 0 ||
        choiceIndex >= decision.choices.length) {
      return;
    }
    final choice = decision.choices[choiceIndex];
    _commit(_state.copyWith(
      peopleApproval: _state.peopleApproval + choice.peopleEffect,
      councilApproval: _state.councilApproval + choice.councilEffect,
      resources: ResourceLogic.apply(_state.resources, choice.resourceEffects),
      clearKurultay: true,
      log: _prependLog('Kurultay kararı: ${choice.label}.'),
    ));
  }

  /// The exchange [npcId] offers right now; dialogues rotate by the day so a
  /// figure does not repeat the same line each visit. Returns null if unknown.
  Dialogue? dialogueFor(String npcId) {
    final pool = NpcDialogues.forNpc(npcId);
    if (pool.isEmpty) return null;
    return pool[_state.day.day % pool.length];
  }

  /// Speaks with an NPC: costs one action point, shifts the bond with the
  /// speaker, and may sway the people, the council or the treasury.
  bool talkTo(String npcId, DialogueChoice choice) {
    if (_state.dailyActionPoints < 1) return false;
    final npc = NpcCharacters.byId(npcId);
    final relations = Map<String, int>.from(_state.npcRelations);
    relations[npcId] =
        (_state.relationWith(npcId) + choice.relationEffect).clamp(0, 100);
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      npcRelations: relations,
      peopleApproval: _state.peopleApproval + choice.peopleEffect,
      councilApproval: _state.councilApproval + choice.councilEffect,
      resources: ResourceLogic.apply(_state.resources, choice.resourceEffects),
      log: _prependLog('${npc?.name ?? 'Biri'} ile konuşuldu: ${choice.label}'),
    ));
    return true;
  }

  /// Finishes first-run onboarding: names the oba and leader and opens play.
  void completeOnboarding({
    required String obaName,
    required String leaderName,
  }) {
    final oba = obaName.trim();
    final leader = leaderName.trim();
    _commit(_state.copyWith(
      onboarded: true,
      clan:
          oba.isEmpty ? _state.clan : Clan(name: oba, motto: _state.clan.motto),
      profile: leader.isEmpty
          ? _state.profile
          : _state.profile.copyWith(name: leader),
      log: _prependLog('$oba obasının ocağı yakıldı. Yeni bir ömür başladı.'),
    ));
  }

  void resetGame() {
    _commit(StarterGameData.create());
  }

  /// Advances every active action-goal quest listening to [actionId].
  List<Quest> _trackAction(String actionId) {
    return _state.quests
        .map(
          (quest) => !quest.completed &&
                  quest.goalType == QuestGoalType.action &&
                  quest.goalAction == actionId &&
                  quest.progress < quest.goalTarget
              ? quest.copyWith(progress: quest.progress + 1)
              : quest,
        )
        .toList();
  }

  dynamic _tribeById(String id) {
    for (final tribe in _state.tribes) {
      if (tribe.id == id) return tribe;
    }
    return null;
  }

  dynamic _candidateById(String id) {
    for (final candidate in _state.marriageCandidates) {
      if (candidate.id == id) return candidate;
    }
    return null;
  }

  dynamic _buildingById(List source, String id) {
    for (final building in source) {
      if (building.id == id) return building;
    }
    return null;
  }

  Ritual? _ritualById(String id) {
    for (final ritual in _state.rituals) {
      if (ritual.id == id) return ritual;
    }
    return null;
  }

  SacredPlace? _sacredPlaceById(String id) {
    for (final place in _state.sacredPlaces) {
      if (place.id == id) return place;
    }
    return null;
  }

  FaithState _rollOmen(Map<ResourceType, int> resources) {
    var faith = _state.faithState;
    final badPressure =
        (resources[ResourceType.morale] ?? 0) < 30 || faith.kut < 25;
    final roll = _random.nextInt(100);
    if (roll < 25) {
      final good = faith.kut >= 55 || roll < 10;
      return faith.copyWith(
        omen: good
            ? 'Ateş beklenmedik şekilde gür yandı.'
            : badPressure
                ? 'Sabah rüzgârı kuzeyden sert esti.'
                : 'Kurt uluması oba yakınında duyuldu.',
        omenSeverity: good ? OmenSeverity.good : OmenSeverity.bad,
        activeBlessings: good
            ? ['İyi alamet', ...faith.activeBlessings].take(4).toList()
            : faith.activeBlessings,
        activeWarnings: good
            ? faith.activeWarnings
            : ['Kötü alamet', ...faith.activeWarnings].take(4).toList(),
        kut: faith.kut + (good ? 1 : -1),
      );
    }
    if (roll < 45) {
      return faith.copyWith(
        omen: 'Gece göğünde uzun bir yıldız kaydı.',
        omenSeverity: OmenSeverity.neutral,
      );
    }
    return faith.copyWith(
        omen: 'Alamet yok', omenSeverity: OmenSeverity.neutral);
  }

  List<String> _prependLog(String message) =>
      [message, ..._state.log].take(6).toList();
}

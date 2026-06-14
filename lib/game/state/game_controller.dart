import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/achievements.dart';
import '../data/companion_roles.dart';
import '../data/craft_recipes.dart';
import '../data/equipment.dart';
import '../data/expedition_sites.dart';
import '../data/faith_paths.dart';
import '../data/kurultay_decisions.dart';
import '../data/market_goods.dart';
import '../data/nations.dart';
import '../data/npc_dialogues.dart';
import '../data/recruitment.dart';
import '../data/starter_game_data.dart';
import '../logic/event_logic.dart';
import '../logic/life_logic.dart';
import '../logic/market_logic.dart';
import '../logic/phase_logic.dart';
import '../logic/progression_logic.dart';
import '../logic/resource_logic.dart';
import '../logic/season_logic.dart';
import '../models/achievement.dart';
import '../models/battle_report.dart';
import '../models/clan.dart';
import '../models/craft.dart';
import '../models/event_choice.dart';
import '../models/faith.dart';
import '../models/expedition.dart';
import '../models/nation.dart';
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

  /// Optional sound hook the app wires to the audio service. Kept as a callback
  /// so the pure game logic stays decoupled from audio and remains testable.
  void Function(String name)? onSfx;

  /// Percent added to expedition rolls by gear the leader has equipped.
  int get equipmentBonus {
    var bonus = 0;
    for (final recipeId in _state.equipped.values) {
      bonus += CraftRecipes.byId(recipeId)?.successBonus ?? 0;
    }
    return bonus;
  }

  /// The roles the leader's sworn followers hold, each a real standing bonus.
  Iterable<CompanionRole> get companionRoles => _state.companionRoles.values
      .map(CompanionRoles.byId)
      .whereType<CompanionRole>();

  int get companionWarPercent =>
      companionRoles.fold(0, (s, r) => s + r.warPercent);
  int get companionMarketDiscount =>
      companionRoles.fold(0, (s, r) => s + r.marketDiscountPercent);
  int get companionCraftDiscount =>
      companionRoles.fold(0, (s, r) => s + r.craftDiscountPercent);
  bool get companionCalmsOmens => companionRoles.any((r) => r.calmsOmens);

  /// Daily resource trickle from merchant/hunter/hearth-mother roles.
  Map<ResourceType, int> get companionDailyBonus =>
      CompanionRoles.dailyBonus(_state.companionRoles.values);

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
        equipmentBonus +
        companionWarPercent;
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
    if (next.profile.level > _state.profile.level) {
      onSfx?.call('level_up');
    }
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
  bool exploreRegion(
    String title,
    Map<ResourceType, int> effects, {
    int healthEffect = 0,
    String? note,
  }) {
    if (_state.dailyActionPoints < exploreCost) {
      return false;
    }
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - exploreCost,
      profile: ProgressionLogic.addXp(
          _state.profile.copyWith(
              energy: _state.profile.energy - 12,
              fatigue: _state.profile.fatigue + 8,
              health: _state.profile.health + healthEffect),
          16),
      resources: ResourceLogic.apply(_state.resources, effects),
      quests: _trackAction(GameActions.explore),
      // Scouting the near country is how you find ground fit to settle on.
      landScouted: true,
      log: _prependLog(note ?? '$title keşfi tamamlandı.'),
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
    // A Zanaatkâr (artisan role) shaves a percent off every workshop cost.
    final discount = companionCraftDiscount;
    final costs = {
      for (final entry in recipe.costs.entries)
        entry.key:
            (entry.value * (100 - discount) ~/ 100).clamp(1, 1 << 30).toInt(),
    };
    for (final entry in costs.entries) {
      if (_state.resource(entry.key) < entry.value) {
        return CraftStart.noResources;
      }
    }
    _commit(_state.copyWith(
      resources: ResourceLogic.apply(_state.resources, {
        for (final entry in costs.entries) entry.key: -entry.value,
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
    final price = (MarketLogic.priceFor(good, _state.day.day) *
            (100 - companionMarketDiscount) ~/
            100)
        .clamp(1, 1 << 30)
        .toInt();
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

    // A content, well-fed oba steadily draws and raises new people. A lone
    // traveller with no oba yet draws no one — the world stays quiet.
    final growMorale = resources[ResourceType.morale] ?? 0;
    final growFood = resources[ResourceType.food] ?? 0;
    final growPop = resources[ResourceType.population] ?? 0;
    if (_state.obaFounded &&
        growMorale >= 55 &&
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
    // A sullen council needles the bey's standing day after day.
    if (_state.councilApproval < 25) {
      resources = ResourceLogic.apply(resources, const {
        ResourceType.morale: -2,
        ResourceType.reputation: -1,
      });
    }

    // Provinces and bound states pour tribute into the treasury each day.
    final tribute = _dailyNationIncome();
    if (tribute > 0) {
      resources = ResourceLogic.apply(resources, {ResourceType.gold: tribute});
    }

    // Sworn followers in their roles bring a small daily trickle (merchant
    // gold, hunter food, hearth-mother morale).
    final roleBonus = companionDailyBonus;
    if (roleBonus.isNotEmpty) {
      resources = ResourceLogic.apply(resources, roleBonus);
    }

    // Held provinces drift in loyalty; the neglected break away in revolt.
    final drift = _driftProvinces();
    final nationPolicies = drift.policies;
    final nationLoyalty = drift.loyalty;
    var conqueredRegions = _state.conqueredRegions;
    if (drift.freedCastles.isNotEmpty) {
      conqueredRegions = [
        for (final id in conqueredRegions)
          if (!drift.freedCastles.contains(id)) id,
      ];
      resources = ResourceLogic.apply(resources, const {
        ResourceType.morale: -8,
        ResourceType.reputation: -4,
      });
    }

    // The healer's çadırı mends the wounded back into the ranks.
    var army = _state.army;
    var wounded = _state.wounded;
    if (_state.totalWounded > 0) {
      var cap = healCapacity;
      var healed = 0;
      final a = Map<String, int>.from(army);
      final w = Map<String, int>.from(wounded);
      for (final id in w.keys.toList()) {
        if (cap <= 0) break;
        final heal = w[id]!.clamp(0, cap).toInt();
        w[id] = w[id]! - heal;
        if (w[id]! <= 0) w.remove(id);
        a[id] = (a[id] ?? 0) + heal;
        cap -= heal;
        healed += heal;
      }
      army = a;
      wounded = w;
      if (healed > 0) {
        log = ['$healed yaralı iyileşti, saflara döndü.', ...log]
            .take(6)
            .toList();
      }
    }

    // The council convenes on a fixed cadence — but only once there is an oba
    // and a people to convene. A lone traveller holds no kurultay.
    var kurultayId = _state.currentKurultay;
    var lastKurultay = _state.lastKurultayDay;
    if (_state.obaFounded &&
        kurultayId == null &&
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

    // A revolt is loud news; it leads the chronicle.
    if (drift.notes.isNotEmpty) {
      log = [...drift.notes, ...log].take(6).toList();
    }

    final eventIndex = _state.eventIndex + 1;
    var omenState = _rollOmen(resources);
    // A Kam (kam role) steadies the camp: a bad omen is read away to neutral.
    if (companionCalmsOmens && omenState.omenSeverity == OmenSeverity.bad) {
      omenState = omenState.copyWith(
        omen: 'Kam kötü alameti yatıştırdı.',
        omenSeverity: OmenSeverity.neutral,
        activeWarnings: const [],
      );
    }
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
      nationPolicies: nationPolicies,
      nationLoyalty: nationLoyalty,
      conqueredRegions: conqueredRegions,
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

  /// Reference defence: a unit tougher than this bleeds less, a frailer one
  /// more, so army composition decides who survives a battle.
  static const _refDefense = 6;

  /// Resolves casualties unit by unit. Each kind's losses scale with how its
  /// defence compares to [_refDefense]: heavy cavalry endure where scouts fall.
  /// Returns the surviving army, the new wounded pool, and per-unit tallies of
  /// the slain and the freshly wounded.
  ({
    Map<String, int> army,
    Map<String, int> wounded,
    Map<String, int> lost,
    Map<String, int> hurt,
  }) _battleCasualties(double woundFrac, double lostFrac) {
    final army = <String, int>{};
    final wounded = Map<String, int>.from(_state.wounded);
    final lostMap = <String, int>{};
    final hurtMap = <String, int>{};
    for (final entry in _state.army.entries) {
      final unit = UnitTypes.byId(entry.key);
      final defense = unit?.defense ?? _refDefense;
      final frailty = (_refDefense / defense).clamp(0.5, 2.0);
      final hurt = (entry.value * woundFrac * frailty).round();
      final lost = (entry.value * lostFrac * frailty).round();
      final cappedLost = lost.clamp(0, entry.value).toInt();
      final cappedHurt = hurt.clamp(0, entry.value - cappedLost).toInt();
      final left = entry.value - cappedHurt - cappedLost;
      if (left > 0) army[entry.key] = left;
      if (cappedHurt > 0) {
        wounded[entry.key] = (wounded[entry.key] ?? 0) + cappedHurt;
        hurtMap[entry.key] = cappedHurt;
      }
      if (cappedLost > 0) lostMap[entry.key] = cappedLost;
    }
    return (army: army, wounded: wounded, lost: lostMap, hurt: hurtMap);
  }

  /// Combined defence of every battle-ready unit.
  int get armyDefense {
    var total = 0;
    for (final entry in _state.army.entries) {
      total += (UnitTypes.byId(entry.key)?.defense ?? 0) * entry.value;
    }
    return total;
  }

  /// The most recent battle's outcome, for the UI to recount. Transient — not
  /// part of the saved state.
  BattleReport? lastBattle;

  /// Military weight thrown behind a regional war. Attack drives the punch,
  /// defence steadies the line, and the leader and realm add their weight. A
  /// Savaşçı Başı (warleader role) lifts the whole host by a percent.
  int get warStrength {
    final base = armyStrength * 4 +
        armyDefense * 2 +
        _state.resource(ResourceType.population) +
        _state.profile.warfare * 8 +
        _state.profile.courage * 3 +
        equipmentBonus * 3 +
        _state.completedExpeditions.length * 10 +
        _state.vassalObas * 20 +
        (_state.isKhan ? 50 : 0);
    return base * (100 + companionWarPercent) ~/ 100;
  }

  /// Current relation with a castle.
  int regionRelation(Castle castle) =>
      _state.regionRelations[castle.id] ?? castle.baseRelation;

  /// War success chance against a castle, 10–90 percent.
  int warChanceFor(Castle castle) {
    final s = warStrength;
    return (s * 100 / (s + castle.power)).round().clamp(10, 90);
  }

  /// A center castle is sealed until its nation's outer castles all fall.
  bool centerLocked(Castle castle) {
    if (!castle.isCenter) return false;
    final nation = Nations.nationOf(castle.id);
    if (nation == null) return false;
    return nation.outerCastles.any((c) => !_state.regionConquered(c.id));
  }

  bool canAnnex(Castle castle) =>
      !_state.regionConquered(castle.id) &&
      !centerLocked(castle) &&
      regionRelation(castle) >= Nations.annexRelation;

  /// Diplomacy: gold and an action point to warm a castle toward you.
  bool improveRegionRelation(String castleId) {
    final castle = Nations.castleById(castleId);
    if (castle == null ||
        _state.regionConquered(castleId) ||
        _state.dailyActionPoints < 1 ||
        _state.resource(ResourceType.gold) < 80) {
      return false;
    }
    final next = (regionRelation(castle) + 12).clamp(0, 100).toInt();
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      resources: ResourceLogic.apply(_state.resources, const {
        ResourceType.gold: -80,
      }),
      regionRelations: {..._state.regionRelations, castleId: next},
      log: _prependLog('${castle.name} ile ilişkiler ısındı ($next/100).'),
    ));
    return true;
  }

  /// Annex a friendly castle peacefully once relations are high enough.
  bool annexRegion(String castleId) {
    final castle = Nations.castleById(castleId);
    if (castle == null || !canAnnex(castle)) {
      return false;
    }
    _commit(_takeCastle(
      castle,
      ResourceLogic.apply(_state.resources, {
        ResourceType.reputation: castle.rewardReputation,
        ResourceType.gold: castle.rewardGold ~/ 2,
      }),
      '${castle.name} barışla tamganın altına girdi.',
      _state.dailyActionPoints,
    ));
    return true;
  }

  /// Wage war for a castle. Win to seize it, lose and bleed for it.
  bool attackRegion(String castleId) {
    final castle = Nations.castleById(castleId);
    if (castle == null ||
        _state.regionConquered(castleId) ||
        centerLocked(castle) ||
        _state.dailyActionPoints < 1) {
      return false;
    }
    final chance = warChanceFor(castle);
    final success = _random.nextInt(100) < chance;
    // Winning costs fewer soldiers; a rout wounds and kills many more. Each
    // unit's share of the loss is then weighed by its own toughness.
    final casualties =
        _battleCasualties(success ? 0.10 : 0.25, success ? 0.04 : 0.12);
    final army = casualties.army;
    final wounded = casualties.wounded;
    lastBattle = BattleReport(
      won: success,
      castleName: castle.name,
      chance: chance,
      lost: casualties.lost,
      wounded: casualties.hurt,
    );
    if (success) {
      _commit(_takeCastle(
        castle,
        ResourceLogic.apply(_state.resources, {
          ResourceType.gold: castle.rewardGold,
          ResourceType.reputation: castle.rewardReputation,
          ResourceType.morale: 6,
          ResourceType.food: -15,
        }),
        '${castle.name} kılıçla fethedildi!',
        _state.dailyActionPoints - 1,
        army: army,
        wounded: wounded,
      ));
    } else {
      // A rout can wound the leader too — health bleeds and fatigue mounts.
      final hurtLeader = _state.profile.copyWith(
        health: _state.profile.health - 8,
        fatigue: _state.profile.fatigue + 10,
      );
      _commit(_state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        army: army,
        wounded: wounded,
        profile: hurtLeader,
        resources: ResourceLogic.apply(_state.resources, const {
          ResourceType.morale: -10,
          ResourceType.population: -5,
          ResourceType.food: -15,
        }),
        log: _prependLog(
            '${castle.name} kuşatması püskürtüldü; sen de yara aldın.'),
      ));
    }
    return success;
  }

  /// Commits a castle takeover, flagging a governance verdict when the seized
  /// castle is the capital that completes its nation.
  GameState _takeCastle(
    Castle castle,
    Map<ResourceType, int> resources,
    String logLine,
    int actionPoints, {
    Map<String, int>? army,
    Map<String, int>? wounded,
  }) {
    final conquered = [..._state.conqueredRegions, castle.id];
    final nation = Nations.nationOf(castle.id);
    final nationDone = castle.isCenter &&
        nation != null &&
        nation.castles.every((c) => conquered.contains(c.id));
    return _state.copyWith(
      dailyActionPoints: actionPoints,
      conqueredRegions: conquered,
      army: army,
      wounded: wounded,
      resources: resources,
      pendingNationPolicy: nationDone ? nation.id : null,
      log: _prependLog(nationDone
          ? '$logLine ${nation.name} dize geldi — kaderine sen karar ver.'
          : logLine),
    );
  }

  /// Whether a governance verdict is awaited for a fallen capital.
  Nation? get pendingNation => _state.pendingNationPolicy == null
      ? null
      : Nations.byId(_state.pendingNationPolicy!);

  /// Number of nations fully under your banner.
  int get conqueredNations => _state.nationPolicies.length;

  /// Daily gold from governed nations: a province (vali) pays most, a bound
  /// state (vassal) less; plundered or razed lands yield nothing lasting.
  int _dailyNationIncome() {
    var gold = 0;
    for (final policyId in _state.nationPolicies.values) {
      switch (NationPolicyInfo.byId(policyId)) {
        case NationPolicy.directRule:
          gold += 20;
        case NationPolicy.vali:
          gold += 14;
        case NationPolicy.vassal:
          gold += 8;
        case _:
          break;
      }
    }
    return gold;
  }

  /// Decides the fate of a freshly conquered nation. Each policy trades lasting
  /// income, glory and the people's regard differently.
  bool decideNationPolicy(String nationId, NationPolicy policy) {
    final nation = Nations.byId(nationId);
    if (nation == null || _state.pendingNationPolicy != nationId) {
      return false;
    }
    final reward = nation.center.rewardGold;
    final rep = nation.center.rewardReputation;
    var resources = _state.resources;
    var people = _state.peopleApproval;
    var council = _state.councilApproval;
    var vassals = _state.vassalObas;
    switch (policy) {
      case NationPolicy.vali:
        resources = ResourceLogic.apply(resources, {
          ResourceType.gold: reward ~/ 2,
          ResourceType.reputation: rep,
        });
        people += 4;
        council += 2;
      case NationPolicy.yagma:
        resources = ResourceLogic.apply(resources, {
          ResourceType.gold: reward * 2,
          ResourceType.reputation: rep + 4,
        });
        people -= 12;
        council += 8;
      case NationPolicy.yik:
        resources = ResourceLogic.apply(resources, {
          ResourceType.gold: reward,
          ResourceType.reputation: rep + 8,
          ResourceType.morale: 8,
        });
        people -= 16;
        council += 4;
      case NationPolicy.vassal:
        resources = ResourceLogic.apply(resources, {
          ResourceType.gold: reward ~/ 2,
          ResourceType.reputation: rep,
        });
        vassals += nation.outerCastles.length;
        people += 8;
      case NationPolicy.directRule:
        resources = ResourceLogic.apply(resources, {
          ResourceType.gold: reward,
          ResourceType.reputation: rep + 2,
        });
        people -= 8;
        council += 6;
    }
    // A razed land holds no people to revolt; the rest start at a loyalty set
    // by how the conquest was handled.
    final loyalty = Map<String, int>.from(_state.nationLoyalty);
    final startLoyalty = switch (policy) {
      NationPolicy.vali => 70,
      NationPolicy.vassal => 78,
      NationPolicy.directRule => 55,
      NationPolicy.yagma => 35,
      NationPolicy.yik => 0,
    };
    if (policy == NationPolicy.yik) {
      loyalty.remove(nationId);
    } else {
      loyalty[nationId] = startLoyalty;
    }
    _commit(_state.copyWith(
      resources: resources,
      peopleApproval: people,
      councilApproval: council,
      vassalObas: vassals,
      nationPolicies: {..._state.nationPolicies, nationId: policy.id},
      nationLoyalty: loyalty,
      clearPendingNation: true,
      log: _prependLog('${nation.name}: ${policy.label} kararı verildi.'),
    ));
    return true;
  }

  /// Whether [nationId] is a held province that can revolt (razed lands cannot).
  bool _isHeldProvince(String nationId) {
    final policy = NationPolicyInfo.byId(_state.nationPolicies[nationId] ?? '');
    return policy != null && policy != NationPolicy.yik;
  }

  /// Reinforces a restless province: an action point and gold buy back loyalty.
  bool reinforceProvince(String nationId) {
    if (!_isHeldProvince(nationId) ||
        _state.dailyActionPoints < 1 ||
        _state.resource(ResourceType.gold) < 60) {
      return false;
    }
    final next = (_state.loyaltyOf(nationId) + 25).clamp(0, 100).toInt();
    final nation = Nations.byId(nationId);
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      resources: ResourceLogic.apply(_state.resources, const {
        ResourceType.gold: -60,
      }),
      nationLoyalty: {..._state.nationLoyalty, nationId: next},
      log: _prependLog(
          '${nation?.name ?? 'İl'} sadakati tazelendi ($next/100).'),
    ));
    return true;
  }

  /// Daily loyalty drift for every held province. A respected, popular khan
  /// holds his lands; a neglectful one watches them slip toward revolt. When
  /// loyalty hits zero the province rebels and breaks free. Returns the new
  /// policy and loyalty maps, the freed castle ids, and any rebellion notes.
  ({
    Map<String, String> policies,
    Map<String, int> loyalty,
    List<String> freedCastles,
    List<String> notes,
  }) _driftProvinces() {
    final policies = Map<String, String>.from(_state.nationPolicies);
    final loyalty = Map<String, int>.from(_state.nationLoyalty);
    final freed = <String>[];
    final notes = <String>[];
    final hold = (_state.peopleApproval >= 60 ? 1 : 0) +
        (_state.profile.reputation >= 50 ? 1 : 0) +
        (_state.isKhan ? 1 : 0);
    for (final entry in policies.entries.toList()) {
      final policy = NationPolicyInfo.byId(entry.value);
      if (policy == null || policy == NationPolicy.yik) continue;
      final order = switch (policy) {
        NationPolicy.vali => 1, // a governor keeps order
        NationPolicy.yagma => -1, // the plundered stay resentful
        NationPolicy.directRule => -1, // no local lord to calm the land
        _ => 0,
      };
      final delta = -2 + hold + order;
      final next = (_state.loyaltyOf(entry.key) + delta).clamp(0, 100).toInt();
      if (next <= 0) {
        // Open revolt: the province throws off your banner.
        final nation = Nations.byId(entry.key);
        policies.remove(entry.key);
        loyalty.remove(entry.key);
        if (nation != null) {
          freed.addAll(nation.castles.map((c) => c.id));
          notes.add('${nation.name} isyan etti ve bağımsızlığını ilan etti!');
        }
      } else {
        loyalty[entry.key] = next;
      }
    }
    return (
      policies: policies,
      loyalty: loyalty,
      freedCastles: freed,
      notes: notes
    );
  }

  /// You may only found your oba once the full set of early-game milestones
  /// is behind you: name, followers, a raised tent, a strong bond and a
  /// scouted patch of land. See [PhaseLogic.foundingRequirements].
  bool get canFoundNewOba => PhaseLogic.canFoundOba(_state);

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

  /// Founds the player's own oba under a chosen name and tamga. The same young
  /// founder carries on — this is not a generational reset; their sworn
  /// followers now form the first households of a living settlement, so the
  /// camp gains people and morale. This flips the game into the oba phase,
  /// changing navigation and opening the oba, boy and campaign scenes.
  void foundNewOba(
    String name,
    String tamgaId, {
    Map<String, String> roles = const {},
  }) {
    if (_state.obaFounded || !canFoundNewOba) {
      return;
    }
    final trimmed = name.trim();
    // The followers and their kin become the oba's founding population.
    final founders = 8 + _state.swornFollowers * 4;
    _commit(_state.copyWith(
      obaFounded: true,
      companionRoles: roles,
      clan: Clan(
        name: trimmed.isEmpty ? '${_state.profile.name} Obası' : trimmed,
        motto: _state.clan.motto,
      ),
      tamga: tamgaId,
      profile: _state.profile.copyWith(
        title: 'Oba Beyi',
        reputation: _state.profile.reputation + 5,
      ),
      resources: ResourceLogic.apply(_state.resources, {
        ResourceType.population: founders,
        ResourceType.morale: 10,
      }),
      log: [
        '${trimmed.isEmpty ? '${_state.profile.name} Obası' : trimmed} '
            'kuruldu! Yandaşların ilk haneleri otağ kurdu.',
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
    final people =
        (_state.peopleApproval + choice.peopleEffect).clamp(0, 100).toInt();
    final council =
        (_state.councilApproval + choice.councilEffect).clamp(0, 100).toInt();

    // A verdict echoes through the named beys it touches.
    var relations = _state.npcRelations;
    if (choice.npcEffects.isNotEmpty) {
      relations = Map<String, int>.from(relations);
      for (final e in choice.npcEffects.entries) {
        relations[e.key] = (_state.relationWith(e.key) + e.value).clamp(0, 100);
      }
    }

    // When a verdict pushes approval to an extreme, the realm reacts at once.
    var resources =
        ResourceLogic.apply(_state.resources, choice.resourceEffects);
    var vassals = _state.vassalObas;
    final notes = <String>['Kurultay kararı: ${choice.label}.'];
    if (council <= 20 && vassals > 0) {
      vassals -= 1;
      notes.add('Küskün bir bey obasını alıp gitti (bağlı oba -1).');
    }
    if (people <= 20) {
      resources = ResourceLogic.apply(resources, const {
        ResourceType.population: -6,
        ResourceType.morale: -6,
      });
      notes.add('Küskün halktan göç başladı (nüfus -6).');
    }
    if (people >= 85 && council >= 85) {
      resources = ResourceLogic.apply(resources, const {
        ResourceType.gold: 80,
        ResourceType.morale: 6,
      });
      notes.add('Hem halk hem meclis ardında; obadan armağanlar yağdı.');
    }

    final log = [...notes.reversed, ..._state.log].take(6).toList();
    _commit(_state.copyWith(
      peopleApproval: people,
      councilApproval: council,
      resources: resources,
      vassalObas: vassals,
      npcRelations: relations,
      clearKurultay: true,
      log: log,
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

    var resources =
        ResourceLogic.apply(_state.resources, choice.resourceEffects);
    var people = _state.peopleApproval + choice.peopleEffect;
    var council = _state.councilApproval + choice.councilEffect;
    final notes = <String>[
      '${npc?.name ?? 'Biri'} ile konuşuldu: ${choice.label}'
    ];

    // A word can summon the council, if one is not already in session.
    var kurultayId = _state.currentKurultay;
    if (choice.triggersKurultay != null &&
        kurultayId == null &&
        KurultayDecisions.byId(choice.triggersKurultay!) != null) {
      kurultayId = choice.triggersKurultay;
      notes.insert(0, 'Kurultay toplandı; bir karar bekleniyor.');
    }

    // A defiant or eager word can spill into a raid, fought then and there.
    var army = _state.army;
    var wounded = _state.wounded;
    lastBattle = null;
    if (choice.raidPower > 0) {
      final s = warStrength;
      final chance = (s * 100 / (s + choice.raidPower)).round().clamp(10, 90);
      final won = _random.nextInt(100) < chance;
      final cas = _battleCasualties(won ? 0.08 : 0.20, won ? 0.03 : 0.08);
      army = cas.army;
      wounded = cas.wounded;
      lastBattle = BattleReport(
        won: won,
        castleName: npc?.name ?? 'Akın',
        chance: chance,
        lost: cas.lost,
        wounded: cas.hurt,
      );
      if (won) {
        resources = ResourceLogic.apply(resources, {
          ResourceType.gold: choice.raidPower,
          ResourceType.reputation: 4,
          ResourceType.morale: 4,
        });
        people -= 4;
        council += 6;
        notes.insert(0, 'Akın zaferle döndü; ganimet getirildi.');
      } else {
        resources = ResourceLogic.apply(resources, const {
          ResourceType.morale: -6,
          ResourceType.population: -3,
        });
        council -= 4;
        notes.insert(0, 'Akın bozguna uğradı; kayıp verildi.');
      }
    }

    final log = [...notes, ..._state.log].take(6).toList();
    _commit(_state.copyWith(
      dailyActionPoints: _state.dailyActionPoints - 1,
      npcRelations: relations,
      peopleApproval: people,
      councilApproval: council,
      resources: resources,
      army: army,
      wounded: wounded,
      currentKurultay: kurultayId,
      log: log,
    ));
    return true;
  }

  /// Finishes first-run onboarding: names the traveller (and the oba, if one
  /// is supplied) and opens play.
  void completeOnboarding({
    required String obaName,
    required String leaderName,
  }) {
    final oba = obaName.trim();
    final leader = leaderName.trim();
    final who = leader.isEmpty ? _state.profile.name : leader;
    _commit(_state.copyWith(
      onboarded: true,
      clan:
          oba.isEmpty ? _state.clan : Clan(name: oba, motto: _state.clan.motto),
      profile: leader.isEmpty
          ? _state.profile
          : _state.profile.copyWith(name: leader),
      log: _prependLog('$who tek çadırını kurdu. Yeni bir ömür başladı.'),
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

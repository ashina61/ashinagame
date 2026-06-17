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
import '../data/survival_catalog.dart';
import '../logic/event_logic.dart';
import '../logic/life_logic.dart';
import '../logic/market_logic.dart';
import '../logic/phase_logic.dart';
import '../logic/progression_logic.dart';
import '../logic/resource_logic.dart';
import '../logic/season_logic.dart';
import '../logic/tent_upgrade_logic.dart';
import '../models/achievement.dart';
import '../models/battle_report.dart';
import '../models/clan.dart';
import '../models/craft.dart';
import '../models/event_choice.dart';
import '../models/faith.dart';
import '../models/expedition.dart';
import '../models/horse.dart';
import '../models/nation.dart';
import '../models/npc.dart';
import '../models/quest.dart';
import '../models/resource.dart';
import '../models/season.dart';
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
  factory GameController.restored(GameStorage storage) => GameController(
        storage.load() ?? StarterGameData.create(),
        storage: storage,
      );

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
    _commit(
      _state.copyWith(
        equipped: {..._state.equipped, slot.id: recipeId},
        log: _prependLog(
          '${CraftRecipes.byId(recipeId)?.name ?? recipeId} kuşanıldı.',
        ),
      ),
    );
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
    next = _syncReputation(next);
    if (next.profile.level > _state.profile.level) {
      onSfx?.call('level_up');
    }
    _state = next;
    _storage?.save(next);
    notifyListeners();
  }

  /// Keeps the one true reputation consistent across the whole game. The
  /// [ResourceType.reputation] accumulator is canonical — it is what events,
  /// expeditions, trade and dialogue all feed — and [PlayerProfile.reputation]
  /// is mirrored to it (clamped 0–100) here so the HUD, the character sheet and
  /// the founding gate can never drift apart again.
  GameState _syncReputation(GameState next) {
    final raw = next.resources[ResourceType.reputation];
    if (raw == null) return next;
    final rep = raw.clamp(0, 100).toInt();
    if (rep == raw && rep == next.profile.reputation) return next;
    return next.copyWith(
      profile: next.profile.copyWith(reputation: rep),
      resources: {...next.resources, ResourceType.reputation: rep},
    );
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
    _commit(
      _state.copyWith(
        quests: quests,
        resources: ResourceLogic.apply(_state.resources, quest.resourceRewards),
        profile: ProgressionLogic.addXp(
          ProgressionLogic.applyStats(_state.profile, quest.statRewards),
          quest.xpReward,
        ),
        log: _prependLog(
          'Görev tamamlandı: ${quest.title}. ${quest.rewardText}',
        ),
      ),
    );
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
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - campActionCost,
        resources: ResourceLogic.apply(_state.resources, effects),
        profile: profile,
        quests: _trackAction(actionId),
        log: _prependLog('$title: AP -1, enerji -$adjustedEnergy, XP +$xp.'),
      ),
    );
    return true;
  }

  bool rest() {
    if (_state.dailyActionPoints < 1) return false;
    _commit(
      _state.copyWith(
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
      ),
    );
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
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - exploreCost,
        profile: ProgressionLogic.addXp(
          _state.profile.copyWith(
            energy: _state.profile.energy - 12,
            fatigue: _state.profile.fatigue + 8,
            health: _state.profile.health + healthEffect,
          ),
          16,
        ),
        resources: ResourceLogic.apply(_state.resources, effects),
        quests: _trackAction(GameActions.explore),
        // Scouting the near country is how you find ground fit to settle on.
        landScouted: true,
        log: _prependLog(note ?? '$title keşfi tamamlandı.'),
      ),
    );
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
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - expeditionCost,
        profile: ProgressionLogic.addXp(
          _state.profile.copyWith(
            energy: _state.profile.energy - 18,
            fatigue: _state.profile.fatigue + 12,
          ),
          success ? 28 : 12,
        ),
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
      ),
    );
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
    _commit(
      _state.copyWith(
        resources: ResourceLogic.apply(_state.resources, {
          for (final entry in costs.entries) entry.key: -entry.value,
        }),
        craftQueue: [
          ..._state.craftQueue,
          CraftJob(recipeId: recipe.id, daysLeft: recipe.days),
        ],
        log: _prependLog('${recipe.name} üretimi başladı.'),
      ),
    );
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
    _commit(
      _state.copyWith(
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
      ),
    );
    return true;
  }

  /// Applies a trade if no resource would drop below zero.
  bool tryTrade(String title, Map<ResourceType, int> effects) {
    for (final entry in effects.entries) {
      if (entry.value < 0 && _state.resource(entry.key) + entry.value < 0) {
        return false;
      }
    }
    _commit(
      _state.copyWith(
        resources: ResourceLogic.apply(_state.resources, effects),
        profile: ProgressionLogic.addXp(_state.profile, 8),
        quests: _trackAction(GameActions.trade),
        log: _prependLog('$title takası yapıldı.'),
      ),
    );
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
    var survival = _state.survival.copyWith(
      hunger: _state.survival.hunger - 8,
      thirst: _state.survival.thirst - 10,
      fatigue: _state.survival.fatigue - 12,
      warmth: nextDay.season == Season.winter
          ? _state.survival.warmth - 12
          : _state.survival.warmth - 3,
    );
    var profile = _recoverProfile(resources);
    if (survival.hunger < 25) {
      resources = ResourceLogic.apply(resources, const {
        ResourceType.morale: -3,
      });
      profile = profile.copyWith(health: profile.health - 3);
      log = ['Açlık bastırıyor; sağlık ve moral düştü.', ...log]
          .take(6)
          .toList();
    }
    if (survival.thirst < 25) {
      survival = survival.copyWith(fatigue: survival.fatigue + 10);
      profile = profile.copyWith(health: profile.health - 5);
      log = ['Susuzluk yorgunluğu artırdı; sağlık azaldı.', ...log]
          .take(6)
          .toList();
    }
    if (survival.warmth < 25) {
      profile = profile.copyWith(health: profile.health - 4);
      log = ['Soğuk gece çadırı yokladı; sıcaklık düşük.', ...log]
          .take(6)
          .toList();
    }

    // Starvation bites once the granary is empty.
    if ((resources[ResourceType.food] ?? 0) <= 0) {
      resources = ResourceLogic.apply(resources, const {
        ResourceType.morale: -5,
        ResourceType.population: -1,
      });
      log = [
        'Açlık obayı kırıyor: moral ve nüfus azaldı.',
        ...log,
      ].take(6).toList();
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
        log = [
          '${recipe?.name ?? job.recipeId} tamamlandı, envantere eklendi.',
          ...log,
        ].take(6).toList();
      } else {
        queue.add(ticked);
      }
    }

    // The leader ages a year each time the seasons come full circle.
    var pendingSuccession = false;
    if (LifeLogic.isYearBoundary(nextDay.day)) {
      final agedTo = profile.age + 1;
      profile = profile.copyWith(
        age: agedTo,
        title: LifeLogic.titleForAge(agedTo),
      );
      log = [
        '${profile.name} bir yaş aldı: $agedTo. ${profile.title}.',
        ...log,
      ].take(6).toList();
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
      log = [
        'Oba büyüyor: yeni canlar ocağa katıldı.',
        ...log,
      ].take(6).toList();
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
        log = [
          '$healed yaralı iyileşti, saflara döndü.',
          ...log,
        ].take(6).toList();
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
      log = [
        'Kurultay toplandı; bir karar bekleniyor.',
        ...log,
      ].take(6).toList();
    }

    // A revolt is loud news; it leads the chronicle.
    if (drift.notes.isNotEmpty) {
      log = [...drift.notes, ...log].take(6).toList();
    }

    // Enemy raids make the map feel alive: a free nation musters, a countdown
    // ticks down over days, then the raid strikes — repelled by a strong host,
    // costly to a weak one. The looming raid is shown so the player can arm up.
    var raidCountdown = _state.raidCountdown;
    var raidFrom = _state.raidFrom;
    if (_state.obaFounded) {
      if (raidCountdown > 0) {
        raidCountdown -= 1;
        if (raidCountdown <= 0) {
          final nation = Nations.byId(raidFrom);
          final raidPower = ((nation?.center.power ?? 80) * 0.6).round();
          final s = warStrength;
          final chance = (s * 100 / (s + raidPower)).round().clamp(10, 95);
          final repelled = _random.nextInt(100) < chance;
          if (repelled) {
            resources = ResourceLogic.apply(resources, const {
              ResourceType.reputation: 3,
              ResourceType.morale: 3,
              ResourceType.gold: 30,
            });
            log = [
              '${nation?.name ?? 'Düşman'} akını püskürtüldü!',
              ...log,
            ].take(6).toList();
          } else {
            resources = ResourceLogic.apply(resources, const {
              ResourceType.gold: -40,
              ResourceType.food: -20,
              ResourceType.morale: -8,
              ResourceType.population: -4,
            });
            log = [
              '${nation?.name ?? 'Düşman'} akını obayı vurdu; kayıp verildi.',
              ...log,
            ].take(6).toList();
          }
          raidFrom = '';
          raidCountdown = 0;
        } else {
          log = [
            '${Nations.byId(raidFrom)?.name ?? 'Düşman'} akını '
                '$raidCountdown gün uzakta.',
            ...log,
          ].take(6).toList();
        }
      } else if (nextDay.day % 12 == 0) {
        Nation? src;
        var best = -1;
        for (final n in Nations.all) {
          if (_state.nationConquered(n.id)) continue;
          if (n.center.power > best) {
            best = n.center.power;
            src = n;
          }
        }
        if (src != null) {
          raidCountdown = 3;
          raidFrom = src.id;
          log = [
            '${src.name} sınıra akın için toplanıyor (3 gün).',
            ...log,
          ].take(6).toList();
        }
      }
    }

    // A campaign on the road steps one day closer; the siege itself resolves
    // just after this day's commit (see below).
    var marchDaysLeft = _state.marchDaysLeft;
    if (_state.marching && marchDaysLeft > 0) {
      marchDaysLeft -= 1;
      final name = Nations.castleById(_state.marchTarget)?.name ?? 'hedef';
      log = [
        marchDaysLeft > 0
            ? '$name seferi: $marchDaysLeft gün kaldı.'
            : 'Ordu $name önüne vardı; kuşatma başlıyor.',
        ...log,
      ].take(6).toList();
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
    final spoil = _spoilFood(nextDay.season);
    final actionCooldowns = {
      for (final entry in _state.actionCooldowns.entries)
        if (entry.value > 1) entry.key: entry.value - 1,
    };
    final opportunities = _generateOpportunities(nextDay.day, nextDay.season);
    if (spoil.notes.isNotEmpty) {
      log = [...spoil.notes, ...log].take(6).toList();
    }
    log = [
      'Yaş ${profile.age}, yıl ${LifeLogic.yearOf(nextDay.day)}, '
          '${nextDay.season.label}. Açlık ${survival.hunger}, '
          'susuzluk ${survival.thirst}, yorgunluk ${survival.fatigue}.',
      ...log,
    ].take(6).toList();
    _commit(
      _state.copyWith(
        day: nextDay,
        resources: resources,
        dailyActionPoints: _dailyActionLimit(resources),
        profile: profile,
        survival: survival,
        foodInventory: spoil.inventory,
        foodAges: spoil.ages,
        actionCooldowns: actionCooldowns,
        actionUsesToday: const {},
        dailyOpportunities: opportunities,
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
        currentEvent:
            pendingSuccession ? null : EventLogic.nextEvent(eventIndex),
        clearEvent: pendingSuccession,
        eventIndex: eventIndex,
        raidCountdown: raidCountdown,
        raidFrom: raidFrom,
        marchDaysLeft: marchDaysLeft,
        log: log,
      ),
    );

    // A campaign that reached its walls today storms them now — a second,
    // self-contained commit so the siege report and spoils land cleanly.
    if (_state.marching && _state.marchDaysLeft <= 0) {
      final castle = Nations.castleById(_state.marchTarget);
      if (castle != null && !_state.regionConquered(castle.id)) {
        _resolveSiege(castle, costAp: false);
      } else {
        _commit(_state.copyWith(marchTarget: '', marchDaysLeft: 0));
      }
    }
  }

  bool chooseEvent(EventChoice choice) {
    if (_state.dailyActionPoints < choice.actionPointCost) {
      return false;
    }
    final actionId = choice.faithEffects.containsKey('tore')
        ? GameActions.toreCase
        : GameActions.event;
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - choice.actionPointCost,
        resources: ResourceLogic.apply(
          _state.resources,
          choice.resourceEffects,
        ),
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
      ),
    );
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
    _commit(
      _state.copyWith(
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
          '${ritual.name} tamamlandı: ${ritual.effectDescription}.',
        ),
      ),
    );
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
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        spiritualAdvisor: advisor.copyWith(lastConsultDay: _state.day.day),
        resources: ResourceLogic.apply(_state.resources, {
          ResourceType.morale: isBadOmen ? 3 : 1,
        }),
        faithState: _state.faithState.apply(effects).copyWith(
              omen: isBadOmen
                  ? 'Kam alameti yatıştırdı.'
                  : _state.faithState.omen,
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
      ),
    );
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
    _commit(
      _state.copyWith(
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
      ),
    );
    return true;
  }

  bool spendSkillPoint(String stat) {
    final next = ProgressionLogic.spendSkillPoint(_state.profile, stat);
    if (identical(next, _state.profile) ||
        next.skillPoints == _state.profile.skillPoints) {
      return false;
    }
    _commit(
      _state.copyWith(
        profile: next,
        log: _prependLog('Beceri puanı harcandı: $stat +1.'),
      ),
    );
    return true;
  }

  List<OpportunityDef> todaysOpportunities() {
    final ids = _state.dailyOpportunities.isEmpty
        ? _generateOpportunities(_state.day.day, _state.day.season)
        : _state.dailyOpportunities;
    return [
      for (final id in ids)
        for (final item in SurvivalCatalog.opportunities)
          if (item.id == id) item,
    ];
  }

  BigGoalDef? nextBigGoal() {
    for (final goal in SurvivalCatalog.bigGoals) {
      if (_state.profile.age < goal.minAge) continue;
      if (goal.id == 'survive_week' && _state.day.day >= 7) continue;
      if (goal.id == 'tent_lv2' &&
          (_state.building('main_tent')?.level ?? 1) >= 2) {
        continue;
      }
      if (goal.id == 'tent_lv3' &&
          (_state.building('main_tent')?.level ?? 1) >= 3) {
        continue;
      }
      if (goal.id == 'found_oba' && _state.obaFounded) continue;
      return goal;
    }
    return SurvivalCatalog.bigGoals.last;
  }

  bool performSurvivalAction(String actionId) {
    SurvivalActionDef? action;
    for (final item in SurvivalCatalog.actions) {
      if (item.id == actionId) {
        action = item;
        break;
      }
    }
    if (action == null) return false;
    if (_state.dailyActionPoints < action.apCost) return false;
    if ((_state.actionCooldowns[action.id] ?? 0) > 0) return false;
    if (_state.profile.health < 15) return false;
    for (final entry in action.outputs.entries) {
      if (entry.value < 0 && _state.resource(entry.key) < -entry.value) {
        return false;
      }
    }
    for (final entry in action.foodInputs.entries) {
      if ((_state.foodInventory[entry.key] ?? 0) < entry.value) return false;
    }

    final uses = _state.actionUsesToday[action.id] ?? 0;
    final spammed = uses > 0;
    final outputFactor = spammed ? 0.45 : 1.0;
    final resources = ResourceLogic.apply(_state.resources, {
      for (final entry in action.outputs.entries)
        entry.key: entry.value < 0
            ? entry.value
            : (entry.value * outputFactor).round(),
    });
    final food = Map<String, int>.from(_state.foodInventory);
    for (final entry in action.foodInputs.entries) {
      food[entry.key] = (food[entry.key] ?? 0) - entry.value;
      if ((food[entry.key] ?? 0) <= 0) food.remove(entry.key);
    }
    for (final entry in action.foodOutputs.entries) {
      final amount = (entry.value * outputFactor).round().clamp(0, 99).toInt();
      if (amount > 0) food[entry.key] = (food[entry.key] ?? 0) + amount;
    }
    final survival = _state.survival.copyWith(
      hunger: _state.survival.hunger - action.hungerCost,
      thirst: _state.survival.thirst - action.thirstCost,
      fatigue: _state.survival.fatigue + action.fatigueCost,
    );
    final cooldowns = {..._state.actionCooldowns};
    if (action.cooldownDays > 0) cooldowns[action.id] = action.cooldownDays;
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - action.apCost,
        resources: resources,
        foodInventory: food,
        survival: survival,
        actionCooldowns: cooldowns,
        actionUsesToday: {..._state.actionUsesToday, action.id: uses + 1},
        log: _prependLog(
          spammed
              ? '${action.name} verimsiz geçti. '
                  '${action.hint.isEmpty ? 'Başka işe yönel.' : action.hint}'
              : '${action.name} tamamlandı; ${action.category} ilerledi.',
        ),
      ),
    );
    return true;
  }

  List<Horse> horseMarket() => [
        Horse(
          id: 'market_steppe_${_state.day.day}',
          name: 'Pazar Bozu',
          breed: 'Bozkır Atı',
          price: 55,
          acquiredDay: _state.day.day,
        ),
        Horse(
          id: 'market_pack_${_state.day.day}',
          name: 'Yükçü Kara',
          breed: 'Yük Atı',
          rarity: 'İyi',
          price: 85,
          endurance: 6,
          carryingCapacity: 35,
          acquiredDay: _state.day.day,
        ),
      ];

  bool buyHorse(Horse horse) {
    if (_state.resource(ResourceType.gold) < horse.price) return false;
    _commit(
      _state.copyWith(
        resources: ResourceLogic.apply(
          _state.resources,
          {ResourceType.gold: -horse.price, ResourceType.horse: 1},
        ),
        horses: [..._state.horses, horse],
        log: _prependLog('${horse.name} satın alındı (${horse.breed}).'),
      ),
    );
    return true;
  }

  bool careForHorse(String horseId, String care) {
    if (_state.dailyActionPoints < 1) return false;
    if (!_state.horses.any((horse) => horse.id == horseId)) return false;
    var resources = _state.resources;
    if (care == 'feed') {
      if (_state.resource(ResourceType.food) < 2) return false;
      resources = ResourceLogic.apply(resources, {ResourceType.food: -2});
    }
    final horses = [
      for (final horse in _state.horses)
        if (horse.id == horseId)
          switch (care) {
            'feed' => horse.copyWith(
                hunger: horse.hunger + 22,
                mood: horse.mood + 4,
              ),
            'clean' => horse.copyWith(
                cleanliness: horse.cleanliness + 25,
                loyalty: horse.loyalty + 2,
              ),
            'rest' => horse.copyWith(
                fatigue: horse.fatigue - 25,
                health: horse.health + 3,
              ),
            'train' => horse.copyWith(
                training: horse.training + 8,
                fatigue: horse.fatigue + 12,
                loyalty: horse.loyalty + 1,
              ),
            _ => horse,
          }
        else
          horse,
    ];
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        resources: resources,
        horses: horses,
        log: _prependLog('At bakımı yapıldı: $care.'),
      ),
    );
    return true;
  }

  bool upgradeBuilding(String id) {
    if (id == 'main_tent') return upgradeTent();
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
    _commit(
      _state.copyWith(
        buildings: buildings,
        resources: resources,
        maxDailyActionPoints: _dailyActionLimit(
          resources,
          buildings: buildings,
        ),
        profile: ProgressionLogic.addXp(_state.profile, 20),
        log: _prependLog('${building.name} seviye ${building.level + 1} oldu.'),
      ),
    );
    return true;
  }

  TentUpgradeTarget? tentUpgradeTarget() => TentUpgradeLogic.nextTarget(_state);

  List<String> tentUpgradeBlockReasons() =>
      TentUpgradeLogic.blockReasons(_state);

  String? tentUpgradeBlockReason() {
    final reasons = tentUpgradeBlockReasons();
    return reasons.isEmpty ? null : reasons.first;
  }

  bool canUpgradeTent() => TentUpgradeLogic.canUpgrade(_state);

  bool upgradeTent() {
    final building = _state.building('main_tent');
    final target = TentUpgradeLogic.nextTarget(_state);
    if (building == null || target == null || !canUpgradeTent()) return false;
    final buildings = [
      for (final item in _state.buildings)
        item.id == 'main_tent' ? item.copyWith(level: target.level) : item,
    ];
    final moraleBonus = target.level == 2 ? 2 : target.level == 3 ? 5 : 8;
    final resources = ResourceLogic.apply(_state.resources, {
      for (final entry in target.cost.entries) entry.key: -entry.value,
      ResourceType.morale: moraleBonus,
    });
    _commit(
      _state.copyWith(
        buildings: buildings,
        resources: resources,
        maxDailyActionPoints: _dailyActionLimit(
          resources,
          buildings: buildings,
        ),
        profile: ProgressionLogic.addXp(_state.profile, 25),
        quests: _trackAction(GameActions.tentUpgrade),
        log: _prependLog(
          'Bugün çadır direklerini güçlendirdin: ${target.name} kuruldu.',
        ),
      ),
    );
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
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        resources: ResourceLogic.apply(_state.resources, {
          ...resourceCost,
          ResourceType.reputation: action == 'gift' ? 2 : 1,
        }),
        tribes: [
          for (final item in _state.tribes)
            item.id == tribeId
                ? item.copyWith(
                    relation: item.relation + delta,
                    tradeOpen: tradeOpen,
                  )
                : item,
        ],
        profile: ProgressionLogic.addXp(_state.profile, 14),
        quests: _trackAction(GameActions.diplomacy),
        log: _prependLog(
          '${tribe.name}: diplomasi ($action), ilişki '
          '${delta >= 0 ? '+' : ''}$delta.',
        ),
      ),
    );
    return true;
  }

  bool meetCandidate(String candidateId) {
    if (_state.dailyActionPoints < 1) return false;
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        marriageCandidates: [
          for (final c in _state.marriageCandidates)
            c.id == candidateId ? c.copyWith(relation: c.relation + 8) : c,
        ],
        profile: ProgressionLogic.addXp(_state.profile, 8),
        log: _prependLog('Görüştünüz; adayla araniz biraz daha ısındı.'),
      ),
    );
    return true;
  }

  /// Giving a gift warms a candidate's heart faster than talk, for some gold.
  bool giftCandidate(String candidateId) {
    if (_state.dailyActionPoints < 1 ||
        _state.resource(ResourceType.gold) < 50) {
      return false;
    }
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        resources: ResourceLogic.apply(_state.resources, const {
          ResourceType.gold: -50,
        }),
        marriageCandidates: [
          for (final c in _state.marriageCandidates)
            c.id == candidateId ? c.copyWith(relation: c.relation + 14) : c,
        ],
        profile: ProgressionLogic.addXp(_state.profile, 6),
        log: _prependLog('Armağan verildi; gönlü ısındı.'),
      ),
    );
    return true;
  }

  // Marriage thresholds. The bond you build with the *candidate* (via talk and
  // gifts) is what unlocks the proposal — not the tribe's mood.
  static const marriageRelation = 60;
  static const marriageReputation = 20;
  static const marriageGold = 200;

  /// The leader must reach this age before the marriage stage truly opens, so a
  /// fourteen-year-old traveller cannot wed. They grow into it as the seasons
  /// turn.
  static const marriageMinAge = 16;

  /// The widest believable age gap between the leader and a spouse.
  static const marriageMaxAgeGap = 10;

  /// Why a proposal to [candidateId] cannot go ahead, or null when it can. Used
  /// both to gate [proposeMarriage] and to tell the player what is missing.
  String? marriageBlockReason(String candidateId) {
    final candidate = _candidateById(candidateId);
    if (candidate == null) return 'Aday bulunamadı.';
    if (_state.household.isMarried) return 'Zaten evlisin.';
    if (!candidate.isAvailable) return 'Bu aday artık uygun değil.';
    if (_state.profile.age < marriageMinAge) {
      return 'Henüz evlilik çağında değilsin (en az $marriageMinAge yaş). '
          'Büyümek için zaman ister.';
    }
    if ((candidate.age - _state.profile.age).abs() > marriageMaxAgeGap) {
      return 'Aradaki yaş farkı obanın töresine sığmıyor.';
    }
    if (_state.dailyActionPoints < 1) return 'Bugün takatin kalmadı.';
    if (candidate.relation < marriageRelation) {
      return 'İlişkiniz henüz yeterli değil '
          '(${candidate.relation}/$marriageRelation). Önce görüş, hediye ver.';
    }
    if (_state.resource(ResourceType.reputation) < marriageReputation) {
      return 'Adın daha duyulmalı (itibar en az $marriageReputation).';
    }
    if (_state.resource(ResourceType.gold) < marriageGold) {
      return 'Armağan için yeterli altının yok ($marriageGold gerek).';
    }
    return null;
  }

  bool proposeMarriage(String candidateId) {
    if (marriageBlockReason(candidateId) != null) return false;
    final candidate = _candidateById(candidateId);
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        resources: ResourceLogic.apply(_state.resources, const {
          ResourceType.gold: -marriageGold,
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
            marriageStatus: '${candidate.name} ile evli',
          ),
          40,
        ),
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
      ),
    );
    return true;
  }

  int _dailyActionLimit(Map<ResourceType, int> resources, {List? buildings}) {
    final source = buildings ?? _state.buildings;
    final main = _buildingById(source, 'main_tent');
    var max =
        GameState.baseDailyActionPoints + ((main?.level ?? 1) >= 3 ? 1 : 0);
    if (_state.profile.fatigue >= 75 || _state.survival.fatigue >= 75) {
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
    _commit(
      _state.copyWith(
        resources: ResourceLogic.apply(_state.resources, achievement.reward),
        claimedAchievements: [..._state.claimedAchievements, achievement.id],
        log: _prependLog('Başarım kazanıldı: ${achievement.title}.'),
      ),
    );
    return true;
  }

  /// Seats the late leader's heir, carrying the clan and legacy forward.
  void succeedWithHeir() {
    if (!_state.pendingSuccession) {
      return;
    }
    final heir = LifeLogic.heirOf(_state.profile, _random);
    // The heir inherits the realm, but the funeral spends a fifth of the
    // treasury and the interregnum shakes morale. The heir also starts with a
    // fraction of the founder's renown — written into the canonical reputation
    // accumulator so the mirror in [_commit] keeps the profile in step.
    final resources = {
      ...ResourceLogic.apply(_state.resources, {
        ResourceType.gold: -(_state.resource(ResourceType.gold) ~/ 5),
        ResourceType.morale: -10,
      }),
      ResourceType.reputation: heir.reputation,
    };
    _commit(
      _state.copyWith(
        profile: heir,
        resources: resources,
        generation: _state.generation + 1,
        leaderLifespan: 60 + _random.nextInt(13),
        pendingSuccession: false,
        log: _prependLog(
          '${heir.name} obanın başına geçti. ${_state.generation + 1}. nesil '
          'başladı.',
        ),
      ),
    );
  }

  /// Commits the oba to a belief path, applying its one-time faith lean.
  /// Re-choosing the same path does nothing; switching applies the new lean.
  bool chooseFaithPath(String pathId) {
    final path = FaithPaths.byId(pathId);
    if (path == null || _state.faithPath == pathId) {
      return false;
    }
    _commit(
      _state.copyWith(
        faithPath: pathId,
        faithState: _state.faithState.apply(path.lean),
        log: _prependLog('İnanç yolu seçildi: ${path.name}.'),
      ),
    );
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
    _commit(
      _state.copyWith(
        resources: ResourceLogic.apply(_state.resources, const {
          ResourceType.gold: -120,
        }),
        khanateStanding: _state.khanateStanding + 10,
        log: _prependLog('Kağana haraç ödendi; bağlılık arttı.'),
      ),
    );
    return true;
  }

  /// Answers the khan's call to war: action point and food for standing,
  /// reputation and plunder.
  bool joinKhanCampaign() {
    if (_state.dailyActionPoints < 1 ||
        _state.resource(ResourceType.food) < 20) {
      return false;
    }
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        resources: ResourceLogic.apply(_state.resources, const {
          ResourceType.food: -20,
          ResourceType.gold: 50,
          ResourceType.reputation: 3,
        }),
        profile: ProgressionLogic.addXp(
          _state.profile.copyWith(fatigue: _state.profile.fatigue + 8),
          24,
        ),
        khanateStanding: _state.khanateStanding + 6,
        log: _prependLog(
          'Kağanın seferine katılındı; itibar ve ganimet kazanıldı.',
        ),
      ),
    );
    return true;
  }

  /// Sits at the khan's divan: an action point for standing and wisdom.
  bool attendDivan() {
    if (_state.dailyActionPoints < 1) {
      return false;
    }
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        profile: ProgressionLogic.addXp(
          ProgressionLogic.applyStats(_state.profile, const {'wisdom': 1}),
          18,
        ),
        khanateStanding: _state.khanateStanding + 4,
        log: _prependLog('Divana katılındı; söz sahibi olundu.'),
      ),
    );
    return true;
  }

  /// Rallies a nearby oba under the banner, raising power.
  bool rallyObas() {
    if (_state.resource(ResourceType.gold) < 200 ||
        _state.profile.reputation < 25) {
      return false;
    }
    _commit(
      _state.copyWith(
        resources: ResourceLogic.apply(_state.resources, const {
          ResourceType.gold: -200,
        }),
        vassalObas: _state.vassalObas + 1,
        khanateStanding: _state.khanateStanding + 5,
        log: _prependLog('Bir oba senin tamganın altına girdi.'),
      ),
    );
    return true;
  }

  /// Stakes everything on overthrowing the khan. Success seats you on the
  /// throne; failure scatters followers and burns standing.
  bool attemptRebellion() {
    if (!canRebel) {
      return false;
    }
    final chance = (40 + (khanatePower - rebellionPowerThreshold) ~/ 4).clamp(
      20,
      90,
    );
    final success = _random.nextInt(100) < chance;
    if (success) {
      _commit(
        _state.copyWith(
          isKhan: true,
          khanateStanding: 100,
          resources: ResourceLogic.apply(_state.resources, const {
            ResourceType.gold: 600,
            ResourceType.reputation: 20,
            ResourceType.morale: 15,
          }),
          profile: _state.profile.copyWith(title: 'Kağan'),
          log: _prependLog(
            'İSYAN ZAFERLE BİTTİ! Kağan devrildi, tahta sen geçtin.',
          ),
        ),
      );
    } else {
      _commit(
        _state.copyWith(
          khanateStanding: (_state.khanateStanding - 30).clamp(0, 100).toInt(),
          vassalObas: 0,
          resources: ResourceLogic.apply(_state.resources, const {
            ResourceType.morale: -20,
            ResourceType.population: -8,
            ResourceType.gold: -200,
          }),
          log: _prependLog('İsyan bastırıldı; oba ağır kayıp verdi.'),
        ),
      );
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
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        resources: ResourceLogic.apply(_state.resources, {
          for (final entry in cost.entries) entry.key: -entry.value,
        }),
        army: {..._state.army, unitId: _state.unitCount(unitId) + qty},
        log: _prependLog('$qty ${unit.name} saflara katıldı.'),
      ),
    );
    return true;
  }

  /// Wins over a follower waiting at the han: pays gold, binds them as a sworn
  /// follower (relation 80) in a chosen role. Counts toward the three followers
  /// an oba needs. Returns false without the action point or the gold.
  bool recruitCompanion(
    String npcId, {
    required String roleId,
    required int goldCost,
  }) {
    if (_state.dailyActionPoints < 1 ||
        _state.relationWith(npcId) >= 75 ||
        _state.resource(ResourceType.gold) < goldCost) {
      return false;
    }
    final name = NpcCharacters.byId(npcId)?.name ?? npcId;
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        npcRelations: {..._state.npcRelations, npcId: 80},
        companionRoles: {..._state.companionRoles, npcId: roleId},
        resources: ResourceLogic.apply(_state.resources, {
          ResourceType.gold: -goldCost,
        }),
        log: _prependLog('$name obana katıldı; yoldaşın oldu.'),
      ),
    );
    return true;
  }

  /// How far the marching army has come, 0..1, for the campaign track UI.
  double get marchProgress {
    final castle = marchCastle;
    if (castle == null) return 0;
    final total = marchDaysTo(castle);
    if (total <= 0) return 1;
    return ((total - _state.marchDaysLeft) / total).clamp(0.0, 1.0);
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
  String? lastTalkFeedback;

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
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        resources: ResourceLogic.apply(_state.resources, const {
          ResourceType.gold: -80,
        }),
        regionRelations: {..._state.regionRelations, castleId: next},
        log: _prependLog('${castle.name} ile ilişkiler ısındı ($next/100).'),
      ),
    );
    return true;
  }

  /// Annex a friendly castle peacefully once relations are high enough.
  bool annexRegion(String castleId) {
    final castle = Nations.castleById(castleId);
    if (castle == null || !canAnnex(castle)) {
      return false;
    }
    _commit(
      _takeCastle(
        castle,
        ResourceLogic.apply(_state.resources, {
          ResourceType.reputation: castle.rewardReputation,
          ResourceType.gold: castle.rewardGold ~/ 2,
        }),
        '${castle.name} barışla tamganın altına girdi.',
        _state.dailyActionPoints,
      ),
    );
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
    return _resolveSiege(castle, costAp: true);
  }

  /// Days a campaign needs to reach a castle — a capital lies deeper.
  int marchDaysTo(Castle castle) => castle.isCenter ? 3 : 2;

  /// Provisions a campaign burns on the road to a castle.
  int marchFoodCost(Castle castle) => castle.isCenter ? 25 : 8;

  /// Status of the army on campaign: '', 'Yolda' or 'Kuşatmada'.
  String get marchStatus {
    if (_state.marchTarget.isEmpty) return '';
    return _state.marchDaysLeft <= 0 ? 'Kuşatmada' : 'Yolda';
  }

  /// The castle the army is marching on, or null.
  Castle? get marchCastle => _state.marchTarget.isEmpty
      ? null
      : Nations.castleById(_state.marchTarget);

  /// Sends the army on campaign toward a castle. It marches over several days
  /// (one step per day-end) and the siege resolves automatically on arrival.
  bool startMarch(String castleId) {
    final castle = Nations.castleById(castleId);
    if (castle == null ||
        _state.marching ||
        _state.regionConquered(castleId) ||
        centerLocked(castle) ||
        _state.dailyActionPoints < 1 ||
        _state.resource(ResourceType.food) < marchFoodCost(castle)) {
      return false;
    }
    final days = marchDaysTo(castle);
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        resources: ResourceLogic.apply(_state.resources, {
          ResourceType.food: -marchFoodCost(castle),
        }),
        marchTarget: castle.id,
        marchDaysLeft: days,
        log: _prependLog(
          'Ordu ${castle.name} üzerine yürüyüşe geçti ($days gün).',
        ),
      ),
    );
    return true;
  }

  /// Resolves a siege against [castle], whether reached instantly via
  /// [attackRegion] or at the end of a [startMarch] campaign.
  bool _resolveSiege(Castle castle, {required bool costAp}) {
    final chance = warChanceFor(castle);
    final success = _random.nextInt(100) < chance;
    // Winning costs fewer soldiers; a rout wounds and kills many more. Each
    // unit's share of the loss is then weighed by its own toughness.
    final casualties = _battleCasualties(
      success ? 0.10 : 0.25,
      success ? 0.04 : 0.12,
    );
    final army = casualties.army;
    final wounded = casualties.wounded;
    lastBattle = BattleReport(
      won: success,
      castleName: castle.name,
      chance: chance,
      lost: casualties.lost,
      wounded: casualties.hurt,
    );
    final ap = costAp ? _state.dailyActionPoints - 1 : _state.dailyActionPoints;
    if (success) {
      _commit(
        _takeCastle(
          castle,
          ResourceLogic.apply(_state.resources, {
            ResourceType.gold: castle.rewardGold,
            ResourceType.reputation: castle.rewardReputation,
            ResourceType.morale: 6,
            ResourceType.food: -15,
          }),
          '${castle.name} kılıçla fethedildi!',
          ap,
          army: army,
          wounded: wounded,
        ),
      );
    } else {
      // A rout can wound the leader too — health bleeds and fatigue mounts.
      final hurtLeader = _state.profile.copyWith(
        health: _state.profile.health - 8,
        fatigue: _state.profile.fatigue + 10,
      );
      _commit(
        _state.copyWith(
          dailyActionPoints: ap,
          army: army,
          wounded: wounded,
          profile: hurtLeader,
          marchTarget: '',
          marchDaysLeft: 0,
          resources: ResourceLogic.apply(_state.resources, const {
            ResourceType.morale: -10,
            ResourceType.population: -5,
            ResourceType.food: -15,
          }),
          log: _prependLog(
            '${castle.name} kuşatması püskürtüldü; sen de yara aldın.',
          ),
        ),
      );
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
      marchTarget: '',
      marchDaysLeft: 0,
      pendingNationPolicy: nationDone ? nation.id : null,
      log: _prependLog(
        nationDone
            ? '$logLine ${nation.name} dize geldi — kaderine sen karar ver.'
            : logLine,
      ),
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
    _commit(
      _state.copyWith(
        resources: resources,
        peopleApproval: people,
        councilApproval: council,
        vassalObas: vassals,
        nationPolicies: {..._state.nationPolicies, nationId: policy.id},
        nationLoyalty: loyalty,
        clearPendingNation: true,
        log: _prependLog('${nation.name}: ${policy.label} kararı verildi.'),
      ),
    );
    return true;
  }

  /// Whether [nationId] is a held province that can revolt.
  ///
  /// Razed lands cannot revolt.
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
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        resources: ResourceLogic.apply(_state.resources, const {
          ResourceType.gold: -60,
        }),
        nationLoyalty: {..._state.nationLoyalty, nationId: next},
        log: _prependLog(
          '${nation?.name ?? 'İl'} sadakati tazelendi ($next/100).',
        ),
      ),
    );
    return true;
  }

  /// A restless province's fate is a choice, not just a warning. Each action
  /// trades something — treasury, the people's fear, or töre — for order.
  bool manageProvince(String nationId, String action) {
    if (!_isHeldProvince(nationId) || _state.dailyActionPoints < 1) {
      return false;
    }
    final cost = switch (action) {
      'replace' => const {ResourceType.gold: 80},
      'garrison' => const {ResourceType.gold: 60},
      'gift' => const {ResourceType.food: 20},
      _ => const <ResourceType, int>{},
    };
    for (final e in cost.entries) {
      if (_state.resource(e.key) < e.value) return false;
    }
    var gain = 0;
    var people = _state.peopleApproval;
    var faith = _state.faithState;
    switch (action) {
      case 'lower_tax':
        gain = 12;
        people += 2;
      case 'replace':
        gain = 8;
      case 'garrison':
        gain = 15;
      case 'suppress':
        gain = 20;
        people -= 10;
        faith = faith.apply({'tore': -5, 'kut': -2});
      case 'gift':
        gain = 10;
      default:
        return false;
    }
    final next = (_state.loyaltyOf(nationId) + gain).clamp(0, 100).toInt();
    final nation = Nations.byId(nationId);
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        resources: ResourceLogic.apply(_state.resources, {
          for (final e in cost.entries) e.key: -e.value,
        }),
        nationLoyalty: {..._state.nationLoyalty, nationId: next},
        peopleApproval: people,
        faithState: faith,
        log: _prependLog(
          '${nation?.name ?? 'İl'} için karar verildi; '
          'sadakat $next/100.',
        ),
      ),
    );
    return true;
  }

  /// The player's answer to a looming raid: brace, parley, strike first or
  /// pull back. Returns false if no raid looms or the cost cannot be met.
  bool respondToRaid(String action) {
    if (!_state.raidLooming || _state.dailyActionPoints < 1) return false;
    final nation = Nations.byId(_state.raidFrom);
    final name = nation?.name ?? 'Düşman';
    switch (action) {
      case 'defend':
        if (_state.resource(ResourceType.gold) < 40) return false;
        _commit(
          _state.copyWith(
            dailyActionPoints: _state.dailyActionPoints - 1,
            resources: ResourceLogic.apply(_state.resources, const {
              ResourceType.gold: -40,
              ResourceType.morale: 4,
            }),
            log: _prependLog('Savunma hazırlandı; oba teyakkuzda.'),
          ),
        );
        return true;
      case 'envoy':
        if (_state.resource(ResourceType.gold) < 80) return false;
        final appeased = _random.nextInt(100) < 55;
        _commit(
          _state.copyWith(
            dailyActionPoints: _state.dailyActionPoints - 1,
            resources: ResourceLogic.apply(_state.resources, const {
              ResourceType.gold: -80,
            }),
            raidCountdown: appeased ? 0 : _state.raidCountdown,
            raidFrom: appeased ? '' : _state.raidFrom,
            log: _prependLog(
              appeased
                  ? '$name elçiyle yatıştı; akın dağıldı.'
                  : 'Elçi geri çevrildi; akın sürüyor.',
            ),
          ),
        );
        return true;
      case 'preempt':
        final raidPower = ((nation?.center.power ?? 80) * 0.6).round();
        final s = warStrength;
        final chance = (s * 100 / (s + raidPower)).round().clamp(10, 90);
        final won = _random.nextInt(100) < chance;
        final cas = _battleCasualties(won ? 0.08 : 0.20, won ? 0.03 : 0.08);
        _commit(
          _state.copyWith(
            dailyActionPoints: _state.dailyActionPoints - 1,
            army: cas.army,
            wounded: cas.wounded,
            raidCountdown: won ? 0 : _state.raidCountdown,
            raidFrom: won ? '' : _state.raidFrom,
            resources: ResourceLogic.apply(
              _state.resources,
              won
                  ? const {
                      ResourceType.gold: 40,
                      ResourceType.reputation: 4,
                      ResourceType.morale: 4,
                    }
                  : const {
                      ResourceType.morale: -6,
                      ResourceType.population: -3,
                    },
            ),
            log: _prependLog(
              won
                  ? 'Baskın tuttu; akıncılar dağıtıldı.'
                  : 'Baskın geri tepti; kayıp verildi.',
            ),
          ),
        );
        return won;
      case 'evacuate':
        _commit(
          _state.copyWith(
            dailyActionPoints: _state.dailyActionPoints - 1,
            resources: ResourceLogic.apply(_state.resources, const {
              ResourceType.gold: -20,
              ResourceType.morale: -2,
            }),
            raidCountdown: 0,
            raidFrom: '',
            log: _prependLog('Halk ve sürüler geri çekildi; akın boşa düştü.'),
          ),
        );
        return true;
      default:
        return false;
    }
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
      notes: notes,
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
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        resources: ResourceLogic.apply(_state.resources, {
          for (final entry in source.cost.entries) entry.key: -entry.value,
          ...source.extraEffects,
          ResourceType.population: people,
        }),
        log: _prependLog('${source.name}: obaya $people kişi katıldı.'),
      ),
    );
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
    _commit(
      _state.copyWith(
        obaFounded: true,
        companionRoles: roles,
        clan: Clan(
          name: trimmed.isEmpty ? '${_state.profile.name} Obası' : trimmed,
          motto: _state.clan.motto,
        ),
        tamga: tamgaId,
        profile: _state.profile.copyWith(title: 'Oba Beyi'),
        resources: ResourceLogic.apply(_state.resources, {
          ResourceType.population: founders,
          ResourceType.morale: 10,
          ResourceType.reputation: 5,
        }),
        log: [
          '${trimmed.isEmpty ? '${_state.profile.name} Obası' : trimmed} '
              'kuruldu! Yandaşların ilk haneleri otağ kurdu.',
        ],
      ),
    );
  }

  /// Renames the oba and/or its leader; blank fields are left unchanged.
  void rename({String? obaName, String? leaderName}) {
    final oba = obaName?.trim() ?? '';
    final leader = leaderName?.trim() ?? '';
    if (oba.isEmpty && leader.isEmpty) {
      return;
    }
    _commit(
      _state.copyWith(
        clan: oba.isEmpty
            ? _state.clan
            : Clan(name: oba, motto: _state.clan.motto),
        profile: leader.isEmpty
            ? _state.profile
            : _state.profile.copyWith(name: leader),
        log: _prependLog('İsimler güncellendi.'),
      ),
    );
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
    var resources = ResourceLogic.apply(
      _state.resources,
      choice.resourceEffects,
    );
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
    _commit(
      _state.copyWith(
        peopleApproval: people,
        councilApproval: council,
        resources: resources,
        vassalObas: vassals,
        npcRelations: relations,
        clearKurultay: true,
        log: log,
      ),
    );
  }

  /// The exchange [npcId] offers right now; dialogues rotate by the day so a
  /// figure does not repeat the same line each visit. Returns null if unknown.
  Dialogue? dialogueFor(String npcId) {
    final pool = NpcDialogues.contextualFor(npcId, _state);
    if (pool.isEmpty) return null;
    final recent = _state.npcRecentDialogues[npcId] ?? const <String>[];
    final candidates = [
      for (final d in pool)
        if (!recent.contains(d.id)) d,
    ];
    final usable = candidates.isEmpty ? pool : candidates;
    final relationShift = (_state.relationWith(npcId) / 20).floor();
    final index = (_state.day.day + _state.profile.age + relationShift) %
        usable.length;
    return usable[index];
  }

  /// Speaks with an NPC: costs one action point, shifts the bond with the
  /// speaker, and may sway the people, the council or the treasury.
  bool talkTo(String npcId, DialogueChoice choice) {
    if (_state.dailyActionPoints < 1) return false;
    lastTalkFeedback = null;
    final npc = NpcCharacters.byId(npcId);
    final offered = dialogueFor(npcId);
    final sameDay = _state.npcLastTalkDay[npcId] == _state.day.day;
    final sameType = _state.npcLastTalkType[npcId] == choice.label;
    final spammed = sameDay && sameType;
    final relations = Map<String, int>.from(_state.npcRelations);
    final relationEffect = spammed
        ? 0
        : (sameDay ? choice.relationEffect ~/ 2 : choice.relationEffect);
    relations[npcId] =
        (_state.relationWith(npcId) + relationEffect).clamp(0, 100);

    var resources = ResourceLogic.apply(
      _state.resources,
      spammed ? const {} : choice.resourceEffects,
    );
    var people = _state.peopleApproval + (spammed ? 0 : choice.peopleEffect);
    var council = _state.councilApproval + (spammed ? 0 : choice.councilEffect);
    final notes = <String>[
      spammed
          ? '${npc?.name ?? 'Biri'} aynı sözü uzatmadı.'
          : '${npc?.name ?? 'Biri'} ile konuşuldu: ${choice.label}',
    ];
    if (spammed) {
      lastTalkFeedback = 'Bugün bunu zaten konuştuk.';
    } else if (sameDay) {
      lastTalkFeedback =
          'Kısa konuştunuz; aynı gün ikinci sözün etkisi azaldı.';
    }

    // A word can summon the council, if one is not already in session.
    var kurultayId = _state.currentKurultay;
    if (!spammed &&
        choice.triggersKurultay != null &&
        kurultayId == null &&
        KurultayDecisions.byId(choice.triggersKurultay!) != null) {
      kurultayId = choice.triggersKurultay;
      notes.insert(0, 'Kurultay toplandı; bir karar bekleniyor.');
    }

    // A defiant or eager word can spill into a raid, fought then and there.
    var army = _state.army;
    var wounded = _state.wounded;
    lastBattle = null;
    if (!spammed && choice.raidPower > 0) {
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
    _commit(
      _state.copyWith(
        dailyActionPoints: _state.dailyActionPoints - 1,
        npcRelations: relations,
        npcRecentDialogues: _rememberDialogue(npcId, offered?.id),
        npcLastTalkDay: {..._state.npcLastTalkDay, npcId: _state.day.day},
        npcLastTalkType: {..._state.npcLastTalkType, npcId: choice.label},
        peopleApproval: people,
        councilApproval: council,
        resources: resources,
        army: army,
        wounded: wounded,
        currentKurultay: kurultayId,
        log: log,
      ),
    );
    return true;
  }

  /// Finishes first-run onboarding: names the traveller (and the oba, if one
  /// is supplied) and opens play.
  void completeOnboarding({
    required String obaName,
    required String leaderName,
    String? portrait,
  }) {
    final oba = obaName.trim();
    final leader = leaderName.trim();
    final who = leader.isEmpty ? _state.profile.name : leader;
    _commit(
      _state.copyWith(
        onboarded: true,
        clan: oba.isEmpty
            ? _state.clan
            : Clan(name: oba, motto: _state.clan.motto),
        profile: _state.profile.copyWith(
          name: leader.isEmpty ? null : leader,
          portrait: portrait,
        ),
        log: _prependLog('$who tek çadırını kurdu. Yeni bir ömür başladı.'),
      ),
    );
  }

  /// Changes the leader's cosmetic portrait (from the character screen).
  void setPortrait(String portrait) {
    _commit(
      _state.copyWith(profile: _state.profile.copyWith(portrait: portrait)),
    );
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
      omen: 'Alamet yok',
      omenSeverity: OmenSeverity.neutral,
    );
  }

  Map<String, List<String>> _rememberDialogue(String npcId, String? id) {
    if (id == null) return _state.npcRecentDialogues;
    final current = _state.npcRecentDialogues[npcId] ?? const <String>[];
    return {
      ..._state.npcRecentDialogues,
      npcId: [id, ...current.where((item) => item != id)].take(4).toList(),
    };
  }

  _FoodSpoilResult _spoilFood(Season season) {
    final inventory = Map<String, int>.from(_state.foodInventory);
    final ages = <String, int>{};
    final notes = <String>[];
    final storageLevel = _state.building('storage')?.level ?? 0;
    for (final entry in inventory.entries.toList()) {
      final food = SurvivalCatalog.foods.firstWhere(
        (item) => item.id == entry.key,
        orElse: () => SurvivalCatalog.foods.first,
      );
      final age = (_state.foodAges[entry.key] ?? 0) + 1;
      final protection = storageLevel + (season == Season.winter ? 2 : 0);
      if (age > food.spoilDays + protection) {
        final lost = (entry.value / 2).ceil();
        inventory[entry.key] = (entry.value - lost).clamp(0, 999).toInt();
        if (inventory[entry.key] == 0) inventory.remove(entry.key);
        notes.add('${food.name} bozuldu: -$lost.');
      } else {
        ages[entry.key] = age;
      }
    }
    return _FoodSpoilResult(inventory, ages, notes);
  }

  List<String> _generateOpportunities(int day, Season season) {
    final pool = [
      for (final item in SurvivalCatalog.opportunities)
        if (season == Season.winter
            ? item.category != 'su' || _state.survival.thirst < 55
            : true)
          item,
    ];
    final count = 3 + (day % 3);
    return [
      for (var i = 0; i < count; i++) pool[(day + i * 2) % pool.length].id,
    ];
  }

  List<String> _prependLog(String message) =>
      [message, ..._state.log].take(6).toList();
}

class _FoodSpoilResult {
  const _FoodSpoilResult(this.inventory, this.ages, this.notes);
  final Map<String, int> inventory;
  final Map<String, int> ages;
  final List<String> notes;
}

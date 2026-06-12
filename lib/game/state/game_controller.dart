import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/craft_recipes.dart';
import '../data/expedition_sites.dart';
import '../data/market_goods.dart';
import '../data/starter_game_data.dart';
import '../logic/event_logic.dart';
import '../logic/market_logic.dart';
import '../logic/progression_logic.dart';
import '../logic/resource_logic.dart';
import '../logic/season_logic.dart';
import '../models/craft.dart';
import '../models/event_choice.dart';
import '../models/expedition.dart';
import '../models/quest.dart';
import '../models/resource.dart';
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

  static const campActionCost = 2;
  static const exploreCost = 3;
  static const expeditionCost = 4;

  final GameStorage? _storage;
  final Random _random;
  GameState _state;
  GameState get state => _state;

  /// Percent added to expedition rolls by owned equipment.
  int get equipmentBonus {
    var bonus = 0;
    for (final recipe in CraftRecipes.all) {
      if (_state.craftedCount(recipe.id) > 0) {
        bonus += recipe.successBonus;
      }
    }
    return bonus;
  }

  /// Final success chance for a site, clamped to 5–95 percent.
  int successChanceFor(ExpeditionSite site) {
    final chance =
        site.baseChance + _state.profile.courage * 2 + equipmentBonus;
    return chance.clamp(5, 95);
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
      profile: ProgressionLogic.applyStats(_state.profile, quest.statRewards),
      log: _prependLog('Görev tamamlandı: ${quest.title}. ${quest.rewardText}'),
    ));
  }

  /// Daily camp job; returns false when energy runs short.
  bool performCampAction(
    String actionId,
    String title,
    Map<ResourceType, int> effects,
  ) {
    if (_state.energy < campActionCost) {
      return false;
    }
    _commit(_state.copyWith(
      energy: _state.energy - campActionCost,
      resources: ResourceLogic.apply(_state.resources, effects),
      quests: _trackAction(actionId),
      log: _prependLog('$title aksiyonu obaya etki etti.'),
    ));
    return true;
  }

  /// Scouting run from the expedition list; returns false without energy.
  bool exploreRegion(String title, Map<ResourceType, int> effects) {
    if (_state.energy < exploreCost) {
      return false;
    }
    _commit(_state.copyWith(
      energy: _state.energy - exploreCost,
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
        _state.energy < expeditionCost) {
      return null;
    }
    final success = _random.nextInt(100) < successChanceFor(site);
    final effects = success ? site.gains : site.losses;
    _commit(_state.copyWith(
      energy: _state.energy - expeditionCost,
      resources: ResourceLogic.apply(_state.resources, effects),
      quests: _trackAction(GameActions.expedition),
      completedExpeditions: success
          ? [..._state.completedExpeditions, site.id]
          : _state.completedExpeditions,
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
    final grants = good?.grants;
    if (good == null || grants == null || _state.stockOf(good.id) <= 0) {
      return false;
    }
    final price = MarketLogic.priceFor(good, _state.day.day);
    if (_state.resource(ResourceType.gold) < price) {
      return false;
    }
    _commit(_state.copyWith(
      resources: ResourceLogic.apply(_state.resources, {
        ResourceType.gold: -price,
        grants: good.amount,
      }),
      marketStock: {
        ..._state.marketStock,
        good.id: _state.stockOf(good.id) - 1,
      },
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
      quests: _trackAction(GameActions.trade),
      log: _prependLog('$title takası yapıldı.'),
    ));
    return true;
  }

  void endDay() {
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

    final eventIndex = _state.eventIndex + 1;
    _commit(_state.copyWith(
      day: nextDay,
      resources: resources,
      energy: GameState.maxEnergy,
      collapseDays: collapseDays,
      gameOver: gameOver,
      gameOverReason: gameOver
          ? 'Moral günlerce sıfırda kaldı; oba dağıldı ve halk '
              'başka beyliklere göçtü.'
          : null,
      quests: quests,
      craftQueue: queue,
      craftedItems: crafted,
      marketStock: MarketGoods.startingStock(),
      currentEvent: EventLogic.nextEvent(eventIndex),
      eventIndex: eventIndex,
      log: log,
    ));
  }

  void chooseEvent(EventChoice choice) {
    _commit(_state.copyWith(
      resources: ResourceLogic.apply(_state.resources, choice.resourceEffects),
      profile: ProgressionLogic.applyStats(_state.profile, choice.statEffects),
      quests: _trackAction(GameActions.event),
      clearEvent: true,
      log: _prependLog('Olay seçimi: ${choice.label}. ${choice.description}'),
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

  List<String> _prependLog(String message) =>
      [message, ..._state.log].take(6).toList();
}

import 'package:flutter/foundation.dart';

import '../data/starter_game_data.dart';
import '../logic/event_logic.dart';
import '../logic/progression_logic.dart';
import '../logic/resource_logic.dart';
import '../logic/season_logic.dart';
import '../models/event_choice.dart';
import '../models/quest.dart';
import '../models/resource.dart';
import 'game_state.dart';
import 'game_storage.dart';

class GameController extends ChangeNotifier {
  GameController(this._state, {GameStorage? storage}) : _storage = storage;

  factory GameController.starter() => GameController(StarterGameData.create());

  /// Restores the saved run, or starts a fresh one.
  factory GameController.restored(GameStorage storage) =>
      GameController(storage.load() ?? StarterGameData.create(),
          storage: storage);

  static const campActionCost = 2;
  static const exploreCost = 3;
  static const expeditionCost = 4;

  final GameStorage? _storage;
  GameState _state;
  GameState get state => _state;

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

  /// Embarks on a map expedition; returns false without energy.
  bool embarkExpedition(String title, Map<ResourceType, int> effects) {
    if (_state.energy < expeditionCost) {
      return false;
    }
    _commit(_state.copyWith(
      energy: _state.energy - expeditionCost,
      resources: ResourceLogic.apply(_state.resources, effects),
      quests: _trackAction(GameActions.expedition),
      log: _prependLog('$title seferi tamamlandı.'),
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

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

class GameController extends ChangeNotifier {
  GameController(this._state);

  factory GameController.starter() => GameController(StarterGameData.create());

  GameState _state;
  GameState get state => _state;

  void completeQuest(String id) {
    Quest? quest;
    for (final item in _state.quests) {
      if (item.id == id) {
        quest = item;
        break;
      }
    }
    if (quest == null || quest.completed) {
      return;
    }
    final quests = _state.quests
        .map((item) => item.id == id ? item.complete() : item)
        .toList();
    _state = _state.copyWith(
      quests: quests,
      resources: ResourceLogic.apply(_state.resources, quest.resourceRewards),
      profile: ProgressionLogic.applyStats(_state.profile, quest.statRewards),
      log: _prependLog('Görev tamamlandı: ${quest.title}. ${quest.rewardText}'),
    );
    notifyListeners();
  }

  void performCampAction(String title, Map<ResourceType, int> effects) {
    _state = _state.copyWith(
      resources: ResourceLogic.apply(_state.resources, effects),
      log: _prependLog('$title aksiyonu obaya etki etti.'),
    );
    notifyListeners();
  }

  void exploreRegion(String title, Map<ResourceType, int> effects) {
    _state = _state.copyWith(
      resources: ResourceLogic.apply(_state.resources, effects),
      log: _prependLog('$title keşfi tamamlandı.'),
    );
    notifyListeners();
  }

  void endDay() {
    final nextDay = _state.day.nextDay();
    final dailyCost = SeasonLogic.dailyCost(
      nextDay.season,
      _state.resource(ResourceType.population),
    );
    final eventIndex = _state.eventIndex + 1;
    _state = _state.copyWith(
      day: nextDay,
      resources: ResourceLogic.apply(_state.resources, dailyCost),
      currentEvent: EventLogic.nextEvent(eventIndex),
      eventIndex: eventIndex,
      log: _prependLog(
        'Gün ${nextDay.day} başladı. ${nextDay.season.label} etkileri uygulandı.',
      ),
    );
    notifyListeners();
  }

  void chooseEvent(EventChoice choice) {
    _state = _state.copyWith(
      resources: ResourceLogic.apply(_state.resources, choice.resourceEffects),
      profile: ProgressionLogic.applyStats(_state.profile, choice.statEffects),
      clearEvent: true,
      log: _prependLog('Olay seçimi: ${choice.label}. ${choice.description}'),
    );
    notifyListeners();
  }

  void resetGame() {
    _state = StarterGameData.create();
    notifyListeners();
  }

  List<String> _prependLog(String message) =>
      [message, ..._state.log].take(5).toList();
}

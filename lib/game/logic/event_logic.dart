import '../data/starter_game_data.dart';
import '../models/event_choice.dart';

class EventLogic {
  const EventLogic._();

  static GameEvent nextEvent(int index) {
    final events = StarterGameData.events;
    return events[index % events.length];
  }
}

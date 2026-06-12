import 'resource.dart';

class EventChoice {
  const EventChoice({
    required this.id,
    required this.label,
    required this.description,
    this.resourceEffects = const {},
    this.statEffects = const {},
  });

  final String id;
  final String label;
  final String description;
  final Map<ResourceType, int> resourceEffects;
  final Map<String, int> statEffects;
}

class GameEvent {
  const GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.choices,
  });

  final String id;
  final String title;
  final String description;
  final List<EventChoice> choices;
}

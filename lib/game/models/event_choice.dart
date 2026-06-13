import 'resource.dart';

class EventChoice {
  const EventChoice({
    required this.id,
    required this.label,
    required this.description,
    this.resourceEffects = const {},
    this.statEffects = const {},
    this.faithEffects = const {},
    this.actionPointCost = 0,
    this.healthEffect = 0,
    this.energyEffect = 0,
    this.fatigueEffect = 0,
    this.xpReward = 10,
  });

  final String id;
  final String label;
  final String description;
  final Map<ResourceType, int> resourceEffects;
  final Map<String, int> statEffects;
  final Map<String, int> faithEffects;
  final int actionPointCost;
  final int healthEffect;
  final int energyEffect;
  final int fatigueEffect;
  final int xpReward;
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

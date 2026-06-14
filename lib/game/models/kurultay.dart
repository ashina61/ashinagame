import 'resource.dart';

/// One option put before the council. Choices trade the favour of the common
/// folk against that of the council beys — pleasing one often vexes the other.
class KurultayChoice {
  const KurultayChoice({
    required this.label,
    required this.description,
    this.peopleEffect = 0,
    this.councilEffect = 0,
    this.resourceEffects = const {},
    this.npcEffects = const {},
  });

  final String label;
  final String description;
  final int peopleEffect;
  final int councilEffect;
  final Map<ResourceType, int> resourceEffects;

  /// Bonds shifted with named figures (npc id → delta), so a verdict that
  /// pleases the war captain may vex the elder.
  final Map<String, int> npcEffects;
}

/// A matter raised when the council convenes.
class KurultayDecision {
  const KurultayDecision({
    required this.id,
    required this.title,
    required this.description,
    required this.choices,
    this.khanate = false,
  });

  final String id;
  final String title;
  final String description;
  final List<KurultayChoice> choices;

  /// True for matters that only arise once you sit as khan.
  final bool khanate;
}

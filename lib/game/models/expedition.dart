import 'resource.dart';

class ExpeditionSite {
  const ExpeditionSite({
    required this.id,
    required this.name,
    required this.dangerLabel,
    required this.baseChance,
    required this.gains,
    required this.losses,
  });

  final String id;
  final String name;
  final String dangerLabel;

  /// Base success chance in percent, before courage and equipment.
  final int baseChance;
  final Map<ResourceType, int> gains;
  final Map<ResourceType, int> losses;
}

class ExpeditionOutcome {
  const ExpeditionOutcome({
    required this.site,
    required this.success,
    required this.effects,
  });

  final ExpeditionSite site;
  final bool success;
  final Map<ResourceType, int> effects;
}

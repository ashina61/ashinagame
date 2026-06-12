import 'resource.dart';

enum CraftKind { equipment, other }

class CraftRecipe {
  const CraftRecipe({
    required this.id,
    required this.name,
    required this.kind,
    required this.costs,
    required this.days,
    required this.successBonus,
  });

  final String id;
  final String name;
  final CraftKind kind;
  final Map<ResourceType, int> costs;
  final int days;

  /// Percent added to expedition success while one is owned.
  final int successBonus;
}

class CraftJob {
  const CraftJob({required this.recipeId, required this.daysLeft});

  final String recipeId;
  final int daysLeft;

  CraftJob tick() => CraftJob(recipeId: recipeId, daysLeft: daysLeft - 1);
}

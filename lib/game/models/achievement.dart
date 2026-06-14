import 'resource.dart';

/// The live figure an achievement measures, read from game state.
enum AchievementMetric {
  population,
  gold,
  conquered,
  crafted,
  generation,
  reputation,
  daysSurvived,
}

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.metric,
    required this.target,
    required this.reward,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementMetric metric;
  final int target;
  final Map<ResourceType, int> reward;
}

import 'resource.dart';

enum QuestGoalType { action, resource }

class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.rewardText,
    required this.goalType,
    required this.goalTarget,
    this.goalAction,
    this.goalResource,
    this.resourceRewards = const {},
    this.statRewards = const {},
    this.xpReward = 20,
    this.progress = 0,
    this.completed = false,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String rewardText;
  final QuestGoalType goalType;

  /// Action id counted for [QuestGoalType.action] goals.
  final String? goalAction;

  /// Resource threshold checked for [QuestGoalType.resource] goals.
  final ResourceType? goalResource;
  final int goalTarget;
  final Map<ResourceType, int> resourceRewards;
  final Map<String, int> statRewards;
  final int xpReward;
  final int progress;
  final bool completed;

  Quest copyWith({int? progress, bool? completed}) => Quest(
    id: id,
    title: title,
    category: category,
    description: description,
    rewardText: rewardText,
    goalType: goalType,
    goalTarget: goalTarget,
    goalAction: goalAction,
    goalResource: goalResource,
    resourceRewards: resourceRewards,
    statRewards: statRewards,
    xpReward: xpReward,
    progress: progress ?? this.progress,
    completed: completed ?? this.completed,
  );
}

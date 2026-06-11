import 'resource.dart';

class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.rewardText,
    this.resourceRewards = const {},
    this.statRewards = const {},
    this.completed = false,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String rewardText;
  final Map<ResourceType, int> resourceRewards;
  final Map<String, int> statRewards;
  final bool completed;

  Quest complete() => Quest(
        id: id,
        title: title,
        category: category,
        description: description,
        rewardText: rewardText,
        resourceRewards: resourceRewards,
        statRewards: statRewards,
        completed: true,
      );
}

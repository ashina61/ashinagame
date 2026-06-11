import '../models/resource.dart';
import '../models/season.dart';

class SeasonLogic {
  const SeasonLogic._();

  static Map<ResourceType, int> dailyCost(Season season, int population) {
    final foodCost = season == Season.winter ? 5 : 3;
    final woodCost = season == Season.winter ? 3 : 1;
    return {
      ResourceType.food: -foodCost,
      ResourceType.wood: -woodCost,
      if (population > 35) ResourceType.morale: -1,
    };
  }
}

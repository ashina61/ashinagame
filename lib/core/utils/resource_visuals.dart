import '../../game/models/resource.dart';
import '../assets/game_assets.dart';

/// Maps each resource type to its atlas icon asset.
class ResourceVisuals {
  const ResourceVisuals._();

  static String icon(ResourceType type) => switch (type) {
        ResourceType.gold => GameAssets.iconCoinGold,
        ResourceType.food => GameAssets.iconFood,
        ResourceType.wood => GameAssets.iconItemWood,
        ResourceType.leather => GameAssets.iconItemLeather,
        ResourceType.horse => GameAssets.iconItemHorse,
        ResourceType.reputation => GameAssets.iconScrollMedallion,
        ResourceType.morale => GameAssets.iconMoraleEmblem,
        ResourceType.population => GameAssets.iconPopulationEmblem,
      };
}

import '../../game/models/resource.dart';
import '../assets/game_art.dart';
import '../assets/game_assets.dart';

/// Maps each resource type to its icon. Prefers the produced framed icon set
/// (see [GameArt]) and falls back to the shipping atlas icon for resources that
/// do not have a produced one yet.
class ResourceVisuals {
  const ResourceVisuals._();

  static String icon(ResourceType type) {
    if (GameArt.hasResourceIcon(type.name)) {
      return GameArt.resourceIcon(type.name);
    }
    return _legacy(type);
  }

  static String _legacy(ResourceType type) => switch (type) {
    ResourceType.gold => GameAssets.iconCoinGold,
    ResourceType.food => GameAssets.iconFood,
    ResourceType.wood => GameAssets.iconItemWood,
    ResourceType.leather => GameAssets.iconItemLeather,
    ResourceType.stone => GameAssets.iconItemStone,
    ResourceType.iron => GameAssets.iconItemStone,
    ResourceType.horse => GameAssets.iconItemHorse,
    ResourceType.reputation => GameAssets.iconScrollMedallion,
    ResourceType.morale => GameAssets.iconMoraleEmblem,
    ResourceType.population => GameAssets.iconPopulationEmblem,
  };
}

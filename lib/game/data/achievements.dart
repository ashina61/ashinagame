import '../../core/assets/game_assets.dart';
import '../models/achievement.dart';
import '../models/resource.dart';

class Achievements {
  const Achievements._();

  static const all = <Achievement>[
    Achievement(
      id: 'crowded_camp',
      title: 'Kalabalık Oba',
      description: 'Nüfusu 50’ye çıkar.',
      icon: GameAssets.iconPopulationEmblem,
      metric: AchievementMetric.population,
      target: 50,
      reward: {ResourceType.gold: 200, ResourceType.morale: 5},
    ),
    Achievement(
      id: 'steppe_lord',
      title: 'Bozkırın Hâkimi',
      description: 'Haritadaki dört hedefi de fethet.',
      icon: GameAssets.iconSwordsCrossedGold,
      metric: AchievementMetric.conquered,
      target: 4,
      reward: {ResourceType.gold: 500, ResourceType.morale: 8},
    ),
    Achievement(
      id: 'master_smith',
      title: 'Usta Zanaatkâr',
      description: 'Atölyede 5 eşya üret.',
      icon: GameAssets.iconCraftEmblem,
      metric: AchievementMetric.crafted,
      target: 5,
      reward: {ResourceType.gold: 150},
    ),
    Achievement(
      id: 'dynasty',
      title: 'Hanedan',
      description: 'İkinci nesle ulaş.',
      icon: GameAssets.iconYurtGold,
      metric: AchievementMetric.generation,
      target: 2,
      reward: {ResourceType.gold: 300, ResourceType.morale: 10},
    ),
    Achievement(
      id: 'rich_trader',
      title: 'Zengin Tüccar',
      description: '1.000 altın biriktir.',
      icon: GameAssets.iconCoinsGold,
      metric: AchievementMetric.gold,
      target: 1000,
      reward: {ResourceType.morale: 8},
    ),
    Achievement(
      id: 'respected_bey',
      title: 'Saygın Bey',
      description: 'İtibarı 50’ye çıkar.',
      icon: GameAssets.iconScrollMedallion,
      metric: AchievementMetric.reputation,
      target: 50,
      reward: {ResourceType.gold: 300},
    ),
    Achievement(
      id: 'enduring_oba',
      title: 'Kadim Oba',
      description: '100 gün hayatta kal.',
      icon: GameAssets.iconSunEmblem,
      metric: AchievementMetric.daysSurvived,
      target: 100,
      reward: {ResourceType.gold: 250, ResourceType.morale: 5},
    ),
  ];
}

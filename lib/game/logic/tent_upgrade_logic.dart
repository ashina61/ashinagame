import '../models/resource.dart';
import '../state/game_state.dart';

class TentUpgradeTarget {
  const TentUpgradeTarget({
    required this.level,
    required this.name,
    required this.cost,
    required this.requirements,
    required this.bonuses,
  });

  final int level;
  final String name;
  final Map<ResourceType, int> cost;
  final List<String> requirements;
  final List<String> bonuses;
}

class TentUpgradeLogic {
  const TentUpgradeLogic._();

  static int tentLevel(GameState state) =>
      state.building('main_tent')?.level ?? 1;

  static String tentName(int level) => switch (level) {
        1 => 'Yıpranmış Çadır',
        2 => 'Sağlam Çadır',
        3 => 'Oba Çadırı',
        _ => 'Kağan Otağı',
      };

  static TentUpgradeTarget? nextTarget(GameState state) {
    final next = tentLevel(state) + 1;
    if (next > 4) return null;
    return target(next);
  }

  static TentUpgradeTarget target(int level) => switch (level) {
        2 => const TentUpgradeTarget(
            level: 2,
            name: 'Sağlam Çadır',
            cost: {
              ResourceType.wood: 40,
              ResourceType.leather: 12,
              ResourceType.food: 10,
              ResourceType.reputation: 5,
            },
            requirements: ['Başlangıç çadırını toparla.'],
            bonuses: [
              'Kapasite +10',
              'Soğuk riski azalır',
              'Moral +2',
              'Kış hazırlığı hedefi netleşir',
            ],
          ),
        3 => const TentUpgradeTarget(
            level: 3,
            name: 'Oba Çadırı',
            cost: {
              ResourceType.wood: 90,
              ResourceType.leather: 30,
              ResourceType.iron: 8,
              ResourceType.gold: 25,
              ResourceType.reputation: 25,
            },
            requirements: ['En az 1 yoldaş gerekiyor.'],
            bonuses: [
              'Oba kurma yolunda ana şart',
              'Kapasite +25',
              'Moral +5',
              'Hane ve sosyal fırsatlara hazırlık',
            ],
          ),
        _ => const TentUpgradeTarget(
            level: 4,
            name: 'Kağan Otağı',
            cost: {
              ResourceType.wood: 180,
              ResourceType.leather: 70,
              ResourceType.iron: 35,
              ResourceType.gold: 100,
              ResourceType.reputation: 80,
            },
            requirements: [
              'En az 5 yoldaş gerekiyor.',
              'Önce obanı kurmalısın.'
            ],
            bonuses: [
              'Liderlik ve itibar ağırlığı artar',
              'Diplomasi hedefleri güçlenir',
              'Geç oyun otağı hedefi tamamlanır',
            ],
          ),
      };

  static List<String> blockReasons(GameState state) {
    final target = nextTarget(state);
    if (target == null) return ['Çadır en yüksek seviyede.'];
    final reasons = <String>[];
    for (final entry in target.cost.entries) {
      final have = state.resource(entry.key);
      if (have < entry.value) {
        reasons.add('${entry.key.label} yetersiz: $have/${entry.value}');
      }
    }
    if (target.level >= 3 && state.swornFollowers < 1) {
      reasons.add('Bu yükseltme için en az 1 yoldaş gerekiyor.');
    }
    if (target.level >= 4 && state.swornFollowers < 5) {
      reasons.add('Bu yükseltme için en az 5 yoldaş gerekiyor.');
    }
    if (target.level >= 4 && !state.obaFounded) {
      reasons.add('Kağan otağı için önce obanı kurmalısın.');
    }
    return reasons;
  }

  static bool canUpgrade(GameState state) => blockReasons(state).isEmpty;
}

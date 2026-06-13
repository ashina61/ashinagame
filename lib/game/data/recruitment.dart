import '../models/resource.dart';

/// A source the oba can draw new people from. Reputation widens the welcome,
/// so a respected bey gathers more followers from each call.
class RecruitSource {
  const RecruitSource({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.basePeople,
    this.extraEffects = const {},
  });

  final String id;
  final String name;
  final String description;
  final Map<ResourceType, int> cost;
  final int basePeople;
  final Map<ResourceType, int> extraEffects;
}

class Recruitment {
  const Recruitment._();

  static const sources = <RecruitSource>[
    RecruitSource(
      id: 'nomads',
      name: 'Göçer Aileler',
      description: 'Çevredeki göçer ailelere armağan gönder, obana çağır.',
      cost: {ResourceType.gold: 100},
      basePeople: 5,
    ),
    RecruitSource(
      id: 'refugees',
      name: 'Sığınmacılar',
      description: 'Yurtsuz kalanlara ekmek ver, ocağına kat.',
      cost: {ResourceType.food: 40},
      basePeople: 4,
      extraEffects: {ResourceType.morale: 2},
    ),
    RecruitSource(
      id: 'warriors',
      name: 'Paralı Savaşçılar',
      description: 'Bozkırın yiğitlerini altınla saflarına al.',
      cost: {ResourceType.gold: 180},
      basePeople: 3,
      extraEffects: {ResourceType.reputation: 2},
    ),
  ];

  static RecruitSource? byId(String id) {
    for (final source in sources) {
      if (source.id == id) return source;
    }
    return null;
  }
}

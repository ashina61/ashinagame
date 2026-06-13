import '../models/conquest_region.dart';

class ConquestRegions {
  const ConquestRegions._();

  /// Relation needed to annex a region peacefully.
  static const annexRelation = 80;

  static const all = <ConquestRegion>[
    ConquestRegion(
      id: 'otuken',
      name: 'Ötüken Yaylağı',
      holder: 'Bumin Tigin',
      power: 60,
      baseRelation: 40,
      rewardGold: 120,
      rewardReputation: 6,
    ),
    ConquestRegion(
      id: 'orhun',
      name: 'Orhun Vadisi',
      holder: 'Kara Bey',
      power: 90,
      baseRelation: 30,
      rewardGold: 160,
      rewardReputation: 8,
    ),
    ConquestRegion(
      id: 'altay',
      name: 'Altay Eteği',
      holder: 'Demir Alp',
      power: 120,
      baseRelation: 25,
      rewardGold: 200,
      rewardReputation: 9,
    ),
    ConquestRegion(
      id: 'idil',
      name: 'İdil Boyu',
      holder: 'Yamtar Bey',
      power: 150,
      baseRelation: 20,
      rewardGold: 240,
      rewardReputation: 10,
    ),
    ConquestRegion(
      id: 'yedisu',
      name: 'Yedisu',
      holder: 'Kürşad Tigin',
      power: 190,
      baseRelation: 15,
      rewardGold: 300,
      rewardReputation: 12,
    ),
    ConquestRegion(
      id: 'kasgar',
      name: 'Kaşgar Kapısı',
      holder: 'Tuğrul Bey',
      power: 240,
      baseRelation: 10,
      rewardGold: 380,
      rewardReputation: 15,
    ),
  ];

  static ConquestRegion? byId(String id) {
    for (final region in all) {
      if (region.id == id) return region;
    }
    return null;
  }
}

import '../models/resource.dart';

/// A would-be follower waiting at the han: befriend (and pay) them and they
/// join the oba in a chosen role, counting toward the "three sworn followers"
/// needed to found an oba.
class HanCompanion {
  const HanCompanion({
    required this.npcId,
    required this.name,
    required this.roleId,
    required this.goldCost,
  });

  final String npcId;
  final String name;
  final String roleId;
  final int goldCost;
}

/// A sword for hire at the han: pay gold (and a horse for riders) and they
/// march in your army at once.
class HanMercenary {
  const HanMercenary({
    required this.unitId,
    required this.name,
    required this.goldCost,
    this.needsHorse = false,
  });

  final String unitId;
  final String name;
  final int goldCost;
  final bool needsHorse;
}

class HanOffers {
  const HanOffers._();

  static const companions = <HanCompanion>[
    HanCompanion(
      npcId: 'kaya_atabek',
      name: 'Kaya',
      roleId: 'warleader',
      goldCost: 120,
    ),
    HanCompanion(
      npcId: 'bori_bey',
      name: 'Böri Bey',
      roleId: 'kam',
      goldCost: 100,
    ),
    HanCompanion(
      npcId: 'bezirgan',
      name: 'Bezirgân',
      roleId: 'merchant',
      goldCost: 110,
    ),
    HanCompanion(
      npcId: 'alis_hatun',
      name: 'Alış Hatun',
      roleId: 'hearth_mother',
      goldCost: 90,
    ),
    HanCompanion(
      npcId: 'tugan_bey',
      name: 'Tugan Bey',
      roleId: 'hunter',
      goldCost: 100,
    ),
  ];

  static const mercenaries = <HanMercenary>[
    HanMercenary(
      unitId: 'horse_archer',
      name: 'Atlı Okçu',
      goldCost: 90,
      needsHorse: true,
    ),
    HanMercenary(unitId: 'foot_sword', name: 'Kılıçlı Piyade', goldCost: 50),
    HanMercenary(unitId: 'spear', name: 'Mızraklı', goldCost: 55),
    HanMercenary(unitId: 'scout', name: 'İzci', goldCost: 30, needsHorse: true),
  ];

  static const rumors = <String>[
    'Han’da bir gözcü: "Batıda otlağı bol, sahipsiz bir toprak var."',
    'Bir yolcu: "Kuzeyde toz yükseliyor; akın olabilir."',
    'Tüccar: "Yarın nadir bir teklif gelecekmiş."',
    'Yaşlı bir kadın: "Falanca obanın kızı evlilik çağında."',
    'Bir ozan: "Eski yazıtta atalarımızın izi varmış."',
  ];

  static String rumorForDay(int day) => rumors[(day.abs()) % rumors.length];

  /// Cost helper so callers need not import the resource enum.
  static Map<ResourceType, int> companionCost(HanCompanion c) => {
    ResourceType.gold: c.goldCost,
  };
}

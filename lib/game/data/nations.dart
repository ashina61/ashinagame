import '../models/nation.dart';

/// The conquest map: three neighbouring peoples, each a ring of four castles
/// around a capital. Old save ids (otuken, orhun, altay, idil, yedisu, kasgar)
/// live on as castles so earlier campaigns carry over.
class Nations {
  const Nations._();

  /// Relation needed to annex a castle peacefully.
  static const annexRelation = 80;

  static const all = <Nation>[
    Nation(
      id: 'oguz',
      name: 'Dokuz Oğuz Eli',
      ruler: 'Baga Tarkan',
      castles: [
        Castle(
          id: 'otuken',
          name: 'Ötüken Yaylağı',
          power: 60,
          baseRelation: 40,
          rewardGold: 120,
          rewardReputation: 6,
        ),
        Castle(
          id: 'orhun',
          name: 'Orhun Vadisi',
          power: 90,
          baseRelation: 30,
          rewardGold: 160,
          rewardReputation: 8,
        ),
        Castle(
          id: 'selenge',
          name: 'Selenge Kıyısı',
          power: 110,
          baseRelation: 28,
          rewardGold: 180,
          rewardReputation: 8,
        ),
        Castle(
          id: 'tola',
          name: 'Tola Boyu',
          power: 130,
          baseRelation: 24,
          rewardGold: 200,
          rewardReputation: 9,
        ),
        Castle(
          id: 'oguz_ordasi',
          name: 'Oğuz Ordası',
          power: 210,
          baseRelation: 15,
          rewardGold: 340,
          rewardReputation: 16,
          isCenter: true,
        ),
      ],
    ),
    Nation(
      id: 'turgis',
      name: 'Türgiş Budun',
      ruler: 'Suluk Kağan',
      castles: [
        Castle(
          id: 'altay',
          name: 'Altay Eteği',
          power: 120,
          baseRelation: 25,
          rewardGold: 200,
          rewardReputation: 9,
        ),
        Castle(
          id: 'cu',
          name: 'Çu Vadisi',
          power: 150,
          baseRelation: 22,
          rewardGold: 240,
          rewardReputation: 10,
        ),
        Castle(
          id: 'talas',
          name: 'Talas Ovası',
          power: 170,
          baseRelation: 18,
          rewardGold: 270,
          rewardReputation: 11,
        ),
        Castle(
          id: 'yedisu',
          name: 'Yedisu',
          power: 190,
          baseRelation: 15,
          rewardGold: 300,
          rewardReputation: 12,
        ),
        Castle(
          id: 'turgis_baligi',
          name: 'Türgiş Balığı',
          power: 270,
          baseRelation: 12,
          rewardGold: 420,
          rewardReputation: 18,
          isCenter: true,
        ),
      ],
    ),
    Nation(
      id: 'karluk',
      name: 'Karluk Yabguluğu',
      ruler: 'Bilge Yabgu',
      castles: [
        Castle(
          id: 'idil',
          name: 'İdil Boyu',
          power: 150,
          baseRelation: 20,
          rewardGold: 240,
          rewardReputation: 10,
        ),
        Castle(
          id: 'isikgol',
          name: 'Isık Göl',
          power: 180,
          baseRelation: 16,
          rewardGold: 280,
          rewardReputation: 11,
        ),
        Castle(
          id: 'balasagun',
          name: 'Balasagun',
          power: 210,
          baseRelation: 13,
          rewardGold: 320,
          rewardReputation: 13,
        ),
        Castle(
          id: 'kasgar',
          name: 'Kaşgar Kapısı',
          power: 240,
          baseRelation: 10,
          rewardGold: 380,
          rewardReputation: 15,
        ),
        Castle(
          id: 'karluk_ordu',
          name: 'Karluk Ordu-Kent',
          power: 330,
          baseRelation: 10,
          rewardGold: 500,
          rewardReputation: 20,
          isCenter: true,
        ),
      ],
    ),
  ];

  /// Every castle across every nation.
  static List<Castle> get allCastles => [for (final n in all) ...n.castles];

  static Castle? castleById(String id) {
    for (final n in all) {
      for (final c in n.castles) {
        if (c.id == id) return c;
      }
    }
    return null;
  }

  /// The nation a castle belongs to.
  static Nation? nationOf(String castleId) {
    for (final n in all) {
      for (final c in n.castles) {
        if (c.id == castleId) return n;
      }
    }
    return null;
  }

  static Nation? byId(String id) {
    for (final n in all) {
      if (n.id == id) return n;
    }
    return null;
  }
}

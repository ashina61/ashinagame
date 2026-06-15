import '../../core/assets/game_assets.dart';

/// A tamga is the seal/banner that marks an oba. The player picks one when
/// founding a new oba.
class Tamga {
  const Tamga({required this.id, required this.name, required this.asset});

  final String id;
  final String name;
  final String asset;
}

class Tamgas {
  const Tamgas._();

  static const all = <Tamga>[
    Tamga(id: 'wolf', name: 'Bozkurt', asset: GameAssets.uiEmblemWolfRound),
    Tamga(id: 'war', name: 'Çapraz Kılıç', asset: GameAssets.uiEmblemWarRound),
    Tamga(
      id: 'banner_red',
      name: 'Al Sancak',
      asset: GameAssets.uiBadgeBanner1,
    ),
    Tamga(
      id: 'banner_sky',
      name: 'Gök Sancak',
      asset: GameAssets.uiBadgeBanner3,
    ),
    Tamga(id: 'yurt', name: 'Altın Otağ', asset: GameAssets.iconYurtGold),
  ];

  static const fallback = Tamga(
    id: 'wolf',
    name: 'Bozkurt',
    asset: GameAssets.uiEmblemWolfRound,
  );

  static Tamga byId(String id) {
    for (final tamga in all) {
      if (tamga.id == id) return tamga;
    }
    return fallback;
  }
}

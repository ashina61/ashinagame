/// A belief path the leader can commit the oba to. Each leans the four
/// faith pillars (faith, kut, tore, ancestorHonor) in a different direction
/// when chosen.
class FaithPath {
  const FaithPath({
    required this.id,
    required this.name,
    required this.description,
    required this.lean,
  });

  final String id;
  final String name;
  final String description;
  final Map<String, int> lean;
}

class FaithPaths {
  const FaithPaths._();

  static const all = <FaithPath>[
    FaithPath(
      id: 'gok_tengri',
      name: 'Gök Tengri Yolu',
      description: 'Sonsuz mavi göğe and içilir. Kut ve sefer talihi güçlenir.',
      lean: {'faith': 8, 'kut': 10},
    ),
    FaithPath(
      id: 'atalar_kultu',
      name: 'Atalar Kültü',
      description: 'Ataların ruhu obayı korur. Töre ve atalara saygı yükselir.',
      lean: {'tore': 10, 'ancestorHonor': 10},
    ),
    FaithPath(
      id: 'kam_yolu',
      name: 'Kam Şamanizmi',
      description:
          'Kamlar gök, ateş ve rüzgârla konuşur. İnanç ve alamet sezgisi artar.',
      lean: {'faith': 12, 'tore': 4},
    ),
  ];

  static FaithPath? byId(String id) {
    for (final path in all) {
      if (path.id == id) return path;
    }
    return null;
  }
}

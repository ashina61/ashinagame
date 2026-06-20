import '../models/research.dart';

/// The academy's research tree and the bonuses it grants. A compact three-lane
/// tree (Ekonomi / Altyapı / Bilim) with two capstones that need earlier techs,
/// so investment choices and a sense of progression both show up early.
class ResearchData {
  const ResearchData._();

  /// Research points the academy yields per day, per level.
  static const pointsPerLevel = 3;

  static const techs = <ResearchTech>[
    // --- Ekonomi ---
    ResearchTech(
      id: 'agriculture',
      name: 'Tarım',
      description: 'Otlak ve ekin düzeni, ağılların verimini artırır.',
      category: 'Ekonomi',
      cost: 30,
      effectDescription: 'Erzak üretimi +%50.',
    ),
    ResearchTech(
      id: 'trade_routes',
      name: 'Ticaret Yolları',
      description: 'Kervan güzergâhları pazar gelirini büyütür.',
      category: 'Ekonomi',
      cost: 35,
      effectDescription: 'Altın üretimi +%50.',
    ),
    ResearchTech(
      id: 'husbandry',
      name: 'Hayvancılık',
      description: 'Daha iyi yetiştiricilik, sürüleri güçlendirir.',
      category: 'Ekonomi',
      cost: 40,
      requires: ['agriculture'],
      effectDescription: 'At üretimi iki katına çıkar.',
    ),
    ResearchTech(
      id: 'guild',
      name: 'Lonca',
      description: 'Esnaf birliği bütün üretimi düzene sokar.',
      category: 'Ekonomi',
      cost: 90,
      requires: ['trade_routes', 'husbandry'],
      effectDescription: 'Tüm üretim ek olarak +%25.',
    ),
    // --- Altyapı ---
    ResearchTech(
      id: 'masonry',
      name: 'Taşçılık',
      description: 'Taş temeller daha büyük depolar sağlar.',
      category: 'Altyapı',
      cost: 30,
      effectDescription: 'Depo kapasitesi +600.',
    ),
    ResearchTech(
      id: 'smithing',
      name: 'Demircilik',
      description: 'Gelişmiş ocaklar atölye üretimini artırır.',
      category: 'Altyapı',
      cost: 35,
      effectDescription: 'Deri ve demir üretimi +%50.',
    ),
    ResearchTech(
      id: 'engineering',
      name: 'Mühendislik',
      description: 'Usta kalfalar inşaatı hızlandırır.',
      category: 'Altyapı',
      cost: 60,
      requires: ['masonry', 'smithing'],
      effectDescription: 'Tüm inşa süreleri 1 gün kısalır.',
    ),
    // --- Bilim ---
    ResearchTech(
      id: 'scholarship',
      name: 'İlim',
      description: 'Yazı ve kayıt, bilginin birikmesini sağlar.',
      category: 'Bilim',
      cost: 35,
      effectDescription: 'Akademi araştırma üretimi +%50.',
    ),
    ResearchTech(
      id: 'university',
      name: 'Üniversite',
      description: 'Bilginler okulu araştırmayı zirveye taşır.',
      category: 'Bilim',
      cost: 100,
      requires: ['scholarship'],
      effectDescription: 'Akademi araştırma üretimi bir kat daha artar.',
    ),
  ];

  static ResearchTech? byId(String id) {
    for (final t in techs) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Fold the set of researched techs into the bonus bundle the controller
  /// applies to the economy.
  static ResearchBonuses bonusesFor(Set<String> done) {
    return ResearchBonuses(
      foodMult: done.contains('agriculture') ? 1.5 : 1.0,
      goldMult: done.contains('trade_routes') ? 1.5 : 1.0,
      craftMult: done.contains('smithing') ? 1.5 : 1.0,
      horseMult: done.contains('husbandry') ? 2.0 : 1.0,
      allMult: done.contains('guild') ? 1.25 : 1.0,
      storageBonus: done.contains('masonry') ? 600 : 0,
      buildDaysReduction: done.contains('engineering') ? 1 : 0,
      researchMult: (done.contains('scholarship') ? 1.5 : 1.0) *
          (done.contains('university') ? 2.0 : 1.0),
    );
  }
}

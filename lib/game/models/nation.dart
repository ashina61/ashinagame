/// A single stronghold on the conquest map. Outer castles can be assailed in
/// any order; a nation's center [isCenter] castle only falls once its four
/// outer castles are yours.
class Castle {
  const Castle({
    required this.id,
    required this.name,
    required this.power,
    required this.baseRelation,
    required this.rewardGold,
    required this.rewardReputation,
    this.isCenter = false,
  });

  final String id;
  final String name;

  /// Garrison strength; war success is weighed against this.
  final int power;

  /// Starting diplomatic relation (0–100).
  final int baseRelation;

  /// Spoils granted when the castle becomes yours.
  final int rewardGold;
  final int rewardReputation;

  /// True for the seat of the nation — the last to fall.
  final bool isCenter;
}

/// A neighbouring people holding a cluster of castles around a capital. Taking
/// the capital ends the nation and forces a governance decision.
class Nation {
  const Nation({
    required this.id,
    required this.name,
    required this.ruler,
    required this.castles,
  });

  final String id;
  final String name;

  /// The bey or kağan who rules the nation.
  final String ruler;

  /// Four outer castles followed by the lone center castle.
  final List<Castle> castles;

  List<Castle> get outerCastles => [
        for (final c in castles)
          if (!c.isCenter) c,
      ];

  Castle get center => castles.firstWhere((c) => c.isCenter);
}

/// What the leader does with a nation once its capital falls.
enum NationPolicy {
  /// Appoint a governor; a province that pays steady tribute.
  vali,

  /// Plunder it bare: a great one-time haul, but no lasting income.
  yagma,

  /// Raze it to the ground: fear and glory, the people recoil.
  yik,

  /// Leave it a bound state under its own ruler: lighter, lasting tribute.
  vassal,

  /// Rule it directly from your own seat: the richest tribute, but a resented
  /// land that slips toward revolt without a local lord to calm it.
  directRule,
}

extension NationPolicyInfo on NationPolicy {
  String get id => name;

  String get label => switch (this) {
        NationPolicy.vali => 'Vali Ata',
        NationPolicy.yagma => 'Yağmala',
        NationPolicy.yik => 'Yık',
        NationPolicy.vassal => 'Bağlı Devlet',
        NationPolicy.directRule => 'Doğrudan Yönet',
      };

  String get blurb => switch (this) {
        NationPolicy.vali =>
          'Bir vali atayıp ili eyalet yap. Her gün düzenli vergi akar; '
              'halk düzeni över.',
        NationPolicy.yagma =>
          'İli yağmala. Tek seferde büyük ganimet ve şöhret; beyler sevinir, '
              'halk gaddarlıktan ürker.',
        NationPolicy.yik =>
          'İli yık, korku sal. Büyük şöhret ama halk bu zulümden tedirgin; '
              'kalıcı gelir yok.',
        NationPolicy.vassal =>
          'İli kendi beyine bağlı devlet bırak. Hafif ama kalıcı haraç; '
              'merhametin halkı hoşnut eder.',
        NationPolicy.directRule =>
          'İli kendi otağından doğrudan yönet. En yüksek vergi senin; ama '
              'yerel bir bey olmadan halk huzursuz, isyan riski yüksek.',
      };

  static NationPolicy? byId(String id) {
    for (final p in NationPolicy.values) {
      if (p.name == id) return p;
    }
    return null;
  }
}

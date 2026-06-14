import '../../core/assets/game_assets.dart';
import 'resource.dart';

/// A named figure the leader can speak with — a council bey, a kinswoman, the
/// khan, a rival or the caravan merchant. Relationships shift with each choice.
class Npc {
  const Npc({
    required this.id,
    required this.name,
    required this.role,
    required this.portrait,
    required this.blurb,
    this.khanate = false,
  });

  final String id;
  final String name;
  final String role;
  final String portrait;
  final String blurb;

  /// True for figures that only matter while bound to (or seated as) a khan.
  final bool khanate;
}

/// One reply the leader can give in a dialogue. Effects nudge the bond with the
/// speaker and may sway the people, the council, or the treasury.
class DialogueChoice {
  const DialogueChoice({
    required this.label,
    required this.reply,
    this.relationEffect = 0,
    this.peopleEffect = 0,
    this.councilEffect = 0,
    this.resourceEffects = const {},
  });

  final String label;
  final String reply;
  final int relationEffect;
  final int peopleEffect;
  final int councilEffect;
  final Map<ResourceType, int> resourceEffects;
}

/// A single exchange offered by an NPC: their line and the leader's options.
class Dialogue {
  const Dialogue({
    required this.id,
    required this.npcId,
    required this.line,
    required this.choices,
  });

  final String id;
  final String npcId;
  final String line;
  final List<DialogueChoice> choices;
}

class NpcCharacters {
  const NpcCharacters._();

  static const all = <Npc>[
    Npc(
      id: 'bori_bey',
      name: 'Böri Bey',
      role: 'Kurultay Aksakalı',
      portrait: GameAssets.portraitBori,
      blurb: 'Meclisin en yaşlı beyi; töreye ve eski usule bağlıdır.',
    ),
    Npc(
      id: 'kaya_atabek',
      name: 'Kaya Atabek',
      role: 'Yüzbaşı',
      portrait: GameAssets.portraitKaya,
      blurb: 'Obanın kılıcı; akın ve talim ondan sorulur.',
    ),
    Npc(
      id: 'alis_hatun',
      name: 'Alış Hatun',
      role: 'Ocak Anası',
      portrait: GameAssets.portraitAlis,
      blurb: 'Halkın derdini dinler, ocağın düzenini tutar.',
    ),
    Npc(
      id: 'tugan_bey',
      name: 'Tugan Bey',
      role: 'Rakip Bey',
      portrait: GameAssets.portraitTugan,
      blurb: 'Komşu obanın gözü yükseklerde olan beyi.',
    ),
    Npc(
      id: 'bezirgan',
      name: 'Bezirgân',
      role: 'Kervan Tüccarı',
      portrait: GameAssets.portraitMerchant,
      blurb: 'İpek Yolu’ndan haber ve mal taşır.',
    ),
    Npc(
      id: 'togan_kagan',
      name: 'Togan Kağan',
      role: 'Kağan',
      portrait: GameAssets.portraitTogan,
      blurb: 'Bağlı olduğun kağanlığın hükümdarı.',
      khanate: true,
    ),
  ];

  static Npc? byId(String id) {
    for (final n in all) {
      if (n.id == id) return n;
    }
    return null;
  }
}

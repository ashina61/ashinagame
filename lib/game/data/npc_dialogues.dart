import '../models/npc.dart';
import '../models/resource.dart';
import '../state/game_state.dart';

/// Conversations keyed by NPC. The leader picks a reply; each reply shifts the
/// bond with the speaker and may sway the people, the council or the treasury.
class NpcDialogues {
  const NpcDialogues._();

  static const all = <Dialogue>[
    // —— Böri Bey, the council elder ——
    Dialogue(
      id: 'bori_tore',
      npcId: 'bori_bey',
      line: 'Genç bey, töre eskidikçe sağlamlaşır. Yeni usuller meclisi '
          'huzursuz ediyor. Sözümü dinler misin?',
      choices: [
        DialogueChoice(
          label: 'Töreye sadığım, aksakal.',
          reply: 'Böri Bey başını eğip seni över; beyler rahatlar.',
          relationEffect: 10,
          councilEffect: 6,
          peopleEffect: -2,
        ),
        DialogueChoice(
          label: 'Halk yeni soluk istiyor.',
          reply: 'Yaşlı bey kaşlarını çatar ama halk bunu duyunca sevinir.',
          relationEffect: -8,
          councilEffect: -6,
          peopleEffect: 8,
        ),
        DialogueChoice(
          label: 'Hem töre hem yenilik gözetilir.',
          reply: 'Ölçülü sözün beyleri de halkı da bir nebze hoşnut eder.',
          relationEffect: 2,
          councilEffect: 2,
          peopleEffect: 2,
        ),
      ],
    ),
    Dialogue(
      id: 'bori_gift',
      npcId: 'bori_bey',
      line: 'Meclisin desteğini umuyorsan, eski beyleri unutma. Bir armağan '
          'gönlü yumuşatır.',
      choices: [
        DialogueChoice(
          label: 'Aksakala at ve kürk yolla.',
          reply: 'Cömertliğin dilden dile dolaşır; beyler yanında saf tutar.',
          relationEffect: 12,
          councilEffect: 8,
          resourceEffects: {ResourceType.gold: -60},
        ),
        DialogueChoice(
          label: 'Saygım armağandan büyüktür.',
          reply: 'Böri Bey idare eder ama biraz kırgın görünür.',
          relationEffect: -3,
        ),
      ],
    ),

    // —— Kaya Atabek, the war captain ——
    Dialogue(
      id: 'kaya_drill',
      npcId: 'kaya_atabek',
      line: 'Atlılar talimsiz kalırsa kılıç paslanır, bey. Bir talim '
          'düzenleyelim mi?',
      choices: [
        DialogueChoice(
          label: 'Talimi başlat.',
          reply: 'Kaya gülümser; askerin morali ve cengâverliği artar.',
          relationEffect: 10,
          councilEffect: 4,
          resourceEffects: {ResourceType.morale: 4},
        ),
        DialogueChoice(
          label: 'Şimdi sırası değil.',
          reply: 'Yüzbaşı isteksizce başını sallar.',
          relationEffect: -6,
        ),
      ],
    ),
    Dialogue(
      id: 'kaya_raid',
      npcId: 'kaya_atabek',
      line: 'Komşu bir kervan korumasız geçiyor. Akın edersek hazine dolar '
          'ama kan da dökülür.',
      choices: [
        DialogueChoice(
          label: 'Akına çık.',
          reply: 'Atlılar akına çıktı; çarpışmanın sonucu birazdan belli olur.',
          relationEffect: 8,
          councilEffect: 6,
          peopleEffect: -6,
          raidPower: 90,
        ),
        DialogueChoice(
          label: 'Kan dökmeyiz.',
          reply: 'Halk minnettar olur; Kaya biraz hevesini yitirir.',
          relationEffect: -5,
          councilEffect: -4,
          peopleEffect: 8,
        ),
      ],
    ),
    Dialogue(
      id: 'kaya_council',
      npcId: 'kaya_atabek',
      line: 'Beyler sefer için söyleniyor, bey. Meclisi toplayıp divan '
          'kuralım mı?',
      choices: [
        DialogueChoice(
          label: 'Meclisi topla.',
          reply: 'Davul çalındı; beyler divana çağrıldı.',
          relationEffect: 6,
          triggersKurultay: 'war_council',
        ),
        DialogueChoice(
          label: 'Vakti değil.',
          reply: 'Kaya homurdanır ama emre uyar.',
          relationEffect: -4,
        ),
      ],
    ),

    // —— Alış Hatun, the hearth-mother / voice of the people ——
    Dialogue(
      id: 'alis_winter',
      npcId: 'alis_hatun',
      line: 'Bey, kışlık erzak az. Çocuklar üşüyor. Ocaklara biraz pay '
          'ayırır mısın?',
      choices: [
        DialogueChoice(
          label: 'Ambarı halka aç.',
          reply: 'Alış Hatun dua eder; halkın gönlü seninle olur.',
          relationEffect: 10,
          peopleEffect: 12,
          councilEffect: -4,
          resourceEffects: {ResourceType.food: -15},
        ),
        DialogueChoice(
          label: 'Herkes kendi kışını görsün.',
          reply: 'Erzak korunur ama ocaklarda küskünlük yayılır.',
          relationEffect: -8,
          peopleEffect: -10,
          councilEffect: 2,
        ),
      ],
    ),
    Dialogue(
      id: 'alis_wedding',
      npcId: 'alis_hatun',
      line: 'İki genç birbirine söz verdi. Bir düğün obayı şenlendirir, ne '
          'dersin?',
      choices: [
        DialogueChoice(
          label: 'Düğünü oba kursun.',
          reply: 'Davul çalar, halk göbek atar; herkesin yüzü güler.',
          relationEffect: 8,
          peopleEffect: 10,
          resourceEffects: {ResourceType.food: -10, ResourceType.morale: 6},
        ),
        DialogueChoice(
          label: 'Aileler kendi görsün.',
          reply: 'Düğün küçük kalır; kimse pek sevinmez.',
          relationEffect: -4,
          peopleEffect: -4,
        ),
      ],
    ),

    // —— Tugan Bey, the rival ——
    Dialogue(
      id: 'tugan_taunt',
      npcId: 'tugan_bey',
      line: 'Senin obanın otlağı bana dar geliyor, bey. Sınırı geri çekersen '
          'kavga çıkmaz.',
      choices: [
        DialogueChoice(
          label: 'Bir karış bile vermem.',
          reply: 'Tugan kılıcına davrandı; sınır boyunda çarpışma başladı!',
          relationEffect: -12,
          peopleEffect: 6,
          councilEffect: 4,
          raidPower: 120,
        ),
        DialogueChoice(
          label: 'Otlağı paylaşalım.',
          reply: 'Gerginlik düşer; Tugan ile aran bir nebze yumuşar.',
          relationEffect: 12,
          peopleEffect: -4,
        ),
        DialogueChoice(
          label: 'Hediyeyle gönlünü al.',
          reply: 'Altın el değiştirir; Tugan şimdilik sakinleşir.',
          relationEffect: 15,
          resourceEffects: {ResourceType.gold: -50},
        ),
      ],
    ),

    // —— Bezirgân, the merchant ——
    Dialogue(
      id: 'bezirgan_news',
      npcId: 'bezirgan',
      line: 'İpek Yolu’ndan geldim, bey. Bilgi de mal kadar kıymetli. Bir '
          'kese altına yolların hâlini anlatayım mı?',
      choices: [
        DialogueChoice(
          label: 'Anlat, keseyi aç.',
          reply: 'Bezirgân pazar ve düşman haberleri verir; itibarın artar.',
          relationEffect: 10,
          resourceEffects: {ResourceType.gold: -30, ResourceType.reputation: 4},
        ),
        DialogueChoice(
          label: 'Haberi bedavaya isterim.',
          reply: 'Tüccar omuz silker, ağzından laf almak güçleşir.',
          relationEffect: -6,
        ),
      ],
    ),

    // —— Togan Kağan, your liege (or you, once khan) ——
    Dialogue(
      id: 'togan_loyalty',
      npcId: 'togan_kagan',
      line: 'Beyim, kağanlığa bağlılığın sürüyor mu? Sadık obalar ödülsüz '
          'kalmaz.',
      choices: [
        DialogueChoice(
          label: 'Sancağın altındayım, kağanım.',
          reply: 'Kağan hoşnut olur; kağanlık katındaki itibarın yükselir.',
          relationEffect: 12,
          councilEffect: 4,
          resourceEffects: {ResourceType.reputation: 5},
        ),
        DialogueChoice(
          label: 'Obamın çıkarı önce gelir.',
          reply: 'Kağan gözlerini kısar; bu cesaret pahalıya patlayabilir.',
          relationEffect: -12,
          peopleEffect: 6,
        ),
      ],
    ),
  ];

  /// All dialogues belonging to [npcId].
  static List<Dialogue> forNpc(String npcId) => [
        for (final d in all)
          if (d.npcId == npcId) d,
      ];

  static List<Dialogue> contextualFor(String npcId, GameState state) {
    final relation = state.relationWith(npcId);
    final age = state.profile.age;
    final season = state.day.season.label;
    final phaseHint = age < 16
        ? 'Genç yaşta önce ocağı ve çadırı sağlam tut.'
        : age < 18
            ? 'Oba yolu açılırken güvenilir yoldaş sözü daha değerlidir.'
            : 'Artık sözün obanın ve komşu boyların kulağına gider.';
    final trustHint = relation >= 70
        ? 'Sana güvenirim; sözü uzatmadan gerçeği söylerim.'
        : relation <= 35
            ? 'Aramızdaki güven ince buz gibi; adımını tart.'
            : 'Sözümüz ölçülü olsun, güven böyle büyür.';
    final seasonalHint = '$season mevsimi sözün tadını değiştirir.';
    return [
      ...forNpc(npcId),
      for (final line in _roleLines(npcId))
        Dialogue(
          id: '${npcId}_${line.id}',
          npcId: npcId,
          line: '${line.text} $seasonalHint $phaseHint $trustHint',
          choices: _choices(line.kind),
        ),
    ];
  }

  static List<_RoleLine> _roleLines(String npcId) => switch (npcId) {
        'bori_bey' => _elderLines,
        'kaya_atabek' => _warriorLines,
        'alis_hatun' => _healerLines,
        'tugan_bey' => _rivalLines,
        'bezirgan' => _merchantLines,
        'togan_kagan' => _rulerLines,
        _ => _elderLines,
      };

  static List<DialogueChoice> _choices(String kind) => switch (kind) {
        'rumor' => const [
            DialogueChoice(
              label: 'Söylentiyi dinle',
              reply: 'Duyduğun söz yol ve fırsat sezgini güçlendirdi.',
              relationEffect: 1,
              resourceEffects: {ResourceType.reputation: 1},
            ),
            DialogueChoice(
              label: 'Kısa kes',
              reply: 'Sözü kısa tuttun; vakit sende kaldı.',
            ),
          ],
        'quest' => const [
            DialogueChoice(
              label: 'Görev sor',
              reply: 'Yapılacak işi öğrendin; hedefin biraz daha netleşti.',
              relationEffect: 1,
              peopleEffect: 1,
            ),
            DialogueChoice(
              label: 'Yardım teklif et',
              reply: 'Yardım sözün karşılık buldu; obada güven arttı.',
              relationEffect: 2,
              resourceEffects: {ResourceType.morale: 1},
            ),
          ],
        _ => const [
            DialogueChoice(
              label: 'Öğüt iste',
              reply: 'Öğüdü aklında tuttun; söz aranızdaki bağı az da olsa güçlendirdi.',
              relationEffect: 1,
              councilEffect: 1,
            ),
            DialogueChoice(
              label: 'Dert dinle',
              reply: 'Karşındakinin derdini dinledin; halk bunu duyar.',
              relationEffect: 1,
              peopleEffect: 1,
            ),
          ],
      };

  static const _elderLines = <_RoleLine>[
    _RoleLine('elder_advice_1', 'advice', 'Bozkır sabırsızı sevmez. Önce ateşini, sonra yolunu koru.'),
    _RoleLine('elder_advice_2', 'advice', 'Kış gelmeden yiyeceğini saklamayan, baharı göremez.'),
    _RoleLine('elder_advice_3', 'advice', 'Bir oba çadırla değil, güvenle kurulur.'),
    _RoleLine('elder_advice_4', 'advice', 'Yoldaşın açsa kılıcın keskin olsa ne olur?'),
    _RoleLine('elder_advice_5', 'advice', 'Eski yazıtlar taşta değil, insanın kararında yaşar.'),
    _RoleLine('elder_quest_1', 'quest', 'Ana çadırın güçlenmeden büyük söz verilmez; odun ve deri biriktir.'),
  ];

  static const _warriorLines = <_RoleLine>[
    _RoleLine('warrior_rumor_1', 'rumor', 'Kuzey avlağında taze geyik izi gördüm.'),
    _RoleLine('warrior_rumor_2', 'rumor', 'Bugün rüzgâr ters. Av da akın da kolay olmayacak.'),
    _RoleLine('warrior_rumor_3', 'rumor', 'Irmak kıyısında ördek çok ama sessiz gitmek gerek.'),
    _RoleLine('warrior_rumor_4', 'rumor', 'Kapan kurarsan yarına et çıkabilir.'),
    _RoleLine('warrior_rumor_5', 'rumor', 'Aynı avlağa çok yüklendik, biraz dinlenmesi gerek.'),
    _RoleLine('warrior_quest_1', 'quest', 'Gençler talim bekler; bir gün ayırırsan oba kendini güçlü hisseder.'),
  ];

  static const _healerLines = <_RoleLine>[
    _RoleLine('healer_advice_1', 'advice', 'Ateşin başında susan çocuk, sabah hasta uyanabilir.'),
    _RoleLine('healer_advice_2', 'advice', 'Deri kuru, çadır soğuksa moral de can da düşer.'),
    _RoleLine('healer_advice_3', 'advice', 'Ot kökü kadar tatlı söz de yara kapatır.'),
    _RoleLine('healer_quest_1', 'quest', 'Erzak ve deri getir; ocakları daha sıcak tutayım.'),
    _RoleLine('healer_rumor_1', 'rumor', 'Güney yamaçta şifalı ot gördüler, ama yolu çamurlu.'),
  ];

  static const _rivalLines = <_RoleLine>[
    _RoleLine('rival_advice_1', 'advice', 'Zayıf çadırın gölgesi de kısa olur, bey.'),
    _RoleLine('rival_rumor_1', 'rumor', 'Komşu boylar senin kaç yoldaş topladığını sayıyor.'),
    _RoleLine('rival_rumor_2', 'rumor', 'Pazarda senin itibarını tartan diller var.'),
    _RoleLine('rival_quest_1', 'quest', 'Gücünü kanıtlamak istiyorsan söz değil hazırlık göster.'),
    _RoleLine('rival_advice_2', 'advice', 'Sınırda kararsızlık, kurttan önce korkuyu çağırır.'),
  ];

  static const _merchantLines = <_RoleLine>[
    _RoleLine('merchant_rumor_1', 'rumor', 'Doğu yolunda deri pahalı, demir az.'),
    _RoleLine('merchant_rumor_2', 'rumor', 'Kervanlar sağlam çadırı olan obaya daha rahat uğrar.'),
    _RoleLine('merchant_rumor_3', 'rumor', 'Altını şimdi saklayan, kışın pazarlığı güçlü yapar.'),
    _RoleLine('merchant_quest_1', 'quest', 'Deri getirirsen sana daha sağlam bir yay ayarlayabilirim.'),
    _RoleLine('merchant_advice_1', 'advice', 'Demiri kılıca mı, baltaya mı harcayacağına iyi karar ver.'),
  ];

  static const _rulerLines = <_RoleLine>[
    _RoleLine('ruler_advice_1', 'advice', 'Oba kurmak isteyen önce kendi kapısında düzen kurar.'),
    _RoleLine('ruler_advice_2', 'advice', 'Yoldaşsız otağ boş yankı verir.'),
    _RoleLine('ruler_rumor_1', 'rumor', 'Kağanlık, genç beylerin çadırına değil disiplinine bakar.'),
    _RoleLine('ruler_quest_1', 'quest', 'İtibarını yükselt; sonra büyük söz konuşulur.'),
    _RoleLine('ruler_advice_3', 'advice', 'Güven kazanmadan sancak yükselmez.'),
  ];
}

class _RoleLine {
  const _RoleLine(this.id, this.kind, this.text);
  final String id;
  final String kind;
  final String text;
}

import '../models/npc.dart';
import '../models/resource.dart';

/// Conversations keyed by NPC. The leader picks a reply; each reply shifts the
/// bond with the speaker and may sway the people, the council or the treasury.
class NpcDialogues {
  const NpcDialogues._();

  static const all = <Dialogue>[
    // —— Böri Bey, the council elder ——
    Dialogue(
      id: 'bori_tore',
      npcId: 'bori_bey',
      line:
          'Genç bey, töre eskidikçe sağlamlaşır. Yeni usuller meclisi '
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
      line:
          'Meclisin desteğini umuyorsan, eski beyleri unutma. Bir armağan '
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
      line:
          'Atlılar talimsiz kalırsa kılıç paslanır, bey. Bir talim '
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
      line:
          'Komşu bir kervan korumasız geçiyor. Akın edersek hazine dolar '
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
      line:
          'Beyler sefer için söyleniyor, bey. Meclisi toplayıp divan '
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
      line:
          'Bey, kışlık erzak az. Çocuklar üşüyor. Ocaklara biraz pay '
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
      line:
          'İki genç birbirine söz verdi. Bir düğün obayı şenlendirir, ne '
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
      line:
          'Senin obanın otlağı bana dar geliyor, bey. Sınırı geri çekersen '
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
      line:
          'İpek Yolu’ndan geldim, bey. Bilgi de mal kadar kıymetli. Bir '
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
      line:
          'Beyim, kağanlığa bağlılığın sürüyor mu? Sadık obalar ödülsüz '
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
}

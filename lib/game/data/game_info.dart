import '../models/resource.dart';

/// Plain-language explanations for everything the player sees but the old UI
/// never bothered to describe — resources, skills and what each screen is for.
/// This is the content behind the resource tooltips, the skill detail panels
/// and the living "i" help button.
class GameInfo {
  const GameInfo._();

  // ---- Resources --------------------------------------------------------

  static const resources = <ResourceType, ResourceInfo>{
    ResourceType.gold: ResourceInfo(
      summary: 'Bozkırın akçesi. Erzak, at, kuşam ve yandaş için ödersin.',
      howToEarn: 'Pazarda satış, ticaret, sefer ganimeti ve görev ödülleri.',
      note: 'Evlilik ve oba kurma gibi büyük adımlar altın ister; biriktir.',
    ),
    ResourceType.food: ResourceInfo(
      summary: 'Erzak. Sen, atın ve obanın her gün karnını doyurur.',
      howToEarn: 'Avlan, tarla/toplayıcılık yap, pazardan buğday al.',
      note: 'Her gün biraz tükenir. Biterse moral ve nüfus düşer — açlık.',
    ),
    ResourceType.wood: ResourceInfo(
      summary: 'Odun. Çadır ve yapı güçlendirmenin temel gereci.',
      howToEarn: 'Odun kes ya da pazardan al.',
      note: 'Çadırını seviye atlatmak için odun biriktirmen gerekir.',
    ),
    ResourceType.leather: ResourceInfo(
      summary: 'Deri. Kuşam ve bazı zanaat işleri için kullanılır.',
      howToEarn: 'Avlanınca düşer; pazardan da alınır.',
      note: 'Atölyede kalkan ve zırh yapımında işine yarar.',
    ),
    ResourceType.stone: ResourceInfo(
      summary: 'Taş. Daha sağlam yapılar ve kuleler için gerekir.',
      howToEarn: 'Keşif ve pazardan.',
      note: 'Oba büyüdükçe taş ihtiyacı artar.',
    ),
    ResourceType.iron: ResourceInfo(
      summary: 'Demir. Silah ve sağlam kuşamın özü.',
      howToEarn: 'Keşif, sefer ve pazardan.',
      note: 'İyi silahlar demir ister; sefer gücünü artırır.',
    ),
    ResourceType.horse: ResourceInfo(
      summary: 'At. Bozkırda canın kadar değerli; seni uzağa taşır.',
      howToEarn: 'Pazardan al, ödül ve ganimet olarak kazan.',
      note: 'Atlı birlikler ve uzun keşifler at ister. İyi besle.',
    ),
    ResourceType.reputation: ResourceInfo(
      summary: 'İtibar. Adının bozkırda ne kadar duyulduğu — 0–100.',
      howToEarn:
          'Ticaret, görev, yardım, av/keşif, diplomasi ve sefer itibar kazandırır.',
      note:
          'Tek bir itibar vardır: her ekranda aynı değeri görürsün. Oba '
          'kurmak için 50, evlilik için 20 itibar gerekir.',
    ),
    ResourceType.morale: ResourceInfo(
      summary: 'Moral. Obanın ve hanenin keyfi (0–100).',
      howToEarn: 'Bol erzak, başarı, evlilik ve törenler morali yükseltir.',
      note: 'Sıfıra inip üç gün kalırsa kamp dağılır. Gözünden ayırma.',
    ),
    ResourceType.population: ResourceInfo(
      summary: 'Nüfus. Obana bağlı canlar — gücünün ve büyümenin ölçüsü.',
      howToEarn:
          'Oba kurunca yandaşlarla başlar; moral ve erzak yüksekken artar.',
      note: 'Yalnız bir yolcuyken nüfus 1’dir; oba kurunca büyümeye başlar.',
    ),
  };

  static ResourceInfo? resource(ResourceType type) => resources[type];

  // ---- Skills -----------------------------------------------------------

  /// Keyed by the stat id used in [GameController.spendSkillPoint].
  static const skills = <String, SkillInfo>{
    'courage': SkillInfo(
      name: 'Cesaret',
      affects: 'Sefer ve savaş başarısı, riskli olaylarda gözünü kırpmama.',
      unlocks: 'Yüksek cesaret zorlu seferlere ve akınlara güç katar.',
    ),
    'wisdom': SkillInfo(
      name: 'Bilgelik',
      affects: 'Olay seçimleri, kurultay kararları ve alamet yorumu.',
      unlocks: 'Bilge bir lider kötü olayların zararını azaltır.',
    ),
    'leadership': SkillInfo(
      name: 'Liderlik',
      affects: 'Yandaş çekme, halk ve meclis onayı, oba düzeni.',
      unlocks: 'Liderlik arttıkça insanlar daha kolay yanına gelir.',
    ),
    'endurance': SkillInfo(
      name: 'Dayanıklılık',
      affects: 'Günlük işlerin enerji bedeli ve kıştaki yıpranma.',
      unlocks: 'Her 4 dayanıklılık, aksiyonların enerji bedelini 1 azaltır.',
    ),
    'trade': SkillInfo(
      name: 'Ticaret',
      affects: 'Pazar fiyatları, takas kârı ve ticaretten gelen itibar.',
      unlocks: 'İyi tüccar daha ucuza alır, daha pahalıya satar.',
    ),
    'craft': SkillInfo(
      name: 'Zanaat',
      affects: 'Atölye üretimi ve kuşam yapımı.',
      unlocks: 'Zanaatkârlık daha iyi eşya ve daha hızlı üretim getirir.',
    ),
    'archery': SkillInfo(
      name: 'Okçuluk',
      affects: 'Avın bereketi ve okçu birliklerin gücü.',
      unlocks: 'Usta okçu daha çok av eti ve deri getirir.',
    ),
    'warfare': SkillInfo(
      name: 'Savaş',
      affects: 'Ordu gücü, kuşatma ve sefer başarısı.',
      unlocks: 'Savaş arttıkça fetih ve akınlarda üstün gelirsin.',
    ),
  };

  static SkillInfo? skill(String stat) => skills[stat];

  // ---- Screen help ("i" button) ----------------------------------------

  static HelpTopic? help(HelpId id) => _help[id];

  static const _help = <HelpId, HelpTopic>{
    HelpId.camp: HelpTopic(
      title: 'Kendi Çadırın',
      purpose:
          'Burası gece bozkırında tek çadırın. Sahnedeki yerlere dokunarak '
          'iş yapar, kaynak biriktirir ve adını duyurursun.',
      steps: [
        'Aşağıdaki kartlardan Odun Kes / Avlan ile kaynak topla.',
        'Ocağa dokun: dinlen ya da ateş başı olayını çöz.',
        'Sandık, at ve tezgâha dokun; çevreni keşfet.',
        'Üstteki kaynak ikonlarına dokunup ne işe yaradıklarını öğren.',
      ],
      tip:
          'Bu küçük çadır bir gün obanın kalbi olacak. İtibarını 50’ye '
          'çıkar, yandaş ve güçlü bir bağ kur, toprağı keşfet — sonra oba kur.',
    ),
    HelpId.character: HelpTopic(
      title: 'Karakter',
      purpose:
          'Liderinin hâli burada: yaş, seviye, sağlık, itibar ve beceriler. '
          'Becerilere dokunarak ne işe yaradıklarını gör.',
      steps: [
        'Beceri satırına dokun: o becerinin etkisini açıklar.',
        'Beceri puanın varsa + ile beceri yükselt.',
        'Soy/hane ve evlilik adaylarını buradan takip et.',
      ],
      tip: 'İtibar tek kaynaklıdır — burada gördüğün değer her yerde aynıdır.',
    ),
    HelpId.tent: HelpTopic(
      title: 'Çadırım',
      purpose:
          'Çadırını güçlendirdiğin ve oba kurma yolundaki şartları gördüğün '
          'yer.',
      steps: [
        'Odun/taş biriktirip ana çadırını seviye atlat.',
        'Oba kurma şartlarını gözden geçir; eksiğini tamamla.',
        'Tüm şartlar tamamsa kendi obanı kur.',
      ],
      tip:
          'Oba kurmak için: itibar 50, 3 yandaş, çadır Lv.2, güçlü bir bağ '
          've keşfedilmiş toprak gerekir.',
    ),
    HelpId.people: HelpTopic(
      title: 'Yakınlar',
      purpose:
          'Çevredeki insanlarla konuşup bağ kurduğun yer. Bağ 75’i geçince '
          'kişi sana yürekten bağlı bir yandaş olur.',
      steps: [
        'Biriyle konuş; bağınız ısınsın.',
        'Yardım et, hediye ver; güveni kazan.',
        'Üç güvenilir yandaş, oba kurmanın şartlarından biridir.',
      ],
      tip:
          'Bağı 90’a ulaşan bir yoldaş, evlilik yerine geçen güçlü bağı sağlar.',
    ),
    HelpId.journey: HelpTopic(
      title: 'Yolculuk / Keşif',
      purpose:
          'Yakın yolları ve toprağı keşfettiğin yer. Keşif itibar, ganimet '
          've oba kurmak için gereken "uygun toprak"ı getirir.',
      steps: [
        'Yakın bölgeleri keşfe çık.',
        'Riski ve ödülü tartarak ilerle.',
        'Uygun toprağı bulunca oba kurma şartı tamamlanır.',
      ],
      tip: 'Keşif enerji ister; yorgunsan önce dinlen.',
    ),
    HelpId.market: HelpTopic(
      title: 'Pazar / Han',
      purpose:
          'Alıp sattığın, paralı savaşçı ve yoldaş bulduğun yer. Fiyatlar '
          'günden güne oynar; ucuza al, pahalıya sat.',
      steps: [
        'Sat sekmesinde fazlanı altına çevir.',
        'Al sekmesinde ihtiyacını tamamla; yeşil fiyat ucuz demektir.',
        'Han’da yoldaş ve nadir teklifleri kollar.',
      ],
      tip: 'Yeşil fiyat normalin altında, kırmızı fiyat üstündedir.',
    ),
    HelpId.atelier: HelpTopic(
      title: 'Atölye',
      purpose: 'Kaynaklarını kuşam ve eşyaya dönüştürdüğün tezgâh.',
      steps: [
        'Bir tarif seç ve üretimi başlat (gereçleri peşin öder).',
        'Üretim gün sonunda ilerler; biten eşya envantere düşer.',
        'Kuşamı karakter ekranından kuşan; sefer gücün artar.',
      ],
      tip: 'Zanaat becerin yüksekse üretim daha verimli olur.',
    ),
    HelpId.oba: HelpTopic(
      title: 'Oba',
      purpose:
          'Obanın yapıları, üretimi ve düzeni. Yapıları geliştirdikçe oban '
          'güçlenir.',
      steps: [
        'Yapıları kaynakla geliştir.',
        'Nüfus, moral ve erzak dengesini koru.',
        'Yandaşlara rol vererek günlük bonus kazan.',
      ],
      tip: 'Aç ya da moralsiz bir oba küçülür; önce temeli sağlam tut.',
    ),
    HelpId.boy: HelpTopic(
      title: 'Boylar / Diplomasi',
      purpose:
          'Komşu boylarla ilişki kurduğun yer. Dost boylar ticaret ve evlilik '
          'bağı, düşman boylar tehdit demektir.',
      steps: [
        'Elçi gönder ya da hediye ver; ilişkiyi yükselt.',
        'Ticaret yolu aç.',
        'İlişkiler savaş ve evlilik fırsatlarını etkiler.',
      ],
      tip: 'Bu oyun tek kişiliktir — boylar yapay, çevrimiçi değildir.',
    ),
    HelpId.expeditions: HelpTopic(
      title: 'Sefer / Harita',
      purpose:
          'Uzak hedeflere sefer düzenlediğin yer. Her seferin rotası, riski '
          've süresi vardır.',
      steps: [
        'Hedefi seç; başarı şansını ve ödülü gör.',
        'Ordunu ve kuşamını güçlendirerek şansı yükselt.',
        'Sefer günlerce sürebilir; ordu yolda ilerler.',
      ],
      tip: 'Başarı şansı düşükse önce güçlen; bozgun ağır bedel ödetir.',
    ),
    HelpId.settings: HelpTopic(
      title: 'Ayarlar',
      purpose: 'Ses, sarsıntı ve oyun verisi ayarları.',
      steps: [
        'Müzik, ses efektleri ve sarsıntıyı aç/kapat.',
        'Lider ya da oba adını değiştir.',
        'İstersen oyunu sıfırlayıp yeni bir ömür başlat.',
      ],
      tip: 'Tüm ayarlar gerçek zamanlı çalışır ve kaydedilir.',
    ),
  };
}

class ResourceInfo {
  const ResourceInfo({
    required this.summary,
    required this.howToEarn,
    required this.note,
  });

  final String summary;
  final String howToEarn;
  final String note;
}

class SkillInfo {
  const SkillInfo({
    required this.name,
    required this.affects,
    required this.unlocks,
  });

  final String name;
  final String affects;
  final String unlocks;
}

/// Identifies which screen the "i" help button speaks for.
enum HelpId {
  camp,
  character,
  tent,
  people,
  journey,
  market,
  atelier,
  oba,
  boy,
  expeditions,
  settings,
}

class HelpTopic {
  const HelpTopic({
    required this.title,
    required this.purpose,
    required this.steps,
    required this.tip,
  });

  final String title;
  final String purpose;
  final List<String> steps;
  final String tip;
}

import '../models/camp_building.dart';
import '../models/clan.dart';
import '../models/event_choice.dart';
import '../models/faith.dart';
import '../models/game_day.dart';
import '../models/household.dart';
import '../models/horse.dart';
import '../models/marriage_candidate.dart';
import '../models/player_profile.dart';
import '../models/quest.dart';
import '../models/resource.dart';
import '../models/season.dart';
import '../models/tribe_relation.dart';
import '../state/game_state.dart';
import 'market_goods.dart';

/// Action ids counted by quest goals.
class GameActions {
  const GameActions._();

  static const wood = 'wood';
  static const farm = 'farm';
  static const hunt = 'hunt';
  static const mercenary = 'mercenary';
  static const rest = 'rest';
  static const diplomacy = 'diplomacy';
  static const ritual = 'ritual';
  static const sacredVisit = 'sacred_visit';
  static const advisor = 'advisor';
  static const toreCase = 'tore_case';
  static const training = 'training';
  static const explore = 'explore';
  static const expedition = 'expedition';
  static const event = 'event';
  static const trade = 'trade';
  static const tentUpgrade = 'tent_upgrade';
}

class StarterGameData {
  const StarterGameData._();

  static GameState create() => GameState(
    profile: const PlayerProfile(
      name: 'Bumin',
      title: 'Yolcu',
      age: 14,
      reputation: 5,
      courage: 3,
      wisdom: 3,
      leadership: 2,
      endurance: 3,
      trade: 2,
      craft: 2,
      archery: 3,
      warfare: 3,
    ),
    // Before founding an oba, "clan" simply names the lone tent the
    // traveller pitches. It becomes the oba's name once one is founded.
    clan: const Clan(
      name: 'Kendi Çadırın',
      motto: 'Önce kendini, çadırını ve adını büyüt.',
    ),
    day: const GameDay(day: 1, season: Season.spring),
    // A small, lonely start: a little of everything and a single horse.
    resources: const {
      ResourceType.gold: 40,
      ResourceType.food: 30,
      ResourceType.wood: 15,
      ResourceType.leather: 5,
      ResourceType.stone: 8,
      ResourceType.iron: 4,
      ResourceType.horse: 1,
      ResourceType.reputation: 5,
      ResourceType.morale: 60,
      ResourceType.population: 1,
    },
    quests: [...dailyQuestsFor(1), ...storyQuests],
    currentEvent: events.first,
    eventIndex: 0,
    log: const ['Tek bir çadır kuruldu. Genç bir yolcunun ömrü başlıyor.'],
    buildings: campBuildings,
    tribes: tribes,
    household: const Household(),
    marriageCandidates: marriageCandidates,
    faithState: const FaithState(),
    spiritualAdvisor: spiritualAdvisor,
    rituals: rituals,
    sacredPlaces: sacredPlaces,
    marketStock: MarketGoods.startingStock(),
    foodInventory: const {'raw_meat': 1, 'root_vegetable': 2, 'water_skin': 1},
    dailyOpportunities: const ['fish_river', 'cold_night', 'youth_training'],
    questChainProgress: const {
      'first_fire': 0,
      'winter_prep': 0,
      'first_bow': 0,
      'old_inscription': 0,
      'oba_road': 0,
    },
    horses: const [
      Horse(
        id: 'boz_yele',
        name: 'Boz Yele',
        breed: 'Bozkır Atı',
        acquiredDay: 1,
      ),
    ],
    locationStates: const {
      'hunting_ground': 'discovered',
      'forest_edge': 'discovered',
      'river_bank': 'undiscovered',
      'old_inscription': 'undiscovered',
      'market_road': 'undiscovered',
      'salt_bed': 'undiscovered',
    },
    obaFounded: false,
    landScouted: false,
  );

  static const spiritualAdvisor = SpiritualAdvisor(
    id: 'aruk_kam',
    name: 'Aruk Kam',
    role: 'Kam',
    level: 1,
    effect: 'Alametleri yorumlar, kötü olay riskini azaltır.',
    cooldownDays: 1,
    description:
        'Ateşin dili, rüzgârın yönü ve düşlerin izi üzerine konuşan yaşlı kam.',
  );

  static const rituals = <Ritual>[
    Ritual(
      id: 'sky_oath',
      name: 'Gök Altında Ant İçme',
      description: 'Oba ileri gelenleri açık gök altında birlik sözü verir.',
      cost: {ResourceType.gold: 80},
      cooldownDays: 5,
      faithEffects: {'kut': 8, 'tore': 4},
      resourceEffects: {ResourceType.reputation: 2, ResourceType.morale: 2},
      effectDescription: 'Kut +8, Töre +4, İtibar +2',
      bonusDurationDays: 3,
    ),
    Ritual(
      id: 'ancestor_honor',
      name: 'Atalara Saygı Töreni',
      description: 'Ocak başında geçmiş kuşakların adı saygıyla anılır.',
      cost: {ResourceType.food: 15, ResourceType.wood: 10},
      cooldownDays: 4,
      faithEffects: {'ancestorHonor': 10, 'faith': 3},
      resourceEffects: {ResourceType.morale: 6},
      effectDescription: 'Atalara Saygı +10, Moral +6, Hane morali +4',
      bonusDurationDays: 4,
    ),
    Ritual(
      id: 'spring_fire',
      name: 'Bahar Ateşi',
      description: 'Bahar ve yaz gecelerinde oba ateşi canlı tutulur.',
      cost: {ResourceType.wood: 20},
      cooldownDays: 4,
      faithEffects: {'faith': 5},
      resourceEffects: {ResourceType.morale: 8},
      energyEffect: 10,
      effectDescription: 'Enerji +10, Moral +8, İnanç +5',
      seasonHint: 'İlkbahar/Yaz döneminde daha anlamlıdır.',
    ),
    Ritual(
      id: 'winter_prayer',
      name: 'Kış Duası',
      description:
          'Soğuk günler için sakin ve ölçülü bir hazırlık duası yapılır.',
      cost: {ResourceType.food: 20, ResourceType.wood: 25},
      cooldownDays: 5,
      faithEffects: {'faith': 4, 'kut': 3},
      healthEffect: 5,
      effectDescription:
          'Kış uyarılarını azaltır, sağlık toparlanmasına yardım eder.',
      seasonHint: 'Sonbahar/Kış döneminde daha değerlidir.',
    ),
    Ritual(
      id: 'war_kut',
      name: 'Savaş Öncesi Kut Töreni',
      description:
          'Sefer öncesi yürekler toparlanır, liderin kutu hatırlatılır.',
      cost: {ResourceType.gold: 120},
      cooldownDays: 5,
      faithEffects: {'kut': 5, 'faith': 2},
      statEffects: {'courage': 1},
      effectDescription: 'Kut +5, sefer hazırlığı kutsaması, Cesaret eğitimi',
      bonusDurationDays: 2,
    ),
  ];

  static const sacredPlaces = <SacredPlace>[
    SacredPlace(
      id: 'old_inscription',
      name: 'Eski Yazıt',
      description: 'Taşa işlenmiş eski damgalar obanın geçmişini hatırlatır.',
      risk: 'Düşük',
      reward: 'Bilgelik XP, Atalara Saygı, Kut',
      faithEffects: {'ancestorHonor': 5, 'kut': 2},
      xpReward: 12,
      energyCost: 8,
    ),
    SacredPlace(
      id: 'sky_hill',
      name: 'Gök Tepesi',
      description: 'Ufku geniş, rüzgârı sert bir tepe.',
      risk: 'Orta',
      reward: 'İnanç ve Kut',
      faithEffects: {'faith': 6, 'kut': 3},
      xpReward: 10,
      energyCost: 10,
    ),
    SacredPlace(
      id: 'ancestor_rock',
      name: 'Atalar Kayası',
      description: 'Obanın eski göç yolunda saygıyla durduğu kaya.',
      risk: 'Düşük',
      reward: 'Atalara Saygı ve Töre',
      faithEffects: {'ancestorHonor': 7, 'tore': 2},
      xpReward: 10,
      energyCost: 8,
    ),
    SacredPlace(
      id: 'sacred_river',
      name: 'Kutsal Irmak',
      description: 'Suyu serin, kıyısı sakin bir durak.',
      risk: 'Düşük',
      reward: 'Sağlık, İnanç',
      faithEffects: {'faith': 4},
      resourceEffects: {ResourceType.morale: 2},
      xpReward: 8,
      energyCost: 6,
    ),
    SacredPlace(
      id: 'wind_pass',
      name: 'Rüzgâr Geçidi',
      description: 'Rüzgârın haber taşıdığına inanılan dar geçit.',
      risk: 'Orta',
      reward: 'Kut ve keşif tecrübesi',
      faithEffects: {'kut': 3, 'faith': 3},
      xpReward: 14,
      energyCost: 12,
    ),
  ];

  static const campBuildings = <CampBuilding>[
    CampBuilding(
      id: 'main_tent',
      name: 'Ana Çadır',
      description: 'Obanın merkezi ve kağanın otağı.',
      level: 1,
      maxLevel: 5,
      category: 'Merkez',
      upgradeCost: {
        ResourceType.wood: 40,
        ResourceType.leather: 15,
        ResourceType.gold: 100,
      },
      effectDescription:
          'Her seviye max nüfus ve 2. seviyeden sonra aksiyon hakkı desteği verir.',
    ),
    CampBuilding(
      id: 'storage',
      name: 'Depo',
      description: 'Erzak, odun ve maden saklanan güvenli alan.',
      level: 1,
      maxLevel: 5,
      category: 'Ekonomi',
      upgradeCost: {ResourceType.wood: 35, ResourceType.stone: 20},
      effectDescription: 'Kaynak kapasitesi ve kış hazırlığı güvenliği artar.',
    ),
    CampBuilding(
      id: 'pen',
      name: 'Ağıl',
      description: 'Sürülerin korunduğu çitli alan.',
      level: 1,
      maxLevel: 5,
      category: 'Üretim',
      upgradeCost: {ResourceType.wood: 25, ResourceType.leather: 8},
      effectDescription: 'Gün sonunda küçük erzak ve kış dayanımı bonusu.',
    ),
    CampBuilding(
      id: 'horse_herd',
      name: 'At Sürüsü',
      description: 'Sefer ve ticaret yolları için yetiştirilen atlar.',
      level: 1,
      maxLevel: 5,
      category: 'Sefer',
      upgradeCost: {ResourceType.food: 25, ResourceType.gold: 80},
      effectDescription: 'Sefer başarısı ve ticaret geliri artar.',
    ),
    CampBuilding(
      id: 'workshop',
      name: 'Atölye',
      description: 'Ustaların ekipman ve gündelik eşya ürettiği çadır.',
      level: 1,
      maxLevel: 5,
      category: 'Üretim',
      upgradeCost: {
        ResourceType.wood: 30,
        ResourceType.iron: 25,
        ResourceType.leather: 10,
      },
      effectDescription:
          'Zanaat ödülleri artar, üretim maliyeti hissedilir azalır.',
    ),
    CampBuilding(
      id: 'healer',
      name: 'Şifacı Çadırı',
      description: 'Otacılar hastalık ve yaralarla ilgilenir.',
      level: 1,
      maxLevel: 5,
      category: 'Sağlık',
      upgradeCost: {ResourceType.leather: 12, ResourceType.gold: 60},
      effectDescription: 'Sağlık toparlanması ve hastalık riski iyileşir.',
    ),
    CampBuilding(
      id: 'training',
      name: 'Eğitim Alanı',
      description: 'Gençler ok, kılıç ve disiplin çalışır.',
      level: 1,
      maxLevel: 5,
      category: 'Askerî',
      upgradeCost: {ResourceType.wood: 25, ResourceType.iron: 10},
      effectDescription: 'Savaş ve okçuluk XP kazanımı artar.',
    ),
    CampBuilding(
      id: 'watchtower',
      name: 'Gözcü Kulesi',
      description: 'Bozkırdaki tehlikeleri erken görmeyi sağlar.',
      level: 1,
      maxLevel: 5,
      category: 'Güvenlik',
      upgradeCost: {ResourceType.wood: 45, ResourceType.stone: 15},
      effectDescription:
          'Riskli olaylarda ve seferlerde kayıp ihtimali azalır.',
    ),
    CampBuilding(
      id: 'market_tent',
      name: 'Pazar Çadırı',
      description: 'Kervan ve komşu boylarla alışveriş noktası.',
      level: 1,
      maxLevel: 5,
      category: 'Ekonomi',
      upgradeCost: {ResourceType.wood: 20, ResourceType.gold: 120},
      effectDescription: 'Ticaret ve altın ödülleri artar.',
    ),
    CampBuilding(
      id: 'council',
      name: 'Yaşlılar Meclisi',
      description: 'Bilge yaşlılar zor kararları tartışır.',
      level: 1,
      maxLevel: 5,
      category: 'Karar',
      upgradeCost: {ResourceType.food: 20, ResourceType.gold: 70},
      effectDescription: 'Bilgelik kararları ve olay güvenliği güçlenir.',
    ),
    CampBuilding(
      id: 'kam_tent',
      name: 'Kam Çadırı',
      description: 'Aruk Kam’ın alametleri yorumladığı sakin çadır.',
      level: 1,
      maxLevel: 3,
      category: 'İnanç',
      upgradeCost: {
        ResourceType.wood: 25,
        ResourceType.leather: 10,
        ResourceType.gold: 60,
      },
      effectDescription:
          'Kam danışma etkisi ve kötü alamet yatıştırma gücü artar.',
    ),
    CampBuilding(
      id: 'sacred_fire',
      name: 'Kutsal Ateş Alanı',
      description: 'Oba törenlerinin yakıldığı ortak ateş alanı.',
      level: 1,
      maxLevel: 3,
      category: 'İnanç',
      upgradeCost: {ResourceType.wood: 35, ResourceType.stone: 10},
      effectDescription:
          'Ritüel moral etkileri ve inanç toparlanması güçlenir.',
    ),
  ];

  static const tribes = <TribeRelation>[
    TribeRelation(
      id: 'kara_kurtlar',
      name: 'Kara Kurtlar',
      relation: 18,
      power: 62,
      population: 140,
      leader: 'Togan Alp',
      tradeOpen: true,
    ),
    TribeRelation(
      id: 'demir_kartallar',
      name: 'Demir Kartallar',
      relation: 8,
      power: 78,
      population: 170,
      leader: 'Kutalmış Bey',
    ),
    TribeRelation(
      id: 'gok_yeleler',
      name: 'Gök Yeleler',
      relation: 14,
      power: 58,
      population: 120,
      leader: 'Saru Han',
    ),
    TribeRelation(
      id: 'ak_sancak',
      name: 'Ak Sancak',
      relation: 22,
      power: 54,
      population: 115,
      leader: 'Ilbars',
    ),
    TribeRelation(
      id: 'yagiz_oba',
      name: 'Yağız Oba',
      relation: -8,
      power: 66,
      population: 150,
      leader: 'Barsbek',
    ),
  ];

  static const marriageCandidates = <MarriageCandidate>[
    MarriageCandidate(
      id: 'aybuke',
      name: 'Aybüke',
      age: 18,
      tribeName: 'Kara Kurtlar',
      personality: 'Bilge',
      compatibility: 65,
      relation: 25,
      diplomaticValue: 18,
      bonusType: 'Bilgelik',
    ),
    MarriageCandidate(
      id: 'selen',
      name: 'Selen',
      age: 17,
      tribeName: 'Gök Yeleler',
      personality: 'Cesur',
      compatibility: 58,
      relation: 20,
      diplomaticValue: 16,
      bonusType: 'Savaş/Okçuluk',
    ),
    MarriageCandidate(
      id: 'umay',
      name: 'Umay',
      age: 20,
      tribeName: 'Ak Sancak',
      personality: 'Şifacı',
      compatibility: 72,
      relation: 28,
      diplomaticValue: 20,
      bonusType: 'Sağlık/Moral',
    ),
    MarriageCandidate(
      id: 'almila',
      name: 'Almila',
      age: 19,
      tribeName: 'Demir Kartallar',
      personality: 'Tüccar soylu',
      compatibility: 55,
      relation: 18,
      diplomaticValue: 22,
      bonusType: 'Ticaret/Altın',
    ),
  ];

  /// Rotating pool of daily quests; three are active per day.
  static const dailyQuestPool = <Quest>[
    Quest(
      id: 'd_hunt',
      title: 'Avcıları avlağa gönder',
      category: 'Günlük',
      description: 'Bozkırdaki izleri takip edip obaya av getir.',
      rewardText: 'Erzak +14, Deri +3, XP +18',
      xpReward: 18,
      goalType: QuestGoalType.action,
      goalAction: GameActions.hunt,
      goalTarget: 1,
      resourceRewards: {ResourceType.food: 14, ResourceType.leather: 3},
    ),
    Quest(
      id: 'd_wood',
      title: 'Ocak için odun yığ',
      category: 'Günlük',
      description: 'Baltacıları ormana gönderip odun stokunu artır.',
      rewardText: 'Odun +10, Moral +1, XP +12',
      xpReward: 12,
      goalType: QuestGoalType.action,
      goalAction: GameActions.wood,
      goalTarget: 2,
      resourceRewards: {ResourceType.wood: 10, ResourceType.morale: 1},
    ),
    Quest(
      id: 'd_farm',
      title: 'Hasadı kaldır',
      category: 'Günlük',
      description: 'Tarladaki işleri bitirip ambarları doldur.',
      rewardText: 'Erzak +16, İtibar +1, XP +10',
      xpReward: 10,
      goalType: QuestGoalType.action,
      goalAction: GameActions.farm,
      goalTarget: 2,
      resourceRewards: {ResourceType.food: 16, ResourceType.reputation: 1},
    ),
    Quest(
      id: 'd_trade',
      title: 'Pazarda takas yap',
      category: 'Günlük',
      description: 'Tüccarlarla en az bir alışveriş tamamla.',
      rewardText: 'Altın +20, XP +10',
      xpReward: 10,
      goalType: QuestGoalType.action,
      goalAction: GameActions.trade,
      goalTarget: 1,
      resourceRewards: {ResourceType.gold: 20},
    ),
    Quest(
      id: 'd_explore',
      title: 'Bozkırı kolaçan et',
      category: 'Günlük',
      description: 'İzcileri çevre bölgelere gönder.',
      rewardText: 'İtibar +2, Moral +1, XP +16',
      xpReward: 16,
      goalType: QuestGoalType.action,
      goalAction: GameActions.explore,
      goalTarget: 1,
      resourceRewards: {ResourceType.reputation: 2, ResourceType.morale: 1},
    ),
    Quest(
      id: 'd_event',
      title: 'Obanın derdini dinle',
      category: 'Günlük',
      description: 'Günün olayını bir karara bağla.',
      rewardText: 'Moral +2, XP +12',
      xpReward: 12,
      goalType: QuestGoalType.action,
      goalAction: GameActions.event,
      goalTarget: 1,
      resourceRewards: {ResourceType.morale: 2},
    ),
  ];

  /// Three dailies chosen by rotating through the pool day by day.
  static List<Quest> dailyQuestsFor(int day) {
    const pool = dailyQuestPool;
    final start = (day - 1) * 3;
    return [for (var i = 0; i < 3; i++) pool[(start + i) % pool.length]];
  }

  /// One-shot quests that persist across days.
  static const storyQuests = <Quest>[
    Quest(
      id: 's_ancestor_ritual',
      title: 'Atalara Saygı Töreni Düzenle',
      category: 'İnanç',
      description: 'Oba ocağında ataları saygıyla anan bir tören düzenle.',
      rewardText: 'Atalara Saygı ve Moral güçlenir, XP +20',
      goalType: QuestGoalType.action,
      goalAction: GameActions.ritual,
      goalTarget: 1,
      resourceRewards: {ResourceType.morale: 2},
      xpReward: 20,
    ),
    Quest(
      id: 's_sacred_visit',
      title: 'Eski Yazıtı Ziyaret Et',
      category: 'İnanç',
      description:
          'Kutsal mekânlardan birini ziyaret ederek geçmişin izini sür.',
      rewardText: 'Bilgelik +1, İtibar +1, XP +18',
      goalType: QuestGoalType.action,
      goalAction: GameActions.sacredVisit,
      goalTarget: 1,
      resourceRewards: {ResourceType.reputation: 1},
      statRewards: {'wisdom': 1},
      xpReward: 18,
    ),
    Quest(
      id: 's_omen_advisor',
      title: 'Kam ile Alameti Yorumla',
      category: 'İnanç',
      description: 'Aruk Kam’dan günün alametini yorumlamasını iste.',
      rewardText: 'Kut +2, Moral +1, XP +14',
      goalType: QuestGoalType.action,
      goalAction: GameActions.advisor,
      goalTarget: 1,
      resourceRewards: {ResourceType.morale: 1},
      xpReward: 14,
    ),
    Quest(
      id: 's_tore_case',
      title: 'Töre Davasını Çöz',
      category: 'İnanç',
      description:
          'Aileler arasındaki bir anlaşmazlığı töreye uygun karara bağla.',
      rewardText: 'Töre +2, İtibar +1, XP +16',
      goalType: QuestGoalType.action,
      goalAction: GameActions.toreCase,
      goalTarget: 1,
      resourceRewards: {ResourceType.reputation: 1},
      xpReward: 16,
    ),
    Quest(
      id: 's_winter_prayer',
      title: 'Kış Duası Hazırla',
      category: 'İnanç',
      description:
          'Soğuk mevsim için erzak ve odunla ölçülü bir tören hazırla.',
      rewardText: 'Sağlık toparlanır, XP +16',
      goalType: QuestGoalType.action,
      goalAction: GameActions.ritual,
      goalTarget: 2,
      xpReward: 16,
    ),
    Quest(
      id: 's_scout',
      title: 'Irmak kıyısında keşif yap',
      category: 'Hikâye',
      description: 'Su yollarını ve geçitleri haritaya işle: üç keşif tamamla.',
      rewardText: 'Bilgelik +1, Odun +8',
      goalType: QuestGoalType.action,
      goalAction: GameActions.explore,
      goalTarget: 3,
      resourceRewards: {ResourceType.wood: 8},
      statRewards: {'wisdom': 1},
    ),
    Quest(
      id: 's_border',
      title: 'Sınır ötesine sefer düzenle',
      category: 'Hikâye',
      description: 'Haritadaki bir hedefe sefere çık ve geri dön.',
      rewardText: 'Cesaret +1, Altın +30',
      goalType: QuestGoalType.action,
      goalAction: GameActions.expedition,
      goalTarget: 1,
      resourceRewards: {ResourceType.gold: 30},
      statRewards: {'courage': 1},
    ),
    Quest(
      id: 's_council',
      title: 'Yaşlılar Meclisi ile hükmet',
      category: 'Oba',
      description: 'Üç oba olayını karara bağlayıp tecrübe kazan.',
      rewardText: 'Liderlik +1, Moral +2',
      goalType: QuestGoalType.action,
      goalAction: GameActions.event,
      goalTarget: 3,
      resourceRewards: {ResourceType.morale: 2},
      statRewards: {'leadership': 1},
    ),
    Quest(
      id: 's_winter',
      title: 'Kışa hazırlan',
      category: 'Oba',
      description: 'Ambarda 150 erzak biriktir.',
      rewardText: 'Moral +4, Bilgelik +1',
      goalType: QuestGoalType.resource,
      goalResource: ResourceType.food,
      goalTarget: 150,
      resourceRewards: {ResourceType.morale: 4},
      statRewards: {'wisdom': 1},
    ),
    Quest(
      id: 's_herd',
      title: 'At sürüsünü büyüt',
      category: 'Oba',
      description: 'Sürüyü 12 başa çıkar.',
      rewardText: 'Cesaret +1, İtibar +2',
      goalType: QuestGoalType.resource,
      goalResource: ResourceType.horse,
      goalTarget: 12,
      resourceRewards: {ResourceType.reputation: 2},
      statRewards: {'courage': 1},
    ),
  ];

  static const events = <GameEvent>[
    GameEvent(
      id: 'cold_wind',
      title: 'Kuzeyden Soğuk Rüzgâr',
      description:
          'Gece vakti kuzeyden soğuk rüzgâr indi. Sürünün bir kısmı huzursuz.',
      choices: [
        EventChoice(
          id: 'guards',
          label: 'Nöbetçileri artır',
          description: 'Ateşleri besleyip sürüyü sakinleştir.',
          resourceEffects: {
            ResourceType.wood: -5,
            ResourceType.morale: 3,
            ResourceType.reputation: 1,
          },
        ),
        EventChoice(
          id: 'leave',
          label: 'Kendi hâline bırak',
          description: 'Oba kaynak harcamaz ama huzur azalır.',
          resourceEffects: {ResourceType.morale: -2},
        ),
        EventChoice(
          id: 'council',
          label: 'Meclis’e danış',
          description: 'Kadim deneyim doğru yolu gösterir.',
          statEffects: {'wisdom': 1},
        ),
      ],
    ),
    GameEvent(
      id: 'merchant_road',
      title: 'Ticaret Yolunda Duman',
      description: 'Uzakta bir kervanın ateşi göründü; takas fırsatı olabilir.',
      choices: [
        EventChoice(
          id: 'trade',
          label: 'Deri takas et',
          description: 'Deri ver, erzak al.',
          resourceEffects: {ResourceType.leather: -4, ResourceType.food: 16},
        ),
        EventChoice(
          id: 'escort',
          label: 'Kervana refakat et',
          description: 'İtibar kazan ama atlar yorulur.',
          resourceEffects: {ResourceType.horse: -1, ResourceType.reputation: 3},
        ),
      ],
    ),
    GameEvent(
      id: 'winter_wood_shortage',
      title: 'Kış İçin Odun Eksik',
      description: 'Yaşlılar gece soğuğuna karşı odun yığılmasını ister.',
      choices: [
        EventChoice(
          id: 'share_wood',
          label: 'Odun ayır',
          description: 'Stok azalır ama oba rahatlar.',
          resourceEffects: {ResourceType.wood: -12, ResourceType.morale: 5},
          fatigueEffect: -2,
        ),
        EventChoice(
          id: 'tighten',
          label: 'Tasarruf emri ver',
          description: 'Kaynak korunur, moral biraz düşer.',
          resourceEffects: {ResourceType.morale: -2},
          statEffects: {'leadership': 1},
        ),
      ],
    ),
    GameEvent(
      id: 'sick_herd',
      title: 'Sürü Hastalandı',
      description: 'Ağıldaki birkaç hayvanın halsiz olduğu haber verildi.',
      choices: [
        EventChoice(
          id: 'healer',
          label: 'Şifacıları çağır',
          description: 'Altın harcanır, kayıp önlenir.',
          resourceEffects: {ResourceType.gold: -35, ResourceType.morale: 2},
          healthEffect: 2,
        ),
        EventChoice(
          id: 'cull',
          label: 'Sürüyü ayır',
          description: 'Bir at kaybedilir ama hastalık yayılmaz.',
          resourceEffects: {ResourceType.horse: -1, ResourceType.food: 8},
        ),
      ],
    ),
    GameEvent(
      id: 'young_training',
      title: 'Gençler Eğitim İstiyor',
      description: 'Oba gençleri ok ve kılıç talimi için izin ister.',
      choices: [
        EventChoice(
          id: 'train',
          label: 'Eğitim başlat',
          description: 'Erzak harcanır, savaşçılar güçlenir.',
          resourceEffects: {ResourceType.food: -8, ResourceType.morale: 3},
          statEffects: {'warfare': 1, 'archery': 1},
          fatigueEffect: 4,
        ),
        EventChoice(
          id: 'delay',
          label: 'Hasattan sonraya bırak',
          description: 'Bugün kaynak harcanmaz.',
          resourceEffects: {ResourceType.morale: -1},
        ),
      ],
    ),
    GameEvent(
      id: 'neighbor_envoy',
      title: 'Komşu Boy Elçisi',
      description: 'Bir komşu boy sınırdaki geçişler için söz ister.',
      choices: [
        EventChoice(
          id: 'welcome',
          label: 'Elçiyi ağırla',
          description: 'Altın harcanır, itibar yükselir.',
          resourceEffects: {ResourceType.gold: -25, ResourceType.reputation: 2},
          statEffects: {'wisdom': 1},
        ),
        EventChoice(
          id: 'stern',
          label: 'Sert cevap ver',
          description: 'Cesaret duyulur ama gerginlik artar.',
          resourceEffects: {
            ResourceType.reputation: 1,
            ResourceType.morale: -1,
          },
          statEffects: {'courage': 1},
        ),
      ],
    ),
    GameEvent(
      id: 'household_morale',
      title: 'Hane İçinde Moral Yükseldi',
      description: 'Aile ocağında kurulan dayanışma obaya da yayılıyor.',
      choices: [
        EventChoice(
          id: 'celebrate',
          label: 'Sofra kur',
          description: 'Erzak azalır, moral yükselir.',
          resourceEffects: {ResourceType.food: -10, ResourceType.morale: 6},
          fatigueEffect: -4,
        ),
        EventChoice(
          id: 'quiet',
          label: 'Sessizce teşekkür et',
          description: 'Küçük ama kalıcı bir itibar kazanılır.',
          resourceEffects: {ResourceType.reputation: 1},
        ),
      ],
    ),
    GameEvent(
      id: 'foggy_pass',
      title: 'Dağ Geçidinde Puslu Hava',
      description: 'İzciler sefer yolunda pus ve kaygan taşlar gördü.',
      choices: [
        EventChoice(
          id: 'wait',
          label: 'Güvenli bekleyiş',
          description: 'Yorgunluk azalır, zaman kaybedilir.',
          resourceEffects: {ResourceType.morale: 1},
          fatigueEffect: -6,
        ),
        EventChoice(
          id: 'push',
          label: 'Risk al ve ilerle',
          description: 'Cesaret artar ama yorgunluk bindirir.',
          resourceEffects: {ResourceType.reputation: 2},
          statEffects: {'courage': 1},
          fatigueEffect: 10,
          energyEffect: -8,
        ),
      ],
    ),
    GameEvent(
      id: 'tore_herd_dispute',
      title: 'Töre Davası: Sürü Payı',
      description: 'İki aile arasında sürü paylaşımı yüzünden tartışma çıktı.',
      choices: [
        EventChoice(
          id: 'fair_share',
          label: 'Töreye göre paylaştır',
          description: 'Adil karar obayı yatıştırır.',
          resourceEffects: {ResourceType.morale: 3},
          faithEffects: {'tore': 4, 'kut': 2},
          xpReward: 12,
        ),
        EventChoice(
          id: 'favor_strong',
          label: 'Güçlü aileyi kayır',
          description: 'Kısa vadeli kazanç töreyi zedeler.',
          resourceEffects: {ResourceType.gold: 50, ResourceType.morale: -3},
          faithEffects: {'tore': -6, 'kut': -4},
          xpReward: 4,
        ),
        EventChoice(
          id: 'ask_council',
          label: 'Yaşlılar Meclisi’ne danış',
          description: 'Karar yavaşlar ama güven artar.',
          faithEffects: {'tore': 2, 'kut': 1},
          actionPointCost: 1,
          xpReward: 10,
        ),
      ],
    ),
    GameEvent(
      id: 'epic_fire_night',
      title: 'Ateş Başında Eski Destanlar',
      description:
          'Gençler gece ateşi başında eski destanları dinlemek istedi.',
      choices: [
        EventChoice(
          id: 'call_ozan',
          label: 'Ozanı çağır',
          description: 'Söz ve ezgi obanın hafızasını güçlendirir.',
          resourceEffects: {ResourceType.wood: -5, ResourceType.morale: 5},
          faithEffects: {'ancestorHonor': 3},
          xpReward: 10,
        ),
        EventChoice(
          id: 'rest_all',
          label: 'Herkes dinlensin',
          description: 'Oba sakin bir gece geçirir.',
          energyEffect: 5,
          xpReward: 6,
        ),
        EventChoice(
          id: 'train_youth',
          label: 'Gençleri eğitime gönder',
          description: 'Disiplin artar ama heves kırılır.',
          resourceEffects: {ResourceType.morale: -2},
          faithEffects: {'tore': 1},
          statEffects: {'warfare': 1},
          xpReward: 10,
        ),
      ],
    ),
    GameEvent(
      id: 'old_inscription',
      title: 'Eski Yazıttan Haber',
      description: 'Bir izci taş üstündeki eski damgaları gördüğünü söyler.',
      choices: [
        EventChoice(
          id: 'inspect',
          label: 'Yazıtı incele',
          description: 'Bilgelik artar, oba umutlanır.',
          resourceEffects: {ResourceType.morale: 2},
          statEffects: {'wisdom': 1},
        ),
        EventChoice(
          id: 'secure',
          label: 'Bölgeyi güvene al',
          description: 'Savaşçılar yola çıkar, itibar yükselir.',
          resourceEffects: {ResourceType.food: -6, ResourceType.reputation: 2},
          statEffects: {'courage': 1},
        ),
      ],
    ),
  ];
}

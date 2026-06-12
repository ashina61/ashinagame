import '../models/clan.dart';
import '../models/event_choice.dart';
import '../models/game_day.dart';
import '../models/player_profile.dart';
import '../models/quest.dart';
import '../models/resource.dart';
import '../models/season.dart';
import '../state/game_state.dart';

/// Action ids counted by quest goals.
class GameActions {
  const GameActions._();

  static const wood = 'wood';
  static const farm = 'farm';
  static const hunt = 'hunt';
  static const mercenary = 'mercenary';
  static const explore = 'explore';
  static const expedition = 'expedition';
  static const event = 'event';
  static const trade = 'trade';
}

class StarterGameData {
  const StarterGameData._();

  static GameState create() => GameState(
        profile: const PlayerProfile(
          name: 'Bumin',
          title: 'Genç Kağan Adayı',
          age: 24,
          courage: 6,
          wisdom: 5,
          leadership: 6,
          endurance: 5,
        ),
        clan: const Clan(
          name: 'Ashina Obası',
          motto: 'Gök altında birlik, bozkırda dirlik.',
        ),
        day: const GameDay(day: 1, season: Season.spring),
        resources: const {
          ResourceType.gold: 250,
          ResourceType.food: 100,
          ResourceType.wood: 60,
          ResourceType.leather: 25,
          ResourceType.horse: 8,
          ResourceType.reputation: 10,
          ResourceType.morale: 70,
          ResourceType.population: 32,
        },
        quests: [...dailyQuestsFor(1), ...storyQuests],
        currentEvent: events.first,
        eventIndex: 0,
        log: const ['Oba ateşi yakıldı. Yeni bir ömür başladı.'],
      );

  /// Rotating pool of daily quests; three are active per day.
  static const dailyQuestPool = <Quest>[
    Quest(
      id: 'd_hunt',
      title: 'Avcıları avlağa gönder',
      category: 'Günlük',
      description: 'Bozkırdaki izleri takip edip obaya av getir.',
      rewardText: 'Erzak +14, Deri +3',
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
      rewardText: 'Odun +10, Moral +1',
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
      rewardText: 'Erzak +16, İtibar +1',
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
      rewardText: 'Altın +20',
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
      rewardText: 'İtibar +2, Moral +1',
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
      rewardText: 'Moral +2',
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
    return [
      for (var i = 0; i < 3; i++) pool[(start + i) % pool.length],
    ];
  }

  /// One-shot quests that persist across days.
  static const storyQuests = <Quest>[
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

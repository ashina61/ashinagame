import '../models/clan.dart';
import '../models/event_choice.dart';
import '../models/game_day.dart';
import '../models/player_profile.dart';
import '../models/quest.dart';
import '../models/resource.dart';
import '../models/season.dart';
import '../state/game_state.dart';

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
          ResourceType.food: 100,
          ResourceType.wood: 60,
          ResourceType.leather: 25,
          ResourceType.horse: 8,
          ResourceType.reputation: 10,
          ResourceType.morale: 70,
          ResourceType.population: 32,
        },
        quests: quests,
        currentEvent: events.first,
        eventIndex: 0,
        log: const ['Oba ateşi yakıldı. Yeni bir ömür başladı.'],
      );

  static const quests = <Quest>[
    Quest(
      id: 'hunt_steppe',
      title: 'Avcıları avlağa gönder',
      category: 'Günlük',
      description: 'Avcılar bozkırdaki izleri takip ederek erzak getirebilir.',
      rewardText: 'Erzak +14, Deri +3, Moral +1',
      resourceRewards: {
        ResourceType.food: 14,
        ResourceType.leather: 3,
        ResourceType.morale: 1,
      },
    ),
    Quest(
      id: 'winter_food',
      title: 'Kış için erzak biriktir',
      category: 'Oba',
      description: 'Depodaki kurutulmuş et ve tahıl çuvalları düzenlenir.',
      rewardText: 'Erzak +20, İtibar +1',
      resourceRewards: {ResourceType.food: 20, ResourceType.reputation: 1},
    ),
    Quest(
      id: 'river_scout',
      title: 'Irmak kıyısında keşif yap',
      category: 'Hikâye',
      description: 'Irmak kıyısındaki geçitler ve kamp yerleri incelenir.',
      rewardText: 'Odun +8, Bilgelik +1',
      resourceRewards: {ResourceType.wood: 8},
      statRewards: {'wisdom': 1},
    ),
    Quest(
      id: 'council_talk',
      title: 'Yaşlılar Meclisi ile konuş',
      category: 'Oba',
      description: 'Obanın hafızası olan yaşlılardan öğüt alınır.',
      rewardText: 'Liderlik +1, Moral +2',
      resourceRewards: {ResourceType.morale: 2},
      statRewards: {'leadership': 1},
    ),
    Quest(
      id: 'horse_check',
      title: 'At sürüsünü kontrol et',
      category: 'Günlük',
      description: 'Sürüdeki atların sağlığı ve koşumları gözden geçirilir.',
      rewardText: 'At +1, Dayanıklılık +1',
      resourceRewards: {ResourceType.horse: 1},
      statRewards: {'endurance': 1},
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

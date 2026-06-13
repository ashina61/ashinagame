import '../models/kurultay.dart';
import '../models/resource.dart';

class KurultayDecisions {
  const KurultayDecisions._();

  /// Days between councils.
  static const period = 10;

  static const all = <KurultayDecision>[
    KurultayDecision(
      id: 'tax',
      title: 'Vergi Meselesi',
      description: 'Kış yaklaşıyor. Beyler vergi toplanmasını istiyor; halk '
          'ise zaten yorgun.',
      choices: [
        KurultayChoice(
          label: 'Vergiyi artır',
          description: 'Hazine dolar, beyler memnun; halk homurdanır.',
          peopleEffect: -12,
          councilEffect: 10,
          resourceEffects: {ResourceType.gold: 120},
        ),
        KurultayChoice(
          label: 'Vergiyi affet',
          description: 'Halk rahatlar; beyler kazançtan mahrum kalır.',
          peopleEffect: 12,
          councilEffect: -10,
        ),
        KurultayChoice(
          label: 'Orta yol',
          description: 'Ölçülü bir vergi; kimse çok sevinmez, çok küsmez.',
          peopleEffect: -2,
          councilEffect: 2,
          resourceEffects: {ResourceType.gold: 50},
        ),
      ],
    ),
    KurultayDecision(
      id: 'justice',
      title: 'Töre Davası',
      description: 'Bir bey, bir çobanın sürüsüne el koydu. Meclis kararını '
          'bekliyor.',
      choices: [
        KurultayChoice(
          label: 'Çobanı kolla',
          description: 'Adalet halkı kazanır; bey gücenir.',
          peopleEffect: 14,
          councilEffect: -8,
        ),
        KurultayChoice(
          label: 'Beyi kolla',
          description: 'Beyler hoşnut; halk töreye küser.',
          peopleEffect: -12,
          councilEffect: 12,
        ),
      ],
    ),
    KurultayDecision(
      id: 'feast',
      title: 'Şölen Çağrısı',
      description: 'Halk bir şölen ister; beyler kaynak israfından çekinir.',
      choices: [
        KurultayChoice(
          label: 'Büyük şölen ver',
          description: 'Halk coşar; erzak ve altın azalır, beyler söylenir.',
          peopleEffect: 14,
          councilEffect: -4,
          resourceEffects: {
            ResourceType.food: -20,
            ResourceType.gold: -40,
            ResourceType.morale: 8,
          },
        ),
        KurultayChoice(
          label: 'Sade tut',
          description: 'Kaynak korunur; halk biraz küser.',
          peopleEffect: -6,
          councilEffect: 4,
        ),
      ],
    ),
    KurultayDecision(
      id: 'war_council',
      title: 'Sefer Divanı',
      description: 'Beyler komşu bir obaya akın önerir; halk barış ister.',
      choices: [
        KurultayChoice(
          label: 'Akına onay ver',
          description: 'Beyler savaşa hazır; halk evlatları için korkar.',
          peopleEffect: -8,
          councilEffect: 12,
          resourceEffects: {ResourceType.reputation: 3},
        ),
        KurultayChoice(
          label: 'Barışı koru',
          description: 'Halk minnettar; savaşçı beyler hoşnutsuz.',
          peopleEffect: 10,
          councilEffect: -10,
        ),
      ],
    ),
    KurultayDecision(
      id: 'khan_tribute',
      title: 'Kağanlık Divanı: Haraç',
      description: 'Kağan olarak bağlı obalardan haraç istiyorsun.',
      khanate: true,
      choices: [
        KurultayChoice(
          label: 'Ağır haraç iste',
          description: 'Hazine şişer; obalar ve halk küser.',
          peopleEffect: -12,
          councilEffect: 8,
          resourceEffects: {ResourceType.gold: 200},
        ),
        KurultayChoice(
          label: 'Hafif tut',
          description: 'Obalar minnettar; hazine az kazanır.',
          peopleEffect: 10,
          councilEffect: -4,
          resourceEffects: {ResourceType.gold: 60},
        ),
      ],
    ),
  ];

  static KurultayDecision? byId(String id) {
    for (final d in all) {
      if (d.id == id) return d;
    }
    return null;
  }
}

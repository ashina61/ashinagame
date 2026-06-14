import '../../core/assets/game_assets.dart';

/// A special wares-of-the-day a passing caravan or the han offers now and then,
/// to make the market feel restocked and worth checking back.
class RareOffer {
  const RareOffer({
    required this.id,
    required this.title,
    required this.note,
    required this.icon,
  });

  final String id;
  final String title;
  final String note;
  final String icon;
}

class RareOffers {
  const RareOffers._();

  static const _pool = <RareOffer>[
    RareOffer(
      id: 'fine_horse',
      title: 'İyi At',
      note: 'Soylu bir at; sefer ve ticaret için biçilmez.',
      icon: GameAssets.iconItemHorse,
    ),
    RareOffer(
      id: 'rare_bow',
      title: 'Nadir Yay',
      note: 'Usta işi bir yay — eli değen pişman olmaz.',
      icon: GameAssets.iconItemBow,
    ),
    RareOffer(
      id: 'cheap_iron',
      title: 'Ucuz Demir',
      note: 'Kervan bol demir getirdi; fiyat düştü.',
      icon: GameAssets.iconIronOre,
    ),
    RareOffer(
      id: 'mercenary',
      title: 'Paralı Savaşçı',
      note: 'Tecrübeli bir kılıç, kiralık bekliyor.',
      icon: GameAssets.iconSwordsCrossed,
    ),
    RareOffer(
      id: 'healer',
      title: 'Şifacı Desteği',
      note: 'Yolcu bir otacı obanı geçici güçlendirir.',
      icon: GameAssets.iconItemPotion,
    ),
    RareOffer(
      id: 'wedding_gift',
      title: 'Düğün Armağanı',
      note: 'Evlilik için değerli, az bulunur bir hediye.',
      icon: GameAssets.iconTokenGold,
    ),
  ];

  /// The rare offer for [day], or null on ordinary days. One surfaces every
  /// four days, cycling through the pool.
  static RareOffer? forDay(int day) {
    if (day <= 0 || day % 4 != 0) return null;
    return _pool[(day ~/ 4 - 1) % _pool.length];
  }
}

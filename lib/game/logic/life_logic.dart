import 'dart:math';

import '../models/player_profile.dart';

class LifeLogic {
  const LifeLogic._();

  /// Real days that make up one in-game year (four ten-day seasons).
  static const daysPerYear = 40;

  /// In-game year number (1-based) for a given day.
  static int yearOf(int day) => (day - 1) ~/ daysPerYear + 1;

  /// True on the toy day that closes each forty-day year.
  static bool isYearBoundary(int day) => day > 1 && day % daysPerYear == 0;

  /// Honorific that grows with the leader's age, from a green youth chasing
  /// chores up to a grey-bearded khan.
  static String titleForAge(int age) {
    if (age < 16) return 'Çırak';
    if (age < 20) return 'Yiğit';
    if (age < 28) return 'Genç Bey';
    if (age < 36) return 'Boy Beyi';
    if (age < 46) return 'Kağan';
    if (age < 56) return 'Ulu Kağan';
    return 'Bilge Yaşlı Kağan';
  }

  /// Builds the next generation's leader from the late leader's legacy.
  static PlayerProfile heirOf(PlayerProfile parent, Random random) {
    const names = ['Tarkan', 'Alp', 'İlteriş', 'Kürşad', 'Yamtar', 'Böri'];
    final age = 18 + random.nextInt(5);
    // Children inherit a fraction of the parent's mastery, then grow anew.
    int inherit(int value) => 4 + (value ~/ 3) + random.nextInt(2);
    return PlayerProfile(
      name: names[random.nextInt(names.length)],
      title: titleForAge(age),
      age: age,
      portrait: parent.portrait,
      reputation: (parent.reputation * 0.6).round(),
      courage: inherit(parent.courage),
      wisdom: inherit(parent.wisdom),
      leadership: inherit(parent.leadership),
      endurance: inherit(parent.endurance),
      trade: inherit(parent.trade),
      craft: inherit(parent.craft),
      archery: inherit(parent.archery),
      warfare: inherit(parent.warfare),
    );
  }
}

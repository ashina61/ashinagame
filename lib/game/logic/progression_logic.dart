import '../models/player_profile.dart';

class ProgressionLogic {
  const ProgressionLogic._();

  static PlayerProfile applyStats(
    PlayerProfile profile,
    Map<String, int> effects,
  ) {
    return profile.copyWith(
      courage: profile.courage + (effects['courage'] ?? 0),
      wisdom: profile.wisdom + (effects['wisdom'] ?? 0),
      leadership: profile.leadership + (effects['leadership'] ?? 0),
      endurance: profile.endurance + (effects['endurance'] ?? 0),
    );
  }
}

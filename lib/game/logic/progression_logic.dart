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
      trade: profile.trade + (effects['trade'] ?? 0),
      craft: profile.craft + (effects['craft'] ?? 0),
      archery: profile.archery + (effects['archery'] ?? 0),
      warfare: profile.warfare + (effects['warfare'] ?? 0),
    );
  }

  static PlayerProfile addXp(PlayerProfile profile, int amount) {
    var level = profile.level;
    var xp = profile.xp + amount;
    var needed = profile.xpToNextLevel;
    var points = profile.skillPoints;
    while (xp >= needed) {
      xp -= needed;
      level++;
      points += 1;
      needed = (needed * 1.25).round() + 25;
    }
    return profile.copyWith(
      level: level,
      xp: xp,
      xpToNextLevel: needed,
      skillPoints: points,
    );
  }

  static PlayerProfile spendSkillPoint(PlayerProfile profile, String stat) {
    if (profile.skillPoints <= 0) return profile;
    final updated = applyStats(profile, {stat: 1});
    return updated.copyWith(skillPoints: updated.skillPoints - 1);
  }
}

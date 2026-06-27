import 'package:shared_preferences/shared_preferences.dart';

/// One row of the longest-reigns leaderboard.
class LeaderEntry {
  const LeaderEntry(this.name, this.years, this.difficulty);

  final String name;
  final int years;
  final int difficulty; // Difficulty.index

  String encode() => '$name\t$years\t$difficulty';

  static LeaderEntry? decode(String s) {
    final p = s.split('\t');
    if (p.length < 3) return null;
    return LeaderEntry(p[0], int.tryParse(p[1]) ?? 0, int.tryParse(p[2]) ?? 1);
  }
}

/// Persists records across runs: best reign/dynasty, totals, the death
/// gallery, achievements, and the longest-reigns leaderboard.
class StatsStore {
  StatsStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<StatsStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StatsStore(prefs);
  }

  static const _kBestReign = 'ashina_best_reign';
  static const _kBestDynasty = 'ashina_best_dynasty';
  static const _kTotalYears = 'ashina_total_years';
  static const _kGames = 'ashina_games';
  static const _kDeaths = 'ashina_deaths';
  static const _kAchievements = 'ashina_achievements';
  static const _kTutorial = 'ashina_tutorial_seen';
  static const _kLeaders = 'ashina_leaders';
  static const _maxLeaders = 10;

  int get bestReign => _prefs.getInt(_kBestReign) ?? 0;
  int get bestDynasty => _prefs.getInt(_kBestDynasty) ?? 0;
  int get totalYears => _prefs.getInt(_kTotalYears) ?? 0;
  int get gamesPlayed => _prefs.getInt(_kGames) ?? 0;

  /// Death-gallery keys seen, e.g. "halk_low", "ordu_high".
  Set<String> get deathsSeen => _prefs.getStringList(_kDeaths)?.toSet() ?? {};

  Set<String> get achievements =>
      _prefs.getStringList(_kAchievements)?.toSet() ?? {};

  bool get tutorialSeen => _prefs.getBool(_kTutorial) ?? false;

  Future<void> recordReign(int reignYears) async {
    if (reignYears > bestReign) {
      await _prefs.setInt(_kBestReign, reignYears);
    }
  }

  Future<void> recordDynasty(int dynastyYears) async {
    if (dynastyYears > bestDynasty) {
      await _prefs.setInt(_kBestDynasty, dynastyYears);
    }
    await _prefs.setInt(_kTotalYears, totalYears + dynastyYears);
    await _prefs.setInt(_kGames, gamesPlayed + 1);
  }

  Future<void> recordDeath(String key) async {
    final s = deathsSeen..add(key);
    await _prefs.setStringList(_kDeaths, s.toList());
  }

  /// Adds [id] and returns true if it was newly unlocked.
  Future<bool> unlockAchievement(String id) async {
    final s = achievements;
    if (s.contains(id)) return false;
    s.add(id);
    await _prefs.setStringList(_kAchievements, s.toList());
    return true;
  }

  Future<void> markTutorialSeen() async {
    await _prefs.setBool(_kTutorial, true);
  }

  List<LeaderEntry> get leaderboard {
    final raw = _prefs.getStringList(_kLeaders) ?? [];
    final list = raw.map(LeaderEntry.decode).whereType<LeaderEntry>().toList();
    list.sort((a, b) => b.years.compareTo(a.years));
    return list;
  }

  /// Records a finished reign; keeps the top [_maxLeaders] by years.
  Future<void> recordLeader(String name, int years, int difficulty) async {
    final list = leaderboard..add(LeaderEntry(name, years, difficulty));
    list.sort((a, b) => b.years.compareTo(a.years));
    final top = list.take(_maxLeaders).map((e) => e.encode()).toList();
    await _prefs.setStringList(_kLeaders, top);
  }

  Future<void> resetAll() async {
    for (final k in [
      _kBestReign,
      _kBestDynasty,
      _kTotalYears,
      _kGames,
      _kDeaths,
      _kAchievements,
      _kLeaders,
    ]) {
      await _prefs.remove(k);
    }
  }
}

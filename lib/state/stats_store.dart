import 'package:shared_preferences/shared_preferences.dart';

/// Persists records across runs.
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

  /// Longest single reign, in years.
  int get bestReign => _prefs.getInt(_kBestReign) ?? 0;

  /// Longest dynasty (sum of all reign years in one run), in years.
  int get bestDynasty => _prefs.getInt(_kBestDynasty) ?? 0;

  /// All-time years ruled across every run.
  int get totalYears => _prefs.getInt(_kTotalYears) ?? 0;

  /// Number of dynasties played to their end.
  int get gamesPlayed => _prefs.getInt(_kGames) ?? 0;

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
}

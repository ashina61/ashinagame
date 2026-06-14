import '../state/game_state.dart';

/// Gates features behind a deliberate early-game path so a new player has a
/// clear next step: work the camp, raise the tent, wed, arm up, ride out,
/// gather followers, then found an oba.
class UnlockLogic {
  const UnlockLogic._();

  static const tentLevelForMarriage = 3;
  static const levelForTentUpgrade = 2;

  static int _tentLevel(GameState s) => s.building('main_tent')?.level ?? 1;

  /// Camp jobs are always available — that is where you begin.
  static bool tentUpgrade(GameState s) =>
      s.profile.level >= levelForTentUpgrade;

  static bool marriage(GameState s) => _tentLevel(s) >= tentLevelForMarriage;

  /// Need a weapon and a shield in hand before riding to war.
  static bool expeditions(GameState s) =>
      s.equippedIn('weapon') != null && s.equippedIn('shield') != null;

  /// Gather followers only after your first campaign proves your name.
  static bool recruitment(GameState s) => s.completedExpeditions.isNotEmpty;

  static bool foundOba(GameState s) =>
      _tentLevel(s) >= 2 && s.profile.reputation >= 30;

  /// A short, ordered hint of the next thing to chase. Null once everything
  /// is open.
  static String? nextObjective(GameState s) {
    if (!tentUpgrade(s)) {
      return 'İşlerde çalış, seviye $levelForTentUpgrade ol — sonra çadırını '
          'geliştirebilirsin.';
    }
    if (!marriage(s)) {
      return 'Ana Çadırı $tentLevelForMarriage. seviyeye çıkar — sonra '
          'evlilik açılır.';
    }
    if (!expeditions(s)) {
      return 'Atölyede silah ve kalkan üretip kuşan — sonra sefere '
          'çıkabilirsin.';
    }
    if (!recruitment(s)) {
      return 'İlk seferini tamamla — sonra obana adam toplayabilirsin.';
    }
    if (!foundOba(s)) {
      return 'İtibarını 30’a çıkar — sonra kendi obanı kurabilirsin.';
    }
    return null;
  }
}

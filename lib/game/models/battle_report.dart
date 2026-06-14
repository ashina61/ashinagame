/// The aftermath of a single battle, so the player can see how each kind of
/// soldier fared rather than just win or lose.
class BattleReport {
  const BattleReport({
    required this.won,
    required this.castleName,
    required this.chance,
    required this.lost,
    required this.wounded,
  });

  final bool won;
  final String castleName;

  /// The win chance the battle was rolled against (0–100).
  final int chance;

  /// Soldiers slain and soldiers wounded, by unit id.
  final Map<String, int> lost;
  final Map<String, int> wounded;

  int get totalLost => lost.values.fold(0, (s, n) => s + n);
  int get totalWounded => wounded.values.fold(0, (s, n) => s + n);
}

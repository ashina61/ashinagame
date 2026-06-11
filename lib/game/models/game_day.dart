import 'season.dart';

class GameDay {
  const GameDay({required this.day, required this.season});

  final int day;
  final Season season;

  GameDay nextDay() {
    final nextDay = day + 1;
    final shouldChangeSeason = nextDay > 1 && (nextDay - 1) % 10 == 0;
    return GameDay(
      day: nextDay,
      season: shouldChangeSeason ? season.next : season,
    );
  }
}

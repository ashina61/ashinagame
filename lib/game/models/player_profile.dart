class PlayerProfile {
  const PlayerProfile({
    required this.name,
    required this.title,
    required this.age,
    required this.courage,
    required this.wisdom,
    required this.leadership,
    required this.endurance,
  });

  final String name;
  final String title;
  final int age;
  final int courage;
  final int wisdom;
  final int leadership;
  final int endurance;

  PlayerProfile copyWith({
    String? name,
    String? title,
    int? age,
    int? courage,
    int? wisdom,
    int? leadership,
    int? endurance,
  }) {
    return PlayerProfile(
      name: name ?? this.name,
      title: title ?? this.title,
      age: age ?? this.age,
      courage: courage ?? this.courage,
      wisdom: wisdom ?? this.wisdom,
      leadership: leadership ?? this.leadership,
      endurance: endurance ?? this.endurance,
    );
  }
}

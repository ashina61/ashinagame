class TribeRelation {
  const TribeRelation({
    required this.id,
    required this.name,
    required this.relation,
    required this.power,
    required this.population,
    required this.leader,
    this.tradeOpen = false,
    this.marriageTie = false,
  });

  final String id;
  final String name;
  final int relation;
  final int power;
  final int population;
  final String leader;
  final bool tradeOpen;
  final bool marriageTie;

  String get status => relation >= 70
      ? 'Müttefik'
      : relation >= 35
      ? 'Dost'
      : relation <= -50
      ? 'Düşman'
      : relation <= -10
      ? 'Gergin'
      : 'Tarafsız';
  int get warRisk => (50 - relation).clamp(0, 100).toInt();

  TribeRelation copyWith({int? relation, bool? tradeOpen, bool? marriageTie}) =>
      TribeRelation(
        id: id,
        name: name,
        relation: (relation ?? this.relation).clamp(-100, 100).toInt(),
        power: power,
        population: population,
        leader: leader,
        tradeOpen: tradeOpen ?? this.tradeOpen,
        marriageTie: marriageTie ?? this.marriageTie,
      );
}

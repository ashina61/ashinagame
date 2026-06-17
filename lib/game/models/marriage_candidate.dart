class MarriageCandidate {
  const MarriageCandidate({
    required this.id,
    required this.name,
    required this.age,
    required this.tribeName,
    required this.personality,
    required this.compatibility,
    required this.relation,
    required this.diplomaticValue,
    required this.bonusType,
    this.isAvailable = true,
    this.isMarriedToPlayer = false,
  });

  final String id;
  final String name;
  final int age;
  final String tribeName;
  final String personality;
  final int compatibility;
  final int relation;
  final int diplomaticValue;
  final String bonusType;
  final bool isAvailable;
  final bool isMarriedToPlayer;

  MarriageCandidate copyWith({
    int? relation,
    bool? isAvailable,
    bool? isMarriedToPlayer,
  }) => MarriageCandidate(
    id: id,
    name: name,
    age: age,
    tribeName: tribeName,
    personality: personality,
    compatibility: compatibility,
    relation: (relation ?? this.relation).clamp(0, 100).toInt(),
    diplomaticValue: diplomaticValue,
    bonusType: bonusType,
    isAvailable: isAvailable ?? this.isAvailable,
    isMarriedToPlayer: isMarriedToPlayer ?? this.isMarriedToPlayer,
  );
}

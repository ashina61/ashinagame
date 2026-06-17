class Horse {
  const Horse({
    required this.id,
    required this.name,
    required this.breed,
    this.rarity = 'Sıradan',
    this.level = 1,
    this.xp = 0,
    this.price = 40,
    this.speed = 4,
    this.endurance = 4,
    this.strength = 3,
    this.loyalty = 45,
    this.health = 85,
    this.hunger = 70,
    this.cleanliness = 60,
    this.fatigue = 10,
    this.mood = 55,
    this.training = 0,
    this.carryingCapacity = 20,
    this.combatBonus = 0,
    this.travelBonus = 1,
    this.isInjured = false,
    this.isSick = false,
    this.equippedSaddle = '',
    this.equippedHarness = '',
    this.equippedArmor = '',
    this.acquiredDay = 1,
  });

  final String id;
  final String name;
  final String breed;
  final String rarity;
  final int level;
  final int xp;
  final int price;
  final int speed;
  final int endurance;
  final int strength;
  final int loyalty;
  final int health;
  final int hunger;
  final int cleanliness;
  final int fatigue;
  final int mood;
  final int training;
  final int carryingCapacity;
  final int combatBonus;
  final int travelBonus;
  final bool isInjured;
  final bool isSick;
  final String equippedSaddle;
  final String equippedHarness;
  final String equippedArmor;
  final int acquiredDay;

  Horse copyWith({
    int? level,
    int? xp,
    int? loyalty,
    int? health,
    int? hunger,
    int? cleanliness,
    int? fatigue,
    int? mood,
    int? training,
    bool? isInjured,
    bool? isSick,
  }) => Horse(
    id: id,
    name: name,
    breed: breed,
    rarity: rarity,
    level: level ?? this.level,
    xp: xp ?? this.xp,
    price: price,
    speed: speed,
    endurance: endurance,
    strength: strength,
    loyalty: (loyalty ?? this.loyalty).clamp(0, 100).toInt(),
    health: (health ?? this.health).clamp(0, 100).toInt(),
    hunger: (hunger ?? this.hunger).clamp(0, 100).toInt(),
    cleanliness: (cleanliness ?? this.cleanliness).clamp(0, 100).toInt(),
    fatigue: (fatigue ?? this.fatigue).clamp(0, 100).toInt(),
    mood: (mood ?? this.mood).clamp(0, 100).toInt(),
    training: (training ?? this.training).clamp(0, 100).toInt(),
    carryingCapacity: carryingCapacity,
    combatBonus: combatBonus,
    travelBonus: travelBonus,
    isInjured: isInjured ?? this.isInjured,
    isSick: isSick ?? this.isSick,
    equippedSaddle: equippedSaddle,
    equippedHarness: equippedHarness,
    equippedArmor: equippedArmor,
    acquiredDay: acquiredDay,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'breed': breed,
    'rarity': rarity,
    'level': level,
    'xp': xp,
    'price': price,
    'speed': speed,
    'endurance': endurance,
    'strength': strength,
    'loyalty': loyalty,
    'health': health,
    'hunger': hunger,
    'cleanliness': cleanliness,
    'fatigue': fatigue,
    'mood': mood,
    'training': training,
    'carryingCapacity': carryingCapacity,
    'combatBonus': combatBonus,
    'travelBonus': travelBonus,
    'isInjured': isInjured,
    'isSick': isSick,
    'equippedSaddle': equippedSaddle,
    'equippedHarness': equippedHarness,
    'equippedArmor': equippedArmor,
    'acquiredDay': acquiredDay,
  };

  static Horse fromJson(Map<String, dynamic> json) => Horse(
    id: json['id'] as String,
    name: json['name'] as String,
    breed: json['breed'] as String,
    rarity: json['rarity'] as String? ?? 'Sıradan',
    level: json['level'] as int? ?? 1,
    xp: json['xp'] as int? ?? 0,
    price: json['price'] as int? ?? 40,
    speed: json['speed'] as int? ?? 4,
    endurance: json['endurance'] as int? ?? 4,
    strength: json['strength'] as int? ?? 3,
    loyalty: json['loyalty'] as int? ?? 45,
    health: json['health'] as int? ?? 85,
    hunger: json['hunger'] as int? ?? 70,
    cleanliness: json['cleanliness'] as int? ?? 60,
    fatigue: json['fatigue'] as int? ?? 10,
    mood: json['mood'] as int? ?? 55,
    training: json['training'] as int? ?? 0,
    carryingCapacity: json['carryingCapacity'] as int? ?? 20,
    combatBonus: json['combatBonus'] as int? ?? 0,
    travelBonus: json['travelBonus'] as int? ?? 1,
    isInjured: json['isInjured'] as bool? ?? false,
    isSick: json['isSick'] as bool? ?? false,
    equippedSaddle: json['equippedSaddle'] as String? ?? '',
    equippedHarness: json['equippedHarness'] as String? ?? '',
    equippedArmor: json['equippedArmor'] as String? ?? '',
    acquiredDay: json['acquiredDay'] as int? ?? 1,
  );
}

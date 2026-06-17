import '../models/resource.dart';
import '../models/season.dart';

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.hungerRestore,
    required this.thirstRestore,
    this.moraleEffect = 0,
    this.healthEffect = 0,
    this.spoilDays = 99,
    this.seasons = const [
      Season.spring,
      Season.summer,
      Season.autumn,
      Season.winter,
    ],
    this.tradeValue = 1,
    this.requiresCooking = false,
    this.preserveable = false,
  });

  final String id;
  final String name;
  final int hungerRestore;
  final int thirstRestore;
  final int moraleEffect;
  final int healthEffect;
  final int spoilDays;
  final List<Season> seasons;
  final int tradeValue;
  final bool requiresCooking;
  final bool preserveable;
}

class SurvivalActionDef {
  const SurvivalActionDef({
    required this.id,
    required this.category,
    required this.name,
    this.apCost = 1,
    this.fatigueCost = 6,
    this.hungerCost = 4,
    this.thirstCost = 4,
    this.cooldownDays = 0,
    this.successChance = 80,
    this.outputs = const {},
    this.foodInputs = const {},
    this.foodOutputs = const {},
    this.hint = '',
  });

  final String id;
  final String category;
  final String name;
  final int apCost;
  final int fatigueCost;
  final int hungerCost;
  final int thirstCost;
  final int cooldownDays;
  final int successChance;
  final Map<ResourceType, int> outputs;
  final Map<String, int> foodInputs;
  final Map<String, int> foodOutputs;
  final String hint;
}

class OpportunityDef {
  const OpportunityDef(this.id, this.category, this.title, this.detail);
  final String id;
  final String category;
  final String title;
  final String detail;
}

class BigGoalDef {
  const BigGoalDef(this.id, this.title, this.detail, this.minAge);
  final String id;
  final String title;
  final String detail;
  final int minAge;
}

class EquipmentDef {
  const EquipmentDef(this.id, this.name, this.type, this.tier, this.value);
  final String id;
  final String name;
  final String type;
  final String tier;
  final int value;
}

class ProjectRecipeDef {
  const ProjectRecipeDef(
    this.id,
    this.name,
    this.days,
    this.cost,
    this.foodCost,
    this.output,
  );
  final String id;
  final String name;
  final int days;
  final Map<ResourceType, int> cost;
  final Map<String, int> foodCost;
  final String output;
}

class QuestChainDef {
  const QuestChainDef(this.id, this.name, this.unlockAge, this.steps);
  final String id;
  final String name;
  final int unlockAge;
  final List<String> steps;
}

class SurvivalCatalog {
  const SurvivalCatalog._();

  static const foods = <FoodItem>[
    FoodItem(id: 'raw_meat', name: 'Çiğ Et', hungerRestore: 18, thirstRestore: -2, spoilDays: 3, requiresCooking: true, preserveable: true, tradeValue: 4),
    FoodItem(id: 'cooked_meat', name: 'Pişmiş Et', hungerRestore: 24, thirstRestore: 0, moraleEffect: 1, spoilDays: 4, tradeValue: 6),
    FoodItem(id: 'dried_meat', name: 'Kurutulmuş Et', hungerRestore: 20, thirstRestore: -3, spoilDays: 30, tradeValue: 8),
    FoodItem(id: 'fish', name: 'Balık', hungerRestore: 12, thirstRestore: 1, spoilDays: 2, requiresCooking: true, tradeValue: 3),
    FoodItem(id: 'cooked_fish', name: 'Pişmiş Balık', hungerRestore: 18, thirstRestore: 1, spoilDays: 3, tradeValue: 5),
    FoodItem(id: 'fruit', name: 'Meyve', hungerRestore: 7, thirstRestore: 6, moraleEffect: 1, spoilDays: 4, seasons: [Season.summer, Season.autumn], tradeValue: 2, preserveable: true),
    FoodItem(id: 'dried_fruit', name: 'Kuru Meyve', hungerRestore: 8, thirstRestore: 1, moraleEffect: 1, spoilDays: 25, tradeValue: 4),
    FoodItem(id: 'wild_herb', name: 'Yabani Ot', hungerRestore: 3, thirstRestore: 0, healthEffect: 2, spoilDays: 5, tradeValue: 2),
    FoodItem(id: 'root_vegetable', name: 'Kök Sebze', hungerRestore: 10, thirstRestore: 2, spoilDays: 8, seasons: [Season.spring, Season.autumn], tradeValue: 3),
    FoodItem(id: 'grain', name: 'Tahıl', hungerRestore: 12, thirstRestore: -1, spoilDays: 40, tradeValue: 5),
    FoodItem(id: 'milk', name: 'Süt', hungerRestore: 7, thirstRestore: 7, moraleEffect: 1, spoilDays: 2, tradeValue: 4),
    FoodItem(id: 'cheese', name: 'Peynir', hungerRestore: 14, thirstRestore: -1, moraleEffect: 1, spoilDays: 16, tradeValue: 7),
    FoodItem(id: 'honey', name: 'Bal', hungerRestore: 6, thirstRestore: 0, moraleEffect: 5, healthEffect: 1, spoilDays: 99, tradeValue: 10),
    FoodItem(id: 'salt', name: 'Tuz', hungerRestore: 0, thirstRestore: -2, spoilDays: 99, tradeValue: 8),
    FoodItem(id: 'water_skin', name: 'Su Tulumu', hungerRestore: 0, thirstRestore: 24, spoilDays: 6, tradeValue: 3),
    FoodItem(id: 'soup', name: 'Çorba', hungerRestore: 22, thirstRestore: 12, moraleEffect: 3, healthEffect: 2, spoilDays: 2, tradeValue: 7),
  ];

  static const actions = <SurvivalActionDef>[
    SurvivalActionDef(id: 'hunt', category: 'Hayatta Kalma', name: 'Avlan', fatigueCost: 12, hungerCost: 7, thirstCost: 6, cooldownDays: 1, outputs: {ResourceType.leather: 2}, foodOutputs: {'raw_meat': 2}, hint: 'Avlak bugün sessizse kapan kur.'),
    SurvivalActionDef(id: 'fish', category: 'Hayatta Kalma', name: 'Balık tut', fatigueCost: 8, hungerCost: 4, thirstCost: 3, foodOutputs: {'fish': 3}),
    SurvivalActionDef(id: 'gather_fruit', category: 'Hayatta Kalma', name: 'Meyve topla', fatigueCost: 5, hungerCost: 3, thirstCost: 2, foodOutputs: {'fruit': 3}),
    SurvivalActionDef(id: 'dig_roots', category: 'Hayatta Kalma', name: 'Kök/sebze ara', fatigueCost: 6, hungerCost: 4, thirstCost: 3, foodOutputs: {'root_vegetable': 2, 'wild_herb': 1}),
    SurvivalActionDef(id: 'find_water', category: 'Hayatta Kalma', name: 'Su bul', fatigueCost: 5, hungerCost: 2, thirstCost: 1, foodOutputs: {'water_skin': 2}),
    SurvivalActionDef(id: 'seek_salt', category: 'Hayatta Kalma', name: 'Tuz ara', fatigueCost: 7, hungerCost: 4, thirstCost: 5, cooldownDays: 2, foodOutputs: {'salt': 1}),
    SurvivalActionDef(id: 'cut_wood', category: 'Hayatta Kalma', name: 'Odun kes', fatigueCost: 11, hungerCost: 6, thirstCost: 5, outputs: {ResourceType.wood: 15}),
    SurvivalActionDef(id: 'repair_camp', category: 'Hayatta Kalma', name: 'Kampı onar', fatigueCost: 8, hungerCost: 4, thirstCost: 4, outputs: {ResourceType.morale: 2}),
    SurvivalActionDef(id: 'feed_fire', category: 'Hayatta Kalma', name: 'Ateşi besle', fatigueCost: 3, hungerCost: 2, thirstCost: 2, outputs: {ResourceType.wood: -4, ResourceType.morale: 3}),
    SurvivalActionDef(id: 'set_trap', category: 'Hayatta Kalma', name: 'Kapan kur', fatigueCost: 6, hungerCost: 3, thirstCost: 3, cooldownDays: 2, foodOutputs: {'raw_meat': 1}),
    SurvivalActionDef(id: 'cook_meat', category: 'Yiyecek Hazırlama', name: 'Et pişir', fatigueCost: 3, hungerCost: 1, thirstCost: 1, outputs: {ResourceType.wood: -2}, foodInputs: {'raw_meat': 1}, foodOutputs: {'cooked_meat': 1}),
    SurvivalActionDef(id: 'dry_meat', category: 'Yiyecek Hazırlama', name: 'Et kurut', fatigueCost: 5, hungerCost: 2, thirstCost: 2, cooldownDays: 1, outputs: {ResourceType.wood: -3}, foodInputs: {'raw_meat': 1, 'salt': 1}, foodOutputs: {'dried_meat': 1}),
    SurvivalActionDef(id: 'cook_fish', category: 'Yiyecek Hazırlama', name: 'Balık pişir', fatigueCost: 3, hungerCost: 1, thirstCost: 1, outputs: {ResourceType.wood: -1}, foodInputs: {'fish': 1}, foodOutputs: {'cooked_fish': 1}),
    SurvivalActionDef(id: 'make_soup', category: 'Yiyecek Hazırlama', name: 'Çorba yap', fatigueCost: 4, hungerCost: 1, thirstCost: 1, outputs: {ResourceType.wood: -2}, foodInputs: {'root_vegetable': 1, 'water_skin': 1}, foodOutputs: {'soup': 1}),
    SurvivalActionDef(id: 'archery_drill', category: 'Talim', name: 'Ok talimi', fatigueCost: 10, hungerCost: 4, thirstCost: 5, outputs: {ResourceType.reputation: 1}),
    SurvivalActionDef(id: 'riding_drill', category: 'Talim', name: 'At binme talimi', fatigueCost: 9, hungerCost: 4, thirstCost: 5, outputs: {ResourceType.horse: 0}),
    SurvivalActionDef(id: 'elder_lesson', category: 'Sosyal', name: 'Yaşlılardan öğüt al', fatigueCost: 2, hungerCost: 1, thirstCost: 1, outputs: {ResourceType.reputation: 1}),
    SurvivalActionDef(id: 'host_guest', category: 'Sosyal', name: 'Misafir ağırlama', fatigueCost: 4, hungerCost: 2, thirstCost: 2, outputs: {ResourceType.food: -4, ResourceType.morale: 4, ResourceType.reputation: 1}),
    SurvivalActionDef(id: 'track_game', category: 'Keşif', name: 'Avlak izi sür', fatigueCost: 8, hungerCost: 4, thirstCost: 4, cooldownDays: 1, outputs: {ResourceType.reputation: 1}),
    SurvivalActionDef(id: 'river_scout', category: 'Keşif', name: 'Irmak kıyısına in', fatigueCost: 7, hungerCost: 3, thirstCost: 3, foodOutputs: {'fish': 1, 'water_skin': 1}),
    SurvivalActionDef(id: 'search_inscription', category: 'Keşif', name: 'Eski yazıt ara', fatigueCost: 9, hungerCost: 4, thirstCost: 4, cooldownDays: 2, outputs: {ResourceType.reputation: 2}),
    SurvivalActionDef(id: 'market_road', category: 'Keşif', name: 'Pazar yoluna bak', fatigueCost: 7, hungerCost: 3, thirstCost: 4, outputs: {ResourceType.gold: 3}),
    SurvivalActionDef(id: 'make_bow', category: 'Üretim / Zanaat', name: 'Basit yay yap', fatigueCost: 8, hungerCost: 3, thirstCost: 3, outputs: {ResourceType.wood: -8, ResourceType.leather: -2, ResourceType.reputation: 1}),
    SurvivalActionDef(id: 'tan_leather', category: 'Üretim / Zanaat', name: 'Deri işle', fatigueCost: 7, hungerCost: 3, thirstCost: 3, outputs: {ResourceType.leather: 2}),
    SurvivalActionDef(id: 'tent_work', category: 'Oba Hazırlığı', name: 'Çadır dikimi', fatigueCost: 8, hungerCost: 4, thirstCost: 4, outputs: {ResourceType.wood: -4, ResourceType.morale: 2}),
    SurvivalActionDef(id: 'prepare_storage', category: 'Oba Hazırlığı', name: 'Depo alanı hazırla', fatigueCost: 7, hungerCost: 3, thirstCost: 3, outputs: {ResourceType.wood: -6, ResourceType.stone: -2, ResourceType.reputation: 1}),
  ];

  static const opportunities = <OpportunityDef>[
    OpportunityDef('fish_river', 'su', 'Irmak kıyısında balık bol.', 'Bugün balık tutmak daha güvenli.'),
    OpportunityDef('salt_merchant', 'ticaret', 'Pazar yolunda tuz taşıyan tüccar görüldü.', 'Tuz kışlık yiyeceği korur.'),
    OpportunityDef('stag_tracks', 'av', 'Avlakta büyük geyik izi var.', 'Avlan ödülü artabilir ama yorucudur.'),
    OpportunityDef('horse_cough', 'at', 'Atlardan biri hasta görünüyor.', 'Bakım gecikirse yolculuk zayıflar.'),
    OpportunityDef('cold_night', 'hava', 'Gece soğuk olacak, odun hazırla.', 'Sıcaklık düşerse sağlık etkilenir.'),
    OpportunityDef('old_inscription', 'keşif', 'Yaşlı kadın eski yazıttan söz etti.', 'Eski yazıt zinciri ilerleyebilir.'),
    OpportunityDef('youth_training', 'sosyal', 'Gençler ok talimi istiyor.', 'Talim moral ve itibar getirir.'),
    OpportunityDef('spoiling_meat', 'hastalık', 'Depodaki çiğ et bozulmak üzere.', 'Pişir veya kurut.'),
  ];

  static const bigGoals = <BigGoalDef>[
    BigGoalDef('survive_week', '7 gün hayatta kal', 'Açlık ve susuzluğu dengede tut.', 14),
    BigGoalDef('first_dried_meat', 'İlk kurutulmuş eti hazırla', 'Kış için uzun ömürlü yiyecek stokla.', 14),
    BigGoalDef('tent_lv2', 'Çadırını Lv2 yap', 'Sağlam Çadır erken kış güvenliği sağlar.', 14),
    BigGoalDef('first_horse', 'İlk atı satın al', 'Pazar yolu ve at pazarıyla ilgilen.', 16),
    BigGoalDef('tent_lv3', 'Çadırını Lv3 yap', 'Oba Çadırı oba kurma yolunda ana şarttır.', 16),
    BigGoalDef('found_oba', 'Oba kur', 'Yoldaş, itibar, toprak ve güçlü bağ şartlarını tamamla.', 18),
    BigGoalDef('first_campaign', 'İlk sefer hazırlığı', 'Ekipman, at ve yoldaş gücü topla.', 21),
  ];

  static const equipment = <EquipmentDef>[
    EquipmentDef('basic_knife', 'Basit bıçak', 'Silah', 'Kaba', 5),
    EquipmentDef('hunting_bow', 'Av yayı', 'Silah', 'Sıradan', 14),
    EquipmentDef('composite_bow', 'Kompozit yay', 'Silah', 'İyi', 32),
    EquipmentDef('iron_sword', 'Demir kılıç', 'Silah', 'İyi', 40),
    EquipmentDef('fur_cloak', 'Kürk pelerin', 'Zırh', 'Sıradan', 16),
    EquipmentDef('leather_armor', 'Deri zırh', 'Zırh', 'İyi', 28),
    EquipmentDef('iron_axe', 'Demir balta', 'Alet', 'İyi', 22),
    EquipmentDef('salting_bowl', 'Tuzlama kabı', 'Alet', 'Sıradan', 12),
    EquipmentDef('cooking_pot', 'Pişirme kazanı', 'Alet', 'İyi', 24),
  ];

  static const recipes = <ProjectRecipeDef>[
    ProjectRecipeDef('dried_meat', 'Kurutulmuş Et', 1, {ResourceType.wood: 3}, {'raw_meat': 1, 'salt': 1}, 'dried_meat'),
    ProjectRecipeDef('simple_bow', 'Basit Yay', 2, {ResourceType.wood: 12, ResourceType.leather: 3}, {}, 'hunting_bow'),
    ProjectRecipeDef('composite_bow', 'Kompozit Yay', 4, {ResourceType.wood: 25, ResourceType.leather: 10, ResourceType.iron: 2}, {}, 'composite_bow'),
    ProjectRecipeDef('leather_armor', 'Deri Zırh', 3, {ResourceType.leather: 18, ResourceType.iron: 2}, {}, 'leather_armor'),
    ProjectRecipeDef('horse_harness', 'At Koşumu', 2, {ResourceType.leather: 12, ResourceType.iron: 3}, {}, 'horse_harness'),
    ProjectRecipeDef('watchtower_project', 'Gözcü Kulesi', 5, {ResourceType.wood: 60, ResourceType.stone: 20}, {}, 'watchtower'),
  ];

  static const questChains = <QuestChainDef>[
    QuestChainDef('first_fire', 'İlk Ateş', 14, ['Odun topla', 'Ateşi besle', 'Geceyi sıcak geçir']),
    QuestChainDef('winter_prep', 'Kışa Hazırlık', 14, ['Kurutulmuş et hazırla', 'Odun stokla', 'Su tulumu doldur']),
    QuestChainDef('first_bow', 'İlk Yay', 14, ['Deri bul', 'Odun seç', 'Yay yap']),
    QuestChainDef('first_horse', 'İlk At', 16, ['Pazar yolunu aç', 'At seç', 'Atı besle']),
    QuestChainDef('old_inscription', 'Eski Yazıt', 16, ['Söylenti dinle', 'Yazıt ara', 'İşareti yorumla']),
    QuestChainDef('oba_road', 'Oba Yolu', 18, ['Çadırı Lv3 yap', 'Yoldaşları topla', 'Toprak seç']),
  ];
}

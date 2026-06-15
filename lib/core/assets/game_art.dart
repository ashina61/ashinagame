/// Target paths for the produced "game-feel" art, laid out by screen exactly as
/// the asset placement plan dictates. These point into `assets/images/game/...`
/// (see that folder's README for the full mapping). Until a file is dropped in,
/// [GameImage] falls back to the current art, so referencing a path here never
/// breaks the build or regresses the look.
class GameArt {
  const GameArt._();

  static const _base = 'assets/images/game';

  // ---- Scenes (full-screen backgrounds) --------------------------------
  static const campNightBg = '$_base/scenes/camp/camp_night_bg.png';
  static const tentInteriorBg = '$_base/scenes/tent/tent_interior_bg.png';
  static const marketBg = '$_base/scenes/market/market_bg.png';
  static const innBg = '$_base/scenes/market/inn_bg.png';
  static const journeyMapBg = '$_base/scenes/map/journey_map_bg.png';
  static const obaSceneBg = '$_base/scenes/oba/oba_scene_bg.png';
  static const conquestMapBg = '$_base/scenes/conquest/conquest_map_bg.png';
  static const marriageBg = '$_base/scenes/household/marriage_bg.png';
  static const workshopBg = '$_base/scenes/workshop/workshop_bg.png';

  // ---- Buildings -------------------------------------------------------
  static const playerTentLv1 = '$_base/buildings/tent/tent_lv1.png';
  static const playerTentLv2 = '$_base/buildings/tent/tent_lv2.png';
  static const playerTentLv3 = '$_base/buildings/tent/tent_lv3.png';
  static const obaMainTent = '$_base/buildings/oba/main_tent.png';
  static const obaStorage = '$_base/buildings/oba/storage.png';
  static const obaWorkshop = '$_base/buildings/oba/workshop.png';
  static const obaMarketTent = '$_base/buildings/oba/market_tent.png';
  static const obaShamanTent = '$_base/buildings/oba/shaman_tent.png';
  static const obaTrainingGround = '$_base/buildings/oba/training_ground.png';
  static const obaWatchtower = '$_base/buildings/oba/watchtower.png';
  static const obaRitualFire = '$_base/buildings/oba/ritual_fire.png';

  /// Player tent art for a given main-tent level (1..3), clamped.
  static String playerTent(int level) => switch (level) {
        <= 1 => playerTentLv1,
        2 => playerTentLv2,
        _ => playerTentLv3,
      };

  // ---- Camp objects (hotspots) -----------------------------------------
  static const campFire = '$_base/objects/camp/camp_fire.png';
  static const campChest = '$_base/objects/camp/chest.png';
  static const campHorseTie = '$_base/objects/camp/horse_tie.png';
  static const campWorkbench = '$_base/objects/camp/workbench.png';
  static const campJourneyMarker = '$_base/objects/camp/journey_marker.png';

  // ---- Portraits -------------------------------------------------------
  static const playerPortrait1 = '$_base/portraits/player/player_01.png';
  static const playerPortrait2 = '$_base/portraits/player/player_02.png';
  static const playerPortrait3 = '$_base/portraits/player/player_03.png';
  static const playerPortrait4 = '$_base/portraits/player/player_04.png';
  static const playerPortrait5 = '$_base/portraits/player/player_05.png';
  static const playerPortrait6 = '$_base/portraits/player/player_06.png';
  static const npcMerchant = '$_base/portraits/npc/merchant.png';
  static const npcKam = '$_base/portraits/npc/kam.png';
  static const npcAlisHatun = '$_base/portraits/npc/alis_hatun.png';
  static const npcBey = '$_base/portraits/npc/bey.png';

  /// The leader portraits offered at onboarding / on the character screen.
  static const playerPortraits = <String>[
    playerPortrait1,
    playerPortrait2,
    playerPortrait3,
    playerPortrait4,
    playerPortrait5,
    playerPortrait6,
  ];

  /// Portrait for a marriage candidate by id, falling back to a generic one.
  static String marriageCandidate(String id) =>
      '$_base/portraits/marriage/$id.png';

  // ---- UI: frames, panels, bars, cards ---------------------------------
  static const portraitFrameWolf = '$_base/ui/frames/portrait_frame_wolf.png';
  static const equipmentSlot = '$_base/ui/frames/equipment_slot.png';
  static const marriageCandidateFrame =
      '$_base/ui/frames/marriage_candidate_frame.png';
  static const tribeLeaderFrame = '$_base/ui/frames/tribe_leader_frame.png';

  static const resourceBarFrame = '$_base/ui/hud/resource_bar_frame.png';
  static const bottomNavFrame = '$_base/ui/hud/bottom_nav_frame.png';

  static const dayReportPanel = '$_base/ui/panels/day_report_panel.png';
  static const milestonePanel = '$_base/ui/panels/milestone_panel.png';
  static const characterInfoPanel = '$_base/ui/panels/character_info_panel.png';
  static const tooltipPanel = '$_base/ui/panels/tooltip_panel.png';
  static const confirmPanel = '$_base/ui/panels/confirm_panel.png';
  static const rewardPanel = '$_base/ui/panels/reward_panel.png';
  static const inventoryPanel = '$_base/ui/panels/inventory_panel.png';
  static const householdPanel = '$_base/ui/panels/household_panel.png';
  static const diplomacyPanel = '$_base/ui/panels/diplomacy_panel.png';
  static const battleResultPanel = '$_base/ui/panels/battle_result_panel.png';

  static const rumorBar = '$_base/ui/bars/rumor_bar.png';
  static const relationBar = '$_base/ui/bars/relation_bar.png';

  static const rareOfferCard = '$_base/ui/cards/rare_offer_card.png';

  static const infoIcon = '$_base/ui/icons/info.png';
  static const lockIcon = '$_base/ui/icons/lock.png';

  // ---- UI: map pins / markers ------------------------------------------
  static const mapRouteLine = '$_base/ui/map/route_line.png';
  static const mapExploreMarker = '$_base/ui/map/explore_marker.png';
  static const mapLockedRegion = '$_base/ui/map/locked_region.png';
  static const mapCastlePin = '$_base/ui/map/castle_pin.png';
  static const mapArmyPin = '$_base/ui/map/army_pin.png';
  static const mapRaidWarning = '$_base/ui/map/raid_warning.png';
  static const mapRebellionWarning = '$_base/ui/map/rebellion_warning.png';

  // ---- Symbols (Göktürk / tribes) --------------------------------------
  static const tamgaMain = '$_base/symbols/gokturk/tamga_main.png';
  static const runeBorder = '$_base/symbols/gokturk/rune_border.png';
  static const stoneInscription =
      '$_base/symbols/gokturk/stone_inscription.png';
  static const wolfEmblem = '$_base/symbols/gokturk/wolf_emblem.png';

  // ---- Items -----------------------------------------------------------
  static const itemSword = '$_base/items/weapons/sword.png';
  static const itemBow = '$_base/items/weapons/bow.png';
  static const itemLeatherArmor = '$_base/items/armor/leather_armor.png';
  static const itemShield = '$_base/items/armor/shield.png';
  static const itemHorseTack = '$_base/items/horse/horse_tack.png';
  static const itemMarriageGift = '$_base/items/gifts/marriage_gift.png';
}

# Ashina — Game Art Placement

This folder is the home for the produced "game-feel" art. The layout, paths and
naming are fixed so dropping a file in is **turnkey**: the path is already wired
in code (`lib/core/assets/game_art.dart`) and globbed in `pubspec.yaml`, and the
screens prefer this art with a graceful fallback to the art the game ships with
today (`GameImage` / `SceneBackground.fallback` / `OrnateScaffold.backgroundFallback`).

## Integrated batches

- **batch_01** (20): camp/market/journey/oba/workshop night backgrounds; camp
  objects (fire, chest, horse, workbench); tent levels 1–3; 3 player portraits.
  Held: 4 texted action cards, 1 emblem sheet.
- **batch_02** (19): HUD resource-bar frame; tent interior bg; conquest map bg;
  4 marriage-candidate portraits; +3 player portraits (now 6); npc/companion/kam
  portraits placed for a later NPC-screen pass. Held: 8-building oba sheet
  (needs cropping).
- **batch_03** (20): cropped sheets into individual assets — 8 skill emblems
  (wired to the character sheet), 6 framed resource icons (wired to the HUD via
  ResourceVisuals), 5 founding-milestone medallions (wired to the Çadırım
  track), 8 oba buildings (wired to the oba scene hotspots), 7 map pins, 8 tribe
  crests, 5 divider bars. Plus single UI panels/frames/bars and a ritual-fire
  object. The held oba/emblem sheets were consumed here.

- **batch_04** (20): upgraded the wired icon sets in place — cleaner blue-gold
  skill emblems and round resource icons (no code change). Cropped tamga/tribe
  crests (wolf/eagle/sun/horse). Placed singles: arched wolf portrait frame,
  Orhun stone stele, info/confirm/dialog panel skins, an isometric great-hall
  diorama and a sacred-fire object. Remaining UI sheets (button skins, colored
  map pins, route lines, card frames, badge sheets, HUD bars, roster panel)
  archived in _incoming/batch_04 for the SkinnedButton/SkinnedPanel + boy/map
  wiring pass.

## Batch workflow

Art arrives in small batches, not all at once. For each batch:

1. Drop the original files (any name) into `_incoming/batch_xx/` so the source
   is never lost. `_incoming/` is **not** bundled into the app (kept out of
   `pubspec.yaml`); it is just an archive.
2. Copy the chosen file to its target path below, renamed to ASCII
   `snake_case`.
3. If several candidates fit one slot, keep the best as the target and stash the
   rest in `_incoming/alternatives/` (or suffix `_alt_01`, `_alt_02`).
4. Add a `GameArt` constant if the slot is new, and wire it into its screen.

## Rules

- File names are English `snake_case` (no Turkish characters) — Flutter asset
  paths must be ASCII.
- **No baked-in text** in the art. All labels are drawn by Flutter.
- Prefer single, cropped PNGs over sheets/catalogs. If a source is a sheet, cut
  the piece out into its own PNG at the path below.
- Single objects that need to sit over a scene should be **transparent PNGs**
  (alpha), not black-background squares.
- Until a file exists the screen shows the current art — never a broken image.
  Look for `TODO(asset)` markers in code for the spots awaiting art.

## How to add art

1. Save the PNG at the exact path in the tables below.
2. Run `flutter pub get` (only needed if you add a *new* folder not yet globbed).
3. That's it — the screen picks it up. No Dart change needed, except player
   portraits (see note).

> **Player portraits note:** the leader portrait list currently uses the
> shipping character art. When `portraits/player/player_01..03.png` are added,
> swap `GameAssets.playerPortraits` to `GameArt.playerPortraits` (one line; see
> the `TODO(asset)` in `game_assets.dart`).

---

## 1. Ana Kamp / Home  (wired)

| Slot | Path | Status |
|---|---|---|
| Camp night background | `scenes/camp/camp_night_bg.png` | wired (fallback: shipping camp) |
| Player tent Lv1 | `buildings/tent/tent_lv1.png` | path ready |
| Camp fire object | `objects/camp/camp_fire.png` | path ready |
| Chest object | `objects/camp/chest.png` | path ready |
| Horse tie object | `objects/camp/horse_tie.png` | path ready |
| Workbench object | `objects/camp/workbench.png` | path ready |
| Journey marker | `objects/camp/journey_marker.png` | path ready |
| Resource bar frame | `ui/hud/resource_bar_frame.png` | path ready |
| Day report panel | `ui/panels/day_report_panel.png` | path ready |

## 2. Çadırım / Tent  (wired)

| Slot | Path | Status |
|---|---|---|
| Tent interior background | `scenes/tent/tent_interior_bg.png` | wired (fallback: shipping camp) |
| Tent Lv1 / Lv2 / Lv3 | `buildings/tent/tent_lv1.png` … `tent_lv3.png` | path ready (`GameArt.playerTent(level)`) |
| Milestone markers | `ui/milestones/` | path ready |
| Milestone panel | `ui/panels/milestone_panel.png` | path ready |

## 3. Karakter

| Slot | Path | Status |
|---|---|---|
| Player portraits 1–3 | `portraits/player/player_01.png` … `player_03.png` | path ready (swap list — see note) |
| Portrait frame (wolf) | `ui/frames/portrait_frame_wolf.png` | path ready |
| Skill icons | `ui/icons/skills/` | path ready |
| Equipment slot frame | `ui/frames/equipment_slot.png` | path ready |
| Character info panel | `ui/panels/character_info_panel.png` | path ready |

## 4. Pazar / Han  (wired)

| Slot | Path | Status |
|---|---|---|
| Market background | `scenes/market/market_bg.png` | wired (fallback: shipping night) |
| Inn background | `scenes/market/inn_bg.png` | path ready |
| Merchant portrait | `portraits/npc/merchant.png` | wired (fallback: shipping merchant) |
| Rare offer card | `ui/cards/rare_offer_card.png` | path ready |
| Resource icons | `ui/icons/resources/` | path ready |
| Rumor bar | `ui/bars/rumor_bar.png` | path ready |

## 5. Yolculuk / Keşif

| Slot | Path |
|---|---|
| Journey map background | `scenes/map/journey_map_bg.png` |
| Map pins | `ui/map/pins/` |
| Route line | `ui/map/route_line.png` |
| Explore marker | `ui/map/explore_marker.png` |
| Locked region | `ui/map/locked_region.png` |

## 6. Oba / Settlement

| Slot | Path |
|---|---|
| Oba scene background | `scenes/oba/oba_scene_bg.png` |
| Main tent / storage / workshop | `buildings/oba/main_tent.png`, `storage.png`, `workshop.png` |
| Market tent / shaman tent | `buildings/oba/market_tent.png`, `shaman_tent.png` |
| Training ground / watchtower / ritual fire | `buildings/oba/training_ground.png`, `watchtower.png`, `ritual_fire.png` |

## 7. Boylar / Diplomasi

| Slot | Path |
|---|---|
| Tribe crests | `symbols/tribes/` |
| Tribe leader frame | `ui/frames/tribe_leader_frame.png` |
| Diplomacy panel | `ui/panels/diplomacy_panel.png` |
| Relation bar | `ui/bars/relation_bar.png` |

## 8. Seferler / Fetih

| Slot | Path |
|---|---|
| Conquest map background | `scenes/conquest/conquest_map_bg.png` |
| Castle pin | `ui/map/castle_pin.png` |
| Army pin | `ui/map/army_pin.png` |
| Raid warning | `ui/map/raid_warning.png` |
| Rebellion warning | `ui/map/rebellion_warning.png` |
| Battle result panel | `ui/panels/battle_result_panel.png` |

## 9. Envanter / Kuşam

| Slot | Path |
|---|---|
| Inventory panel | `ui/panels/inventory_panel.png` |
| Sword / bow | `items/weapons/sword.png`, `bow.png` |
| Leather armor / shield | `items/armor/leather_armor.png`, `shield.png` |
| Horse tack | `items/horse/horse_tack.png` |
| Resource icons | `ui/icons/resources/` |

## 10. Evlilik / Hane

| Slot | Path |
|---|---|
| Marriage background | `scenes/household/marriage_bg.png` |
| Candidate frame | `ui/frames/marriage_candidate_frame.png` |
| Candidate portraits | `portraits/marriage/` |
| Marriage gift | `items/gifts/marriage_gift.png` |
| Household panel | `ui/panels/household_panel.png` |

## 11. Ortak UI / Skin

| Slot | Path |
|---|---|
| Bottom nav frame | `ui/hud/bottom_nav_frame.png` |
| Tooltip panel | `ui/panels/tooltip_panel.png` |
| Confirm panel | `ui/panels/confirm_panel.png` |
| Reward panel | `ui/panels/reward_panel.png` |
| Info / lock icon | `ui/icons/info.png`, `ui/icons/lock.png` |

## 12. Göktürk / Orhun symbols

| Slot | Path |
|---|---|
| Tamga (main) | `symbols/gokturk/tamga_main.png` |
| Rune border | `symbols/gokturk/rune_border.png` |
| Stone inscription | `symbols/gokturk/stone_inscription.png` |
| Wolf emblem | `symbols/gokturk/wolf_emblem.png` |

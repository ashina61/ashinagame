import '../models/resource.dart';
import '../state/game_state.dart';

/// The five life-stages of the game. The world opens up one stage at a time so
/// the player always begins small — a lone traveller with a single tent — and
/// only later commands an oba, courts the boys and rides on great campaigns.
enum GamePhase {
  tent(1, 'Kendi Çadırın'),
  name(2, 'İsim Yapma'),
  oba(3, 'Oba Kurma'),
  politics(4, 'Boy ve Siyaset'),
  campaign(5, 'Seferler ve Kağanlık');

  const GamePhase(this.number, this.label);

  final int number;
  final String label;
}

/// A single condition on the road to founding an oba, with a human label and
/// live progress so the UI can show it as locked / in-progress / done.
class FoundingRequirement {
  const FoundingRequirement({
    required this.label,
    required this.met,
    required this.progress,
  });

  final String label;
  final bool met;

  /// Short "current / target" readout, e.g. "İtibar 32/50".
  final String progress;
}

/// The single source of truth for the phase system: which stage the player is
/// in, what is unlocked, and what still stands between them and their own oba.
class PhaseLogic {
  const PhaseLogic._();

  // Founding thresholds — the gateway from a lone tent to a living oba.
  static const reputationToFound = 50;
  static const followersToFound = 3;
  static const tentLevelToFound = 2;

  static int tentLevel(GameState s) => s.building('main_tent')?.level ?? 1;

  /// A married leader, or a follower bound body and soul (relation ≥ 90),
  /// counts as the "strong bond" an oba is built around.
  static bool hasStrongBond(GameState s) =>
      s.household.isMarried || s.npcRelations.values.any((v) => v >= 90);

  static GamePhase phaseOf(GameState s) {
    if (!s.obaFounded) {
      final knownName = s.profile.reputation >= 25 && s.swornFollowers >= 1;
      return knownName ? GamePhase.name : GamePhase.tent;
    }
    if (s.completedExpeditions.isNotEmpty || s.conqueredRegions.isNotEmpty) {
      return GamePhase.campaign;
    }
    if (s.resource(ResourceType.population) >= 60 || s.vassalObas > 0) {
      return GamePhase.politics;
    }
    return GamePhase.oba;
  }

  // ---- Screen gating ----------------------------------------------------

  /// Personal-camp screens are open from the very first day.
  static bool tentScene(GameState s) => true;
  static bool nearbyPeople(GameState s) => true;
  static bool journey(GameState s) => true;

  /// Oba, boy and campaign scenes only open once the oba is founded.
  static bool obaScene(GameState s) => s.obaFounded;
  static bool boyScene(GameState s) => s.obaFounded;
  static bool campaignScene(GameState s) => s.obaFounded;

  // ---- Founding requirements -------------------------------------------

  static List<FoundingRequirement> foundingRequirements(GameState s) => [
        FoundingRequirement(
          label: 'İtibarın $reputationToFound’a ulaşsın',
          met: s.profile.reputation >= reputationToFound,
          progress: 'İtibar ${s.profile.reputation}/$reputationToFound',
        ),
        FoundingRequirement(
          label: '$followersToFound güvenilir yandaş bul',
          met: s.swornFollowers >= followersToFound,
          progress: 'Yandaş ${s.swornFollowers}/$followersToFound',
        ),
        FoundingRequirement(
          label: 'Ana çadırını $tentLevelToFound. seviyeye çıkar',
          met: tentLevel(s) >= tentLevelToFound,
          progress: 'Çadır Lv.${tentLevel(s)}/$tentLevelToFound',
        ),
        FoundingRequirement(
          label: 'Evlilik ya da güçlü bir güven bağı kur',
          met: hasStrongBond(s),
          progress: s.household.isMarried ? 'Kuruldu' : 'Henüz yok',
        ),
        FoundingRequirement(
          label: 'Uygun bir toprak keşfet',
          met: s.landScouted,
          progress: s.landScouted ? 'Bulundu' : 'Aranıyor',
        ),
      ];

  static bool canFoundOba(GameState s) =>
      foundingRequirements(s).every((r) => r.met);

  static int requirementsMet(GameState s) =>
      foundingRequirements(s).where((r) => r.met).length;

  /// One short, ordered hint of the next milestone to chase. Null once an oba
  /// has been founded and the early road is behind you.
  static String? nextObjective(GameState s) {
    if (s.obaFounded) return null;
    for (final r in foundingRequirements(s)) {
      if (!r.met) return '${r.label} (${r.progress}).';
    }
    return 'Her şey hazır — Çadırım ekranından kendi obanı kur!';
  }
}

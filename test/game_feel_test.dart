import 'package:ashinagame/core/assets/game_assets.dart';
import 'package:ashinagame/game/data/game_info.dart';
import 'package:ashinagame/game/data/starter_game_data.dart';
import 'package:ashinagame/game/logic/phase_logic.dart';
import 'package:ashinagame/game/models/household.dart';
import 'package:ashinagame/game/models/resource.dart';
import 'package:ashinagame/game/state/game_controller.dart';
import 'package:ashinagame/game/state/game_serializer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('reputation is a single source of truth', () {
    test('a reputation gain reads identically on the profile and the HUD', () {
      final c = GameController.starter();
      // Starts in lockstep.
      expect(
        c.state.profile.reputation,
        c.state.resource(ResourceType.reputation),
      );

      // Earn reputation through the resource channel (as events/quests do).
      c.performCampAction(
          GameActions.wood,
          'Yardım',
          const {
            ResourceType.reputation: 30,
          },
          xp: 0);

      expect(c.state.resource(ResourceType.reputation), 35);
      expect(c.state.profile.reputation, 35); // mirrored
      expect(c.state.reputation, 35); // canonical getter
    });

    test('resource-earned reputation lifts the oba founding gate', () {
      final fresh = StarterGameData.create();
      final base = fresh.copyWith(
        landScouted: true,
        household: const Household(spouseName: 'Aybüke'),
        npcRelations: const {
          'kaya_atabek': 80,
          'alis_hatun': 85,
          'bori_bey': 90,
        },
        buildings: [
          for (final b in fresh.buildings)
            if (b.id == 'main_tent') b.copyWith(level: 3) else b,
        ],
      );
      final c = GameController(base);
      // Everything is ready except renown, which sits at the starting 5.
      expect(PhaseLogic.canFoundOba(c.state), isFalse);

      // Earn renown purely as a resource — the old bug ignored this.
      c.performCampAction(
          GameActions.wood,
          'Ad yap',
          const {
            ResourceType.reputation: 50,
          },
          xp: 0);

      expect(c.state.reputation, greaterThanOrEqualTo(50));
      expect(
        c.state.profile.reputation,
        c.state.resource(ResourceType.reputation),
      );
      expect(PhaseLogic.canFoundOba(c.state), isTrue);
    });

    test('reputation stays clamped to 0..100', () {
      final c = GameController.starter();
      c.performCampAction(
          GameActions.wood,
          'Büyük şöhret',
          const {
            ResourceType.reputation: 500,
          },
          xp: 0);
      expect(c.state.reputation, 100);
      expect(c.state.profile.reputation, 100);
    });
  });

  group('marriage age consistency', () {
    GameController controllerAtAge(int age) {
      final fresh = StarterGameData.create();
      return GameController(
        fresh.copyWith(
          profile: fresh.profile.copyWith(age: age),
          resources: {
            ...fresh.resources,
            ResourceType.gold: 600,
            ResourceType.reputation: 25,
          },
          marriageCandidates: [
            for (final cand in fresh.marriageCandidates)
              cand.id == 'aybuke' ? cand.copyWith(relation: 70) : cand,
          ],
        ),
      );
    }

    test('a fourteen-year-old cannot wed even when all else is ready', () {
      final young = controllerAtAge(14);
      expect(young.marriageBlockReason('aybuke'), isNotNull);
      expect(young.proposeMarriage('aybuke'), isFalse);
      expect(young.state.household.isMarried, isFalse);
    });

    test('coming of age opens the proposal', () {
      final grown = controllerAtAge(16);
      expect(grown.marriageBlockReason('aybuke'), isNull);
      expect(grown.proposeMarriage('aybuke'), isTrue);
      expect(grown.state.household.isMarried, isTrue);
    });
  });

  group('portrait identity', () {
    test('a chosen portrait is kept and survives a save/load', () {
      final c = GameController.starter();
      final pick = GameAssets.playerPortraits[2];
      c.setPortrait(pick);
      expect(c.state.profile.portrait, pick);

      final decoded = GameSerializer.decode(GameSerializer.encode(c.state));
      expect(decoded, isNotNull);
      expect(decoded!.profile.portrait, pick);
    });

    test('onboarding records the chosen portrait', () {
      final c = GameController(StarterGameData.create());
      final pick = GameAssets.playerPortraits[1];
      c.completeOnboarding(obaName: '', leaderName: 'Alp', portrait: pick);
      expect(c.state.onboarded, isTrue);
      expect(c.state.profile.portrait, pick);
    });
  });

  group('explanatory content exists for the help systems', () {
    test('every resource has a tooltip', () {
      for (final type in ResourceType.values) {
        expect(GameInfo.resource(type), isNotNull, reason: type.name);
      }
    });

    test('every spendable skill has a detail panel', () {
      for (final stat in const [
        'courage',
        'wisdom',
        'leadership',
        'endurance',
        'trade',
        'craft',
        'archery',
        'warfare',
      ]) {
        expect(GameInfo.skill(stat), isNotNull, reason: stat);
      }
    });

    test('every screen the "i" button serves has help content', () {
      for (final id in HelpId.values) {
        final topic = GameInfo.help(id);
        expect(topic, isNotNull, reason: id.name);
        expect(topic!.steps, isNotEmpty, reason: id.name);
      }
    });
  });
}

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/ornate.dart';
import '../../game/logic/phase_logic.dart';
import '../../game/state/game_scope.dart';
import '../npc/npc_screen.dart';

/// "Yakınlar" — the early-game relationship scene. Before there is any oba,
/// the player wins trust one person at a time. It reuses the named-figure
/// roster but frames it around gathering sworn followers, and tops it with a
/// followers panel instead of the council-flavoured oba intro.
class NearbyPeopleScreen extends StatelessWidget {
  const NearbyPeopleScreen({this.showBack = true, super.key});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return NpcScreen(
      title: 'Yakınlar',
      intro:
          'Güven kazan, ismini yükselt. Konuştukça bağ kurar, bağ '
          'derinleştikçe yandaş toplarsın. 75 güvene ulaşan biri sana yoldaş '
          'olur.',
      topPanel: const _FollowersPanel(),
      showBack: showBack,
    );
  }
}

class _FollowersPanel extends StatelessWidget {
  const _FollowersPanel();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final bond = state.npcRelations.values.fold<int>(0, (s, v) => s + v);
    final followers = state.swornFollowers;
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Yandaşların: $followers / ${PhaseLogic.followersToFound}',
                  style: AppTextStyles.bodyStrong,
                ),
              ),
              Text(
                'Yandaşlık $bond / 1000',
                style: AppTextStyles.meta.copyWith(color: AppColors.goldBright),
              ),
            ],
          ),
          const SizedBox(height: 6),
          StatBar(fraction: bond / 1000, height: 8),
        ],
      ),
    );
  }
}

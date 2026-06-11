import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../game/state/game_scope.dart';

class AshinaTopBar extends StatelessWidget {
  const AshinaTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.amber,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${state.clan.name} • Gün ${state.day.day} • '
                '${state.day.season.label}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.parchment,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ashina_button.dart';
import '../../core/widgets/ashina_card.dart';
import '../../core/widgets/ashina_scaffold.dart';
import '../../core/widgets/asset_placeholder.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';
import '../inventory/inventory_screen.dart';
import '../settings/settings_screen.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final profile = state.profile;

    return AshinaScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const AssetPlaceholder(
            assetPath: GameAssets.characterLeader,
            label: 'Karakter Görsel Slotu',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 12),
          Text(profile.name, style: AppTextStyles.title),
          Text(
            '${profile.title} • ${profile.age} yaş • ${state.clan.name}',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 12),
          AshinaCard(
            child: Column(
              children: [
                _StatRow('İtibar', state.resource(ResourceType.reputation)),
                _StatRow('Cesaret', profile.courage),
                _StatRow('Bilgelik', profile.wisdom),
                _StatRow('Liderlik', profile.leadership),
                _StatRow('Dayanıklılık', profile.endurance),
              ],
            ),
          ),
          AshinaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Oba Sözü', style: AppTextStyles.section),
                Text(state.clan.motto, style: AppTextStyles.body),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AshinaButton(
                label: 'Envanter',
                icon: Icons.inventory_2_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const InventoryScreen(),
                  ),
                ),
              ),
              AshinaButton(
                label: 'Ayarlar',
                icon: Icons.settings_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.parchment,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.amber,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

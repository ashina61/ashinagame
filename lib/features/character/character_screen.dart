import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/asset_placeholder.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';
import '../inventory/inventory_screen.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final profile = state.profile;

    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            const OrnateHeader(title: 'Karakter', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  OrnatePanel(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 170,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              GameAssets.characterLeader,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const AssetPlaceholder(
                                assetPath: GameAssets.characterLeader,
                                label: 'Karakter',
                                height: 170,
                                icon: Icons.person_rounded,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${profile.name}, ${profile.age}',
                                style: AppTextStyles.title,
                              ),
                              Text(profile.title, style: AppTextStyles.meta),
                              const SizedBox(height: 6),
                              Text(
                                state.clan.name,
                                style: AppTextStyles.bodyStrong
                                    .copyWith(color: AppColors.gold),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Gün ${state.day.day} • '
                                '${state.day.season.label}',
                                style: AppTextStyles.body,
                              ),
                              Text(
                                'İtibar '
                                '${state.resource(ResourceType.reputation)}',
                                style: AppTextStyles.value,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SectionPlaque('BECERİLER'),
                  OrnatePanel(
                    child: Column(
                      children: [
                        _SkillBar('Cesaret', profile.courage),
                        _SkillBar('Bilgelik', profile.wisdom),
                        _SkillBar('Liderlik', profile.leadership),
                        _SkillBar('Dayanıklılık', profile.endurance),
                      ],
                    ),
                  ),
                  const SectionPlaque('OBA SÖZÜ'),
                  OrnatePanel(
                    backgroundAsset: GameAssets.bgSceneCampNight,
                    child: Text(
                      state.clan.motto,
                      style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: DarkButton(
                      label: 'ENVANTER',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const InventoryScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  const _SkillBar(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.bodyStrong),
          ),
          Expanded(child: StatBar(fraction: value / 12, height: 11)),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: AppTextStyles.value,
            ),
          ),
        ],
      ),
    );
  }
}

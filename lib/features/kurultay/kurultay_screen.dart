import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/kurultay_decisions.dart';
import '../../game/models/kurultay.dart';
import '../../game/models/npc.dart';
import '../../game/state/game_scope.dart';

class KurultayScreen extends StatelessWidget {
  const KurultayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final decision = KurultayDecisions.byId(state.currentKurultay ?? '');

    return OrnateScaffold(
      backgroundAsset: GameAssets.bgSceneCampNight,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
          children: [
            Center(
              child: Text(
                'KURULTAY',
                style: AppTextStyles.display.copyWith(fontSize: 34),
              ),
            ),
            const SizedBox(height: 4),
            OrnatePanel(
              child: Column(
                children: [
                  _ApprovalBar('Halk', state.peopleApproval),
                  const SizedBox(height: 6),
                  _ApprovalBar('Kurultay', state.councilApproval),
                ],
              ),
            ),
            if (decision == null)
              const OrnatePanel(
                child: Text('Gündem boş.', style: AppTextStyles.body),
              )
            else ...[
              const SectionPlaque('GÜNDEM'),
              OrnatePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      decision.title,
                      style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(decision.description, style: AppTextStyles.body),
                  ],
                ),
              ),
              for (var i = 0; i < decision.choices.length; i++)
                _ChoicePanel(index: i, choice: decision.choices[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _ApprovalBar extends StatelessWidget {
  const _ApprovalBar(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final color = value >= 60
        ? AppColors.success
        : value >= 30
        ? AppColors.gold
        : AppColors.danger;
    return Row(
      children: [
        SizedBox(width: 76, child: Text(label, style: AppTextStyles.body)),
        Expanded(
          child: StatBar(fraction: value / 100, height: 11, fill: color),
        ),
        const SizedBox(width: 8),
        Text('$value/100', style: AppTextStyles.meta),
      ],
    );
  }
}

class _ChoicePanel extends StatelessWidget {
  const _ChoicePanel({required this.index, required this.choice});

  final int index;
  final KurultayChoice choice;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    String effect(int v, String who) =>
        v == 0 ? '' : '$who ${v > 0 ? '+$v' : '$v'}';
    final parts = [
      effect(choice.peopleEffect, 'Halk'),
      effect(choice.councilEffect, 'Kurultay'),
      if (choice.resourceEffects.isNotEmpty)
        Formatters.resourceDelta(choice.resourceEffects),
      for (final e in choice.npcEffects.entries)
        effect(e.value, NpcCharacters.byId(e.key)?.name ?? e.key),
    ].where((s) => s.isNotEmpty).join(' • ');

    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(choice.label, style: AppTextStyles.bodyStrong),
          Text(choice.description, style: AppTextStyles.meta),
          const SizedBox(height: 4),
          Text(
            parts,
            style: AppTextStyles.meta.copyWith(color: AppColors.goldBright),
          ),
          const SizedBox(height: 8),
          GoldButton(
            label: 'KARAR VER',
            height: 38,
            onPressed: () {
              controller.resolveKurultay(index);
              AudioService.instance.playSfx('reward');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Karar verildi: ${choice.label}')),
              );
            },
          ),
        ],
      ),
    );
  }
}

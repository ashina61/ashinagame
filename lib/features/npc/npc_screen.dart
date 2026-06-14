import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/npc.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';
import '../conquest/battle_report_dialog.dart';

/// Roster of named figures the leader can speak with. Each carries a living
/// relationship that shifts as conversations play out.
class NpcScreen extends StatelessWidget {
  const NpcScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final folk = [
      for (final npc in NpcCharacters.all)
        if (!npc.khanate || state.isKhan || state.khanateStanding > 0) npc,
    ];

    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            const OrnateHeader(title: 'Oba Halkı', showBack: true),
            const OrnatePanel(
              child: Text(
                'Beylerin, ocağın ve komşuların gönlünü konuşarak kazan. Her '
                'sohbet bir aksiyon harcar; sözlerin halkı ve meclisi de etkiler.',
                style: AppTextStyles.body,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  for (final npc in folk) _NpcCard(npc: npc),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NpcCard extends StatelessWidget {
  const _NpcCard({required this.npc});

  final Npc npc;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final relation = state.relationWith(npc.id);
    final hasAp = state.dailyActionPoints > 0;

    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: _portraitFrame(),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  npc.portrait,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.leatherDeep),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(npc.name,
                        style: AppTextStyles.bodyStrong.copyWith(fontSize: 16)),
                    Text(npc.role,
                        style: AppTextStyles.meta
                            .copyWith(color: AppColors.goldBright)),
                    const SizedBox(height: 4),
                    Text(npc.blurb, style: AppTextStyles.meta),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('İlişki: ${_relationLabel(relation)} ($relation)',
                        style: AppTextStyles.meta),
                    const SizedBox(height: 4),
                    StatBar(
                      fraction: relation / 100,
                      fill: _relationColor(relation),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 110,
                child: GoldButton(
                  label: 'KONUŞ',
                  height: 34,
                  onPressed:
                      hasAp ? () => _openDialogue(context, controller) : null,
                ),
              ),
            ],
          ),
          if (!hasAp)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Aksiyon kalmadı; günü bitir.',
                  style: AppTextStyles.meta.copyWith(color: AppColors.danger)),
            ),
        ],
      ),
    );
  }

  void _openDialogue(BuildContext context, GameController controller) {
    final dialogue = controller.dialogueFor(npc.id);
    if (dialogue == null) return;
    AudioService.instance.playSfx('tap');
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DialogueSheet(npc: npc, dialogue: dialogue),
    );
  }
}

class _DialogueSheet extends StatelessWidget {
  const _DialogueSheet({required this.npc, required this.dialogue});

  final Npc npc;
  final Dialogue dialogue;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: OrnatePanel(
          margin: EdgeInsets.zero,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${npc.name} • ${npc.role}',
                    style: AppTextStyles.bodyStrong
                        .copyWith(color: AppColors.goldBright)),
                const SizedBox(height: 8),
                Text('“${dialogue.line}”', style: AppTextStyles.body),
                const SizedBox(height: 12),
                for (final choice in dialogue.choices) ...[
                  DarkButton(
                    label: choice.label,
                    onPressed: () {
                      final ok = controller.talkTo(npc.id, choice);
                      Navigator.of(context).maybePop();
                      final report = controller.lastBattle;
                      if (ok && choice.raidPower > 0 && report != null) {
                        AudioService.instance
                            .playSfx(report.won ? 'victory' : 'defeat');
                        showDialog<void>(
                          context: context,
                          builder: (_) => BattleReportDialog(report),
                        );
                        return;
                      }
                      AudioService.instance.playSfx(ok ? 'coin' : 'denied');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? choice.reply
                              : 'Konuşmak için aksiyon gerekiyor.'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _portraitFrame() => BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
      image: const DecorationImage(
        image: AssetImage(GameAssets.uiFramePortraitRound),
        fit: BoxFit.cover,
      ),
    );

String _relationLabel(int v) {
  if (v >= 75) return 'Sadık dost';
  if (v >= 60) return 'Dost';
  if (v >= 40) return 'Ölçülü';
  if (v >= 25) return 'Soğuk';
  return 'Düşman';
}

Color _relationColor(int v) {
  if (v >= 60) return AppColors.success;
  if (v >= 40) return AppColors.gold;
  if (v >= 25) return AppColors.amber;
  return AppColors.danger;
}

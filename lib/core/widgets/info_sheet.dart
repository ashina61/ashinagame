import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../game/data/game_info.dart';
import '../../game/models/resource.dart';
import '../utils/resource_visuals.dart';
import 'ornate.dart';

/// Slides up a compact, parchment-style game panel. Shared shell for the
/// resource tooltips, skill detail panels and the living "i" help button — so
/// every explanation reads like the same in-world note, not an app dialog.
Future<void> _showPanel(
  BuildContext context, {
  required String title,
  String? icon,
  String? value,
  required List<Widget> children,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: OrnatePanel(
          margin: EdgeInsets.zero,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Image.asset(
                        icon,
                        width: 32,
                        height: 32,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.title.copyWith(
                          fontSize: 19,
                          color: AppColors.goldBright,
                        ),
                      ),
                    ),
                    if (value != null)
                      Text(
                        value,
                        style: AppTextStyles.value.copyWith(fontSize: 18),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                ...children,
                const SizedBox(height: 12),
                GoldButton(
                  label: 'ANLADIM',
                  height: 42,
                  onPressed: () => Navigator.of(sheetContext).maybePop(),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// One labelled paragraph block inside an info panel.
class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.label, required this.text, this.color});

  final String label;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.meta.copyWith(
              color: color ?? AppColors.gold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(text, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

/// Tooltip-style panel for a single resource: what it is, how to earn it and
/// the bonus/passive note. Shown when a resource icon is tapped.
Future<void> showResourceInfoSheet(
  BuildContext context,
  ResourceType type,
  int amount,
) {
  final info = GameInfo.resource(type);
  return _showPanel(
    context,
    title: type.label,
    icon: ResourceVisuals.icon(type),
    value: '$amount',
    children: info == null
        ? [
            const Text('Bu kaynak hakkında bilgi yok.',
                style: AppTextStyles.body)
          ]
        : [
            _InfoBlock(label: 'NEDİR', text: info.summary),
            _InfoBlock(label: 'NASIL KAZANILIR', text: info.howToEarn),
            _InfoBlock(
              label: 'İPUCU',
              text: info.note,
              color: AppColors.goldBright,
            ),
          ],
  );
}

/// Detail panel for a single skill: its current level, what it affects and what
/// growing it unlocks.
Future<void> showSkillInfoSheet(BuildContext context, String stat, int value) {
  final info = GameInfo.skill(stat);
  return _showPanel(
    context,
    title: info?.name ?? stat,
    value: '$value',
    children: info == null
        ? [
            const Text('Bu beceri hakkında bilgi yok.',
                style: AppTextStyles.body)
          ]
        : [
            _InfoBlock(label: 'NEYİ ETKİLER', text: info.affects),
            _InfoBlock(
              label: 'YÜKSELİNCE',
              text: info.unlocks,
              color: AppColors.goldBright,
            ),
          ],
  );
}

/// The living "i" button content: a context-sensitive note on what this screen
/// is for, the smart next steps and a tip.
Future<void> showHelpSheet(BuildContext context, HelpId id) {
  final topic = GameInfo.help(id);
  return _showPanel(
    context,
    title: topic?.title ?? 'Yardım',
    icon: null,
    children: topic == null
        ? [const Text('Bu ekran için yardım yok.', style: AppTextStyles.body)]
        : [
            Text(topic.purpose, style: AppTextStyles.body),
            const SizedBox(height: 10),
            Text(
              'NE YAPMALIYIM?',
              style: AppTextStyles.meta.copyWith(
                color: AppColors.gold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            for (final step in topic.steps)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.goldBright,
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(step, style: AppTextStyles.body)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.goldDim.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: AppColors.goldBright,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      topic.tip,
                      style: AppTextStyles.body.copyWith(color: AppColors.sand),
                    ),
                  ),
                ],
              ),
            ),
          ],
  );
}

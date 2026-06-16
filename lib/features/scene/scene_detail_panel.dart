import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/ornate.dart';

/// One action offered inside a scene detail panel.
class SceneAction {
  const SceneAction({
    required this.label,
    required this.onTap,
    this.subtitle,
    this.enabled = true,
    this.primary = false,
  });

  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool enabled;
  final bool primary;
}

/// Slides up a compact, game-styled panel describing a tapped hotspot and the
/// moves available there — keeping detail off the scene itself, as the brief
/// asks (short info, actions in a drawer, not a wall of text).
Future<void> showSceneDetail(
  BuildContext context, {
  required String title,
  String? icon,
  String description = '',
  List<SceneAction> actions = const [],
  Widget? extra,
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
                        width: 34,
                        height: 34,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.title.copyWith(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(description, style: AppTextStyles.body),
                ],
                if (extra != null) ...[const SizedBox(height: 10), extra],
                const SizedBox(height: 12),
                for (final action in actions) ...[
                  if (action.primary)
                    GoldButton(
                      label: action.label,
                      height: 46,
                      onPressed: action.enabled
                          ? () {
                              Navigator.of(sheetContext).maybePop();
                              action.onTap();
                            }
                          : null,
                    )
                  else
                    _DetailActionRow(
                      action: action,
                      sheetContext: sheetContext,
                    ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _DetailActionRow extends StatelessWidget {
  const _DetailActionRow({required this.action, required this.sheetContext});

  final SceneAction action;
  final BuildContext sheetContext;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: action.enabled ? 1 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DarkButton(
            label: action.label,
            onPressed: action.enabled
                ? () {
                    Navigator.of(sheetContext).maybePop();
                    action.onTap();
                  }
                : null,
          ),
          if (action.subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 4),
              child: Text(
                action.subtitle!,
                style: AppTextStyles.meta.copyWith(
                  color: AppColors.goldBright,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

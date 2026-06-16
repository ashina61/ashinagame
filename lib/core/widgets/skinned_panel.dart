import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../assets/game_art.dart';

/// Reusable game-skin panel that paints a produced UI asset behind Flutter
/// content, while keeping the old leather panel as a safe fallback.
class SkinnedPanel extends StatelessWidget {
  const SkinnedPanel({
    required this.child,
    this.backgroundAsset = GameArt.dialogPanel,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.fromLTRB(12, 0, 12, 10),
    this.minSkinnedSize = const Size(120, 88),
    super.key,
  });

  final Widget child;
  final String? backgroundAsset;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Size minSkinnedSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded =
            constraints.hasBoundedWidth && constraints.hasBoundedHeight;
        final tooSmall = bounded &&
            (constraints.maxWidth < minSkinnedSize.width ||
                constraints.maxHeight < minSkinnedSize.height);
        return Container(
          width: double.infinity,
          margin: margin,
          decoration: _fallbackDecoration(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                if (!tooSmall && backgroundAsset != null)
                  Positioned.fill(
                    child: Image.asset(
                      backgroundAsset!,
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        );
      },
    );
  }

  static BoxDecoration _fallbackDecoration() => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xE61A140C), Color(0xF20F0B07)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      );
}

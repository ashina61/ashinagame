import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Full-bleed scene art with a soft dark scrim plus a cinematic vignette so the
/// edges fall into shadow and the eye is drawn to the middle of the scene. This
/// is the bottom layer of every scene.
class SceneBackground extends StatelessWidget {
  const SceneBackground({
    required this.asset,
    this.fallback,
    this.scrim = true,
    super.key,
  });

  final String asset;

  /// Shown when [asset] is not in the bundle yet (the art the game ships with
  /// today), so pointing [asset] at produced art never regresses the look.
  final String? fallback;
  final bool scrim;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          asset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback == null
              ? const ColoredBox(color: AppColors.leatherDeep)
              : Image.asset(
                  fallback!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.leatherDeep),
                ),
        ),
        if (scrim) ...[
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99000000),
                  Color(0x33000000),
                  Color(0xCC000000),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          // Vignette: corners sink into the dark, framing the scene like a shot.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.1),
                radius: 1.1,
                colors: [
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0x88000000)
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

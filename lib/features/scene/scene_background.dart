import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Full-bleed scene art with a soft dark scrim so HUD text and hotspots stay
/// readable over the painting. This is the bottom layer of every scene.
class SceneBackground extends StatelessWidget {
  const SceneBackground({
    required this.asset,
    this.scrim = true,
    super.key,
  });

  final String asset;
  final bool scrim;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          asset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const ColoredBox(color: AppColors.leatherDeep),
        ),
        if (scrim)
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
      ],
    );
  }
}

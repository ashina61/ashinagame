import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../assets/game_art.dart';

/// Stacks the wolf portrait frame over the supplied portrait so missing frame
/// art never hides the character image.
class WolfPortraitFrame extends StatelessWidget {
  const WolfPortraitFrame({
    required this.asset,
    this.width = 120,
    this.height = 170,
    this.onTap,
    this.selected = false,
    super.key,
  });

  final String asset;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final portrait = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          GameArt.playerPortrait1,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(
            color: AppColors.leatherDeep,
            child: Icon(Icons.person, color: AppColors.gold),
          ),
        ),
      ),
    );
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(padding: const EdgeInsets.all(10), child: portrait),
            Image.asset(
              GameArt.portraitFrameWolfRound,
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => Image.asset(
                GameArt.portraitFrameWolf,
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) => DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.goldBright
                          : AppColors.goldDim,
                      width: selected ? 2.4 : 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

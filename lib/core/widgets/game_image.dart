import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Shows [primary] art if it has been added to the bundle, otherwise quietly
/// falls back to [fallback] (the art the game ships with today), and finally to
/// a neutral placeholder. This is what makes the asset pipeline turnkey: code
/// can point at the new `assets/images/game/...` paths now, and the moment a
/// real file is dropped in it appears — with no regression in the meantime.
class GameImage extends StatelessWidget {
  const GameImage({
    required this.primary,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.placeholderIcon,
    super.key,
  });

  /// The desired (produced) art path, e.g. a [GameArt] constant.
  final String primary;

  /// The currently-shipping art to use until [primary] exists.
  final String fallback;

  final BoxFit fit;
  final double? width;
  final double? height;
  final Color? color;
  final BlendMode? colorBlendMode;
  final IconData? placeholderIcon;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      primary,
      fit: fit,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: (context, _, __) => Image.asset(
        fallback,
        fit: fit,
        width: width,
        height: height,
        color: color,
        colorBlendMode: colorBlendMode,
        errorBuilder: (context, ___, ____) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: AppColors.leatherDeep,
        alignment: Alignment.center,
        child: Icon(
          placeholderIcon ?? Icons.image_not_supported_outlined,
          color: AppColors.goldDim,
        ),
      );
}

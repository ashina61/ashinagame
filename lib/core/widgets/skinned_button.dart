import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../assets/game_assets.dart';
import '../audio/audio_service.dart';
import '../settings/app_settings.dart';

enum SkinnedButtonVariant { primary, secondary, danger }

/// Asset-backed button with a safe decorated fallback and the same tap sfx /
/// haptic behaviour as the existing ornate buttons.
class SkinnedButton extends StatelessWidget {
  const SkinnedButton({
    required this.label,
    required this.onPressed,
    this.variant = SkinnedButtonVariant.primary,
    this.height = 44,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final SkinnedButtonVariant variant;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final asset = switch (variant) {
      SkinnedButtonVariant.primary => GameAssets.uiButtonGold,
      SkinnedButtonVariant.secondary => GameAssets.uiButtonBronzeSlim,
      SkinnedButtonVariant.danger => GameAssets.uiButtonBronze,
    };
    return Opacity(
      opacity: enabled ? 1 : 0.48,
      child: GestureDetector(
        onTap: enabled
            ? () {
                AudioService.instance.playSfx('tap');
                AppSettings.instance.tap();
                onPressed!();
              }
            : null,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: variant == SkinnedButtonVariant.primary
                ? AppColors.goldDim
                : AppColors.leatherDeep,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
            image: DecorationImage(
              image: AssetImage(asset),
              fit: BoxFit.fill,
              onError: (_, __) {},
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label.toUpperCase(),
            style: (variant == SkinnedButtonVariant.primary
                    ? AppTextStyles.buttonGold
                    : AppTextStyles.buttonDark)
                .copyWith(color: enabled ? null : AppColors.stone),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

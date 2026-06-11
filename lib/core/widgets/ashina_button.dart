import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AshinaButton extends StatelessWidget {
  const AshinaButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.arrow_forward_rounded, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.deepNight,
        disabledBackgroundColor: AppColors.stone.withValues(alpha: 0.25),
        disabledForegroundColor: AppColors.stone,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

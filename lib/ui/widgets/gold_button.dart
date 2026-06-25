import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Primary ornate gold action button.
class GoldButton extends StatelessWidget {
  const GoldButton(
      {super.key, required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [AppColors.goldBright, AppColors.gold],
            ),
            boxShadow: [
              BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 16),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: const Color(0xFF2B1D08)),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTextStyles.buttonGold),
            ],
          ),
        ),
      ),
    );
  }
}

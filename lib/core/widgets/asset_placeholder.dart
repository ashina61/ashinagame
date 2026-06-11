import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

class AssetPlaceholder extends StatelessWidget {
  const AssetPlaceholder({
    required this.assetPath,
    required this.label,
    this.height = 132,
    this.icon = Icons.landscape_outlined,
    super.key,
  });

  final String assetPath;
  final String label;
  final double height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Image.asset(
        assetPath,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.night, AppColors.earth, AppColors.leather],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -22,
                bottom: -22,
                child: Icon(icon, size: 112, color: Colors.white12),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: AppColors.amber, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.parchment,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Asset slotu hazır',
                      style: TextStyle(color: AppColors.sand, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

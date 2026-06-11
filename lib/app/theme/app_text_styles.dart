import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const title = TextStyle(
    color: AppColors.parchment,
    fontSize: 24,
    fontWeight: FontWeight.w800,
  );

  static const section = TextStyle(
    color: AppColors.parchment,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const body = TextStyle(
    color: AppColors.sand,
    fontSize: 14,
    height: 1.35,
  );

  static const meta = TextStyle(
    color: AppColors.stone,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}

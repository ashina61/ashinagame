import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get darkSteppeTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.amber,
      brightness: Brightness.dark,
      surface: AppColors.deepNight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.ink,
      fontFamily: 'Alegreya',
      textTheme: const TextTheme(bodyMedium: TextStyle(color: AppColors.sand)),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.card,
        contentTextStyle: TextStyle(color: AppColors.parchment),
      ),
    );
  }
}

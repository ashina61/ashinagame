import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const _cinzelBold = [FontVariation('wght', 700)];
  static const _cinzelBlack = [FontVariation('wght', 800)];
  static const _alegreyaBold = [FontVariation('wght', 700)];

  /// Big ornate logo / screen titles.
  static const display = TextStyle(
    fontFamily: 'Cinzel',
    fontVariations: _cinzelBlack,
    color: AppColors.goldBright,
    fontSize: 40,
    letterSpacing: 8,
  );

  static const header = TextStyle(
    fontFamily: 'Cinzel',
    fontVariations: _cinzelBold,
    color: AppColors.parchment,
    fontSize: 19,
    letterSpacing: 2.5,
  );

  static const section = TextStyle(
    fontFamily: 'Cinzel',
    fontVariations: _cinzelBold,
    color: AppColors.gold,
    fontSize: 14,
    letterSpacing: 1.6,
  );

  static const buttonGold = TextStyle(
    fontFamily: 'Cinzel',
    fontVariations: _cinzelBlack,
    color: Color(0xFF2B1D08),
    fontSize: 15,
    letterSpacing: 1.8,
  );

  static const buttonDark = TextStyle(
    fontFamily: 'Cinzel',
    fontVariations: _cinzelBold,
    color: AppColors.parchment,
    fontSize: 13,
    letterSpacing: 1.4,
  );

  static const speaker = TextStyle(
    fontFamily: 'Cinzel',
    fontVariations: _cinzelBold,
    color: AppColors.goldBright,
    fontSize: 18,
    letterSpacing: 1.2,
  );

  static const prompt = TextStyle(
    fontFamily: 'Alegreya',
    color: AppColors.parchment,
    fontSize: 19,
    height: 1.4,
  );

  static const body = TextStyle(
    fontFamily: 'Alegreya',
    color: AppColors.sand,
    fontSize: 15,
    height: 1.35,
  );

  static const bodyStrong = TextStyle(
    fontFamily: 'Alegreya',
    fontVariations: _alegreyaBold,
    color: AppColors.parchment,
    fontSize: 15,
    height: 1.3,
  );

  static const value = TextStyle(
    fontFamily: 'Alegreya',
    fontVariations: _alegreyaBold,
    color: AppColors.goldBright,
    fontSize: 14,
  );

  static const meta = TextStyle(
    fontFamily: 'Alegreya',
    color: AppColors.stone,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );
}

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';

/// Shared chrome for the game's "beat" screens — game over, succession and the
/// expedition result. They all framed the same way (a wolf banner, a big
/// title, a subtitle, a stack of panels and a row of action buttons) on three
/// near-identical scaffolds; this folds that shell into one place so each
/// screen only describes what is unique to it.
class ResultScaffold extends StatelessWidget {
  const ResultScaffold({
    required this.title,
    required this.body,
    required this.actions,
    this.subtitle,
    this.backgroundAsset = GameAssets.bgScreenNight,
    this.titleColor,
    this.headerTitle,
    this.bannerWidth = 110,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> body;
  final List<Widget> actions;
  final String backgroundAsset;
  final Color? titleColor;

  /// When set, an [OrnateHeader] with a back button is shown (a pushed screen,
  /// like the expedition result). When null the screen is a full modal beat
  /// (game over, succession) with no header.
  final String? headerTitle;
  final double bannerWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrnateScaffold(
        backgroundAsset: backgroundAsset,
        child: Column(
          children: [
            if (headerTitle != null)
              OrnateHeader(title: headerTitle!, showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        GameAssets.uiBannerWolfTall,
                        width: bannerWidth,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.display
                          .copyWith(fontSize: 34, color: titleColor),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.section.copyWith(letterSpacing: 3),
                      ),
                    const SizedBox(height: 14),
                    ...body,
                  ],
                ),
              ),
            ),
            for (final action in actions)
              Padding(
                padding: const EdgeInsets.fromLTRB(44, 0, 44, 10),
                child: action,
              ),
          ],
        ),
      ),
    );
  }
}

/// A label on the left, a gold value on the right — the summary line every
/// result screen used to redeclare privately.
class ResultRow extends StatelessWidget {
  const ResultRow(this.label, this.value, {this.valueColor, super.key});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(
            value,
            style: AppTextStyles.value
                .copyWith(color: valueColor ?? AppColors.goldBright),
          ),
        ],
      ),
    );
  }
}

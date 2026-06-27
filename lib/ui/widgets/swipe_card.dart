import 'package:flutter/material.dart';

import '../../data/portraits.dart';
import '../../l10n.dart';
import '../../models/kagan_card.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// The dilemma card face. [progress] runs -1 (full left) .. 1 (full right);
/// the parent handles translation/rotation, this widget handles the look and
/// the active-choice highlight.
class SwipeCard extends StatelessWidget {
  const SwipeCard({super.key, required this.card, required this.progress});

  final KaganCard card;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final toRight = progress > 0;
    final mag = progress.abs().clamp(0.0, 1.0);
    final showChoice = mag > 0.04;
    final accent = AppColors.gold.withValues(alpha: 0.4 + 0.6 * mag);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.leather, AppColors.leatherDeep],
        ),
        border:
            Border.all(color: showChoice ? accent : AppColors.bronze, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            child: Column(
              children: [
                _Portrait(speaker: card.speaker),
                const SizedBox(height: 12),
                Text(card.speaker,
                    style: AppTextStyles.speaker, textAlign: TextAlign.center),
                Text(cardTitle(card),
                    style: AppTextStyles.meta, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Container(
                    height: 1, color: AppColors.bronze.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        '«${cardPrompt(card)}»',
                        style: AppTextStyles.prompt,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ChoiceHints(
                    left: cardLabel(card, false),
                    right: cardLabel(card, true),
                    progress: progress),
              ],
            ),
          ),
          // Active choice label, fading in toward the swiped side.
          if (showChoice)
            Positioned(
              top: 14,
              left: toRight ? null : 14,
              right: toRight ? 14 : null,
              child: Opacity(
                opacity: mag,
                child: Transform.rotate(
                  angle: toRight ? -0.18 : 0.18,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.goldBright, width: 2),
                      color: AppColors.ink.withValues(alpha: 0.7),
                    ),
                    child: Text(cardLabel(card, toRight).toUpperCase(),
                        style: AppTextStyles.section),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Portrait extends StatelessWidget {
  const _Portrait({required this.speaker});

  final String speaker;

  static const double _size = 92;

  @override
  Widget build(BuildContext context) {
    final asset = portraitFor(speaker);
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [AppColors.bronze, AppColors.leatherDeep],
        ),
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: asset == null
          ? _monogram()
          : Image.asset(
              asset,
              width: _size,
              height: _size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => _monogram(),
            ),
    );
  }

  Widget _monogram() {
    final initial = speaker.isNotEmpty ? speaker.substring(0, 1) : '?';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontFamily: 'Cinzel',
          fontVariations: [FontVariation('wght', 800)],
          color: AppColors.goldBright,
          fontSize: 40,
        ),
      ),
    );
  }
}

class _ChoiceHints extends StatelessWidget {
  const _ChoiceHints(
      {required this.left, required this.right, required this.progress});

  final String left;
  final String right;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.arrow_back_ios_rounded,
            size: 12, color: AppColors.sand.withValues(alpha: 0.6)),
        Expanded(
          child: Text(left,
              style: AppTextStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(right,
              textAlign: TextAlign.right,
              style: AppTextStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        Icon(Icons.arrow_forward_ios_rounded,
            size: 12, color: AppColors.sand.withValues(alpha: 0.6)),
      ],
    );
  }
}

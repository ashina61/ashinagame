import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../assets/game_art.dart';
import '../assets/game_assets.dart';
import '../audio/audio_service.dart';
import '../settings/app_settings.dart';

/// Wraps a button callback so a tap also clicks and gives a light haptic,
/// unless it is disabled.
VoidCallback? _tap(VoidCallback? onPressed) => onPressed == null
    ? null
    : () {
        AudioService.instance.playSfx('tap');
        AppSettings.instance.tap();
        onPressed();
      };

/// Full-screen night-steppe background with framed border, per the atlas.
class OrnateScaffold extends StatelessWidget {
  const OrnateScaffold({
    required this.child,
    this.backgroundAsset = GameAssets.bgScreenNight,
    this.backgroundFallback,
    super.key,
  });

  final Widget child;
  final String backgroundAsset;

  /// Art to use until [backgroundAsset] (often a produced [GameArt] path) is in
  /// the bundle, so a screen can opt into scene art without regressing.
  final String? backgroundFallback;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          backgroundAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              backgroundFallback == null
                  ? const ColoredBox(color: AppColors.leatherDeep)
                  : Image.asset(
                      backgroundFallback!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(color: AppColors.leatherDeep),
                    ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

/// Header row: optional back medallion, plaque title, optional info medallion.
class OrnateHeader extends StatelessWidget {
  const OrnateHeader({
    required this.title,
    this.showBack = false,
    this.showInfo = true,
    this.onInfo,
    super.key,
  });

  final String title;
  final bool showBack;
  final bool showInfo;

  /// Tapped when the info medallion is pressed. When null the medallion is
  /// hidden, so a screen never shows a dead "i" button.
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
      child: Row(
        children: [
          if (showBack)
            _MedallionButton(
              asset: GameAssets.uiButtonBack,
              onTap: () => Navigator.of(context).maybePop(),
            )
          else
            const SizedBox(width: 38),
          Expanded(
            child: Container(
              height: 46,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: _stretchedImage(GameAssets.uiPanelPlaque),
              alignment: Alignment.center,
              child: Text(
                title.toUpperCase(),
                style: AppTextStyles.header,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (showInfo && onInfo != null)
            _MedallionButton(asset: GameAssets.uiButtonInfo, onTap: onInfo!)
          else
            const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class _MedallionButton extends StatelessWidget {
  const _MedallionButton({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(asset, width: 38, height: 38),
    );
  }
}

/// Top resource strip on the five-slot ornate bar.
class ResourceBar extends StatelessWidget {
  const ResourceBar({required this.entries, this.onEntryTap, super.key});

  final List<(String asset, String value)> entries;

  /// Tapped with the entry index — used to pop a resource tooltip. Null leaves
  /// the bar as a plain readout.
  final ValueChanged<int>? onEntryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(GameArt.resourceBarFrame),
          fit: BoxFit.fill,
          // Swallow load errors so a missing frame never crashes the HUD.
          onError: (_, __) {},
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < entries.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onEntryTap == null ? null : () => onEntryTap!(i),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(entries[i].$1, width: 22, height: 22),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        entries[i].$2,
                        style: AppTextStyles.value.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Leather panel with thin gold border — the workhorse card of the atlas.
/// An optional [backgroundAsset] scene is shown behind a dark overlay.
class OrnatePanel extends StatelessWidget {
  const OrnatePanel({
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin = const EdgeInsets.fromLTRB(12, 0, 12, 10),
    this.backgroundAsset,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final String? backgroundAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xE61A140C), Color(0xF20F0B07)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.45),
          width: 1.1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            if (backgroundAsset != null)
              Positioned.fill(
                child: Image.asset(
                  backgroundAsset!,
                  fit: BoxFit.cover,
                  color: Colors.black.withValues(alpha: 0.45),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// Section heading rendered on the wide ornate strip.
class SectionPlaque extends StatelessWidget {
  const SectionPlaque(this.label, {this.trailing, super.key});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      margin: const EdgeInsets.fromLTRB(12, 2, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _stretchedImage(GameAssets.uiPanelTitleWide),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.section,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Primary call-to-action on the shiny gold plaque.
class GoldButton extends StatelessWidget {
  const GoldButton({
    required this.label,
    required this.onPressed,
    this.height = 52,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _tap(onPressed),
      child: Container(
        height: height,
        decoration: _stretchedImage(GameAssets.uiButtonGold),
        alignment: Alignment.center,
        child: Text(label.toUpperCase(), style: AppTextStyles.buttonGold),
      ),
    );
  }
}

/// Secondary action on the dark pill plaque.
class DarkButton extends StatelessWidget {
  const DarkButton({
    required this.label,
    required this.onPressed,
    this.height = 40,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _tap(onPressed),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: _stretchedImage(GameAssets.uiPanelField),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.buttonDark,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// A button whose entire artwork (including label) is a baked image.
class ImageButton extends StatelessWidget {
  const ImageButton({
    required this.asset,
    required this.onPressed,
    this.height = 42,
    super.key,
  });

  final String asset;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _tap(onPressed),
      child: Image.asset(asset, height: height, fit: BoxFit.contain),
    );
  }
}

/// Pill tab row (selected tab gets the bronze plaque).
class OrnateTabs extends StatelessWidget {
  const OrnateTabs({
    required this.tabs,
    required this.index,
    required this.onChanged,
    super.key,
  });

  final List<String> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: Container(
                  height: 36,
                  decoration: i == index
                      ? _stretchedImage(GameAssets.uiButtonBronzeSlim)
                      : BoxDecoration(
                          color: AppColors.leatherDeep.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.goldDim.withValues(alpha: 0.5),
                          ),
                        ),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[i].toUpperCase(),
                    style: i == index
                        ? AppTextStyles.buttonDark.copyWith(
                            color: AppColors.goldBright,
                          )
                        : AppTextStyles.buttonDark.copyWith(
                            color: AppColors.stone,
                            fontSize: 11,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Gold-framed inventory/craft slot with icon and optional count.
class ItemSlot extends StatelessWidget {
  const ItemSlot({
    required this.asset,
    this.count,
    this.label,
    this.labelAbove = false,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final String asset;
  final String? count;
  final String? label;
  final bool labelAbove;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final labelText = label == null
        ? null
        : Text(
            label!,
            style: AppTextStyles.meta.copyWith(
              color: AppColors.sand,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (labelAbove && labelText != null) ...[
            labelText,
            const SizedBox(height: 4),
          ],
          Container(
            decoration: _stretchedImage(GameAssets.uiSlotItem),
            foregroundDecoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.goldBright, width: 2),
                  )
                : null,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(asset, fit: BoxFit.contain),
                  ),
                ),
                if (count != null)
                  Positioned(
                    right: 5,
                    bottom: 3,
                    child: Text(
                      count!,
                      style: AppTextStyles.value.copyWith(
                        fontSize: 13,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!labelAbove && labelText != null) ...[
            const SizedBox(height: 4),
            labelText,
          ],
        ],
      ),
    );
  }
}

/// Gold-on-leather stat bar (health, energy, clan vault…).
class StatBar extends StatelessWidget {
  const StatBar({
    required this.fraction,
    this.height = 12,
    this.fill,
    super.key,
  });

  final double fraction;
  final double height;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: AppColors.goldDim.withValues(alpha: 0.7)),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fraction.clamp(0.0, 1.0),
        child: Container(
          margin: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: fill != null
                  ? [fill!, fill!]
                  : const [AppColors.goldBright, AppColors.gold],
            ),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

/// Bottom navigation drawn on the five-slot leather bar with medallions.
class OrnateNavBar extends StatelessWidget {
  const OrnateNavBar({
    required this.index,
    required this.onChanged,
    this.items = defaultItems,
    super.key,
  });

  final int index;
  final ValueChanged<int> onChanged;

  /// Each entry is (icon asset, label). The router swaps the set as the game
  /// moves from the lone-tent phase into the oba phase.
  final List<(String, String)> items;

  static const defaultItems = [
    (GameAssets.navHome, 'Ana Sayfa'),
    (GameAssets.iconPopulationMedallion, 'Karakter'),
    (GameAssets.navAtelier, 'Oba'),
    (GameAssets.navBoy, 'Boy'),
    (GameAssets.iconCompassStar, 'Seferler'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: _stretchedImage(
        GameAssets.uiPanelNavBar,
      ).copyWith(color: AppColors.ink),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: i == index
                          ? const BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x80EEC36A),
                                  blurRadius: 14,
                                ),
                              ],
                            )
                          : null,
                      child: Image.asset(
                        items[i].$1,
                        width: i == index ? 42 : 36,
                        height: i == index ? 42 : 36,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i].$2,
                      style: i == index
                          ? AppTextStyles.navLabel.copyWith(
                              color: AppColors.goldBright,
                            )
                          : AppTextStyles.navLabel,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

BoxDecoration _stretchedImage(String asset) {
  return BoxDecoration(
    image: DecorationImage(image: AssetImage(asset), fit: BoxFit.fill),
  );
}

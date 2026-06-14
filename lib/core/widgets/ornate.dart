import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../assets/game_assets.dart';
import '../audio/audio_service.dart';

/// Wraps a button callback so a tap also clicks, unless it is disabled.
VoidCallback? _tap(VoidCallback? onPressed) => onPressed == null
    ? null
    : () {
        AudioService.instance.playSfx('tap');
        onPressed();
      };

/// Full-screen night-steppe background with framed border, per the atlas.
class OrnateScaffold extends StatelessWidget {
  const OrnateScaffold({
    required this.child,
    this.backgroundAsset = GameAssets.bgScreenNight,
    super.key,
  });

  final Widget child;
  final String backgroundAsset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          backgroundAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const ColoredBox(color: AppColors.leatherDeep),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

/// Ornate screen header: a centred gold title flanked by scroll flourishes
/// (and an optional small-caps subtitle), drawn over a faint scene strip,
/// with optional round back / info medallions. Matches the in-game mockups.
class OrnateHeader extends StatelessWidget {
  const OrnateHeader({
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.showInfo = true,
    this.onInfo,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final bool showInfo;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: subtitle == null ? 60 : 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Faint battlefield strip fading into the page, as in the mockups.
          Positioned.fill(
            child: ClipRect(
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x66000000), Color(0x00000000)],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  GameAssets.sceneBattlefieldDusk,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  color: Colors.black.withValues(alpha: 0.55),
                  colorBlendMode: BlendMode.darken,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _HeaderFlourish(),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        title.toUpperCase(),
                        style: AppTextStyles.header.copyWith(
                          fontSize: 22,
                          color: AppColors.goldBright,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 6),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const _HeaderFlourish(flip: true),
                ],
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    subtitle!.toUpperCase(),
                    style: AppTextStyles.navLabel.copyWith(
                      color: AppColors.gold,
                      fontSize: 9,
                      letterSpacing: 2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          if (showBack)
            Align(
              alignment: Alignment.centerLeft,
              child: _MedallionButton(
                asset: GameAssets.uiButtonBack,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
          if (showInfo)
            Align(
              alignment: Alignment.centerRight,
              child: _MedallionButton(
                asset: GameAssets.uiButtonInfo,
                onTap: onInfo ?? () {},
              ),
            ),
        ],
      ),
    );
  }
}

/// Small mirrored scroll ornament that flanks an [OrnateHeader] title.
class _HeaderFlourish extends StatelessWidget {
  const _HeaderFlourish({this.flip = false});

  final bool flip;

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: flip,
      child: Image.asset(
        GameAssets.uiDividerOrnate,
        width: 44,
        height: 18,
        fit: BoxFit.contain,
        alignment: Alignment.centerRight,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.star,
          size: 12,
          color: AppColors.gold.withValues(alpha: 0.8),
        ),
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
      onTap: _tap(onTap),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Image.asset(
          asset,
          width: 38,
          height: 38,
          errorBuilder: (context, error, stackTrace) => Icon(
            asset == GameAssets.uiButtonBack
                ? Icons.arrow_back_ios_new
                : Icons.info_outline,
            color: AppColors.gold,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Top resource strip on the five-slot ornate bar.
class ResourceBar extends StatelessWidget {
  const ResourceBar({required this.entries, super.key});

  final List<(String asset, String value)> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: _stretchedImage(GameAssets.uiBarResources),
      child: Row(
        children: [
          for (final (asset, value) in entries)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(asset, width: 22, height: 22),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      value,
                      style: AppTextStyles.value.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
              color: Colors.black54, blurRadius: 10, offset: Offset(0, 5)),
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
                        ? AppTextStyles.buttonDark
                            .copyWith(color: AppColors.goldBright)
                        : AppTextStyles.buttonDark
                            .copyWith(color: AppColors.stone, fontSize: 11),
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
    super.key,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const _items = [
    (GameAssets.navHome, 'Ana Sayfa'),
    (GameAssets.iconItemHelmet, 'Karakter'),
    (GameAssets.iconYurtGold, 'Oba'),
    (GameAssets.iconSwordsCrossedGold, 'Seferler'),
    (GameAssets.iconMedallionHorse, 'Han'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: _stretchedImage(GameAssets.uiPanelNavBar).copyWith(
        color: AppColors.ink,
        border: const Border(
          top: BorderSide(color: AppColors.goldDim, width: 1.2),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++)
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
                        _items[i].$1,
                        width: i == index ? 42 : 36,
                        height: i == index ? 42 : 36,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _items[i].$2,
                      style: i == index
                          ? AppTextStyles.navLabel
                              .copyWith(color: AppColors.goldBright)
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

import 'package:flutter/material.dart';

import 'scene_background.dart';
import 'scene_hotspot.dart';

/// The shared skeleton for every game scene. It stacks five layers, top to
/// bottom: a bottom slot (action cards), a hotspot layer, a HUD overlay, and
/// the background painting — turning a "page" into a place you stand in.
///
/// The bottom navigation is supplied by the router around this widget, so a
/// scene is just a body and never owns the nav bar.
class SceneScreen extends StatelessWidget {
  const SceneScreen({
    required this.background,
    this.backgroundFallback,
    this.hotspots = const [],
    this.hud,
    this.bottom,
    this.foreground,
    this.atmosphere,
    super.key,
  });

  final String background;

  /// Art to use until [background] (often a produced [GameArt] path) lands in
  /// the bundle.
  final String? backgroundFallback;

  final List<SceneHotspot> hotspots;

  /// Optional click-through overlay drawn just above the background art (e.g.
  /// an [EmberGlow] firelight), beneath the HUD and content.
  final Widget? atmosphere;

  /// Overlay pinned to the top (resources, day, end-day).
  final Widget? hud;

  /// Content pinned to the bottom (big action cards, hints).
  final Widget? bottom;

  /// Optional extra widget drawn over the hotspot layer (e.g. a title plate).
  final Widget? foreground;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        SceneBackground(asset: background, fallback: backgroundFallback),
        if (atmosphere != null) atmosphere!,
        SafeArea(
          child: Column(
            children: [
              if (hud != null) hud!,
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (foreground != null) foreground!,
                        for (final hot in hotspots)
                          Positioned(
                            left: hot.x * w - 28,
                            top: hot.y * h - 28,
                            child: SceneHotspotWidget(hotspot: hot),
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (bottom != null) bottom!,
            ],
          ),
        ),
      ],
    );
  }
}

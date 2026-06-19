import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/audio/audio_service.dart';
import '../../core/settings/app_settings.dart';

/// A tappable place inside a game scene — a tent, a fire, a road, a building.
/// Positioned by fractional coordinates (0..1) so it scales with the scene
/// rather than living at fixed pixels. This is the contract every scene
/// element carries, per the design brief: id, title, icon, position, locked
/// state, an action and a short description.
class SceneHotspot {
  const SceneHotspot({
    required this.id,
    required this.title,
    required this.x,
    required this.y,
    this.icon,
    this.iconData,
    this.description = '',
    this.locked = false,
    this.lockHint,
    this.badge,
    this.onTap,
  });

  final String id;
  final String title;

  /// Fractional position within the scene, 0..1 from top-left.
  final double x;
  final double y;

  /// Image asset for the pin, when one fits the place.
  final String? icon;

  /// Fallback glyph when no art is supplied.
  final IconData? iconData;

  final String description;
  final bool locked;
  final String? lockHint;

  /// Small count shown on the pin (e.g. an unread event), null to hide.
  final String? badge;

  final VoidCallback? onTap;
}

/// Renders a hotspot as a softly pulsing, tappable medallion with a label
/// pill beneath it. Locked hotspots dim and show a lock.
class SceneHotspotWidget extends StatefulWidget {
  const SceneHotspotWidget({required this.hotspot, super.key});

  final SceneHotspot hotspot;

  @override
  State<SceneHotspotWidget> createState() => _SceneHotspotWidgetState();
}

class _SceneHotspotWidgetState extends State<SceneHotspotWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hot = widget.hotspot;
    final locked = hot.locked;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: hot.onTap == null
          ? null
          : () {
              AudioService.instance.playSfx(locked ? 'denied' : 'tap');
              AppSettings.instance.tap();
              hot.onTap!();
            },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              final glow = locked ? 0.0 : 6 + _pulse.value * 12;
              return Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.ink.withValues(alpha: 0.55),
                  border: Border.all(
                    color: locked
                        ? AppColors.stone.withValues(alpha: 0.6)
                        : AppColors.gold,
                    width: 1.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0x80EEC36A,
                      ).withValues(alpha: locked ? 0.0 : 0.5),
                      blurRadius: glow,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(11),
                  child: hot.icon != null
                      ? Image.asset(
                          hot.icon!,
                          fit: BoxFit.contain,
                          color: locked ? Colors.black54 : null,
                          colorBlendMode:
                              locked ? BlendMode.srcATop : BlendMode.dst,
                          errorBuilder: (_, __, ___) => Icon(
                            hot.iconData ?? Icons.place,
                            color: AppColors.gold,
                          ),
                        )
                      : Icon(
                          hot.iconData ?? Icons.place,
                          color:
                              locked ? AppColors.stone : AppColors.goldBright,
                          size: 26,
                        ),
                ),
                if (locked)
                  const Icon(Icons.lock, size: 18, color: AppColors.sand),
                if (hot.badge != null)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        hot.badge!,
                        style: AppTextStyles.meta.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.ink.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.goldDim.withValues(alpha: 0.6),
              ),
            ),
            child: Text(
              hot.title,
              style: AppTextStyles.meta.copyWith(
                fontSize: 11,
                color: locked ? AppColors.stone : AppColors.sand,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

/// A soft, slowly flickering warm glow laid over a scene to suggest firelight
/// on the steppe at night. Cheap: one looping controller driving a single
/// radial gradient. Always click-through, so it never blocks the scene beneath.
///
/// [center] places the glow in fractional scene coordinates (0..1).
class EmberGlow extends StatefulWidget {
  const EmberGlow({
    this.center = const Alignment(0.3, 0.2),
    this.color = const Color(0xFFFF9A3D),
    this.radius = 0.55,
    super.key,
  });

  /// Glow centre as an [Alignment] (-1..1 on each axis).
  final Alignment center;
  final Color color;

  /// Glow radius as a fraction of the shortest side.
  final double radius;

  @override
  State<EmberGlow> createState() => _EmberGlowState();
}

class _EmberGlowState extends State<EmberGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            // A gentle flicker: breathe the alpha and radius a touch.
            final t = (sin(_c.value * pi * 2) + 1) / 2; // 0..1
            final alpha = 0.10 + t * 0.10;
            final r = widget.radius * (0.94 + t * 0.12);
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: widget.center,
                  radius: r,
                  colors: [
                    widget.color.withValues(alpha: alpha),
                    widget.color.withValues(alpha: alpha * 0.4),
                    widget.color.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

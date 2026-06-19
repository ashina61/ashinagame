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

/// A handful of warm sparks drifting up off an unseen fire and winking out, to
/// give a still night-camp painting a sense of life. Cheap: one looping
/// controller drives a [CustomPainter] over a fixed set of embers seeded once,
/// so there is no per-frame allocation. Always click-through.
class RisingEmbers extends StatefulWidget {
  const RisingEmbers({
    this.count = 14,
    this.color = const Color(0xFFFFB259),
    this.origin = 0.4,
    this.spread = 0.26,
    super.key,
  });

  /// How many embers are alive at once.
  final int count;
  final Color color;

  /// Horizontal centre of the fire the embers rise from (0..1 across width).
  final double origin;

  /// How far to either side of [origin] embers may start (0..1 of width).
  final double spread;

  @override
  State<RisingEmbers> createState() => _RisingEmbersState();
}

class _Ember {
  const _Ember(this.x, this.size, this.phase, this.sway);

  /// Start column as a fraction of width.
  final double x;

  /// Radius in logical pixels.
  final double size;

  /// Offset into the rise cycle (0..1) so embers don't move in lockstep.
  final double phase;

  /// Horizontal drift amplitude as a fraction of width.
  final double sway;
}

class _RisingEmbersState extends State<RisingEmbers>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 6200),
  )..repeat();

  late final List<_Ember> _embers = _seed();

  List<_Ember> _seed() {
    // Fixed seed: deterministic across rebuilds and stable under widget tests.
    final rng = Random(7);
    return List.generate(widget.count, (_) {
      final x = widget.origin + (rng.nextDouble() * 2 - 1) * widget.spread;
      return _Ember(
        x.clamp(0.02, 0.98),
        1.2 + rng.nextDouble() * 2.2,
        rng.nextDouble(),
        0.01 + rng.nextDouble() * 0.04,
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _EmberPainter(
              progress: _c,
              embers: _embers,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmberPainter extends CustomPainter {
  _EmberPainter({
    required this.progress,
    required this.embers,
    required this.color,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final List<_Ember> embers;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final base = progress.value;
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);
    for (final ember in embers) {
      // Each ember runs its own 0..1 life, rising from low in the scene and
      // fading in then out so it never pops on or off.
      final life = (base + ember.phase) % 1.0;
      final y = 0.92 - life * 0.62;
      final dx = sin((life + ember.phase) * pi * 2) * ember.sway;
      final alpha = sin(life * pi) * 0.7;
      if (alpha <= 0) continue;
      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset((ember.x + dx) * size.width, y * size.height),
        ember.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_EmberPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Code-only premium backdrop: layered leather gradient with a faint golden
/// ring suggesting a tamga / sun over the steppe.
class SteppeBackground extends StatelessWidget {
  const SteppeBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.4),
          radius: 1.2,
          colors: [
            AppColors.leatherDark,
            AppColors.leatherDeep,
            AppColors.ink,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Optional steppe photo/illustration; falls back to the painted
          // ring backdrop when the asset is absent.
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/bg/steppe.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    CustomPaint(painter: _RingPainter()),
              ),
            ),
          ),
          // Scrim so card/text stay legible over any background image.
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x66000000), Color(0xAA000000)],
                  ),
                ),
              ),
            ),
          ),
          if (child != null) Positioned.fill(child: child!),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.32);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.gold.withValues(alpha: 0.06);

    for (var i = 0; i < 3; i++) {
      paint.strokeWidth = 2.0 - i * 0.4;
      canvas.drawCircle(center, size.width * (0.28 + i * 0.14), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => false;
}

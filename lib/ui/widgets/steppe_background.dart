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
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _RingPainter()),
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

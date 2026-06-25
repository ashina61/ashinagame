import 'package:flutter/material.dart';

import '../../models/metric.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// The four pillar gauges across the top of the game screen. When [preview]
/// holds the pending choice's effects, affected pillars show a direction hint.
class MetricMeters extends StatelessWidget {
  const MetricMeters({super.key, required this.metrics, this.preview});

  final Map<Metric, int> metrics;
  final Map<Metric, int>? preview;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final m in Metric.values)
          _Meter(
            metric: m,
            value: metrics[m] ?? 0,
            delta: preview?[m] ?? 0,
          ),
      ],
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter(
      {required this.metric, required this.value, required this.delta});

  final Metric metric;
  final int value;
  final int delta;

  @override
  Widget build(BuildContext context) {
    final active = delta != 0;
    final up = delta > 0;
    final hintColor = up ? AppColors.success : AppColors.danger;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 18,
          child: active
              ? Icon(
                  up
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: hintColor,
                  size: 18,
                )
              : null,
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.card,
            border: Border.all(
              color: active ? hintColor : AppColors.bronze,
              width: active ? 2 : 1,
            ),
          ),
          child: Icon(metric.icon, color: metric.color, size: 20),
        ),
        const SizedBox(height: 6),
        _Bar(value: value, color: metric.color),
        const SizedBox(height: 4),
        Text('$value', style: AppTextStyles.value),
        Text(metric.label, style: AppTextStyles.meta),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.bronze.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            tween: Tween(begin: 0, end: value / 100),
            builder: (context, t, _) => FractionallySizedBox(
              widthFactor: t.clamp(0.0, 1.0),
              child: Container(color: color),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../../models/metric.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// The four pillar gauges across the top of the game screen. When [preview]
/// holds the pending choice's effects, affected pillars show a direction hint.
/// When a value changes, the affected meter gives a short pulse.
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

class _Meter extends StatefulWidget {
  const _Meter(
      {required this.metric, required this.value, required this.delta});

  final Metric metric;
  final int value;
  final int delta;

  @override
  State<_Meter> createState() => _MeterState();
}

class _MeterState extends State<_Meter> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void didUpdateWidget(covariant _Meter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _pulse.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.delta != 0;
    final up = widget.delta > 0;
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
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            // 0 -> peak -> 0 over the controller's run.
            final t = math.sin(_pulse.value * math.pi);
            return Transform.scale(
              scale: 1 + 0.22 * t,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
                  border: Border.all(
                    color: active
                        ? hintColor
                        : Color.lerp(AppColors.bronze, widget.metric.color, t)!,
                    width: active ? 2 : 1 + t,
                  ),
                  boxShadow: t > 0.01
                      ? [
                          BoxShadow(
                            color:
                                widget.metric.color.withValues(alpha: 0.5 * t),
                            blurRadius: 12 * t,
                          ),
                        ]
                      : null,
                ),
                child: Icon(widget.metric.icon,
                    color: widget.metric.color, size: 20),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        _Bar(value: widget.value, color: widget.metric.color),
        const SizedBox(height: 4),
        Text('${widget.value}', style: AppTextStyles.value),
        Text(metricLabel(widget.metric), style: AppTextStyles.meta),
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

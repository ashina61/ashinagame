import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Pops a small "+6 Odun" style label that floats up and fades, giving each
/// gain a bit of juice. Fail-safe: does nothing if there is no overlay or the
/// text is empty.
void showFloatingGain(BuildContext context, String text, {Color? color}) {
  if (text.trim().isEmpty) return;
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _FloatingText(
      text: text,
      color: color ?? AppColors.goldBright,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

/// A brief dark fade with a "Gün N" plate, played when the day turns, so the
/// passage of time has a beat. Fail-safe: no overlay, no effect.
void showDayTransition(BuildContext context, String label) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _DayTransition(label: label, onDone: () => entry.remove()),
  );
  overlay.insert(entry);
}

class _DayTransition extends StatefulWidget {
  const _DayTransition({required this.label, required this.onDone});

  final String label;
  final VoidCallback onDone;

  @override
  State<_DayTransition> createState() => _DayTransitionState();
}

class _DayTransitionState extends State<_DayTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
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
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            // Fade in then out: peak darkness in the middle.
            final t = _c.value;
            final o = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.0, 1.0);
            return Opacity(
              opacity: o,
              child: ColoredBox(
                color: Colors.black,
                child: Center(
                  child: Text(widget.label, style: AppTextStyles.display),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FloatingText extends StatefulWidget {
  const _FloatingText({
    required this.text,
    required this.color,
    required this.onDone,
  });

  final String text;
  final Color color;
  final VoidCallback onDone;

  @override
  State<_FloatingText> createState() => _FloatingTextState();
}

class _FloatingTextState extends State<_FloatingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Positioned(
      top: media.padding.top + 96,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final t = _c.value;
            return Opacity(
              opacity: (1 - t).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, -34 * t),
                child: child,
              ),
            );
          },
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.color.withValues(alpha: 0.7)),
              ),
              child: Text(
                widget.text,
                style: AppTextStyles.value.copyWith(
                  color: widget.color,
                  fontSize: 15,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

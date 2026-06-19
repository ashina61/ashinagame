import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_art.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/skinned_button.dart';
import '../../core/widgets/skinned_panel.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_state.dart';

/// A short end-of-day report: the day's headline, atmosphere and the latest
/// chronicle lines (healed wounded, news, omens, raids, relations…). Shown as
/// a dismissible card so the turn closes with a beat, not just a date change.
Future<void> showDayReport(
  BuildContext context, {
  required String title,
  required String atmosphere,
  required List<String> lines,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      child: SkinnedPanel(
        backgroundAsset: GameArt.dialogPanel,
        margin: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.title.copyWith(color: AppColors.goldBright),
            ),
            const SizedBox(height: 4),
            Text(atmosphere, style: AppTextStyles.meta),
            const SizedBox(height: 10),
            for (final line in lines.take(5))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.brightness_2,
                      size: 12,
                      color: AppColors.goldDim,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(line, style: AppTextStyles.body)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SkinnedButton(
              label: 'DEVAM',
              height: 44,
              onPressed: () => Navigator.of(dialogContext).maybePop(),
            ),
          ],
        ),
      ),
    ),
  );
}

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

/// A short note floated in the game's voice instead of a material SnackBar.
/// [good] tints it gold (a confirmation) or ember (a warning / refusal).
void showFloatingNote(BuildContext context, String text, {bool good = true}) {
  showFloatingGain(
    context,
    text,
    color: good ? AppColors.goldBright : AppColors.ember,
  );
}

/// Floats the net resource (and food-bag) change between two game states, e.g.
/// "+3 Erzak, +1 Altın". Lets quick actions that only return a bool still show
/// the gain they produced, without the controller exposing a delta. Falls back
/// to [fallback] when nothing measurable changed (e.g. a stat-only action).
void showStateDelta(
  BuildContext context,
  GameState before,
  GameState after, {
  String? fallback,
}) {
  final parts = <String>[];
  var net = 0;
  for (final type in ResourceType.values) {
    final delta = (after.resources[type] ?? 0) - (before.resources[type] ?? 0);
    if (delta != 0) {
      parts.add('${type.label} ${Formatters.signed(delta)}');
      net += delta;
    }
  }
  final foodBag = _foodBagCount(after) - _foodBagCount(before);
  if (foodBag != 0) {
    parts.add('Azık ${Formatters.signed(foodBag)}');
    net += foodBag;
  }
  final text = parts.isEmpty ? (fallback ?? '') : parts.join(', ');
  showFloatingGain(
    context,
    text,
    color: net < 0 ? AppColors.ember : AppColors.success,
  );
}

int _foodBagCount(GameState state) {
  var total = 0;
  for (final amount in state.foodInventory.values) {
    total += amount;
  }
  return total;
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

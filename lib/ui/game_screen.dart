import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../models/metric.dart';
import '../state/game_state.dart';
import '../state/stats_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'widgets/gold_button.dart';
import 'widgets/metric_meters.dart';
import 'widgets/steppe_background.dart';
import 'widgets/swipe_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.stats});

  final StatsStore stats;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final GameState _game;
  late final AnimationController _ctrl;

  double _drag = 0; // horizontal offset in px
  double _from = 0;
  double _to = 0;
  bool _committing = false;
  bool _commitRight = false;

  @override
  void initState() {
    super.initState();
    _game = GameState(widget.stats)..addListener(_onGame);
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 240))
      ..addListener(_tickAnim)
      ..addStatusListener(_onAnimStatus);
  }

  @override
  void dispose() {
    _game.removeListener(_onGame);
    _game.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _onGame() => setState(() {});

  void _tickAnim() {
    setState(() {
      _drag =
          lerpDouble(_from, _to, Curves.easeOut.transform(_ctrl.value)) ?? _to;
    });
  }

  void _onAnimStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (_committing) {
      _committing = false;
      _drag = 0;
      _game.choose(_commitRight); // triggers _onGame -> setState
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_ctrl.isAnimating || _game.dead) return;
    setState(() => _drag += d.delta.dx);
  }

  void _onPanEnd(DragEndDetails d) {
    if (_ctrl.isAnimating || _game.dead) return;
    final width = MediaQuery.of(context).size.width;
    final threshold = width * 0.26;
    if (_drag.abs() > threshold) {
      _commitRight = _drag > 0;
      _committing = true;
      _animateTo(_commitRight ? width * 1.3 : -width * 1.3);
    } else {
      _animateTo(0);
    }
  }

  void _animateTo(double target) {
    _from = _drag;
    _to = target;
    _ctrl.forward(from: 0);
  }

  double get _threshold => MediaQuery.of(context).size.width * 0.26;

  double get _progress => (_drag / _threshold).clamp(-1.0, 1.0);

  Map<Metric, int>? get _preview {
    if (_game.current == null || _drag.abs() < 8 || _committing) return null;
    return (_drag > 0 ? _game.current!.right : _game.current!.left).effects;
  }

  @override
  Widget build(BuildContext context) {
    final card = _game.current;
    return Scaffold(
      body: SteppeBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child:
                        MetricMeters(metrics: _game.metrics, preview: _preview),
                  ),
                  Expanded(
                    child: card == null
                        ? const SizedBox.shrink()
                        : GestureDetector(
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                child: Transform.translate(
                                  offset: Offset(_drag, 0),
                                  child: Transform.rotate(
                                    angle: _progress * 0.12,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          maxWidth: 420, maxHeight: 460),
                                      child: SwipeCard(
                                          card: card, progress: _progress),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  _Footer(game: _game),
                ],
              ),
              if (_game.dead) _DeathOverlay(game: _game, onEnd: _endRun),
            ],
          ),
        ),
      ),
    );
  }

  void _endRun() {
    _game.endDynasty();
    Navigator.of(context).pop();
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Column(
        children: [
          SizedBox(
            height: 22,
            child: game.lastOutcome != null
                ? Text(
                    '» ${game.lastOutcome}',
                    style: AppTextStyles.meta,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : const Text('Kararını vermek için kartı kaydır',
                    style: AppTextStyles.meta, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 6),
          Text(
            '${game.rulerName} Kağan · Ashina Hanedanı',
            style: AppTextStyles.bodyStrong,
          ),
          Text(
            '${game.reign}. hükümdar · ${game.reignYears}. yıl · hanedan ${game.dynastyYears} yaşında',
            style: AppTextStyles.meta,
          ),
        ],
      ),
    );
  }
}

class _DeathOverlay extends StatelessWidget {
  const _DeathOverlay({required this.game, required this.onEnd});

  final GameState game;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final metric = game.deathMetric;
    return Container(
      color: Colors.black.withValues(alpha: 0.82),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              metric?.icon ?? Icons.dangerous_rounded,
              color: AppColors.danger,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text('SALTANAT SONA ERDİ',
                style: AppTextStyles.header, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              '${game.rulerName} Kağan, ${game.reignYears} yıl hüküm sürdü.',
              style: AppTextStyles.value,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(game.deathCause,
                style: AppTextStyles.body, textAlign: TextAlign.center),
            const SizedBox(height: 28),
            GoldButton(
              label: 'VÂRİS TAHTA ÇIKSIN',
              icon: Icons.account_balance_rounded,
              onTap: game.succeed,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onEnd,
              child:
                  const Text('HANEDANI BİTİR', style: AppTextStyles.buttonDark),
            ),
          ],
        ),
      ),
    );
  }
}

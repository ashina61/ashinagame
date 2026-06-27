import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/achievements.dart';
import '../l10n.dart';
import '../models/metric.dart';
import '../state/audio_service.dart';
import '../state/game_state.dart';
import '../state/settings.dart';
import '../state/stats_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'widgets/gold_button.dart';
import 'widgets/metric_meters.dart';
import 'widgets/steppe_background.dart';
import 'widgets/swipe_card.dart';

const _cardConstraints = BoxConstraints(maxWidth: 420, maxHeight: 460);

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.stats});

  final StatsStore stats;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late final GameState _game;
  late final AnimationController _ctrl; // snap / fling
  late final AnimationController _entry; // new-card entrance

  double _drag = 0; // horizontal offset in px
  double _from = 0;
  double _to = 0;
  bool _committing = false;
  bool _commitRight = false;
  bool _pastThreshold = false;
  bool _wasDead = false;
  bool _showTutorial = false;
  String? _shownId;

  @override
  void initState() {
    super.initState();
    _showTutorial = !widget.stats.tutorialSeen;
    _game = GameState(widget.stats)..addListener(_onGame);
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 240))
      ..addListener(_tickAnim)
      ..addStatusListener(_onAnimStatus);
    _entry = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 360));
    _shownId = _game.current?.id;
    _entry.forward(from: 0);
    AudioService.instance.startMusic();
  }

  @override
  void dispose() {
    _game.removeListener(_onGame);
    _game.dispose();
    _ctrl.dispose();
    _entry.dispose();
    AudioService.instance.stopMusic();
    super.dispose();
  }

  void _onGame() {
    // Heavy buzz + toll the moment a reign ends.
    if (_game.dead && !_wasDead) {
      if (Settings.instance.haptics) HapticFeedback.heavyImpact();
      AudioService.instance.death();
    }
    _wasDead = _game.dead;
    if (_game.newAchievements.isNotEmpty) {
      final ids = List<String>.from(_game.newAchievements);
      _game.clearNewAchievements();
      _showAchievements(ids);
    }
    // Play an entrance whenever a fresh card takes the stage.
    final id = _game.current?.id;
    if (!_game.dead && id != null && id != _shownId) {
      _shownId = id;
      _pastThreshold = false;
      _entry.forward(from: 0);
    }
    setState(() {});
  }

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
    final past = _drag.abs() > _threshold;
    if (past != _pastThreshold) {
      _pastThreshold = past;
      if (past && Settings.instance.haptics) {
        HapticFeedback.selectionClick(); // tick when a side arms
      }
    }
  }

  void _showAchievements(List<String> ids) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    for (final id in ids) {
      final a = achievements.where((x) => x.id == id);
      if (a.isEmpty) continue;
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content:
              Text('🏆 ${tr2('Başarım', 'Achievement')}: ${achName(a.first)}'),
        ),
      );
    }
  }

  void _onPanEnd(DragEndDetails d) {
    if (_ctrl.isAnimating || _game.dead) return;
    final width = MediaQuery.of(context).size.width;
    final velocity = d.velocity.pixelsPerSecond.dx;
    final flung = velocity.abs() > 720 && _drag.abs() > 24;
    final committed = _drag.abs() > _threshold || flung;
    if (committed) {
      _commitRight = (_drag.abs() > 4 ? _drag : velocity) > 0;
      _committing = true;
      if (Settings.instance.haptics) HapticFeedback.lightImpact();
      AudioService.instance.swipe();
      if (_showTutorial) {
        _showTutorial = false;
        widget.stats.markTutorialSeen();
      }
      _animateTo(_commitRight ? width * 1.3 : -width * 1.3);
    } else {
      _pastThreshold = false;
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
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const _DeckBack(),
                                    AnimatedBuilder(
                                      animation: _entry,
                                      builder: (context, child) {
                                        final e = _entry.value;
                                        final opacity =
                                            Curves.easeOut.transform(e);
                                        final scale = 0.94 +
                                            0.06 *
                                                Curves.easeOutBack.transform(e);
                                        final dy = (1 - opacity) * 26;
                                        return Opacity(
                                          opacity: opacity,
                                          child: Transform.translate(
                                            offset: Offset(0, dy),
                                            child: Transform.scale(
                                                scale: scale, child: child),
                                          ),
                                        );
                                      },
                                      child: Transform.translate(
                                        offset: Offset(_drag, 0),
                                        child: Transform.rotate(
                                          angle: _progress * 0.12,
                                          child: ConstrainedBox(
                                            constraints: _cardConstraints,
                                            child: SwipeCard(
                                                card: card,
                                                progress: _progress),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                  _Footer(game: _game),
                ],
              ),
              Positioned(
                top: 2,
                right: 2,
                child: IconButton(
                  onPressed: () async {
                    await AudioService.instance.toggleMute();
                    setState(() {});
                  },
                  icon: Icon(
                    AudioService.instance.muted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: AppColors.sand,
                    size: 20,
                  ),
                ),
              ),
              if (_showTutorial && !_game.dead) const _TutorialHint(),
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

/// A faint, slightly smaller card behind the active one to suggest a deck.
class _DeckBack extends StatelessWidget {
  const _DeckBack();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 14),
      child: Transform.scale(
        scale: 0.93,
        child: Opacity(
          opacity: 0.45,
          child: ConstrainedBox(
            constraints: _cardConstraints,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.leather, AppColors.leatherDeep],
                ),
                border: Border.all(color: AppColors.bronze),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// First-run coachmark. Ignores pointer events so the swipe still reaches the
/// card; the game screen hides it after the first committed swipe.
class _TutorialHint extends StatelessWidget {
  const _TutorialHint();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard_double_arrow_left_rounded,
                    color: AppColors.sand, size: 40),
                SizedBox(width: 16),
                Icon(Icons.swipe_rounded,
                    color: AppColors.goldBright, size: 56),
                SizedBox(width: 16),
                Icon(Icons.keyboard_double_arrow_right_rounded,
                    color: AppColors.sand, size: 40),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                tr2(
                  'Kartı sağa ya da sola kaydırarak karar ver.\n'
                      'Hangi yöne çektiğine göre dört denge değişir.',
                  'Swipe the card left or right to decide.\n'
                      'Which way you pull shifts the four pillars.',
                ),
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.game});

  final GameState game;

  String get _traitStr =>
      game.trait != null ? ' · ${traitName(game.trait!)}' : '';

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
                : Text(
                    tr2('Kararını vermek için kartı kaydır',
                        'Swipe the card to decide'),
                    style: AppTextStyles.meta,
                    textAlign: TextAlign.center),
          ),
          const SizedBox(height: 6),
          Text(
            tr2('${game.rulerName} Kağan$_traitStr',
                'Khan ${game.rulerName}$_traitStr'),
            style: AppTextStyles.bodyStrong,
          ),
          Text(
            tr2(
              '${game.reign}. hükümdar · ${eraLabel(game.era)} çağı · '
                  '${game.reignYears}. yıl · hanedan ${game.dynastyYears} yaşında',
              'Khan ${game.reign} · ${eraLabel(game.era)} era · '
                  'year ${game.reignYears} · dynasty aged ${game.dynastyYears}',
            ),
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
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOut,
      tween: Tween(begin: 0, end: 1),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Container(
          color: Colors.black.withValues(alpha: 0.82 * t),
          alignment: Alignment.center,
          child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
        ),
      ),
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
            Text(tr2('SALTANAT SONA ERDİ', 'THE REIGN HAS ENDED'),
                style: AppTextStyles.header, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              tr2('${game.rulerName} Kağan, ${game.reignYears} yıl hüküm sürdü.',
                  'Khan ${game.rulerName} reigned ${game.reignYears} years.'),
              style: AppTextStyles.value,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
                game.deathMetric != null
                    ? deathCause(game.deathMetric!, game.deathTooHigh)
                    : game.deathCause,
                style: AppTextStyles.body,
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            GoldButton(
              label: tr2('VÂRİS TAHTA ÇIKSIN', 'THE HEIR TAKES THE THRONE'),
              icon: Icons.account_balance_rounded,
              onTap: () {
                AudioService.instance.succeed();
                game.succeed();
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onEnd,
              child: Text(tr2('HANEDANI BİTİR', 'END THE DYNASTY'),
                  style: AppTextStyles.buttonDark),
            ),
          ],
        ),
      ),
    );
  }
}

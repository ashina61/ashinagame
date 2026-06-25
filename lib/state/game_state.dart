import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/deck.dart';
import '../data/rulers.dart';
import '../models/kagan_card.dart';
import '../models/metric.dart';
import 'stats_store.dart';

const int kStartValue = 50;

/// Drives one dynasty run: balancing pillars, drawing cards, succession.
class GameState extends ChangeNotifier {
  GameState(this._stats, {Random? rng}) : _rng = rng ?? Random() {
    _startReign();
  }

  final StatsStore _stats;
  final Random _rng;

  final Map<Metric, int> metrics = {
    for (final m in Metric.values) m: kStartValue,
  };

  /// Total years of the whole dynasty (sum across reigns in this run).
  int year = 0;
  int reign = 1;
  String rulerName = rulerForReign(1);
  int _reignStartYear = 0;
  int cardsSeen = 0;

  KaganCard? current;
  String? _lastId;
  String? lastOutcome;

  bool dead = false;
  Metric? deathMetric;
  bool deathTooHigh = false;
  String deathCause = '';
  bool dynastyEnded = false;

  int get reignYears => year - _reignStartYear;
  int get dynastyYears => year;

  void _startReign() {
    rulerName = rulerForReign(reign);
    _reignStartYear = year;
    for (final m in Metric.values) {
      metrics[m] = kStartValue;
    }
    dead = false;
    deathMetric = null;
    deathCause = '';
    lastOutcome = null;
    _draw();
  }

  void _draw() {
    final pool = deck.where((c) => c.id != _lastId).toList();
    final total = pool.fold<double>(0, (s, c) => s + c.weight);
    var r = _rng.nextDouble() * total;
    KaganCard picked = pool.last;
    for (final c in pool) {
      r -= c.weight;
      if (r <= 0) {
        picked = c;
        break;
      }
    }
    current = picked;
    _lastId = picked.id;
    cardsSeen++;
  }

  /// Apply the choice for the current card. [right] = swiped right.
  void choose(bool right) {
    if (dead || dynastyEnded || current == null) return;
    final choice = right ? current!.right : current!.left;

    choice.effects.forEach((metric, delta) {
      metrics[metric] = (metrics[metric]! + delta).clamp(0, 100);
    });
    lastOutcome = choice.outcome;
    year += 1;

    for (final m in Metric.values) {
      final v = metrics[m]!;
      if (v <= 0 || v >= 100) {
        _die(m, v >= 100);
        return;
      }
    }

    _draw();
    notifyListeners();
  }

  void _die(Metric m, bool tooHigh) {
    dead = true;
    deathMetric = m;
    deathTooHigh = tooHigh;
    deathCause = m.deathCause(tooHigh);
    _stats.recordReign(reignYears);
    notifyListeners();
  }

  /// The heir takes the throne; the dynasty continues.
  void succeed() {
    if (!dead) return;
    reign += 1;
    _startReign();
    notifyListeners();
  }

  /// End the run and persist the dynasty record.
  void endDynasty() {
    if (dynastyEnded) return;
    dynastyEnded = true;
    _stats.recordDynasty(dynastyYears);
    notifyListeners();
  }
}

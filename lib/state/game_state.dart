import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/deck.dart';
import '../data/rulers.dart';
import '../data/traits.dart';
import '../models/era.dart';
import '../models/kagan_card.dart';
import '../models/metric.dart';
import 'stats_store.dart';

const int kStartValue = 50;

class _Pending {
  _Pending(this.id, this.dueYear);
  final String id;
  final int dueYear;
}

/// Drives one dynasty run: pillars, era, card draw (with conditions, eras,
/// and event chains), succession with heir traits, and achievement tracking.
class GameState extends ChangeNotifier {
  GameState(this._stats, {Random? rng}) : _rng = rng ?? Random() {
    _startReign();
  }

  final StatsStore _stats;
  final Random _rng;

  final Map<Metric, int> metrics = {
    for (final m in Metric.values) m: kStartValue,
  };

  int year = 0;
  int reign = 1;
  String rulerName = rulerForReign(1);
  Trait? trait;
  int _reignStartYear = 0;
  int cardsSeen = 0;

  final Set<String> flags = {};
  final List<_Pending> _queue = [];

  KaganCard? current;
  String? _lastId;
  String? lastOutcome;

  bool dead = false;
  Metric? deathMetric;
  bool deathTooHigh = false;
  String deathCause = '';
  bool dynastyEnded = false;

  /// Achievement ids unlocked since the UI last consumed them.
  final List<String> newAchievements = [];

  int get reignYears => year - _reignStartYear;
  int get dynastyYears => year;
  Era get era => eraForYear(year);

  CardContext get _ctx => CardContext(
        metrics: metrics,
        flags: flags,
        era: era,
        reign: reign,
        year: year,
      );

  void _startReign() {
    rulerName = rulerForReign(reign);
    trait = traits[_rng.nextInt(traits.length)];
    _reignStartYear = year;
    flags.clear();
    _queue.clear();
    for (final m in Metric.values) {
      final delta = trait!.deltas[m] ?? 0;
      metrics[m] = (kStartValue + delta).clamp(12, 88);
    }
    dead = false;
    deathMetric = null;
    deathCause = '';
    lastOutcome = null;
    _draw();
  }

  void _draw() {
    // Due, scheduled follow-ups take priority.
    _queue.sort((a, b) => a.dueYear.compareTo(b.dueYear));
    for (var i = 0; i < _queue.length; i++) {
      if (_queue[i].dueYear > year) continue;
      final card = _cardById(_queue[i].id);
      if (card != null) {
        _queue.removeAt(i);
        current = card;
        _lastId = card.id;
        cardsSeen++;
        return;
      }
      _queue.removeAt(i);
      i--;
    }

    final ctx = _ctx;
    final pool = deck.where((c) {
      if (c.scheduledOnly || c.id == _lastId) return false;
      if (c.eras != null && !c.eras!.contains(era)) return false;
      if (c.condition != null && !c.condition!(ctx)) return false;
      return true;
    }).toList();
    if (pool.isEmpty) {
      // Fallback: ignore the last-id guard.
      pool.addAll(deck.where((c) =>
          !c.scheduledOnly &&
          (c.eras == null || c.eras!.contains(era)) &&
          (c.condition == null || c.condition!(ctx))));
    }
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

  KaganCard? _cardById(String id) {
    for (final c in deck) {
      if (c.id == id) return c;
    }
    return null;
  }

  void choose(bool right) {
    if (dead || dynastyEnded || current == null) return;
    final choice = right ? current!.right : current!.left;

    choice.effects.forEach((metric, delta) {
      metrics[metric] = (metrics[metric]! + delta).clamp(0, 100);
    });
    flags.addAll(choice.setFlags);
    if (choice.enqueue != null) {
      _queue.add(_Pending(choice.enqueue!, year + choice.enqueueAfter));
    }
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
    _checkAchievements();
    notifyListeners();
  }

  void _die(Metric m, bool tooHigh) {
    dead = true;
    deathMetric = m;
    deathTooHigh = tooHigh;
    deathCause = m.deathCause(tooHigh);
    _stats.recordReign(reignYears);
    _stats.recordDeath('${m.name}_${tooHigh ? 'high' : 'low'}');
    _checkAchievements(died: true);
    notifyListeners();
  }

  void succeed() {
    if (!dead) return;
    reign += 1;
    _startReign();
    _checkAchievements();
    notifyListeners();
  }

  void endDynasty() {
    if (dynastyEnded) return;
    dynastyEnded = true;
    _stats.recordDynasty(dynastyYears);
    notifyListeners();
  }

  void clearNewAchievements() => newAchievements.clear();

  Future<void> _checkAchievements({bool died = false}) async {
    final unlocked = <String>[];
    Future<void> tryUnlock(String id, bool cond) async {
      if (cond && await _stats.unlockAchievement(id)) unlocked.add(id);
    }

    final balanced =
        Metric.values.every((m) => metrics[m]! >= 45 && metrics[m]! <= 55);
    await tryUnlock('ilk_olum', died);
    await tryUnlock('saltanat_15', reignYears >= 15);
    await tryUnlock('saltanat_30', reignYears >= 30);
    await tryUnlock('hanedan_50', dynastyYears >= 50);
    await tryUnlock('hanedan_100', dynastyYears >= 100);
    await tryUnlock('cag_cokus', era == Era.cokus);
    await tryUnlock('besinci_kagan', reign >= 5);
    await tryUnlock('denge', balanced);
    await tryUnlock('tum_olumler', _stats.deathsSeen.length >= 8);

    if (unlocked.isNotEmpty) {
      newAchievements.addAll(unlocked);
      notifyListeners();
    }
  }
}

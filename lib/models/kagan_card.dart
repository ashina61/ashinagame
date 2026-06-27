import 'era.dart';
import 'metric.dart';

/// Lightweight snapshot a card's [condition] is evaluated against. Kept
/// separate from GameState so the data layer doesn't depend on it.
class CardContext {
  const CardContext({
    required this.metrics,
    required this.flags,
    required this.era,
    required this.reign,
    required this.year,
    required this.relation,
  });

  final Map<Metric, int> metrics;
  final Set<String> flags;
  final Era era;
  final int reign;
  final int year;

  /// Relationship with the neighbouring khanate (0..100).
  final int relation;

  int m(Metric metric) => metrics[metric] ?? 0;
  bool has(String flag) => flags.contains(flag);
}

typedef CardCondition = bool Function(CardContext c);

/// One of the two answers to a dilemma card.
class Choice {
  const Choice({
    required this.label,
    this.effects = const {},
    this.outcome,
    this.setFlags = const [],
    this.enqueue,
    this.enqueueAfter = 2,
    this.relation = 0,
  });

  /// Short label shown on the card while swiping toward this side.
  final String label;

  /// How the four pillars shift when this choice is taken.
  final Map<Metric, int> effects;

  /// Shift to the neighbouring khanate relationship (0..100).
  final int relation;

  /// Optional one-line consequence shown after the choice is made.
  final String? outcome;

  /// Flags raised on the current reign (drive chains / conditional cards).
  final List<String> setFlags;

  /// Optional card id to schedule as a follow-up.
  final String? enqueue;

  /// How many years later the [enqueue] card becomes due.
  final int enqueueAfter;
}

/// A single dilemma presented by an advisor / envoy / threat.
class KaganCard {
  const KaganCard({
    required this.id,
    required this.speaker,
    required this.title,
    required this.prompt,
    required this.left,
    required this.right,
    this.weight = 1,
    this.eras,
    this.condition,
    this.scheduledOnly = false,
  });

  final String id;
  final String speaker;
  final String title;
  final String prompt;

  /// Taken by swiping left.
  final Choice left;

  /// Taken by swiping right.
  final Choice right;

  /// Relative draw probability.
  final double weight;

  /// Eras this card may appear in; null = any era.
  final Set<Era>? eras;

  /// Extra gate on top of era; null = always eligible.
  final CardCondition? condition;

  /// When true the card is never drawn at random — only via [Choice.enqueue].
  final bool scheduledOnly;
}

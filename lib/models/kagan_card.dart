import 'metric.dart';

/// One of the two answers to a dilemma card.
class Choice {
  /// Short label shown on the card while swiping toward this side.
  final String label;

  /// Optional one-line consequence shown after the choice is made.
  final String? outcome;

  /// How the four pillars shift when this choice is taken.
  final Map<Metric, int> effects;

  const Choice({
    required this.label,
    this.effects = const {},
    this.outcome,
  });
}

/// A single dilemma presented by an advisor / envoy / threat.
class KaganCard {
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

  const KaganCard({
    required this.id,
    required this.speaker,
    required this.title,
    required this.prompt,
    required this.left,
    required this.right,
    this.weight = 1,
  });
}

/// The dynasty moves through three ages as the years accumulate. Some cards
/// are gated to an era so the deck shifts in flavour over a long run.
enum Era { kurulus, yukselis, cokus }

extension EraInfo on Era {
  String get label {
    switch (this) {
      case Era.kurulus:
        return 'Kuruluş';
      case Era.yukselis:
        return 'Yükseliş';
      case Era.cokus:
        return 'Çöküş';
    }
  }
}

/// Era from the dynasty's total age in years.
Era eraForYear(int dynastyYears) {
  if (dynastyYears < 15) return Era.kurulus;
  if (dynastyYears < 35) return Era.yukselis;
  return Era.cokus;
}

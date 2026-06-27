import 'data/achievements.dart';
import 'data/deck_en.dart';
import 'data/traits.dart';
import 'models/era.dart';
import 'models/kagan_card.dart';
import 'models/metric.dart';
import 'state/settings.dart';

bool get _en => Settings.instance.lang == Lang.en;

/// Pick the Turkish or English variant for an inline string.
String tr2(String tr, String en) => _en ? en : tr;

// --- Card text -------------------------------------------------------------

String cardTitle(KaganCard c) =>
    _en ? (deckEn[c.id]?.title ?? c.title) : c.title;

String cardPrompt(KaganCard c) =>
    _en ? (deckEn[c.id]?.prompt ?? c.prompt) : c.prompt;

String cardLabel(KaganCard c, bool right) {
  if (!_en) return (right ? c.right : c.left).label;
  final t = deckEn[c.id];
  if (t == null) return (right ? c.right : c.left).label;
  return right ? t.l1 : t.l0;
}

String? outcomeFor(KaganCard c, bool right) {
  if (!_en) return (right ? c.right : c.left).outcome;
  final t = deckEn[c.id];
  if (t == null) return (right ? c.right : c.left).outcome;
  return right ? t.o1 : t.o0;
}

// --- Pillars ---------------------------------------------------------------

String metricLabel(Metric m) {
  if (!_en) return m.label;
  switch (m) {
    case Metric.halk:
      return 'People';
    case Metric.ordu:
      return 'Army';
    case Metric.hazine:
      return 'Treasury';
    case Metric.tore:
      return 'Tradition';
  }
}

String deathCause(Metric m, bool tooHigh) {
  if (!_en) return m.deathCause(tooHigh);
  switch (m) {
    case Metric.halk:
      return tooHigh
          ? 'The people loved you so much that the fearful beys had you strangled in your tent one night.'
          : 'The hungry, downtrodden people rose up; your camp was put to the torch and your dynasty fell.';
    case Metric.ordu:
      return tooHigh
          ? 'The bloated army trusted its own might; your commanders deposed you and chose their own khan.'
          : 'Left without an army, your camp was wiped out in a dawn raid by neighbouring tribes.';
    case Metric.hazine:
      return tooHigh
          ? 'Drowning in gold, you sank into excess; the weary people deposed you in a tax revolt.'
          : 'The treasury ran dry; your unpaid soldiers and beys abandoned you.';
    case Metric.tore:
      return tooHigh
          ? 'Smothered by rigid law, the tribes could not breathe; a reformer bey brought you down.'
          : 'You trampled the law; shamans and elders cursed you and turned the tribes against you.';
  }
}

// --- Era / trait / achievement ---------------------------------------------

String eraLabel(Era e) {
  if (!_en) return e.label;
  switch (e) {
    case Era.kurulus:
      return 'Founding';
    case Era.yukselis:
      return 'Ascent';
    case Era.cokus:
      return 'Decline';
  }
}

const _traitEn = <String, (String, String)>{
  'cesur': ('Brave', 'Knows no fear; the army adores him, gold he ignores.'),
  'bilge': ('Wise', 'Knows the law and the ancestors\' way well.'),
  'comert': ('Generous', 'Wins the people\'s heart, but the purse melts.'),
  'kurnaz': ('Cunning', 'Loves gold and counts every coin.'),
  'adil': ('Just', 'Keeps the balance; touches a little of everything.'),
  'mağrur': (
    'Proud',
    'Boasts of his strength; cows the beys, tires the people.'
  ),
};

String traitName(Trait t) => _en ? (_traitEn[t.id]?.$1 ?? t.name) : t.name;
String traitBlurb(Trait t) => _en ? (_traitEn[t.id]?.$2 ?? t.blurb) : t.blurb;

const _achEn = <String, (String, String)>{
  'ilk_olum': ('First Reign', 'Lose the throne for the first time.'),
  'saltanat_15': ('Master Khan', 'Sustain a reign for 15 years.'),
  'saltanat_30': ('Legendary Khan', 'Sustain a reign for 30 years.'),
  'hanedan_50': ('Rooted Dynasty', 'Keep the dynasty alive 50 years.'),
  'hanedan_100': ('Eternal Ashina', 'Keep the dynasty alive 100 years.'),
  'cag_cokus': ('See the Ages', 'Reach the Decline era.'),
  'denge': (
    'Master of Balance',
    'Hold all four pillars between 45–55 at once.'
  ),
  'besinci_kagan': ('The Line Endures', 'Reach the 5th khan in one game.'),
  'tum_olumler': ('Eight Ends', 'Witness all eight kinds of death.'),
};

String achName(Achievement a) => _en ? (_achEn[a.id]?.$1 ?? a.name) : a.name;
String achBlurb(Achievement a) => _en ? (_achEn[a.id]?.$2 ?? a.blurb) : a.blurb;

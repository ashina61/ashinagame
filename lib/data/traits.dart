import '../models/metric.dart';

/// A new khan inherits a temperament that nudges the pillars they start with.
class Trait {
  const Trait({
    required this.id,
    required this.name,
    required this.blurb,
    required this.deltas,
  });

  final String id;
  final String name;
  final String blurb;
  final Map<Metric, int> deltas;
}

const traits = <Trait>[
  Trait(
    id: 'cesur',
    name: 'Cesur',
    blurb: 'Korku nedir bilmez; ordu ona tapar, hazineyi umursamaz.',
    deltas: {Metric.ordu: 12, Metric.hazine: -8},
  ),
  Trait(
    id: 'bilge',
    name: 'Bilge',
    blurb: 'Töreyi ve atalar yolunu iyi bilir.',
    deltas: {Metric.tore: 12, Metric.ordu: -6},
  ),
  Trait(
    id: 'comert',
    name: 'Cömert',
    blurb: 'Halkın gönlünü kazanır ama kese erir.',
    deltas: {Metric.halk: 12, Metric.hazine: -8},
  ),
  Trait(
    id: 'kurnaz',
    name: 'Kurnaz',
    blurb: 'Altını sever, hesabını bilir.',
    deltas: {Metric.hazine: 14, Metric.tore: -6},
  ),
  Trait(
    id: 'adil',
    name: 'Adil',
    blurb: 'Dengeyi gözetir; her şeye az da olsa dokunur.',
    deltas: {Metric.halk: 5, Metric.tore: 5},
  ),
  Trait(
    id: 'mağrur',
    name: 'Mağrur',
    blurb: 'Gücüyle övünür; beyleri ürkütür, halkı yorar.',
    deltas: {Metric.ordu: 8, Metric.halk: -8, Metric.tore: 4},
  ),
];

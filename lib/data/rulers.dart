/// Names the Ashina dynasty cycles through, one per reign.
const rulerNames = <String>[
  'Bumin',
  'İstemi',
  'Mukan',
  'Tapo',
  'İşbara',
  'Tulan',
  'Kara',
  'Bağa',
  'Tölis',
  'Şad',
  'Kapgan',
  'Bilge',
  'Kül Tigin',
  'Yollug',
  'Tonga',
  'Alp Er',
  'Arslan',
  'Böri',
  'Yamtar',
  'Kürşad',
];

String rulerForReign(int reign) {
  if (reign <= rulerNames.length) {
    return rulerNames[reign - 1];
  }
  // After the list is exhausted, append an ordinal for fresh khans.
  final base = rulerNames[(reign - 1) % rulerNames.length];
  final round = (reign - 1) ~/ rulerNames.length + 1;
  return '$base $round';
}

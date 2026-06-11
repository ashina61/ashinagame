enum Season {
  spring('İlkbahar', 'Ilık rüzgârlar otağların arasından geçiyor.'),
  summer('Yaz', 'Uzun günler keşif ve av için elverişli.'),
  autumn('Sonbahar', 'Bozkır kış hazırlığı için sarıya dönüyor.'),
  winter('Kış', 'Soğuk keskin; erzak tüketimi ağırlaşıyor.');

  const Season(this.label, this.atmosphere);
  final String label;
  final String atmosphere;

  Season get next => Season.values[(index + 1) % Season.values.length];
}

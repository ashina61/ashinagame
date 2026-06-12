enum ResourceType {
  gold('Altın'),
  food('Erzak'),
  wood('Odun'),
  leather('Deri'),
  stone('Taş'),
  iron('Demir'),
  horse('At'),
  reputation('İtibar'),
  morale('Moral'),
  population('Nüfus');

  const ResourceType(this.label);
  final String label;
}

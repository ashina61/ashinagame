enum ResourceType {
  food('Erzak'),
  wood('Odun'),
  leather('Deri'),
  horse('At'),
  reputation('İtibar'),
  morale('Moral'),
  population('Nüfus');

  const ResourceType(this.label);
  final String label;
}

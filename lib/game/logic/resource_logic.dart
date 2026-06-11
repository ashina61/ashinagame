import '../models/resource.dart';

class ResourceLogic {
  const ResourceLogic._();

  static Map<ResourceType, int> apply(
    Map<ResourceType, int> current,
    Map<ResourceType, int> delta,
  ) {
    final next = Map<ResourceType, int>.from(current);
    for (final entry in delta.entries) {
      final currentValue = next[entry.key] ?? 0;
      final updatedValue = currentValue + entry.value;
      next[entry.key] = updatedValue.clamp(0, 9999).toInt();
    }
    return next;
  }
}

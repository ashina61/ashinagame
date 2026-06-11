import '../../game/models/resource.dart';

class Formatters {
  const Formatters._();

  static String signed(int value) => value > 0 ? '+$value' : '$value';

  static String resourceDelta(Map<ResourceType, int> effects) {
    if (effects.isEmpty) {
      return 'Kaynak etkisi yok';
    }
    return effects.entries.map((entry) => '${entry.key.label} ${signed(entry.value)}').join(', ');
  }
}

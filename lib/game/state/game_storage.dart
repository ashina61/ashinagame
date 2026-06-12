import 'package:shared_preferences/shared_preferences.dart';

import 'game_serializer.dart';
import 'game_state.dart';

/// Persists the run to local storage between launches.
class GameStorage {
  const GameStorage(this._prefs);

  static const _key = 'ashina_save_v1';

  final SharedPreferences _prefs;

  static Future<GameStorage> create() async =>
      GameStorage(await SharedPreferences.getInstance());

  GameState? load() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      return null;
    }
    return GameSerializer.decode(raw);
  }

  void save(GameState state) {
    _prefs.setString(_key, GameSerializer.encode(state));
  }
}

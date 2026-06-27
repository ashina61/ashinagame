import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Lang { tr, en }

enum Difficulty { merhametli, normal, zorlu }

extension DifficultyInfo on Difficulty {
  /// Multiplier applied to every choice's effect — bigger swings = harder.
  double get multiplier {
    switch (this) {
      case Difficulty.merhametli:
        return 0.8;
      case Difficulty.normal:
        return 1.0;
      case Difficulty.zorlu:
        return 1.3;
    }
  }
}

/// User preferences: language, audio levels and haptics. A small singleton so
/// any widget can read it; listenable so the UI updates live.
class Settings extends ChangeNotifier {
  Settings._();

  static final Settings instance = Settings._();

  SharedPreferences? _prefs;
  double _musicVolume = 0.4;
  double _sfxVolume = 0.9;
  bool _haptics = true;
  Lang _lang = Lang.tr;
  Difficulty _difficulty = Difficulty.normal;

  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  bool get haptics => _haptics;
  Lang get lang => _lang;
  Difficulty get difficulty => _difficulty;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _musicVolume = _prefs?.getDouble('set_music') ?? 0.4;
    _sfxVolume = _prefs?.getDouble('set_sfx') ?? 0.9;
    _haptics = _prefs?.getBool('set_haptics') ?? true;
    _lang = (_prefs?.getString('set_lang') == 'en') ? Lang.en : Lang.tr;
    final d = _prefs?.getInt('set_difficulty') ?? 1;
    _difficulty = Difficulty.values[d.clamp(0, Difficulty.values.length - 1)];
  }

  Future<void> setDifficulty(Difficulty v) async {
    _difficulty = v;
    await _prefs?.setInt('set_difficulty', v.index);
    notifyListeners();
  }

  Future<void> setLang(Lang v) async {
    _lang = v;
    await _prefs?.setString('set_lang', v == Lang.en ? 'en' : 'tr');
    notifyListeners();
  }

  Future<void> setMusicVolume(double v) async {
    _musicVolume = v.clamp(0.0, 1.0);
    await _prefs?.setDouble('set_music', _musicVolume);
    notifyListeners();
  }

  Future<void> setSfxVolume(double v) async {
    _sfxVolume = v.clamp(0.0, 1.0);
    await _prefs?.setDouble('set_sfx', _sfxVolume);
    notifyListeners();
  }

  Future<void> setHaptics(bool v) async {
    _haptics = v;
    await _prefs?.setBool('set_haptics', v);
    notifyListeners();
  }
}

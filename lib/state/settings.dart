import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences: audio levels and haptics. A small singleton so any
/// widget can read it; listenable so the settings screen updates live.
class Settings extends ChangeNotifier {
  Settings._();

  static final Settings instance = Settings._();

  SharedPreferences? _prefs;
  double _musicVolume = 0.4;
  double _sfxVolume = 0.9;
  bool _haptics = true;

  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  bool get haptics => _haptics;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _musicVolume = _prefs?.getDouble('set_music') ?? 0.4;
    _sfxVolume = _prefs?.getDouble('set_sfx') ?? 0.9;
    _haptics = _prefs?.getBool('set_haptics') ?? true;
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

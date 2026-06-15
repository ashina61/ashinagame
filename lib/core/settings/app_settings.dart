import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Small, fail-safe holder for non-audio player preferences. Today it carries
/// the haptics toggle; every call is wrapped so a missing platform channel (in
/// tests, say) never crashes the game.
class AppSettings {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  bool _haptics = true;
  SharedPreferences? _prefs;

  bool get haptics => _haptics;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _haptics = _prefs?.getBool('haptics') ?? true;
    } catch (_) {
      // Preferences are optional; ignore setup failures.
    }
  }

  Future<void> setHaptics(bool value) async {
    _haptics = value;
    try {
      _prefs?.setBool('haptics', value);
    } catch (_) {}
    if (value) tap();
  }

  /// A light tap, only when haptics are on. Safe to call from anywhere.
  void tap() {
    if (!_haptics) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }
}

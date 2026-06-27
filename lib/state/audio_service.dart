import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Plays short sound effects and a looping ambient track. Every call is
/// wrapped so a missing asset (none shipped yet) is silently ignored — drop
/// files into `assets/audio/` and they start playing with no code change.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _sfx = AudioPlayer(playerId: 'sfx');
  final AudioPlayer _music = AudioPlayer(playerId: 'music');
  SharedPreferences? _prefs;
  bool _muted = false;
  bool _musicOn = false;

  static const _kMuted = 'ashina_muted';

  bool get muted => _muted;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _muted = _prefs?.getBool(_kMuted) ?? false;
    await _sfx.setReleaseMode(ReleaseMode.stop);
    await _music.setReleaseMode(ReleaseMode.loop);
    // Keep the ambient bed under the effects so it never overpowers.
    await _safe(() => _sfx.setVolume(0.9));
    await _safe(() => _music.setVolume(0.4));
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    await _prefs?.setBool(_kMuted, _muted);
    if (_muted) {
      await _safe(() => _music.stop());
    } else if (_musicOn) {
      await startMusic();
    }
  }

  void swipe() => _play('audio/sfx/swipe.wav');
  void death() => _play('audio/sfx/death.wav');
  void succeed() => _play('audio/sfx/succeed.wav');
  void tap() => _play('audio/sfx/tap.wav');

  Future<void> startMusic() async {
    _musicOn = true;
    if (_muted) return;
    await _safe(() => _music.play(AssetSource('audio/music/steppe.mp3')));
  }

  Future<void> stopMusic() async {
    _musicOn = false;
    await _safe(() => _music.stop());
  }

  void _play(String asset) {
    if (_muted) return;
    _safe(() => _sfx.play(AssetSource(asset)));
  }

  Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      // Missing asset or platform without audio — ignore.
      debugPrint('AudioService: $e');
    }
  }
}

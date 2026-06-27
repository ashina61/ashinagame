import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/metric.dart';
import 'settings.dart';

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
    await applyVolumes();
  }

  /// Push the current Settings volumes into the players (call after changes).
  Future<void> applyVolumes() async {
    await _safe(() => _sfx.setVolume(Settings.instance.sfxVolume));
    await _safe(() => _music.setVolume(Settings.instance.musicVolume));
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

  /// Event-specific commit sound based on the dominant pillar affected.
  void accent(Metric m) {
    switch (m) {
      case Metric.ordu:
        _play('audio/sfx/war.wav');
      case Metric.hazine:
        _play('audio/sfx/coin.wav');
      case Metric.tore:
        _play('audio/sfx/faith.wav');
      case Metric.halk:
        _play('audio/sfx/people.wav');
    }
  }

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

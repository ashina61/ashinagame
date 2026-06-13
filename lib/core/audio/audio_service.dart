import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central, fail-safe audio. Every call is wrapped so a missing file or an
/// unavailable audio platform (e.g. in widget tests) never crashes the game.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _music = AudioPlayer(playerId: 'ashina_music');
  final AudioPlayer _sfx = AudioPlayer(playerId: 'ashina_sfx');

  bool _musicOn = true;
  bool _sfxOn = true;
  String? _currentMusic;
  SharedPreferences? _prefs;

  bool get musicOn => _musicOn;
  bool get sfxOn => _sfxOn;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _musicOn = _prefs?.getBool('audio_music') ?? true;
      _sfxOn = _prefs?.getBool('audio_sfx') ?? true;
      await _music.setReleaseMode(ReleaseMode.loop);
    } catch (_) {
      // Audio is optional; ignore setup failures.
    }
  }

  Future<void> playSfx(String name) async {
    if (!_sfxOn) return;
    try {
      await _sfx.stop();
      await _sfx.play(AssetSource('audio/sfx/$name.mp3'));
    } catch (_) {}
  }

  Future<void> playMusic(String name) async {
    _currentMusic = name;
    if (!_musicOn) return;
    try {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.play(AssetSource('audio/music/$name.mp3'));
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    try {
      await _music.stop();
    } catch (_) {}
  }

  Future<void> setMusicOn(bool value) async {
    _musicOn = value;
    try {
      _prefs?.setBool('audio_music', value);
    } catch (_) {}
    if (value) {
      if (_currentMusic != null) await playMusic(_currentMusic!);
    } else {
      await stopMusic();
    }
  }

  Future<void> setSfxOn(bool value) async {
    _sfxOn = value;
    try {
      _prefs?.setBool('audio_sfx', value);
    } catch (_) {}
  }
}

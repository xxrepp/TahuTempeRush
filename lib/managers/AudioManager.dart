import 'package:flame_audio/flame_audio.dart';

/// Manages dynamic background music and sound effects
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  double _musicSpeed = 1.0;
  bool _isMusicPlaying = false;

  /// Initialize audio system
  Future<void> init() async {
    // Preload audio files (uncomment when assets are added)
    // await FlameAudio.audioCache.loadAll([
    //   'bgm.mp3',
    //   'tahu.mp3',
    //   'pecah.mp3',
    // ]);
    print('AudioManager initialized (assets not loaded - add to assets/ folder)');
  }

  /// Start background music
  Future<void> playBackgroundMusic() async {
    if (!_isMusicPlaying) {
      // TODO: Uncomment when bgm.mp3 is added to assets/audio/
      // await FlameAudio.bgm.play('bgm.mp3', volume: 0.5);
      _isMusicPlaying = true;
      _musicSpeed = 1.0;
      print('Background music started (placeholder)');
    }
  }

  /// Update music speed based on score milestones
  void updateMusicSpeed(int score) {
    // Increase speed by 0.1x every 500 points
    final speedIncrement = (score ~/ 500) * 0.1;
    final newSpeed = 1.0 + speedIncrement;
    
    if (newSpeed != _musicSpeed) {
      _musicSpeed = newSpeed;
      // TODO: Implement pitch/speed change when audio is integrated
      // This may require using audioplayers package with playback rate
      print('Music speed updated to ${_musicSpeed}x');
    }
  }

  /// Stop background music
  void stopBackgroundMusic() {
    // FlameAudio.bgm.stop();
    _isMusicPlaying = false;
    print('Background music stopped');
  }

  /// Play sound effect
  void playSFX(String soundName) {
    // TODO: Uncomment when SFX files are added
    // FlameAudio.play(soundName);
    print('Playing SFX: $soundName (placeholder)');
  }

  /// Play "Tahu" voice clip (throttled to prevent chaos)
  DateTime? _lastTahuSFX;
  void playTahuSpawnSFX() {
    final now = DateTime.now();
    if (_lastTahuSFX == null || 
        now.difference(_lastTahuSFX!).inMilliseconds > 500) {
      playSFX('tahu.mp3');
      _lastTahuSFX = now;
    }
  }

  /// Play "Pecah" (break) sound
  void playBreakSFX() {
    playSFX('pecah.mp3');
  }

  double get musicSpeed => _musicSpeed;

  void dispose() {
    stopBackgroundMusic();
  }
}

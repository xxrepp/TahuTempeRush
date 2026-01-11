import 'package:vibration/vibration.dart';

/// Wrapper for haptic feedback with device capability checking
class HapticManager {
  static final HapticManager _instance = HapticManager._internal();
  factory HapticManager() => _instance;
  HapticManager._internal();

  bool _hasVibrator = false;

  /// Check if device has vibration capability
  Future<void> init() async {
    _hasVibrator = await Vibration.hasVibrator() ?? false;
    print('Vibration available: $_hasVibrator');
  }

  /// Light vibration (for shooting)
  Future<void> light() async {
    if (_hasVibrator) {
      await Vibration.vibrate(duration: 50, amplitude: 64);
    }
  }

  /// Medium vibration (for enemy destroyed)
  Future<void> medium() async {
    if (_hasVibrator) {
      await Vibration.vibrate(duration: 100, amplitude: 128);
    }
  }

  /// Heavy vibration (for game over, nuke)
  Future<void> heavy() async {
    if (_hasVibrator) {
      await Vibration.vibrate(duration: 200, amplitude: 255);
    }
  }

  /// Pattern vibration (optional - for special effects)
  Future<void> pattern(List<int> pattern) async {
    if (_hasVibrator) {
      await Vibration.vibrate(pattern: pattern);
    }
  }
}

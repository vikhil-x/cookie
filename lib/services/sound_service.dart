import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      _isInitialized = true;
    } catch (e) {
      debugPrint('SoundService init error: $e');
    }
  }

  Future<void> playChime() async {
    try {
      // Trigger haptic vibration feedback
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.vibrate();

      // Play local sound asset
      await _player.stop();
      await _player.play(AssetSource('sounds/chime.wav'));
    } catch (e) {
      debugPrint('SoundService play error: $e');
      // Fallback to system alert sound
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
  }

  void dispose() {
    _player.dispose();
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static const String _soundEnabledKey =
      'notification_sound_enabled';

  // Check if notification sound is enabled
  static Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();

    // Default = ON
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  // Turn sound ON or OFF
  static Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _soundEnabledKey,
      enabled,
    );

    if (!enabled) {
      await stopSound();
    }
  }

  // Play notification sound
  static Future<void> playNotificationSound() async {
    try {
      final enabled = await isSoundEnabled();

      if (!enabled) {
        return;
      }

      await _audioPlayer.stop();

      await _audioPlayer.play(
        AssetSource(
          'sounds/notification.wav',
        ),
      );
    } catch (e) {
      // Ignore sound errors
    }
  }

  // Stop sound
  static Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      // Ignore stop errors
    }
  }

  // Dispose player
  static Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
// services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playNotificationSound() async {
    try {
      // ✅ استخدام Source.asset بشكل صحيح
      await _player.play(AssetSource('sounds/notification_sound.mp3'));
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }

  Future<void> playCompletionSound() async {
    try {
      await _player.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      print('Error playing completion sound: $e');
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}

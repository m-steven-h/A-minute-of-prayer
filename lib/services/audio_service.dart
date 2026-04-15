// services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  // ✅ صوت الإشعارات (اللي بيشتغل لما تجي notification)
  Future<void> playNotificationSound() async {
    try {
      await _player.play(AssetSource('sounds/notification_sound.mp3'));
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }

  // ✅ صوت إكمال اليوم (اللي بيشتغل لما تخلص يوم في طريق الصلاة)
  Future<void> playCompletionSound() async {
    try {
      await _player.play(AssetSource('sounds/completion_sound.mp3'));
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
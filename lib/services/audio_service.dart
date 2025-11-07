import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    await _tts.setLanguage('kk-KZ'); // Казахский язык
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _isInitialized = true;
  }

  static Future<void> speak(String text) async {
    await initialize();
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }

  static Future<void> pause() async {
    await _tts.pause();
  }

  static Future<bool> isSpeaking() async {
    return await _tts.isLanguageInstalled('kk-KZ') ?? false;
  }
}


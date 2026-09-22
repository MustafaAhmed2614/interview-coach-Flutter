import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isInitialized = false;

  static double _speechRate = 0.5;
  static String _language = 'en-US';

  static Future<void> initialize() async {
    if (_isInitialized) return;
    await _tts.setLanguage(_language);
    await _tts.setSpeechRate(_speechRate);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _isInitialized = true;
  }

  static Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }

  static Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _tts.setSpeechRate(rate);
  }

  static Future<void> setLanguage(String language) async {
    _language = language;
    await _tts.setLanguage(language);
  }

  static void setCompletionHandler(VoidCallback? handler) {
    _tts.setCompletionHandler(handler ?? () {});
  }

  static double get speechRate => _speechRate;
  static String get language => _language;
}

typedef VoidCallback = void Function();

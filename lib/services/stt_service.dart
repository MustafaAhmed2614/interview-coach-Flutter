import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttService {
  static final SpeechToText _speech = SpeechToText();
  static bool _isAvailable = false;

  static Future<bool> initialize() async {
    _isAvailable = await _speech.initialize(
      onError: (error) => debugPrint('STT Error: $error'),
      onStatus: (status) => debugPrint('STT Status: $status'),
    );
    return _isAvailable;
  }

  static Future<void> startListening({
    required void Function(String text) onResult,
    required void Function() onDone,
  }) async {
    if (!_isAvailable) await initialize();
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) onDone();
      },
      listenFor: const Duration(minutes: 3),
      pauseFor: const Duration(seconds: 5),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  static Future<void> stopListening() async {
    await _speech.stop();
  }

  static bool get isListening => _speech.isListening;
  static bool get isAvailable => _isAvailable;
}

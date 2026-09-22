import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/tts_service.dart';

class AppSettings {
  final double ttsSpeed;
  final String ttsLanguage;
  final bool autoPlayQuestion;
  final bool showTranscript;
  final bool isDarkMode;

  const AppSettings({
    this.ttsSpeed = 0.5,
    this.ttsLanguage = 'en-US',
    this.autoPlayQuestion = true,
    this.showTranscript = true,
    this.isDarkMode = true,
  });

  AppSettings copyWith({
    double? ttsSpeed,
    String? ttsLanguage,
    bool? autoPlayQuestion,
    bool? showTranscript,
    bool? isDarkMode,
  }) {
    return AppSettings(
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      ttsLanguage: ttsLanguage ?? this.ttsLanguage,
      autoPlayQuestion: autoPlayQuestion ?? this.autoPlayQuestion,
      showTranscript: showTranscript ?? this.showTranscript,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  static const _storage = FlutterSecureStorage();

  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final speed = await _storage.read(key: 'tts_speed');
    final lang = await _storage.read(key: 'tts_language');
    final autoPlay = await _storage.read(key: 'auto_play');
    final showT = await _storage.read(key: 'show_transcript');
    final dark = await _storage.read(key: 'dark_mode');

    state = AppSettings(
      ttsSpeed: speed != null ? double.parse(speed) : 0.5,
      ttsLanguage: lang ?? 'en-US',
      autoPlayQuestion: autoPlay != 'false',
      showTranscript: showT != 'false',
      isDarkMode: dark != 'false',
    );

    await TtsService.setSpeechRate(state.ttsSpeed);
    await TtsService.setLanguage(state.ttsLanguage);
  }

  Future<void> setTtsSpeed(double speed) async {
    state = state.copyWith(ttsSpeed: speed);
    await _storage.write(key: 'tts_speed', value: speed.toString());
    await TtsService.setSpeechRate(speed);
  }

  Future<void> setTtsLanguage(String language) async {
    state = state.copyWith(ttsLanguage: language);
    await _storage.write(key: 'tts_language', value: language);
    await TtsService.setLanguage(language);
  }

  Future<void> setAutoPlay(bool value) async {
    state = state.copyWith(autoPlayQuestion: value);
    await _storage.write(key: 'auto_play', value: value.toString());
  }

  Future<void> setShowTranscript(bool value) async {
    state = state.copyWith(showTranscript: value);
    await _storage.write(key: 'show_transcript', value: value.toString());
  }

  Future<void> setDarkMode(bool value) async {
    state = state.copyWith(isDarkMode: value);
    await _storage.write(key: 'dark_mode', value: value.toString());
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
      (ref) => SettingsNotifier(),
    );

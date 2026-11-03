import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  FlutterTts? _flutterTts;
  bool _isMuted = false;
  bool _isInitialized = false;

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  void setMuted(bool muted) {
    _isMuted = muted;
  }

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _flutterTts = FlutterTts();
      await _flutterTts!.setLanguage("zh-TW");
      await _flutterTts!.setSpeechRate(0.5); // 稍微沉穩清晰的語速
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (_isMuted) return;
    try {
      if (!_isInitialized) {
        await init();
      }
      if (_flutterTts != null) {
        await _flutterTts!.stop();
        await _flutterTts!.speak(text);
      }
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      if (_flutterTts != null) {
        await _flutterTts!.stop();
      }
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }
}

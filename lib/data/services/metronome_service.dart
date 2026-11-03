import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// 110 BPM CPR 按壓音訊節拍器服務
class MetronomeService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _ticker;
  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  static const int bpm = 110;
  static const int intervalMs = 60000 ~/ bpm; // 約 545 毫秒一次

  MetronomeService() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setSource(AssetSource('sounds/metronome_click.wav'));
      await _audioPlayer.setVolume(1.0);
    } catch (e) {
      debugPrint('MetronomeService init error: $e');
    }
  }

  void toggleMetronome(bool activeCprRunning) {
    _isEnabled = !_isEnabled;
    if (_isEnabled && activeCprRunning) {
      start();
    } else {
      stop();
    }
  }

  void start() {
    if (!_isEnabled) return;
    _ticker?.cancel();
    _playTick();
    _ticker = Timer.periodic(const Duration(milliseconds: intervalMs), (_) {
      _playTick();
    });
  }

  void pause() {
    _ticker?.cancel();
  }

  void stop() {
    _ticker?.cancel();
  }

  void _playTick() {
    try {
      // 觸發音效與輕觸覺脈衝
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.resume();
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  void dispose() {
    _ticker?.cancel();
    _audioPlayer.dispose();
  }
}

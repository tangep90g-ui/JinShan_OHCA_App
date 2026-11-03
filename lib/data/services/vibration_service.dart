import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class VibrationService {
  static final VibrationService _instance = VibrationService._internal();
  factory VibrationService() => _instance;
  VibrationService._internal();

  bool _isVibrationEnabled = true;

  bool get isVibrationEnabled => _isVibrationEnabled;

  void toggleVibration() {
    _isVibrationEnabled = !_isVibrationEnabled;
  }

  Future<void> lightFeedback() async {
    if (!_isVibrationEnabled) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> warningFeedback() async {
    if (!_isVibrationEnabled) return;
    try {
      final hasCustomVibrations = await Vibration.hasCustomVibrationsSupport();
      if (hasCustomVibrations == true) {
        // 震動 200ms, 停 100ms, 震動 200ms
        await Vibration.vibrate(pattern: [0, 200, 100, 200]);
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (_) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> urgentFeedback() async {
    if (!_isVibrationEnabled) return;
    try {
      final hasCustomVibrations = await Vibration.hasCustomVibrationsSupport();
      if (hasCustomVibrations == true) {
        // 三連震，強烈警示
        await Vibration.vibrate(pattern: [0, 500, 150, 500, 150, 500]);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (_) {
      HapticFeedback.heavyImpact();
    }
  }
}

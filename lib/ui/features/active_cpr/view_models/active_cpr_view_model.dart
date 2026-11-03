import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'package:hsinchu_ohca_app/data/repositories/session_repository.dart';
import 'package:hsinchu_ohca_app/data/services/line_report_formatter.dart';
import 'package:hsinchu_ohca_app/data/services/tts_service.dart';
import 'package:hsinchu_ohca_app/data/services/vibration_service.dart';
import 'package:hsinchu_ohca_app/domain/engine/ohca_decision_engine.dart';
import 'package:hsinchu_ohca_app/domain/models/cpr_event.dart';
import 'package:hsinchu_ohca_app/domain/models/decision_guidance.dart';
import 'package:hsinchu_ohca_app/domain/models/ohca_session.dart';
import 'package:hsinchu_ohca_app/domain/models/rhythm_type.dart';

class ActiveCprViewModel extends ChangeNotifier {
  final SessionRepository _repository;
  final TtsService _tts = TtsService();
  final VibrationService _vibration = VibrationService();

  ActiveCprViewModel({SessionRepository? repository})
      : _repository = repository ?? SessionRepository() {
    _initSession();
  }

  static const int cprCycleDuration = 120; // 2 分鐘 (秒)
  static const int epiIntervalDuration = 240; // 4 分鐘 (秒)

  late OhcaSession _session;
  OhcaSession get session => _session;

  Timer? _timer;
  int _cycleSecondsRemaining = cprCycleDuration;
  int get cycleSecondsRemaining => _cycleSecondsRemaining;

  int _currentCycle = 1;
  int get currentCycle => _currentCycle;

  int _totalElapsedSeconds = 0;
  int get totalElapsedSeconds => _totalElapsedSeconds;

  int? _epiSecondsRemaining;
  int? get epiSecondsRemaining => _epiSecondsRemaining;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  bool get isMuted => _tts.isMuted;
  bool get isVibrationEnabled => _vibration.isVibrationEnabled;

  DecisionGuidance _guidance = const DecisionGuidance(
    primaryTitle: '等待開始急救',
    primaryDetail: '點擊下方「開始 CPR」即刻啟動 2 分鐘循環計時與決策輔助',
    secondaryAction: '準備 AED/去顫器、BVM、建立 IV/IO 通路',
  );
  DecisionGuidance get guidance => _guidance;

  void _initSession() {
    final now = DateTime.now();
    _session = OhcaSession(
      id: const Uuid().v4(),
      startTime: now,
      squadName: '金山分隊',
      patientContactTime: now,
    );
    _updateGuidance();
  }

  void toggleMute() {
    _tts.toggleMute();
    notifyListeners();
  }

  void toggleVibration() {
    _vibration.toggleVibration();
    notifyListeners();
  }

  void startCpr() {
    if (_isRunning) return;
    final now = DateTime.now();
    _isRunning = true;
    _isPaused = false;
    _session.cprStartTime ??= now;

    _addEvent(
      type: EventType.cprStart,
      title: '開始 CPR',
      details: '第 1 循環開始 (速率 100-120bpm)',
    );

    _tts.speak('開始CPR，第1循環計時啟動');
    _vibration.lightFeedback();

    _startTimer();
    _updateGuidance();
    notifyListeners();
  }

  void pauseCpr() {
    if (!_isRunning || _isPaused) return;
    _isPaused = true;
    _addEvent(
      type: EventType.cprPause,
      title: '暫停按壓',
      details: '按壓中斷',
    );
    _vibration.warningFeedback();
    _updateGuidance();
    notifyListeners();
  }

  void resumeCpr() {
    if (!_isRunning || !_isPaused) return;
    _isPaused = false;
    _addEvent(
      type: EventType.cprResume,
      title: '恢復按壓',
      details: '繼續第 $_currentCycle 循環',
    );
    _vibration.lightFeedback();
    _tts.speak('恢復按壓');
    _updateGuidance();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning || _isPaused) return;

      _totalElapsedSeconds++;
      if (_session.isLucasUsed) {
        _session.lucasSeconds++;
      }

      // 倒數 2 分鐘，若歸零後繼續累計超時秒數
      _cycleSecondsRemaining--;

      // Epinephrine 倒數計時
      if (_epiSecondsRemaining != null && _epiSecondsRemaining! > 0) {
        _epiSecondsRemaining = _epiSecondsRemaining! - 1;
      }

      // 關鍵時間節點提醒 (T-30s, T-0s, 以及超時每 30 秒提醒)
      if (_cycleSecondsRemaining == 30) {
        _tts.speak('注意，距離下次分析心律剩 30 秒，請準備換手');
        _vibration.warningFeedback();
      } else if (_cycleSecondsRemaining == 0) {
        _tts.speak('2分鐘循環時間已到，請下達停止按壓分析心律指令');
        _vibration.urgentFeedback();
      } else if (_cycleSecondsRemaining < 0 && _cycleSecondsRemaining % 30 == 0) {
        final overtimeSec = -_cycleSecondsRemaining;
        _tts.speak('CPR 已超時 $overtimeSec 秒，請下達分析心律指令');
        _vibration.urgentFeedback();
      }

      if (_epiSecondsRemaining == 30) {
        _tts.speak('Epinephrine 剩 30 秒可給予');
        _vibration.lightFeedback();
      } else if (_epiSecondsRemaining == 0) {
        _tts.speak('可下達下一劑 Epinephrine 指令');
        _vibration.warningFeedback();
      }

      _updateGuidance();
      notifyListeners();
    });
  }

  /// Leader 下達換手或進入下一循環按壓指令
  void startNextCycleUponCommand() {
    _currentCycle++;
    _cycleSecondsRemaining = cprCycleDuration;
    _isPaused = false;
    _isRunning = true;

    _addEvent(
      type: EventType.cprResume,
      title: '指令下達：開始第 $_currentCycle 循環 CPR',
      details: 'Leader 下達按壓指令，重置啟動 2 分鐘倒數',
      cycleNumber: _currentCycle,
    );

    _tts.speak('指令下達，第 $_currentCycle 循環 CPR 倒數啟動');
    _vibration.lightFeedback();
    _startTimer();
    _updateGuidance();
    notifyListeners();
  }

  /// Leader 聽到現場 AED 分析指令時按下記錄
  void recordRhythmAnalysis(RhythmType rhythm) {
    // 現場分析心律時，立即暫停 CPR 壓胸計時
    _isPaused = true;

    _addEvent(
      type: EventType.rhythmAnalysis,
      title: '現場分析心律：${rhythm.displayName}',
      details: 'Leader 記錄現場 AED/監視器分析波形',
      rhythm: rhythm,
      cycleNumber: _currentCycle,
    );

    if (rhythm.isShockable) {
      _tts.speak('${rhythm.shortName}，建議電擊，充電中請繼續按壓');
      _vibration.urgentFeedback();
    } else if (rhythm == RhythmType.rosc) {
      recordRosc();
    } else {
      _tts.speak('${rhythm.shortName}，不建議電擊，請下達立即恢復按壓指令');
      _vibration.warningFeedback();
    }

    _updateGuidance();
    notifyListeners();
  }

  /// Leader 現場確認安全並按下電擊後點擊記錄
  void recordDefibrillation(int joules) {
    final shockNum = _session.totalShocks + 1;
    final now = DateTime.now();
    _session.firstShockTime ??= now;

    // 記錄精確電擊時間戳記
    _addEvent(
      type: EventType.defibrillation,
      title: '現場執行電擊第 $shockNum 次 ($joules J)',
      details: 'Leader 確認現場電擊執行，雙相波 $joules 焦耳',
      energyJoules: joules,
      countNumber: shockNum,
      cycleNumber: _currentCycle,
    );

    _tts.speak('第 $shockNum 次電擊已記錄，請立即下達恢復按壓指令！');
    _vibration.urgentFeedback();

    // 依據使用者需求：不自動開始計時，等待 Leader 下達「恢復按壓」後啟動下一循環
    _updateGuidance();
    notifyListeners();
  }

  /// Leader 現場下達給藥指令後記錄
  void recordEpinephrine() {
    final epiNum = _session.totalEpi + 1;
    _epiSecondsRemaining = epiIntervalDuration; // 從指令下達當刻啟動 4 分鐘倒數

    _addEvent(
      type: EventType.epinephrine,
      title: '指令下達：給予 Epinephrine 第 $epiNum 劑 (1mg)',
      details: 'Leader 下達推藥指令，啟動 4 分鐘倒數計時',
      medicationDose: 1.0,
      countNumber: epiNum,
      cycleNumber: _currentCycle,
    );

    _tts.speak('已記錄第 $epiNum 劑 Epinephrine，啟動4分鐘計時');
    _vibration.lightFeedback();
    _updateGuidance();
    notifyListeners();
  }

  void recordAmiodarone(double doseMg) {
    final count = _session.totalAmiodarone + 1;
    _addEvent(
      type: EventType.amiodarone,
      title: '給予 Amiodarone 第 $count 劑 (${doseMg.toInt()}mg)',
      details: '靜脈/骨針快速推注',
      medicationDose: doseMg,
      countNumber: count,
      cycleNumber: _currentCycle,
    );

    _tts.speak('已記錄 Amiodarone ${doseMg.toInt()} 毫克');
    _vibration.lightFeedback();
    _updateGuidance();
    notifyListeners();
  }

  void recordLidocaine(double doseMg) {
    final count = _session.totalLidocaine + 1;
    _addEvent(
      type: EventType.lidocaine,
      title: '給予 Lidocaine 第 $count 劑 (${doseMg.toStringAsFixed(1)}mg)',
      medicationDose: doseMg,
      countNumber: count,
      cycleNumber: _currentCycle,
    );

    _tts.speak('已記錄 Lidocaine');
    _vibration.lightFeedback();
    _updateGuidance();
    notifyListeners();
  }

  void toggleLucas() {
    _session.isLucasUsed = !_session.isLucasUsed;
    if (_session.isLucasUsed) {
      _addEvent(
        type: EventType.lucasStart,
        title: 'LUCAS 機械心肺復甦機上機',
        details: '啟動機械按壓，頻率 102 次/分',
      );
      _tts.speak('LUCAS 上機開始按壓');
    } else {
      _addEvent(
        type: EventType.lucasStop,
        title: 'LUCAS 暫停/停機',
        details: '轉為徒手按壓或停止',
      );
      _tts.speak('LUCAS 停機');
    }
    _vibration.warningFeedback();
    _updateGuidance();
    notifyListeners();
  }

  void recordAirway({
    required String type,
    required String size,
    bool isVideoLaryngoscope = false,
    int? depthCm,
  }) {
    final vlText = isVideoLaryngoscope ? ' (使用視訊喉頭鏡)' : '';
    final depthText = depthCm != null ? '，固定 $depthCm cm' : '';
    final summary = '$type $size$vlText$depthText';
    _session.airwaySummary = summary;

    _addEvent(
      type: EventType.airway,
      title: '呼吸道建立：$type $size',
      details: '$summary，接上 BVM 與 ETCO2',
    );

    _tts.speak('已記錄呼吸道處置');
    _vibration.lightFeedback();
    _updateGuidance();
    notifyListeners();
  }

  void recordVascularAccess({required String type, required String site}) {
    final summary = '$type ($site)';
    _session.vascularSummary = summary;

    _addEvent(
      type: EventType.vascularAccess,
      title: '建立血管通路：$summary',
      details: '輸液順暢，可供推藥',
    );

    _tts.speak('已建立 $type 通路');
    _vibration.lightFeedback();
    _updateGuidance();
    notifyListeners();
  }

  void recordEtco2(double value) {
    final previous = _session.latestEtco2;
    _session.latestEtco2 = value;

    _addEvent(
      type: EventType.etco2,
      title: 'ETCO2 數值：${value.toStringAsFixed(0)} mmHg',
      details: '呼氣末二氧化碳連續監測',
    );

    // 突升警示 (Δ > 15 或直接 > 40)
    if (previous != null && (value - previous >= 15 || value >= 40)) {
      _tts.speak('注意！ETCO2 數值顯著回升至 ${value.toInt()}，請評估是否恢復自主循環！');
      _vibration.urgentFeedback();
    } else {
      _tts.speak('ETCO2 ${value.toInt()}');
    }

    _updateGuidance();
    notifyListeners();
  }

  void recordRosc() {
    _session.roscTime = DateTime.now();
    _addEvent(
      type: EventType.rosc,
      title: '🌟 恢復自發循環 (ROSC)',
      details: '捫及頸動脈博動，ETCO2 升高',
    );

    _tts.speak('評估自發循環已恢復，ROSC！請持續監測生命徵象');
    _vibration.urgentFeedback();
    _updateGuidance();
    notifyListeners();
  }

  void recordTransport() {
    _session.transportStartTime = DateTime.now();
    _addEvent(
      type: EventType.transportStart,
      title: '🚑 上車出發送醫',
      details: '後送醫院：${_session.hospitalName}',
    );
    _tts.speak('出發送醫');
    _vibration.lightFeedback();
    notifyListeners();
  }

  void recordHospitalArrival() {
    _session.hospitalArrivalTime = DateTime.now();
    _addEvent(
      type: EventType.hospitalArrival,
      title: '🏥 抵達醫院交接',
      details: '抵達 ${_session.hospitalName} 急診室',
    );
    _tts.speak('抵達醫院交接');
    _vibration.lightFeedback();
    notifyListeners();
  }

  void recordTermination() {
    _session.terminationTime = DateTime.now();
    _addEvent(
      type: EventType.termination,
      title: '停止急救處置',
      details: '現場終止急救或簽署 DNR',
    );
    _tts.speak('急救停止');
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void _addEvent({
    required EventType type,
    required String title,
    String details = '',
    int? cycleNumber,
    RhythmType? rhythm,
    int? energyJoules,
    double? medicationDose,
    int? countNumber,
  }) {
    final event = CprEvent(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      type: type,
      title: title,
      details: details,
      cycleNumber: cycleNumber ?? _currentCycle,
      rhythm: rhythm,
      energyJoules: energyJoules,
      medicationDose: medicationDose,
      countNumber: countNumber,
    );
    _session.events.add(event);
    _repository.saveActiveSession(_session);
  }

  void _updateGuidance() {
    _guidance = OhcaDecisionEngine.evaluate(
      session: _session,
      cycleSecondsRemaining: _cycleSecondsRemaining,
      currentCycle: _currentCycle,
      epiSecondsRemaining: _epiSecondsRemaining,
      isPaused: _isPaused,
    );
  }

  String getLineReportText() {
    return LineReportFormatter.generateReport(_session);
  }

  Future<void> copyLineReportToClipboard() async {
    final text = getLineReportText();
    await Clipboard.setData(ClipboardData(text: text));
    _vibration.lightFeedback();
  }

  Future<void> archiveCurrentCase() async {
    await startNewCase(archiveCurrent: true);
  }

  Future<void> endCaseAndArchive({
    required String outcome,
    String? note,
    bool startNewImmediately = false,
  }) async {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;

    final now = DateTime.now();
    EventType eventType = EventType.note;

    if (outcome.contains('ROSC')) {
      _session.roscTime ??= now;
      eventType = EventType.rosc;
    } else if (outcome.contains('終止') || outcome.contains('TOR')) {
      _session.terminationTime = now;
      eventType = EventType.termination;
    } else if (outcome.contains('急診') || outcome.contains('抵達')) {
      _session.hospitalArrivalTime ??= now;
      eventType = EventType.hospitalArrival;
    }

    _addEvent(
      type: eventType,
      title: '🏁 結束案件：$outcome',
      details: note ?? '',
    );

    await _repository.archiveSession(_session);

    if (startNewImmediately) {
      _initSession();
      _cycleSecondsRemaining = cprCycleDuration;
      _totalElapsedSeconds = 0;
      _currentCycle = 1;
      _epiSecondsRemaining = null;
    }

    notifyListeners();
  }

  Future<void> startNewCase({bool archiveCurrent = true}) async {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;

    if (archiveCurrent && _session.events.isNotEmpty) {
      await _repository.archiveSession(_session);
    } else {
      await _repository.clearActiveSession();
    }

    _initSession();
    _cycleSecondsRemaining = cprCycleDuration;
    _totalElapsedSeconds = 0;
    _currentCycle = 1;
    _epiSecondsRemaining = null;
    notifyListeners();
  }

  Future<List<OhcaSession>> getHistorySessions() async {
    return await _repository.getHistorySessions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hsinchu_ohca_app/domain/engine/ohca_decision_engine.dart';
import 'package:hsinchu_ohca_app/domain/models/cpr_event.dart';
import 'package:hsinchu_ohca_app/domain/models/decision_guidance.dart';
import 'package:hsinchu_ohca_app/domain/models/ohca_session.dart';
import 'package:hsinchu_ohca_app/domain/models/rhythm_type.dart';

void main() {
  group('OhcaDecisionEngine Tests', () {
    test('應在倒數歸零時提示2分鐘已滿並等待Leader下達分析心律指令', () {
      final session = OhcaSession(id: 'test-1', startTime: DateTime.now());
      final guidance = OhcaDecisionEngine.evaluate(
        session: session,
        cycleSecondsRemaining: 0,
        currentCycle: 1,
        epiSecondsRemaining: 180,
        isPaused: false,
      );

      expect(guidance.urgency, equals(GuidanceUrgency.critical));
      expect(guidance.primaryTitle, contains('2分鐘已滿'));
      expect(guidance.voiceAnnouncement, contains('分析心律'));
    });

    test('應在剩餘30秒時提示準備換手', () {
      final session = OhcaSession(id: 'test-2', startTime: DateTime.now());
      final guidance = OhcaDecisionEngine.evaluate(
        session: session,
        cycleSecondsRemaining: 30,
        currentCycle: 1,
        epiSecondsRemaining: 120,
        isPaused: false,
      );

      expect(guidance.urgency, equals(GuidanceUrgency.warning));
      expect(guidance.primaryTitle, contains('30 秒'));
    });

    test('電擊剛執行後應立即提示 Leader 下達恢復按壓指令', () {
      final session = OhcaSession(id: 'test-shock', startTime: DateTime.now());
      session.events.add(CprEvent(
        id: 'e1',
        timestamp: DateTime.now(),
        type: EventType.defibrillation,
        title: '現場執行電擊',
        energyJoules: 200,
      ));

      final guidance = OhcaDecisionEngine.evaluate(
        session: session,
        cycleSecondsRemaining: 120,
        currentCycle: 1,
        epiSecondsRemaining: 100,
        isPaused: true,
      );

      expect(guidance.primaryTitle, contains('電擊已完成！請下達「立即恢復按壓」'));
      expect(guidance.urgency, equals(GuidanceUrgency.critical));
    });

    test('VF 且兩次電擊恢復按壓後應建議 Amiodarone 300mg', () {
      final session = OhcaSession(id: 'test-3', startTime: DateTime.now());
      session.events.add(CprEvent(
        id: 'e1',
        timestamp: DateTime.now(),
        type: EventType.rhythmAnalysis,
        title: 'VF',
        rhythm: RhythmType.vf,
      ));
      session.events.add(CprEvent(
        id: 'e2',
        timestamp: DateTime.now(),
        type: EventType.defibrillation,
        title: '電擊1',
        energyJoules: 200,
      ));
      session.events.add(CprEvent(
        id: 'e3',
        timestamp: DateTime.now(),
        type: EventType.defibrillation,
        title: '電擊2',
        energyJoules: 200,
      ));
      // Leader 下達恢復按壓
      session.events.add(CprEvent(
        id: 'e4',
        timestamp: DateTime.now(),
        type: EventType.cprResume,
        title: '恢復按壓',
      ));

      final guidance = OhcaDecisionEngine.evaluate(
        session: session,
        cycleSecondsRemaining: 90,
        currentCycle: 2,
        epiSecondsRemaining: 100,
        isPaused: false,
      );

      expect(guidance.primaryDetail, contains('Amiodarone 300mg'));
    });

    test('不可電擊心律 PEA 應優先提示給予 Epinephrine 與 4H4T', () {
      final session = OhcaSession(id: 'test-4', startTime: DateTime.now());
      session.events.add(CprEvent(
        id: 'e1',
        timestamp: DateTime.now(),
        type: EventType.rhythmAnalysis,
        title: 'PEA',
        rhythm: RhythmType.pea,
      ));

      final guidance = OhcaDecisionEngine.evaluate(
        session: session,
        cycleSecondsRemaining: 80,
        currentCycle: 1,
        epiSecondsRemaining: null,
        isPaused: false,
      );

      expect(guidance.primaryTitle, contains('Epinephrine'));
      expect(guidance.secondaryAction, contains('4H4T'));
    });

    test('ROSC 時應轉為自發循環恢復狀態', () {
      final session = OhcaSession(
        id: 'test-5',
        startTime: DateTime.now(),
        roscTime: DateTime.now(),
      );

      final guidance = OhcaDecisionEngine.evaluate(
        session: session,
        cycleSecondsRemaining: 60,
        currentCycle: 3,
        epiSecondsRemaining: null,
        isPaused: false,
      );

      expect(guidance.urgency, equals(GuidanceUrgency.rosc));
      expect(guidance.primaryTitle, contains('ROSC'));
    });
  });
}

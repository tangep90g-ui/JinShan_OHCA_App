import 'package:flutter_test/flutter_test.dart';
import 'package:hsinchu_ohca_app/data/services/line_report_formatter.dart';
import 'package:hsinchu_ohca_app/domain/models/cpr_event.dart';
import 'package:hsinchu_ohca_app/domain/models/ohca_session.dart';

void main() {
  group('LineReportFormatter Tests', () {
    test('應正確產生新竹市救護格式的文字報告', () {
      final now = DateTime(2026, 10, 31, 9, 15, 0);
      final session = OhcaSession(
        id: 'case-test-1',
        startTime: now,
        squadName: '金山分隊',
        emtNames: '陳同仁、李同仁',
        hospitalName: '新竹台大分院',
        patientGender: '男',
        patientAge: '65',
        patientContactTime: now,
        cprStartTime: now.add(const Duration(seconds: 15)),
        firstShockTime: now.add(const Duration(minutes: 1)),
        isLucasUsed: true,
        lucasSeconds: 420,
        airwaySummary: 'SGA (i-gel) #4',
        vascularSummary: 'EZ-IO 骨內針 (右側近端脛骨)',
        latestEtco2: 36,
      );

      session.events.add(CprEvent(
        id: 'e1',
        timestamp: now.add(const Duration(seconds: 15)),
        type: EventType.cprStart,
        title: '開始 CPR',
      ));
      session.events.add(CprEvent(
        id: 'e2',
        timestamp: now.add(const Duration(minutes: 1)),
        type: EventType.defibrillation,
        title: '去顫電擊 (200J)',
        energyJoules: 200,
      ));
      session.events.add(CprEvent(
        id: 'e3',
        timestamp: now.add(const Duration(minutes: 2)),
        type: EventType.epinephrine,
        title: '給予 Epinephrine 1mg',
        medicationDose: 1.0,
      ));

      final report = LineReportFormatter.generateReport(session);

      expect(report, contains('【新竹市消防局 OHCA 現場急救紀錄】'));
      expect(report, contains('出勤單位：金山分隊'));
      expect(report, contains('救護人員：陳同仁、李同仁'));
      expect(report, contains('後送醫院：新竹台大分院'));
      expect(report, contains('LUCAS 機械按壓：已使用'));
      expect(report, contains('SGA (i-gel) #4'));
      expect(report, contains('EZ-IO 骨內針'));
      expect(report, contains('去顫電擊：共 1 次'));
      expect(report, contains('Epinephrine 1mg：共 1 劑'));
    });
  });
}

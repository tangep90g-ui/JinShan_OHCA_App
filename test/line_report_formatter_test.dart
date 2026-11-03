import 'package:flutter_test/flutter_test.dart';
import 'package:hsinchu_ohca_app/data/services/line_report_formatter.dart';
import 'package:hsinchu_ohca_app/domain/models/cpr_event.dart';
import 'package:hsinchu_ohca_app/domain/models/ohca_session.dart';

void main() {
  group('LineReportFormatter Tests', () {
    test('應正確產生金山分隊標準格式的文字報告', () {
      final now = DateTime(2026, 9, 3, 20, 51, 0);
      final session = OhcaSession(
        id: 'case-test-1',
        startTime: now,
        squadName: '金山91',
        location: '新竹市東區慈雲路O號',
        patientName: '馬O倫',
        patientGender: '男',
        patientAge: '17',
        caseStory: '現場患者無意識、無呼吸、無脈搏，立即實施急救處置。',
        medicalHistory: '精神疾病',
        allergyHistory: '無',
        emtNames: '金山 李心廷（T2)\n金山 張涵淇（T2)\n金山志工 湯宗達（T1)',
        hospitalName: '國軍新竹醫院',
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

      expect(report, contains('金山分隊報告'));
      expect(report, contains('1.出勤時間：9月3日20時51分'));
      expect(report, contains('2.單位：金山91'));
      expect(report, contains('3.救護類別：OHCA-救護'));
      expect(report, contains('4.地點：新竹市東區慈雲路O號'));
      expect(report, contains('5.患者：馬O倫，男性，17歲'));
      expect(report, contains('6.案情：'));
      expect(report, contains('7.過去病史：精神疾病。'));
      expect(report, contains('  過敏史：無。'));
      expect(report, contains('8.出勤人員：'));
      expect(report, contains('金山 李心廷（T2)'));
      expect(report, contains('LUCAS 機械按壓：已使用'));
      expect(report, contains('SGA (i-gel) #4'));
      expect(report, contains('EZ-IO 骨內針'));
      expect(report, contains('去顫電擊：共 1 次'));
      expect(report, contains('Epinephrine 1mg：共 1 劑'));
    });
  });
}

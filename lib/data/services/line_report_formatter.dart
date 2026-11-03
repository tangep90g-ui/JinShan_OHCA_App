import 'package:intl/intl.dart';
import 'package:hsinchu_ohca_app/domain/models/cpr_event.dart';
import 'package:hsinchu_ohca_app/domain/models/ohca_session.dart';

class LineReportFormatter {
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');
  static final DateFormat _chineseDateFormat = DateFormat('M月d日HH時mm分');

  static String generateReport(OhcaSession session) {
    final buffer = StringBuffer();
    final dispatchTimeStr = _chineseDateFormat.format(session.startTime);

    // 1~5 項次
    buffer.writeln('金山分隊報告');
    buffer.writeln('1.出勤時間：$dispatchTimeStr');
    buffer.writeln('2.單位：${session.squadName.isNotEmpty ? session.squadName : "金山91"}');
    buffer.writeln('3.救護類別：OHCA-救護');
    buffer.writeln('4.地點：${session.location.isNotEmpty ? session.location : "新竹市東區"}');

    // 患者資訊格式化: 馬O倫，男性，17歲
    final pName = session.patientName.isNotEmpty ? session.patientName : '患者';
    final pGender = session.patientGender.isNotEmpty ? '${session.patientGender}性' : '性別不詳';
    final pAge = session.patientAge.isNotEmpty ? '${session.patientAge}歲' : '年齡不詳';
    buffer.writeln('5.患者：$pName，$pGender，$pAge');

    // 6. 案情
    buffer.writeln('6.案情：');
    if (session.caseStory.isNotEmpty) {
      buffer.writeln(session.caseStory);
    } else {
      buffer.writeln('現場患者無意識、無呼吸、無脈搏，立即實施 CPR 及各項急救處置。');
    }
    buffer.writeln();

    buffer.writeln('【⏱️ 現場急救處置與時間鏈】');
    if (session.patientContactTime != null) {
      buffer.writeln(
          '- 接觸患者：${_timeFormat.format(session.patientContactTime!)}');
    }
    if (session.cprStartTime != null) {
      buffer.writeln('- 開始CPR：${_timeFormat.format(session.cprStartTime!)}');
    }
    if (session.firstShockTime != null) {
      buffer.writeln('- 首次電擊：${_timeFormat.format(session.firstShockTime!)}');
    }
    if (session.transportStartTime != null) {
      buffer.writeln(
          '- 送醫出發：${_timeFormat.format(session.transportStartTime!)}');
    }
    if (session.hospitalArrivalTime != null) {
      buffer.writeln(
          '- 抵達醫院：${_timeFormat.format(session.hospitalArrivalTime!)}');
    }
    if (session.roscTime != null) {
      buffer.writeln(
          '- 恢復循環 (ROSC)：${_timeFormat.format(session.roscTime!)} 🌟');
    } else if (session.terminationTime != null) {
      buffer.writeln(
          '- 停止急救：${_timeFormat.format(session.terminationTime!)}');
    }
    buffer.writeln();

    buffer.writeln('【⚡ 處置統計摘要】');
    // CPR & LUCAS
    final cprDuration = (session.terminationTime ??
            session.roscTime ??
            session.hospitalArrivalTime ??
            DateTime.now())
        .difference(session.cprStartTime ?? session.startTime);
    final minutes = cprDuration.inMinutes;
    final seconds = cprDuration.inSeconds % 60;
    buffer.writeln('- CPR 總歷時：${minutes}分${seconds}秒');
    if (session.isLucasUsed) {
      final lMin = session.lucasSeconds ~/ 60;
      final lSec = session.lucasSeconds % 60;
      buffer.writeln('- LUCAS 機械按壓：已使用 (運轉歷時約 ${lMin}分${lSec}秒)');
    }

    // 電擊次數
    final shockEvents =
        session.events.where((e) => e.type == EventType.defibrillation).toList();
    if (shockEvents.isNotEmpty) {
      final shockDetails = shockEvents
          .map((e) =>
              '${_timeFormat.format(e.timestamp)}(${e.energyJoules ?? 200}J)')
          .join('、');
      buffer.writeln('- 去顫電擊：共 ${shockEvents.length} 次 [$shockDetails]');
    } else {
      buffer.writeln('- 去顫電擊：0 次 (非可電擊心律)');
    }

    // 藥物紀錄
    final epiEvents =
        session.events.where((e) => e.type == EventType.epinephrine).toList();
    if (epiEvents.isNotEmpty) {
      final epiTimes =
          epiEvents.map((e) => _timeFormat.format(e.timestamp)).join('、');
      buffer.writeln(
          '- Epinephrine 1mg：共 ${epiEvents.length} 劑 [$epiTimes]');
    }

    final amioEvents =
        session.events.where((e) => e.type == EventType.amiodarone).toList();
    if (amioEvents.isNotEmpty) {
      final amioDetails = amioEvents
          .map((e) =>
              '${_timeFormat.format(e.timestamp)}(${e.medicationDose?.toInt() ?? 300}mg)')
          .join('、');
      buffer.writeln('- Amiodarone：共 ${amioEvents.length} 劑 [$amioDetails]');
    }

    final lidoEvents =
        session.events.where((e) => e.type == EventType.lidocaine).toList();
    if (lidoEvents.isNotEmpty) {
      final lidoDetails = lidoEvents
          .map((e) =>
              '${_timeFormat.format(e.timestamp)}(${e.medicationDose ?? 100}mg)')
          .join('、');
      buffer.writeln('- Lidocaine：共 ${lidoEvents.length} 劑 [$lidoDetails]');
    }

    // 呼吸道
    if (session.airwaySummary != null && session.airwaySummary!.isNotEmpty) {
      buffer.writeln('- 呼吸道處置：${session.airwaySummary}');
    }
    if (session.latestEtco2 != null) {
      buffer.writeln('- ETCO2 最新數值：${session.latestEtco2!.toStringAsFixed(0)} mmHg');
    }

    // 血管通路
    if (session.vascularSummary != null && session.vascularSummary!.isNotEmpty) {
      buffer.writeln('- 建立通路：${session.vascularSummary}');
    }

    // 送往醫院總結
    final unitName = session.squadName.isNotEmpty ? session.squadName : '91';
    buffer.writeln('${unitName}人員持續急救後送往${session.hospitalName}急診室交接。');
    buffer.writeln();

    // 7. 過去病史與過敏史
    final medHist = session.medicalHistory.isNotEmpty ? session.medicalHistory : '不詳';
    final allergyHist = session.allergyHistory.isNotEmpty ? session.allergyHistory : '無';
    buffer.writeln('7.過去病史：$medHist。');
    buffer.writeln('  過敏史：$allergyHist。');

    // 8. 出勤人員
    buffer.writeln('8.出勤人員：');
    if (session.emtNames.isNotEmpty) {
      buffer.writeln(session.emtNames);
    } else {
      buffer.writeln('(出勤人員未輸入)');
    }

    buffer.writeln();
    buffer.writeln('【📜 詳細處置事件歷程】');
    for (int i = 0; i < session.events.length; i++) {
      final event = session.events[i];
      final time = _timeFormat.format(event.timestamp);
      final detail = event.details.isNotEmpty ? ' (${event.details})' : '';
      buffer.writeln('${i + 1}. [$time] ${event.title}$detail');
    }

    return buffer.toString();
  }
}

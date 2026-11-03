import 'package:hsinchu_ohca_app/domain/models/cpr_event.dart';
import 'package:hsinchu_ohca_app/domain/models/decision_guidance.dart';
import 'package:hsinchu_ohca_app/domain/models/ohca_session.dart';
import 'package:hsinchu_ohca_app/domain/models/rhythm_type.dart';

class OhcaDecisionEngine {
  static DecisionGuidance evaluate({
    required OhcaSession session,
    required int cycleSecondsRemaining,
    required int currentCycle,
    required int? epiSecondsRemaining,
    required bool isPaused,
  }) {
    // 1. ROSC 狀態判定
    if (session.roscTime != null) {
      return const DecisionGuidance(
        primaryTitle: '🌟 自發循環已恢復 (ROSC)',
        primaryDetail: '持續評估呼吸心跳、每 2~3 分鐘量測生命徵象 (BP/SPO2/ETCO2)',
        secondaryAction: '維持進階呼吸道氣道通暢、給予鎮靜/後送急診室並通報醫院準備',
        urgency: GuidanceUrgency.rosc,
      );
    }

    // 2. 剛執行電擊，等待 Leader 下達恢復按壓指令
    if (session.events.isNotEmpty &&
        session.events.last.type == EventType.defibrillation) {
      return const DecisionGuidance(
        primaryTitle: '⚡ 電擊已完成！請下達「立即恢復按壓」',
        primaryDetail: '確認電擊放電完畢，立即全體人員恢復高質量胸外按壓！',
        secondaryAction: '下達指令後點擊下方「恢復按壓 / 開始下一循環」重啟 2 分鐘倒數',
        urgency: GuidanceUrgency.critical,
      );
    }

    // 3. 暫停中判定
    if (isPaused) {
      return const DecisionGuidance(
        primaryTitle: '⏸️ 壓胸暫停中 (現場分析 / 換手)',
        primaryDetail: '等待現場指揮官下達「恢復按壓」指令',
        secondaryAction: '下達恢復指令後，點擊下方「恢復按壓」即刻開始新循環倒數',
        urgency: GuidanceUrgency.warning,
      );
    }

    // 4. CPR 2分鐘週期到期或超時 (等待現場指令)
    if (cycleSecondsRemaining <= 0) {
      final overtime = -cycleSecondsRemaining;
      final overtimeText = overtime > 0 ? ' (已超時 ${overtime} 秒)' : '';
      return DecisionGuidance(
        primaryTitle: '⚠️ 2分鐘已滿$overtimeText！請下達分析心律指令',
        primaryDetail: '等待現場指令：Leader 下達「停止按壓」並於下方點擊「心律分析判定」',
        secondaryAction: '若現場已換手，請點擊「指令：開始下一循環」重啟 2 分鐘倒數',
        urgency: GuidanceUrgency.critical,
        voiceAnnouncement:
            cycleSecondsRemaining == 0 ? '2分鐘循環時間已到，請下達停止按壓分析心律指令' : null,
      );
    }

    // 5. CPR 週期剩餘 30 秒 (即將換手與充電)
    if (cycleSecondsRemaining <= 30) {
      return DecisionGuidance(
        primaryTitle: '⏳ 倒數 $cycleSecondsRemaining 秒！請準備換手',
        primaryDetail: '第二位按壓員就位，若使用手動去顫器可提前充電',
        secondaryAction: '保持按壓不中斷，直到倒數歸零',
        urgency: GuidanceUrgency.warning,
        voiceAnnouncement:
            cycleSecondsRemaining == 30 ? '距離下次分析心律剩30秒，請準備換手' : null,
      );
    }

    // 5. 依據目前最新心律給予演算法下一步建議
    final rhythm = session.latestRhythm;

    if (rhythm.isShockable) {
      // VF / pVT 分支 (Shockable)
      final shockCount = session.totalShocks;
      final amioCount = session.totalAmiodarone;

      if (shockCount == 1) {
        return const DecisionGuidance(
          primaryTitle: '⚡ VF/pVT：已第 1 次電擊，持續 CPR',
          primaryDetail: '立即恢復高質量壓胸 (100-120次/分，深度5-6公分)，建立 IV / IO',
          secondaryAction: '準備第 2 劑電擊能量，並備妥 Epinephrine 1mg',
          urgency: GuidanceUrgency.normal,
        );
      } else if (shockCount == 2) {
        if (amioCount == 0) {
          return const DecisionGuidance(
            primaryTitle: '💉 電擊 2 次後：建議準備抗心律不整藥物',
            primaryDetail: '建議給予 Amiodarone 300mg (或 Lidocaine 1-1.5mg/kg)',
            secondaryAction: '維持高質量 CPR，若血管已建立可給予 Epinephrine 1mg',
            urgency: GuidanceUrgency.warning,
          );
        } else {
          return const DecisionGuidance(
            primaryTitle: '⚡ 持續 VF/pVT：維持 CPR 與藥物循環',
            primaryDetail: '確認氣道暢通 (SGA/ETT) 與 ETCO2 數值，準備下一循環分析',
            secondaryAction: '注意按壓深度與完全回彈，避免過度換氣',
            urgency: GuidanceUrgency.normal,
          );
        }
      } else if (shockCount >= 3) {
        if (amioCount == 1) {
          return const DecisionGuidance(
            primaryTitle: '💉 電擊 3 次後：可考慮 Amiodarone 第 2 劑 (150mg)',
            primaryDetail: '若前次使用 Lidocaine，則給予 Lidocaine 第 2 劑 (0.5-0.75mg/kg)',
            secondaryAction: '檢視難治性 VF 原因：雙向非同步、電極貼片位置與 4H4T',
            urgency: GuidanceUrgency.warning,
          );
        }
      }
    } else if (rhythm == RhythmType.pea || rhythm == RhythmType.asystole) {
      // PEA / Asystole 分支 (Non-Shockable)
      final epiCount = session.totalEpi;
      if (epiCount == 0) {
        return const DecisionGuidance(
          primaryTitle: '🚨 PEA/Asystole 不可電擊心律：首要儘速給予 Epinephrine 1mg',
          primaryDetail: '立即恢復按壓！盡速建立 IV 或 EZ-IO，給藥後以 20ml NS flush 並抬高手臂',
          secondaryAction: '立即排查 4H4T (特別是低血容、缺氧、酸中毒、張力性氣胸)',
          urgency: GuidanceUrgency.warning,
        );
      } else {
        return const DecisionGuidance(
          primaryTitle: '🫀 PEA/Asystole：持續 CPR 並每 3-5 分鐘給予 Epi',
          primaryDetail: '建立高級呼吸道 (i-gel / ETT)，確認 ETCO2 (若<10mmHg改善按壓品質)',
          secondaryAction: '全面檢視可逆病因 4H4T，考慮送醫或線上醫師指導 (OLMC)',
          urgency: GuidanceUrgency.normal,
        );
      }
    }

    // 6. Epinephrine 給藥提醒整合
    if (epiSecondsRemaining != null && epiSecondsRemaining <= 0) {
      return DecisionGuidance(
        primaryTitle: '💉 Epinephrine 已可給予第 ${session.totalEpi + 1} 劑！',
        primaryDetail: '距離上次給藥已達 4 分鐘週期，請指示給藥員推進 1mg 靜脈/骨內推注',
        secondaryAction: '給藥後立即以 20ml NS 沖洗導管',
        urgency: GuidanceUrgency.warning,
        voiceAnnouncement: '可給予下一劑 Epinephrine',
      );
    }

    // 7. 預設按壓計時引導
    return DecisionGuidance(
      primaryTitle: '🟢 第 $currentCycle 循環 CPR 進行中',
      primaryDetail:
          '維持速率 100-120 bpm、深度 5-6 cm，胸回彈完全。剩餘 ${cycleSecondsRemaining}s',
      secondaryAction: session.airwaySummary == null
          ? '建議建立高級呼吸道 (i-gel 或插管) 並連接 ETCO2'
          : '確認 ETCO2 數值 (${session.latestEtco2?.toStringAsFixed(0) ?? "未量測"} mmHg)，監測波形',
      urgency: GuidanceUrgency.normal,
    );
  }
}

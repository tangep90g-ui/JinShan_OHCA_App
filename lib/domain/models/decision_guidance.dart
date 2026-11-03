enum GuidanceUrgency {
  normal, // 正常壓胸計時中 (綠色)
  warning, // 剩餘 30 秒或即將給藥 (黃橘色)
  critical, // 停止按壓分析心律 / 立即電擊 (紅色閃爍)
  rosc; // 自發循環恢復 (青藍色)
}

class DecisionGuidance {
  final String primaryTitle;
  final String primaryDetail;
  final String secondaryAction;
  final GuidanceUrgency urgency;
  final String? voiceAnnouncement;
  final List<String> checklist4H4T;

  const DecisionGuidance({
    required this.primaryTitle,
    required this.primaryDetail,
    required this.secondaryAction,
    this.urgency = GuidanceUrgency.normal,
    this.voiceAnnouncement,
    this.checklist4H4T = const [
      '低血容量 (Hypovolemia)',
      '缺氧 (Hypoxia)',
      '酸中毒 (Hydrogen ion)',
      '低/高血鉀 (Hypo/Hyperkalemia)',
      '低體溫 (Hypothermia)',
      '張力性氣胸 (Tension Pneumo)',
      '心包填塞 (Tamponade)',
      '中毒 (Toxins)',
      '肺栓塞/冠狀動脈栓塞 (Thrombosis)',
    ],
  });
}

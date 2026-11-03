enum RhythmType {
  vf, // 心室顫動 (Ventricular Fibrillation)
  pvt, // 無脈搏心室心搏過速 (Pulseless Ventricular Tachycardia)
  pea, // 無脈搏電氣活動 (Pulseless Electrical Activity)
  asystole, // 心搏停止
  rosc, // 恢復自發循環 (Return of Spontaneous Circulation)
  unknown; // 尚未分析

  bool get isShockable => this == RhythmType.vf || this == RhythmType.pvt;

  String get displayName {
    switch (this) {
      case RhythmType.vf:
        return 'VF (心室顫動)';
      case RhythmType.pvt:
        return 'pVT (無脈心室頻脈)';
      case RhythmType.pea:
        return 'PEA (無脈電氣活動)';
      case RhythmType.asystole:
        return 'Asystole (心搏停止)';
      case RhythmType.rosc:
        return 'ROSC (自發循環恢復)';
      case RhythmType.unknown:
        return '未分析';
    }
  }

  String get shortName {
    switch (this) {
      case RhythmType.vf:
        return 'VF';
      case RhythmType.pvt:
        return 'pVT';
      case RhythmType.pea:
        return 'PEA';
      case RhythmType.asystole:
        return 'Asystole';
      case RhythmType.rosc:
        return 'ROSC';
      case RhythmType.unknown:
        return '未分析';
    }
  }
}

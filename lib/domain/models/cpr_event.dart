import 'rhythm_type.dart';

enum EventType {
  cprStart,
  cprPause,
  cprResume,
  rhythmAnalysis,
  defibrillation,
  epinephrine,
  amiodarone,
  lidocaine,
  otherMedication,
  lucasStart,
  lucasStop,
  vascularAccess,
  airway,
  etco2,
  rosc,
  transportStart,
  hospitalArrival,
  patientContact,
  termination,
  note;

  String get defaultTitle {
    switch (this) {
      case EventType.cprStart:
        return '開始 CPR';
      case EventType.cprPause:
        return '暫停按壓';
      case EventType.cprResume:
        return '恢復按壓';
      case EventType.rhythmAnalysis:
        return '心律分析';
      case EventType.defibrillation:
        return '去顫電擊';
      case EventType.epinephrine:
        return '給予 Epinephrine';
      case EventType.amiodarone:
        return '給予 Amiodarone';
      case EventType.lidocaine:
        return '給予 Lidocaine';
      case EventType.otherMedication:
        return '其他給藥';
      case EventType.lucasStart:
        return 'LUCAS 機械按壓上機';
      case EventType.lucasStop:
        return 'LUCAS 機械按壓停機';
      case EventType.vascularAccess:
        return '建立血管通路';
      case EventType.airway:
        return '呼吸道建立';
      case EventType.etco2:
        return 'ETCO2 監測';
      case EventType.rosc:
        return 'ROSC 恢復自發循環';
      case EventType.transportStart:
        return '上車出發送醫';
      case EventType.hospitalArrival:
        return '抵達醫院交接';
      case EventType.patientContact:
        return '接觸患者';
      case EventType.termination:
        return '停止急救';
      case EventType.note:
        return '現場備註';
    }
  }

  String get category {
    switch (this) {
      case EventType.cprStart:
      case EventType.cprPause:
      case EventType.cprResume:
      case EventType.lucasStart:
      case EventType.lucasStop:
        return 'CPR / 按壓';
      case EventType.rhythmAnalysis:
      case EventType.defibrillation:
        return '心律 / 電擊';
      case EventType.epinephrine:
      case EventType.amiodarone:
      case EventType.lidocaine:
      case EventType.otherMedication:
        return '藥物處置';
      case EventType.vascularAccess:
      case EventType.airway:
      case EventType.etco2:
        return '進階處置';
      case EventType.rosc:
      case EventType.transportStart:
      case EventType.hospitalArrival:
      case EventType.patientContact:
      case EventType.termination:
      case EventType.note:
        return '救護時間鏈';
    }
  }
}

class CprEvent {
  final String id;
  final DateTime timestamp;
  final EventType type;
  final String title;
  final String details;
  final int cycleNumber;
  final RhythmType? rhythm;
  final int? energyJoules;
  final double? medicationDose;
  final int? countNumber; // e.g. 第幾劑、第幾次電擊

  const CprEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.title,
    this.details = '',
    this.cycleNumber = 1,
    this.rhythm,
    this.energyJoules,
    this.medicationDose,
    this.countNumber,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'type': type.name,
        'title': title,
        'details': details,
        'cycleNumber': cycleNumber,
        'rhythm': rhythm?.name,
        'energyJoules': energyJoules,
        'medicationDose': medicationDose,
        'countNumber': countNumber,
      };

  factory CprEvent.fromJson(Map<String, dynamic> json) => CprEvent(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        type: EventType.values.byName(json['type'] as String),
        title: json['title'] as String,
        details: json['details'] as String? ?? '',
        cycleNumber: json['cycleNumber'] as int? ?? 1,
        rhythm: json['rhythm'] != null
            ? RhythmType.values.byName(json['rhythm'] as String)
            : null,
        energyJoules: json['energyJoules'] as int?,
        medicationDose: (json['medicationDose'] as num?)?.toDouble(),
        countNumber: json['countNumber'] as int?,
      );
}

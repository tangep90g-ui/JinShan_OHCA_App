import 'cpr_event.dart';
import 'rhythm_type.dart';

class OhcaSession {
  final String id;
  final DateTime startTime;
  DateTime? patientContactTime;
  DateTime? cprStartTime;
  DateTime? firstShockTime;
  DateTime? transportStartTime;
  DateTime? hospitalArrivalTime;
  DateTime? roscTime;
  DateTime? terminationTime;

  String squadName; // 新竹市消防局分隊 e.g. 光復分隊 / 三民分隊 / 特搜分隊
  String emtNames; // 出勤同仁
  String hospitalName; // 送往醫院 e.g. 新竹台大分院 / 馬偕紀念醫院 / 國軍新竹醫院
  String patientGender; // 男 / 女 / 不詳
  String patientAge; // 年齡估計

  String? airwaySummary; // e.g. i-gel #4 / ETT 7.5mm
  String? vascularSummary; // e.g. EZ-IO 右側近端脛骨 / IV 18G
  bool isLucasUsed;
  int lucasSeconds;
  double? latestEtco2;

  List<CprEvent> events;

  OhcaSession({
    required this.id,
    required this.startTime,
    this.patientContactTime,
    this.cprStartTime,
    this.firstShockTime,
    this.transportStartTime,
    this.hospitalArrivalTime,
    this.roscTime,
    this.terminationTime,
    this.squadName = '金山分隊',
    this.emtNames = '',
    this.hospitalName = '新竹台大分院',
    this.patientGender = '不詳',
    this.patientAge = '',
    this.airwaySummary,
    this.vascularSummary,
    this.isLucasUsed = false,
    this.lucasSeconds = 0,
    this.latestEtco2,
    List<CprEvent>? events,
  }) : events = events ?? [];

  int get totalShocks =>
      events.where((e) => e.type == EventType.defibrillation).length;

  int get totalEpi =>
      events.where((e) => e.type == EventType.epinephrine).length;

  int get totalAmiodarone =>
      events.where((e) => e.type == EventType.amiodarone).length;

  int get totalLidocaine =>
      events.where((e) => e.type == EventType.lidocaine).length;

  RhythmType get latestRhythm {
    for (final e in events.reversed) {
      if (e.rhythm != null) return e.rhythm!;
    }
    return RhythmType.unknown;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'patientContactTime': patientContactTime?.toIso8601String(),
        'cprStartTime': cprStartTime?.toIso8601String(),
        'firstShockTime': firstShockTime?.toIso8601String(),
        'transportStartTime': transportStartTime?.toIso8601String(),
        'hospitalArrivalTime': hospitalArrivalTime?.toIso8601String(),
        'roscTime': roscTime?.toIso8601String(),
        'terminationTime': terminationTime?.toIso8601String(),
        'squadName': squadName,
        'emtNames': emtNames,
        'hospitalName': hospitalName,
        'patientGender': patientGender,
        'patientAge': patientAge,
        'airwaySummary': airwaySummary,
        'vascularSummary': vascularSummary,
        'isLucasUsed': isLucasUsed,
        'lucasSeconds': lucasSeconds,
        'latestEtco2': latestEtco2,
        'events': events.map((e) => e.toJson()).toList(),
      };

  factory OhcaSession.fromJson(Map<String, dynamic> json) => OhcaSession(
        id: json['id'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        patientContactTime: json['patientContactTime'] != null
            ? DateTime.parse(json['patientContactTime'] as String)
            : null,
        cprStartTime: json['cprStartTime'] != null
            ? DateTime.parse(json['cprStartTime'] as String)
            : null,
        firstShockTime: json['firstShockTime'] != null
            ? DateTime.parse(json['firstShockTime'] as String)
            : null,
        transportStartTime: json['transportStartTime'] != null
            ? DateTime.parse(json['transportStartTime'] as String)
            : null,
        hospitalArrivalTime: json['hospitalArrivalTime'] != null
            ? DateTime.parse(json['hospitalArrivalTime'] as String)
            : null,
        roscTime: json['roscTime'] != null
            ? DateTime.parse(json['roscTime'] as String)
            : null,
        terminationTime: json['terminationTime'] != null
            ? DateTime.parse(json['terminationTime'] as String)
            : null,
        squadName: json['squadName'] as String? ?? '金山分隊',
        emtNames: json['emtNames'] as String? ?? '',
        hospitalName: json['hospitalName'] as String? ?? '新竹台大分院',
        patientGender: json['patientGender'] as String? ?? '不詳',
        patientAge: json['patientAge'] as String? ?? '',
        airwaySummary: json['airwaySummary'] as String?,
        vascularSummary: json['vascularSummary'] as String?,
        isLucasUsed: json['isLucasUsed'] as bool? ?? false,
        lucasSeconds: json['lucasSeconds'] as int? ?? 0,
        latestEtco2: (json['latestEtco2'] as num?)?.toDouble(),
        events: (json['events'] as List<dynamic>?)
                ?.map((e) => CprEvent.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

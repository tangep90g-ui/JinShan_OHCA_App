import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hsinchu_ohca_app/domain/models/cpr_event.dart';
import 'package:hsinchu_ohca_app/domain/models/ohca_session.dart';
import 'package:hsinchu_ohca_app/domain/models/rhythm_type.dart';
import 'package:hsinchu_ohca_app/ui/core/app_colors.dart';

enum TimelineFilter {
  all('全部'),
  shocks('⚡ 電擊'),
  meds('💉 藥物'),
  rhythm('🫀 心律'),
  procedures('🛠️ 處置');

  final String label;
  const TimelineFilter(this.label);
}

class TimelineSheet extends StatefulWidget {
  final OhcaSession session;
  final VoidCallback onExportLine;

  const TimelineSheet({
    super.key,
    required this.session,
    required this.onExportLine,
  });

  @override
  State<TimelineSheet> createState() => _TimelineSheetState();
}

class _TimelineSheetState extends State<TimelineSheet> {
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');
  TimelineFilter _selectedFilter = TimelineFilter.all;
  bool _isNewestFirst = true;

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.cprStart:
      case EventType.cprResume:
        return Icons.play_arrow_rounded;
      case EventType.cprPause:
        return Icons.pause_rounded;
      case EventType.rhythmAnalysis:
        return Icons.monitor_heart_rounded;
      case EventType.defibrillation:
        return Icons.bolt_rounded;
      case EventType.epinephrine:
      case EventType.amiodarone:
      case EventType.lidocaine:
      case EventType.otherMedication:
        return Icons.vaccines_rounded;
      case EventType.lucasStart:
      case EventType.lucasStop:
        return Icons.precision_manufacturing_rounded;
      case EventType.vascularAccess:
        return Icons.water_drop_rounded;
      case EventType.airway:
        return Icons.air_rounded;
      case EventType.etco2:
        return Icons.waves_rounded;
      case EventType.rosc:
        return Icons.stars_rounded;
      case EventType.transportStart:
        return Icons.local_shipping_rounded;
      case EventType.hospitalArrival:
        return Icons.local_hospital_rounded;
      default:
        return Icons.fiber_manual_record_rounded;
    }
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.defibrillation:
        return AppColors.urgentRed;
      case EventType.epinephrine:
      case EventType.amiodarone:
      case EventType.lidocaine:
      case EventType.otherMedication:
        return AppColors.drugBlue;
      case EventType.rhythmAnalysis:
        return AppColors.shockPurple;
      case EventType.rosc:
        return AppColors.roscCyan;
      case EventType.cprStart:
      case EventType.cprResume:
      case EventType.airway:
      case EventType.vascularAccess:
        return AppColors.cprGreen;
      case EventType.lucasStart:
      case EventType.lucasStop:
      case EventType.cprPause:
        return AppColors.warningAmber;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatElapsed(DateTime eventTime) {
    final baseTime = widget.session.cprStartTime ?? widget.session.startTime;
    final diff = eventTime.difference(baseTime);
    final isNegative = diff.isNegative;
    final absSeconds = diff.inSeconds.abs();
    final m = (absSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (absSeconds % 60).toString().padLeft(2, '0');
    return '${isNegative ? '-' : '+'}$m:$s';
  }

  String? _getEventBadge(CprEvent event, List<CprEvent> allChronological) {
    if (event.type == EventType.defibrillation) {
      final shocksSoFar = allChronological
          .where((e) =>
              e.type == EventType.defibrillation &&
              !e.timestamp.isAfter(event.timestamp))
          .length;
      return '第 $shocksSoFar 次電擊';
    }
    if (event.type == EventType.epinephrine) {
      final epiSoFar = allChronological
          .where((e) =>
              e.type == EventType.epinephrine &&
              !e.timestamp.isAfter(event.timestamp))
          .length;
      return '第 $epiSoFar 支 (1mg)';
    }
    if (event.type == EventType.rhythmAnalysis && event.rhythm != null) {
      return event.rhythm!.displayName;
    }
    if (event.type == EventType.rosc) {
      return 'ROSC 成功';
    }
    return null;
  }

  String? _getDeltaToPrevious(
      CprEvent current, List<CprEvent> allChronological) {
    final idx = allChronological.indexOf(current);
    if (idx <= 0) return null;
    final prev = allChronological[idx - 1];
    final diff = current.timestamp.difference(prev.timestamp).inSeconds;
    if (diff < 10) return null;
    final m = diff ~/ 60;
    final s = diff % 60;
    if (m > 0) {
      return '距前處置 ${m}m ${s}s';
    } else {
      return '距前處置 ${s}s';
    }
  }

  List<CprEvent> _getFilteredEvents() {
    final all = List<CprEvent>.from(widget.session.events);
    List<CprEvent> filtered;
    switch (_selectedFilter) {
      case TimelineFilter.all:
        filtered = all;
        break;
      case TimelineFilter.shocks:
        filtered =
            all.where((e) => e.type == EventType.defibrillation).toList();
        break;
      case TimelineFilter.meds:
        filtered = all
            .where((e) =>
                e.type == EventType.epinephrine ||
                e.type == EventType.amiodarone ||
                e.type == EventType.lidocaine ||
                e.type == EventType.otherMedication)
            .toList();
        break;
      case TimelineFilter.rhythm:
        filtered =
            all.where((e) => e.type == EventType.rhythmAnalysis).toList();
        break;
      case TimelineFilter.procedures:
        filtered = all
            .where((e) =>
                e.type == EventType.airway ||
                e.type == EventType.vascularAccess ||
                e.type == EventType.etco2 ||
                e.type == EventType.lucasStart ||
                e.type == EventType.lucasStop)
            .toList();
        break;
    }

    if (_isNewestFirst) {
      return filtered.reversed.toList();
    } else {
      return filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final allChronological = List<CprEvent>.from(session.events);
    final displayedEvents = _getFilteredEvents();

    final cprElapsedMinutes = session.cprStartTime != null
        ? DateTime.now().difference(session.cprStartTime!).inMinutes
        : 0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 頂部抓桿
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 6),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 標題與操作欄
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.cprGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.timeline_rounded,
                        color: AppColors.cprGreen, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '圖示化現場時間軸',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${session.squadName} • 現場交接視圖',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: _isNewestFirst ? '切換為正序' : '切換為最新在頂部',
                    onPressed: () {
                      setState(() {
                        _isNewestFirst = !_isNewestFirst;
                      });
                    },
                    icon: Icon(
                      _isNewestFirst
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // 🌟 1. 交接核心 KPI 統計看板 (Executive Handover Cards)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.surfaceElevated,
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // 總急救時間
                      Expanded(
                        child: _buildKpiBox(
                          label: 'CPR 時長',
                          value: '${cprElapsedMinutes}m',
                          icon: Icons.timer_outlined,
                          color: AppColors.cprGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 電擊次數
                      Expanded(
                        child: _buildKpiBox(
                          label: '電擊放電',
                          value: '${session.totalShocks}次',
                          icon: Icons.bolt_rounded,
                          color: AppColors.urgentRed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Epinephrine
                      Expanded(
                        child: _buildKpiBox(
                          label: 'Epinephrine',
                          value: '${session.totalEpi}支',
                          icon: Icons.vaccines_rounded,
                          color: AppColors.drugBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 最新心律
                      Expanded(
                        child: _buildKpiBox(
                          label: '最新心律',
                          value: session.latestRhythm.shortName,
                          icon: Icons.monitor_heart_outlined,
                          color: session.latestRhythm.isShockable
                              ? AppColors.urgentRed
                              : AppColors.shockPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 氣道與管路摘要列
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.air_rounded,
                            size: 15, color: AppColors.cprGreen),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '氣道: ${session.airwaySummary ?? 'BVM'}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 14,
                          color: AppColors.textMuted.withValues(alpha: 0.3),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        const Icon(Icons.water_drop_rounded,
                            size: 15, color: AppColors.drugBlue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '路徑: ${session.vascularSummary ?? '未建立'}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (session.latestEtco2 != null) ...[
                          Container(
                            width: 1,
                            height: 14,
                            color: AppColors.textMuted.withValues(alpha: 0.3),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          Text(
                            'ETCO2: ${session.latestEtco2!.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warningAmber),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🏷️ 2. 分類篩選標籤列 (Filter Chips)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: TimelineFilter.values.map((f) {
                  final isSelected = _selectedFilter == f;
                  int count = 0;
                  switch (f) {
                    case TimelineFilter.all:
                      count = allChronological.length;
                      break;
                    case TimelineFilter.shocks:
                      count = session.totalShocks;
                      break;
                    case TimelineFilter.meds:
                      count = session.totalEpi +
                          session.totalAmiodarone +
                          session.totalLidocaine;
                      break;
                    case TimelineFilter.rhythm:
                      count = allChronological
                          .where((e) => e.type == EventType.rhythmAnalysis)
                          .length;
                      break;
                    case TimelineFilter.procedures:
                      count = allChronological
                          .where((e) =>
                              e.type == EventType.airway ||
                              e.type == EventType.vascularAccess ||
                              e.type == EventType.etco2 ||
                              e.type == EventType.lucasStart ||
                              e.type == EventType.lucasStop)
                          .length;
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text('${f.label} ($count)'),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedFilter = f;
                        });
                      },
                      selectedColor: AppColors.cprGreen.withValues(alpha: 0.22),
                      backgroundColor: AppColors.surface,
                      checkmarkColor: AppColors.cprGreen,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.cprGreen
                            : AppColors.surfaceElevated,
                        width: 1,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppColors.cprGreen
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 4),

            // 📈 3. 圖示化連續時間軸 (Connected Metro Timeline Rail)
            Expanded(
              child: displayedEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_toggle_off_rounded,
                              size: 48,
                              color:
                                  AppColors.textMuted.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          const Text(
                            '目前無符合篩選的處置紀錄',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      itemCount: displayedEvents.length,
                      itemBuilder: (ctx, idx) {
                        final event = displayedEvents[idx];
                        final icon = _getEventIcon(event.type);
                        final color = _getEventColor(event.type);
                        final elapsedStr = _formatElapsed(event.timestamp);
                        final clockStr = _timeFormat.format(event.timestamp);
                        final badge =
                            _getEventBadge(event, allChronological);
                        final deltaStr =
                            _getDeltaToPrevious(event, allChronological);
                        final isFirst = idx == 0;
                        final isLast = idx == displayedEvents.length - 1;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 左欄：時間雙標籤 (相對急救時長 + 鐘錶絕對時間)
                              SizedBox(
                                width: 62,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      elapsedStr,
                                      style: TextStyle(
                                        fontFamily: 'Courier',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                    Text(
                                      clockStr,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // 中欄：軌道線軸 + 節點圖示 (Vertical Track Rail)
                              SizedBox(
                                width: 32,
                                child: Column(
                                  children: [
                                    // 上半段連接軌道
                                    Expanded(
                                      child: Container(
                                        width: 2.5,
                                        color: isFirst
                                            ? Colors.transparent
                                            : AppColors.surfaceElevated,
                                      ),
                                    ),
                                    // 圓點節點徽章
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.18),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: color,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                color.withValues(alpha: 0.35),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Icon(icon, size: 15, color: color),
                                    ),
                                    // 下半段連接軌道
                                    Expanded(
                                      child: Container(
                                        width: 2.5,
                                        color: isLast
                                            ? Colors.transparent
                                            : AppColors.surfaceElevated,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              // 右欄：高對比處置卡片 (Event Card)
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.35),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              event.title,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (badge != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: color.withValues(
                                                    alpha: 0.22),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                badge,
                                                style: TextStyle(
                                                  color: color,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (event.details.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          event.details,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                      if (deltaStr != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.hourglass_bottom_rounded,
                                                size: 11,
                                                color: AppColors.textMuted),
                                            const SizedBox(width: 4),
                                            Text(
                                              deltaStr,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // 📋 4. 底部交接操作列 (Handover Export Bar)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.surfaceElevated, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cprGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: widget.onExportLine,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text(
                        '📋 產出 LINE 救護交接報告',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 3),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

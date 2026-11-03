import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:hsinchu_ohca_app/data/services/line_report_formatter.dart';
import 'package:hsinchu_ohca_app/domain/models/ohca_session.dart';
import 'package:hsinchu_ohca_app/ui/core/app_colors.dart';
import 'package:hsinchu_ohca_app/ui/features/timeline/views/timeline_sheet.dart';

class CaseHistorySheet extends StatelessWidget {
  final List<OhcaSession> sessions;
  final VoidCallback? onRefresh;

  const CaseHistorySheet({
    super.key,
    required this.sessions,
    this.onRefresh,
  });

  static final DateFormat _dateFormat = DateFormat('yyyy/MM/dd HH:mm');

  @override
  Widget build(BuildContext context) {
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

            // 標題欄
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.drugBlue.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.folder_shared_rounded,
                        color: AppColors.drugBlue, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '歷史案件存檔紀錄',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '已保存 ${sessions.length} 筆出勤案件',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.surfaceElevated, height: 1),

            // 案件列表
            Expanded(
              child: sessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 48,
                              color: AppColors.textMuted.withValues(alpha: 0.4)),
                          const SizedBox(height: 8),
                          const Text(
                            '目前尚無任何封存的歷史案件',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '完成現場處置後點擊「結束案件存檔」即可保存',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      itemCount: sessions.length,
                      itemBuilder: (ctx, idx) {
                        final s = sessions[idx];
                        final dateStr = _dateFormat.format(s.startTime);
                        final cprMinutes = s.cprStartTime != null
                            ? (s.terminationTime ??
                                    s.hospitalArrivalTime ??
                                    DateTime.now())
                                .difference(s.cprStartTime!)
                                .inMinutes
                            : 0;

                        String outcomeText = '處置存檔';
                        Color outcomeColor = AppColors.cprGreen;
                        if (s.roscTime != null) {
                          outcomeText = '🌟 自發循環恢復 (ROSC)';
                          outcomeColor = AppColors.roscCyan;
                        } else if (s.terminationTime != null) {
                          outcomeText = '🛑 現場終止急救 (TOR)';
                          outcomeColor = AppColors.warningAmber;
                        } else if (s.hospitalArrivalTime != null) {
                          outcomeText = '🚑 送抵急診交接';
                          outcomeColor = AppColors.drugBlue;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 頂部時間與結局徽章
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 13, color: AppColors.textMuted),
                                  const SizedBox(width: 5),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color:
                                          outcomeColor.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      outcomeText,
                                      style: TextStyle(
                                        color: outcomeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // 出勤分隊、送往醫院與病患
                              Row(
                                children: [
                                  Text(
                                    '${s.squadName} • 送往 ${s.hospitalName}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (s.patientGender != '不詳' ||
                                      s.patientAge.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${s.patientGender} / ${s.patientAge.isEmpty ? '年齡不詳' : '${s.patientAge}歲'})',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 8),

                              // 關鍵急救數據指標列
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildMiniStat('⏱️ 壓胸', '${cprMinutes}m',
                                        AppColors.cprGreen),
                                    _buildMiniStat('⚡ 電擊', '${s.totalShocks}次',
                                        AppColors.urgentRed),
                                    _buildMiniStat('💉 Epi', '${s.totalEpi}支',
                                        AppColors.drugBlue),
                                    _buildMiniStat(
                                        '🫀 心律',
                                        s.latestRhythm.shortName,
                                        AppColors.shockPurple),
                                    _buildMiniStat('📜 事件', '${s.events.length}筆',
                                        AppColors.textSecondary),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              // 操作按鈕列
                              Row(
                                children: [
                                  // 查看時間軸按鈕
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.textPrimary,
                                        side: const BorderSide(
                                            color: AppColors.surfaceElevated),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) => FractionallySizedBox(
                                            heightFactor: 0.90,
                                            child: TimelineSheet(
                                              session: s,
                                              onExportLine: () {
                                                _copyLineReport(context, s);
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.timeline_rounded,
                                          size: 15),
                                      label: const Text('查看時間軸',
                                          style: TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // 複製 LINE 報告按鈕
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.cprGreen,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () =>
                                          _copyLineReport(context, s),
                                      icon: const Icon(Icons.copy_rounded,
                                          size: 15),
                                      label: const Text('複製 LINE 報告',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyLineReport(BuildContext context, OhcaSession s) async {
    final report = LineReportFormatter.generateReport(s);
    await Clipboard.setData(ClipboardData(text: report));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已複製 ${s.squadName} 救護回報格式至剪貼簿！'),
          backgroundColor: AppColors.cprGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

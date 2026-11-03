import 'package:flutter/material.dart';
import 'package:hsinchu_ohca_app/ui/core/app_colors.dart';
import 'package:hsinchu_ohca_app/ui/features/active_cpr/view_models/active_cpr_view_model.dart';
import 'widgets/action_keypad.dart';
import 'widgets/airway_dialog.dart';
import 'widgets/case_history_sheet.dart';
import 'widgets/checklist_4h4t_sheet.dart';
import 'widgets/cpr_master_timer_card.dart';
import 'widgets/decision_guidance_card.dart';
import 'widgets/end_case_dialog.dart';
import 'widgets/etco2_dialog.dart';
import 'widgets/line_export_dialog.dart';
import 'widgets/vascular_dialog.dart';
import 'package:hsinchu_ohca_app/ui/features/timeline/views/timeline_sheet.dart';

class ActiveCprScreen extends StatelessWidget {
  final ActiveCprViewModel viewModel;

  const ActiveCprScreen({super.key, required this.viewModel});

  void _showCaseInfoDialog(BuildContext context) {
    final session = viewModel.session;
    final squadController = TextEditingController(text: session.squadName);
    final emtController = TextEditingController(text: session.emtNames);
    final hospitalController = TextEditingController(text: session.hospitalName);
    final ageController = TextEditingController(text: session.patientAge);
    String gender = session.patientGender;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('📋 出勤案件資訊設定',
              style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: squadController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '出勤單位 (預設: 金山91 / 可改金山92等)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emtController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '救護同仁姓名 / 職稱',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: hospitalController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '後送醫院 (例如: 新竹台大 / 馬偕 / 國軍新竹)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: gender,
                        dropdownColor: AppColors.surfaceElevated,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: '性別',
                          labelStyle: TextStyle(color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                        ),
                        items: ['不詳', '男', '女']
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => gender = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: '估計年齡',
                          labelStyle: TextStyle(color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cprGreen),
              onPressed: () {
                session.squadName = squadController.text.trim();
                session.emtNames = emtController.text.trim();
                session.hospitalName = hospitalController.text.trim();
                session.patientGender = gender;
                session.patientAge = ageController.text.trim();
                Navigator.pop(ctx);
              },
              child: const Text('儲存資訊',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLineReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => LineExportDialog(
        session: viewModel.session,
        onCopy: () async {
          await viewModel.copyLineReportToClipboard();
        },
        onArchive: () async {
          await viewModel.archiveCurrentCase();
        },
      ),
    );
  }

  void _showTimelineSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.90,
        child: TimelineSheet(
          session: viewModel.session,
          onExportLine: () {
            Navigator.pop(ctx);
            _showLineReportDialog(context);
          },
        ),
      ),
    );
  }

  void _showEndCaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => EndCaseDialog(
        session: viewModel.session,
        onConfirmEnd: ({
          required String outcome,
          String? note,
          required bool startNew,
        }) async {
          await viewModel.endCaseAndArchive(
            outcome: outcome,
            note: note,
            startNewImmediately: startNew,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  startNew
                      ? '案件已存檔並已開啟全新出勤案件！'
                      : '案件已結束並成功封存至歷史紀錄！',
                ),
                backgroundColor: AppColors.cprGreen,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
      ),
    );
  }

  void _confirmStartNewCase(BuildContext context) {
    if (viewModel.session.events.isEmpty) {
      viewModel.startNewCase(archiveCurrent: false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已建立新出勤案件！'),
          backgroundColor: AppColors.cprGreen,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline_rounded, color: AppColors.cprGreen),
            SizedBox(width: 8),
            Text('建立新案件確認',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
        content: Text(
          '目前案件已有 ${viewModel.session.events.length} 筆急救處置紀錄。\n\n請選擇是否先將當前案件存檔歸檔，再清空建立新案件？',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: AppColors.textMuted)),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.urgentRed,
              side: const BorderSide(color: AppColors.urgentRed),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await viewModel.startNewCase(archiveCurrent: false);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已放棄當前紀錄並開啟新案件！'),
                    backgroundColor: AppColors.warningAmber,
                  ),
                );
              }
            },
            child: const Text('不存檔，直接開新案'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cprGreen,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await viewModel.startNewCase(archiveCurrent: true);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已存檔當前案件，並開啟全新案件！'),
                    backgroundColor: AppColors.cprGreen,
                  ),
                );
              }
            },
            child: const Text('存檔並開新案',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCaseHistorySheet(BuildContext context) async {
    final history = await viewModel.getHistorySessions();
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => FractionallySizedBox(
          heightFactor: 0.88,
          child: CaseHistorySheet(sessions: history),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final session = viewModel.session;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 2,
            titleSpacing: 14,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.urgentRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.emergency,
                      color: AppColors.urgentRed, size: 20),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '新竹市消防局 OHCA 現場輔助',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${session.squadName} | 送往 ${session.hospitalName}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: '結束案件並存檔',
                icon: const Icon(Icons.archive_rounded,
                    color: AppColors.warningAmber),
                onPressed: () => _showEndCaseDialog(context),
              ),
              PopupMenuButton<String>(
                tooltip: '案件存檔與管理',
                icon: const Icon(Icons.folder_shared_rounded,
                    color: AppColors.textSecondary),
                color: AppColors.surface,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.surfaceElevated),
                ),
                onSelected: (val) {
                  switch (val) {
                    case 'end':
                      _showEndCaseDialog(context);
                      break;
                    case 'new':
                      _confirmStartNewCase(context);
                      break;
                    case 'history':
                      _showCaseHistorySheet(context);
                      break;
                    case 'info':
                      _showCaseInfoDialog(context);
                      break;
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'end',
                    child: Row(
                      children: [
                        Icon(Icons.archive_rounded,
                            color: AppColors.warningAmber, size: 20),
                        SizedBox(width: 10),
                        Text('結束案件並存檔',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'new',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline_rounded,
                            color: AppColors.cprGreen, size: 20),
                        SizedBox(width: 10),
                        Text('建立新案件',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: 1),
                  const PopupMenuItem(
                    value: 'history',
                    child: Row(
                      children: [
                        Icon(Icons.history_rounded,
                            color: AppColors.drugBlue, size: 20),
                        SizedBox(width: 10),
                        Text('歷史存檔紀錄',
                            style: TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'info',
                    child: Row(
                      children: [
                        Icon(Icons.edit_note,
                            color: AppColors.textSecondary, size: 20),
                        SizedBox(width: 10),
                        Text('出勤案件設定',
                            style: TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                tooltip: viewModel.isMuted ? '解除靜音' : '靜音語音',
                icon: Icon(
                  viewModel.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: viewModel.isMuted
                      ? AppColors.urgentRed
                      : AppColors.cprGreen,
                ),
                onPressed: viewModel.toggleMute,
              ),
              IconButton(
                tooltip: viewModel.isVibrationEnabled ? '關閉震動' : '開啟震動',
                icon: Icon(
                  viewModel.isVibrationEnabled
                      ? Icons.vibration
                      : Icons.smartphone,
                  color: viewModel.isVibrationEnabled
                      ? AppColors.cprGreen
                      : AppColors.textMuted,
                ),
                onPressed: viewModel.toggleVibration,
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                children: [
                  // 1. 2分鐘 CPR 主計時面板
                  CprMasterTimerCard(
                    totalElapsedSeconds: viewModel.totalElapsedSeconds,
                    cycleSecondsRemaining: viewModel.cycleSecondsRemaining,
                    currentCycle: viewModel.currentCycle,
                    epiSecondsRemaining: viewModel.epiSecondsRemaining,
                    isRunning: viewModel.isRunning,
                    isPaused: viewModel.isPaused,
                    onStart: viewModel.startCpr,
                    onPause: viewModel.pauseCpr,
                    onResume: viewModel.resumeCpr,
                    onNextCycle: viewModel.startNextCycleUponCommand,
                  ),

                  // 2. ACLS 動態下一步決策卡片
                  DecisionGuidanceCard(
                    guidance: viewModel.guidance,
                    onOpen4H4T: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => const Checklist4H4TSheet(),
                      );
                    },
                  ),

                  // 3. 現場處置快速操作面板
                  ActionKeypad(
                    session: session,
                    onRhythmSelect: viewModel.recordRhythmAnalysis,
                    onDefibrillate: viewModel.recordDefibrillation,
                    onEpinephrine: viewModel.recordEpinephrine,
                    onAmiodarone: viewModel.recordAmiodarone,
                    onLidocaine: viewModel.recordLidocaine,
                    onToggleLucas: viewModel.toggleLucas,
                    onOpenAirwayDialog: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AirwayDialog(
                          onConfirm: viewModel.recordAirway,
                        ),
                      );
                    },
                    onOpenVascularDialog: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => VascularDialog(
                          onConfirm: viewModel.recordVascularAccess,
                        ),
                      );
                    },
                    onOpenEtco2Dialog: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => Etco2Dialog(
                          currentEtco2: session.latestEtco2 ?? 20,
                          onConfirm: viewModel.recordEtco2,
                        ),
                      );
                    },
                    onRosc: viewModel.recordRosc,
                  ),
                ],
              ),
            ),
          ),
          bottomSheet: Container(
            color: AppColors.surface,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (session.hospitalArrivalTime != null || session.roscTime != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        border: Border(
                          top: BorderSide(
                            color: session.roscTime != null
                                ? AppColors.roscCyan.withValues(alpha: 0.5)
                                : AppColors.cprGreen.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            session.roscTime != null
                                ? Icons.stars_rounded
                                : Icons.local_hospital_rounded,
                            color: session.roscTime != null
                                ? AppColors.roscCyan
                                : AppColors.cprGreen,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              session.roscTime != null
                                  ? '🌟 ROSC 自發循環恢復！點右側結束存檔'
                                  : '🚑 已抵達急診交接！點右側結束存檔',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warningAmber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: const Size(60, 30),
                            ),
                            onPressed: () => _showEndCaseDialog(context),
                            icon: const Icon(Icons.archive_rounded, size: 14),
                            label: const Text(
                              '結束存檔',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        // 送醫出發按鈕
                        Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(
                          color: session.transportStartTime != null
                              ? AppColors.cprGreen
                              : AppColors.textMuted,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: viewModel.recordTransport,
                      icon: Icon(
                        Icons.local_shipping,
                        size: 16,
                        color: session.transportStartTime != null
                            ? AppColors.cprGreen
                            : AppColors.textSecondary,
                      ),
                      label: Text(
                        session.transportStartTime != null ? '已出發' : '上車送醫',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // 抵達醫院按鈕
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(
                          color: session.hospitalArrivalTime != null
                              ? AppColors.cprGreen
                              : AppColors.textMuted,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: viewModel.recordHospitalArrival,
                      icon: Icon(
                        Icons.local_hospital,
                        size: 16,
                        color: session.hospitalArrivalTime != null
                            ? AppColors.cprGreen
                            : AppColors.textSecondary,
                      ),
                      label: Text(
                        session.hospitalArrivalTime != null ? '已抵達' : '抵達醫院',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // 查看時間軸
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceElevated,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                    ),
                    onPressed: () => _showTimelineSheet(context),
                    icon: const Icon(Icons.history, size: 16),
                    label: Text(
                      '時間軸 (${session.events.length})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // LINE 報告按鈕
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cprGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                    ),
                    onPressed: () => _showLineReportDialog(context),
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text(
                      'LINE',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
      },
    );
  }
}

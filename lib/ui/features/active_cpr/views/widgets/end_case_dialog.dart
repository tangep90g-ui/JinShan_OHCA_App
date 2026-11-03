import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hsinchu_ohca_app/domain/models/ohca_session.dart';
import 'package:hsinchu_ohca_app/ui/core/app_colors.dart';

class EndCaseDialog extends StatefulWidget {
  final OhcaSession session;
  final Function({required String outcome, String? note, required bool startNew}) onConfirmEnd;

  const EndCaseDialog({
    super.key,
    required this.session,
    required this.onConfirmEnd,
  });

  @override
  State<EndCaseDialog> createState() => _EndCaseDialogState();
}

class _EndCaseDialogState extends State<EndCaseDialog> {
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');
  String _selectedOutcome = '🌟 自發循環恢復 (ROSC) 送醫';
  final TextEditingController _noteController = TextEditingController();

  final List<String> _outcomes = [
    '🌟 自發循環恢復 (ROSC) 送醫',
    '🚑 持續 CPR 送抵急診交接',
    '🛑 現場終止急救 (TOR / 拒送)',
    '📋 其他處置完成歸檔',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.session.roscTime != null) {
      _selectedOutcome = '🌟 自發循環恢復 (ROSC) 送醫';
    } else if (widget.session.hospitalArrivalTime != null) {
      _selectedOutcome = '🚑 持續 CPR 送抵急診交接';
    } else if (widget.session.terminationTime != null) {
      _selectedOutcome = '🛑 現場終止急救 (TOR / 拒送)';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final cprElapsedMinutes = session.cprStartTime != null
        ? DateTime.now().difference(session.cprStartTime!).inMinutes
        : 0;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.warningAmber.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.archive_rounded,
                color: AppColors.warningAmber, size: 22),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '結束案件並存檔',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 案件快速概要
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.surfaceElevated,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '分隊：${session.squadName}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '時間：${_timeFormat.format(session.startTime)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '送往：${session.hospitalName} | 壓胸時長：約 $cprElapsedMinutes 分鐘',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '統計：⚡ 電擊 ${session.totalShocks} 次 | 💉 Epi ${session.totalEpi} 支 | 心律：${session.latestRhythm.displayName}',
                    style: const TextStyle(
                      color: AppColors.cprGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 選擇案件結局
            const Text(
              '急救結局與交接狀態：',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            ..._outcomes.map((outcome) {
              final isSelected = _selectedOutcome == outcome;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.cprGreen.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.cprGreen
                        : AppColors.surfaceElevated,
                    width: 1,
                  ),
                ),
                child: RadioListTile<String>(
                  dense: true,
                  activeColor: AppColors.cprGreen,
                  title: Text(
                    outcome,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.cprGreen
                          : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  value: outcome,
                  groupValue: _selectedOutcome,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedOutcome = val;
                      });
                    }
                  },
                ),
              );
            }),

            const SizedBox(height: 10),

            // 結束備註
            TextField(
              controller: _noteController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                labelText: '結束交接備註 (選填)',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                hintText: '如：交接醫師李醫師、續壓入急救室...',
                hintStyle:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.surfaceElevated),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceElevated,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  widget.onConfirmEnd(
                    outcome: _selectedOutcome,
                    note: _noteController.text.trim(),
                    startNew: false,
                  );
                  Navigator.pop(context);
                },
                child: const Text('僅存檔歸檔', style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cprGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  widget.onConfirmEnd(
                    outcome: _selectedOutcome,
                    note: _noteController.text.trim(),
                    startNew: true,
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  '存檔並開新案',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

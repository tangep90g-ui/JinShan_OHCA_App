import 'package:flutter/material.dart';
import 'package:hsinchu_ohca_app/domain/models/ohca_session.dart';
import 'package:hsinchu_ohca_app/ui/core/app_colors.dart';

class LineExportDialog extends StatefulWidget {
  final OhcaSession session;
  final String reportText;
  final Future<void> Function() onCopy;
  final Future<void> Function() onArchive;

  const LineExportDialog({
    super.key,
    required this.session,
    required this.reportText,
    required this.onCopy,
    required this.onArchive,
  });

  @override
  State<LineExportDialog> createState() => _LineExportDialogState();
}

class _LineExportDialogState extends State<LineExportDialog> {
  bool _isCopied = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.description,
                    color: AppColors.cprGreen, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'LINE 救護交接文字報告',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceElevated),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    widget.reportText,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (_isCopied)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.cprGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: AppColors.cprGreen, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '已成功複製至剪貼簿！可直接切換至 LINE 貼上',
                      style: TextStyle(
                        color: AppColors.cprGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cprGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      await widget.onCopy();
                      setState(() => _isCopied = true);
                    },
                    icon: const Icon(Icons.copy, size: 20),
                    label: const Text(
                      '一鍵複製 LINE 報告',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.textMuted),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          title: const Text('案件歸檔並結束',
                              style: TextStyle(color: AppColors.textPrimary)),
                          content: const Text(
                            '確定要將當前急救案件儲存至歷史紀錄，並重置開新案件嗎？',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('取消'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.urgentRed),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('確定歸檔'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && mounted) {
                        await widget.onArchive();
                        if (mounted) Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.archive, size: 18),
                    label: const Text('案件歸檔'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hsinchu_ohca_app/data/services/line_report_formatter.dart';
import 'package:hsinchu_ohca_app/domain/models/ohca_session.dart';
import 'package:hsinchu_ohca_app/ui/core/app_colors.dart';

class LineExportDialog extends StatefulWidget {
  final OhcaSession session;
  final Future<void> Function() onCopy;
  final Future<void> Function() onArchive;

  const LineExportDialog({
    super.key,
    required this.session,
    required this.onCopy,
    required this.onArchive,
  });

  @override
  State<LineExportDialog> createState() => _LineExportDialogState();
}

class _LineExportDialogState extends State<LineExportDialog> {
  bool _isCopied = false;
  bool _showEditor = true;

  late TextEditingController _unitController;
  late TextEditingController _locationController;
  late TextEditingController _patientNameController;
  late TextEditingController _patientAgeController;
  late TextEditingController _caseStoryController;
  late TextEditingController _medHistoryController;
  late TextEditingController _allergyController;
  late TextEditingController _emtNamesController;
  late String _patientGender;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    _unitController = TextEditingController(text: s.squadName.isNotEmpty ? s.squadName : '金山91');
    _locationController = TextEditingController(text: s.location);
    _patientNameController = TextEditingController(text: s.patientName);
    _patientAgeController = TextEditingController(text: s.patientAge);
    _caseStoryController = TextEditingController(text: s.caseStory);
    _medHistoryController = TextEditingController(text: s.medicalHistory);
    _allergyController = TextEditingController(text: s.allergyHistory.isNotEmpty ? s.allergyHistory : '無');
    _emtNamesController = TextEditingController(text: s.emtNames);
    _patientGender = s.patientGender.isNotEmpty ? s.patientGender : '不詳';
  }

  @override
  void dispose() {
    _unitController.dispose();
    _locationController.dispose();
    _patientNameController.dispose();
    _patientAgeController.dispose();
    _caseStoryController.dispose();
    _medHistoryController.dispose();
    _allergyController.dispose();
    _emtNamesController.dispose();
    super.dispose();
  }

  void _syncToSession() {
    widget.session.squadName = _unitController.text.trim();
    widget.session.location = _locationController.text.trim();
    widget.session.patientName = _patientNameController.text.trim();
    widget.session.patientAge = _patientAgeController.text.trim();
    widget.session.patientGender = _patientGender;
    widget.session.caseStory = _caseStoryController.text.trim();
    widget.session.medicalHistory = _medHistoryController.text.trim();
    widget.session.allergyHistory = _allergyController.text.trim();
    widget.session.emtNames = _emtNamesController.text.trim();
  }

  String get _currentReportText {
    _syncToSession();
    return LineReportFormatter.generateReport(widget.session);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 頂部標題與切換分頁
            Row(
              children: [
                const Icon(Icons.description, color: AppColors.cprGreen, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'LINE 救護通報報告',
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
            const SizedBox(height: 6),

            // 模式切換按鈕：簡短輸入 vs 文字預覽
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_note_rounded, size: 18),
                        SizedBox(width: 4),
                        Text('填寫地點與案情病史', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    selected: _showEditor,
                    selectedColor: AppColors.cprGreen,
                    labelStyle: TextStyle(
                      color: _showEditor ? Colors.black : AppColors.textSecondary,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _showEditor = true;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.preview_rounded, size: 18),
                        SizedBox(width: 4),
                        Text('查看完整文字預覽', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    selected: !_showEditor,
                    selectedColor: AppColors.cprGreen,
                    labelStyle: TextStyle(
                      color: !_showEditor ? Colors.black : AppColors.textSecondary,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _syncToSession();
                        _showEditor = false;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 主內容區塊
            Expanded(
              child: _showEditor ? _buildEditorForm() : _buildPreviewBox(),
            ),

            const SizedBox(height: 12),
            if (_isCopied)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.cprGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.cprGreen, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '已複製金山分隊格式！可直接切換至 LINE 貼上',
                      style: TextStyle(
                        color: AppColors.cprGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

            // 底部操作按鈕
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
                      _syncToSession();
                      await widget.onCopy();
                      setState(() => _isCopied = true);
                    },
                    icon: const Icon(Icons.copy, size: 20),
                    label: const Text(
                      '一鍵複製 LINE 報告',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        final navigator = Navigator.of(context);
                        _syncToSession();
                        await widget.onArchive();
                        if (mounted) navigator.pop();
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

  Widget _buildEditorForm() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceElevated),
      ),
      child: ListView(
        children: [
          // 單位與地點
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _unitController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '2. 單位',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: TextField(
                  controller: _locationController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '4. 地點 (例如: 慈雲路O號)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 患者姓名、性別、年齡
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _patientNameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '5. 患者姓名',
                    hintText: '例: 馬O倫',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _patientGender,
                  dropdownColor: AppColors.surfaceElevated,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '性別',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    isDense: true,
                  ),
                  items: ['男', '女', '不詳']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _patientGender = val);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _patientAgeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '年齡',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 6. 案情簡述
          TextField(
            controller: _caseStoryController,
            maxLines: 2,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: '6. 案情 (例如: 家屬表示剛倒地呼叫無反應...)',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surfaceElevated,
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),

          // 7. 過去病史與過敏史
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _medHistoryController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '7. 過去病史 (例: 精神疾病 / 高血壓)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _allergyController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '過敏史 (預設無)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 8. 出勤同仁名單
          TextField(
            controller: _emtNamesController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: '8. 出勤人員名單 (無預設，請直接輸入或留空)',
              hintText: '金山 某某某 (T2)\n金山志工 某某某 (T1)\n\nTP某某某(輪休)',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surfaceElevated,
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '💡 提示：關鍵時間鏈、CPR歷時、電擊與給藥統計已由 App 自動記錄，複製時會自動組合！',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceElevated),
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          _currentReportText,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12.5,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

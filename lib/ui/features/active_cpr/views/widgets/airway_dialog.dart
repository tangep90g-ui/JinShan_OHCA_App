import 'package:flutter/material.dart';
import 'package:hsinchu_ohca_app/ui/core/app_colors.dart';

class AirwayDialog extends StatefulWidget {
  final Function({
    required String type,
    required String size,
    bool isVideoLaryngoscope,
    int? depthCm,
  }) onConfirm;

  const AirwayDialog({super.key, required this.onConfirm});

  @override
  State<AirwayDialog> createState() => _AirwayDialogState();
}

class _AirwayDialogState extends State<AirwayDialog> {
  String _selectedType = 'SGA (i-gel)';
  String _selectedSize = '#4 (中等成人 50-90kg)';
  bool _useVideoLaryngoscope = false;
  int _depthCm = 22;

  final Map<String, List<String>> _options = {
    'SGA (i-gel)': [
      '#3 (小型成人 30-60kg)',
      '#4 (中等成人 50-90kg)',
      '#5 (大型成人 >90kg)',
    ],
    'SGA (LMA)': ['#3', '#4', '#5'],
    'ETT (氣管內管)': ['6.5 mm', '7.0 mm', '7.5 mm', '8.0 mm'],
    'BVM 甦醒球': ['成人型面罩通氣'],
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('🫁 呼吸道處置建立',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('選擇呼吸道器械類型：',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedType,
              dropdownColor: AppColors.surfaceElevated,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(),
              ),
              items: _options.keys
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedType = val;
                    _selectedSize = _options[val]!.first;
                  });
                }
              },
            ),
            const SizedBox(height: 14),
            const Text('型號 / 尺寸：',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedSize,
              dropdownColor: AppColors.surfaceElevated,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(),
              ),
              items: (_options[_selectedType] ?? [])
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedSize = val);
              },
            ),
            if (_selectedType.startsWith('ETT')) ...[
              const SizedBox(height: 14),
              CheckboxListTile(
                title: const Text('使用視訊喉頭鏡 (VL)',
                    style: TextStyle(color: AppColors.textPrimary)),
                value: _useVideoLaryngoscope,
                activeColor: AppColors.cprGreen,
                onChanged: (val) =>
                    setState(() => _useVideoLaryngoscope = val ?? false),
                contentPadding: EdgeInsets.zero,
              ),
              Row(
                children: [
                  const Text('固定深度：',
                      style: TextStyle(color: AppColors.textSecondary)),
                  Expanded(
                    child: Slider(
                      value: _depthCm.toDouble(),
                      min: 18,
                      max: 26,
                      divisions: 8,
                      label: '$_depthCm cm',
                      activeColor: AppColors.cprGreen,
                      onChanged: (val) =>
                          setState(() => _depthCm = val.toInt()),
                    ),
                  ),
                  Text('$_depthCm cm',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.cprGreen),
          onPressed: () {
            Navigator.pop(context);
            widget.onConfirm(
              type: _selectedType,
              size: _selectedSize,
              isVideoLaryngoscope: _useVideoLaryngoscope,
              depthCm: _selectedType.startsWith('ETT') ? _depthCm : null,
            );
          },
          child: const Text('確認記錄',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

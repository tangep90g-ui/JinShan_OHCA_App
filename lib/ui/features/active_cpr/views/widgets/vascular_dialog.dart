import 'package:flutter/material.dart';
import 'package:hsinchu_ohca_app/ui/core/app_colors.dart';

class VascularDialog extends StatefulWidget {
  final Function({required String type, required String site}) onConfirm;

  const VascularDialog({super.key, required this.onConfirm});

  @override
  State<VascularDialog> createState() => _VascularDialogState();
}

class _VascularDialogState extends State<VascularDialog> {
  String _type = 'EZ-IO 骨內針';
  String _site = '右側近端脛骨 (Proximal Tibia)';

  final List<String> _ioSites = [
    '右側近端脛骨 (Proximal Tibia)',
    '左側近端脛骨 (Proximal Tibia)',
    '右側肱骨頭 (Humeral Head)',
    '左側肱骨頭 (Humeral Head)',
  ];

  final List<String> _ivSites = [
    '右手上肢周邊靜脈 (18G)',
    '左手上肢周邊靜脈 (18G)',
    '右手上肢周邊靜脈 (20G)',
    '左手上肢周邊靜脈 (20G)',
    '右肘正中靜脈 (Antecubital)',
    '左肘正中靜脈 (Antecubital)',
  ];

  @override
  Widget build(BuildContext context) {
    final currentSites = _type.contains('IO') ? _ioSites : _ivSites;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('🩸 建立血管通路',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('EZ-IO 骨內針')),
                    selected: _type.contains('IO'),
                    selectedColor: AppColors.cprGreen,
                    backgroundColor: AppColors.surfaceElevated,
                    labelStyle: TextStyle(
                      color: _type.contains('IO')
                          ? Colors.black
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _type = 'EZ-IO 骨內針';
                        _site = _ioSites.first;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('周邊靜脈 IV')),
                    selected: _type.contains('IV'),
                    selectedColor: AppColors.drugBlue,
                    backgroundColor: AppColors.surfaceElevated,
                    labelStyle: TextStyle(
                      color: _type.contains('IV')
                          ? Colors.black
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _type = '周邊靜脈 IV';
                        _site = _ivSites.first;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('選擇穿刺部位：',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            ...currentSites.map((site) {
              return RadioListTile<String>(
                value: site,
                groupValue: _site,
                activeColor:
                    _type.contains('IO') ? AppColors.cprGreen : AppColors.drugBlue,
                title: Text(site,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13.5)),
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  if (val != null) setState(() => _site = val);
                },
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _type.contains('IO') ? AppColors.cprGreen : AppColors.drugBlue,
          ),
          onPressed: () {
            Navigator.pop(context);
            widget.onConfirm(type: _type, site: _site);
          },
          child: Text(
            '確認建立',
            style: TextStyle(
              color: _type.contains('IO') ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

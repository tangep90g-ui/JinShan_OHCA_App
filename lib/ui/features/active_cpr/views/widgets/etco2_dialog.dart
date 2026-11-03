import 'package:flutter/material.dart';
import 'package:hsinchu_ohca_app/ui/core/app_colors.dart';

class Etco2Dialog extends StatefulWidget {
  final double currentEtco2;
  final Function(double value) onConfirm;

  const Etco2Dialog({
    super.key,
    required this.currentEtco2,
    required this.onConfirm,
  });

  @override
  State<Etco2Dialog> createState() => _Etco2DialogState();
}

class _Etco2DialogState extends State<Etco2Dialog> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentEtco2 <= 0 ? 20 : widget.currentEtco2;
  }

  @override
  Widget build(BuildContext context) {
    final isRoscLevel = _value >= 40;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('📊 ETCO2 數值監測記錄',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_value.toInt()} mmHg',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: isRoscLevel ? AppColors.urgentRed : AppColors.roscCyan,
            ),
          ),
          if (isRoscLevel)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.urgentRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.urgentRed),
              ),
              child: const Text(
                '⚡ 數值顯著回升 (≥40 mmHg)，高度提示可能 ROSC！',
                style: TextStyle(
                    color: AppColors.urgentRed,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          Slider(
            value: _value,
            min: 5,
            max: 70,
            divisions: 65,
            activeColor: isRoscLevel ? AppColors.urgentRed : AppColors.roscCyan,
            onChanged: (val) => setState(() => _value = val),
          ),
          const SizedBox(height: 10),
          const Text('快速數值選取：',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [10, 15, 20, 25, 30, 35, 40, 45, 50].map((v) {
              return ActionChip(
                label: Text('$v'),
                backgroundColor: AppColors.surfaceElevated,
                labelStyle: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13),
                onPressed: () => setState(() => _value = v.toDouble()),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.roscCyan),
          onPressed: () {
            Navigator.pop(context);
            widget.onConfirm(_value);
          },
          child: const Text('儲存數值',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

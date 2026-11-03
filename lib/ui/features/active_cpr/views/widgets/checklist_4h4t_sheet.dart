import 'package:flutter/material.dart';
import 'package:hsinchu_ohca_app/ui/core/app_colors.dart';

class Checklist4H4TSheet extends StatefulWidget {
  const Checklist4H4TSheet({super.key});

  @override
  State<Checklist4H4TSheet> createState() => _Checklist4H4TSheetState();
}

class _Checklist4H4TSheetState extends State<Checklist4H4TSheet> {
  final Map<String, bool> _checkedItems = {
    '低血容量 (Hypovolemia) - 創傷出血/脫水，給予大量輸液': false,
    '缺氧 (Hypoxia) - 呼吸道阻塞，確認氧氣與 SGA/ETT 深度': false,
    '酸中毒 (Hydrogen ion) - 嚴重缺氧或代謝酸，給予充足換氣': false,
    '高/低血鉀 (Hyper/Hypokalemia) - 腎病透析洗腎病史': false,
    '低體溫 (Hypothermia) - 評估體溫，必要時回溫': false,
    '張力性氣胸 (Tension Pneumothorax) - 單側呼吸音消失/胸部穿刺減壓': false,
    '心包填塞 (Cardiac Tamponade) - 創傷/頸靜脈怒張/心音低沉': false,
    '毒物/藥物過量 (Toxins) - 鴉片類過量/有機磷/抗抑鬱劑': false,
    '肺栓塞/冠狀動脈栓塞 (Thrombosis) - 猝死/心肌梗塞/DVT病史': false,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist_rtl,
                    color: AppColors.warningAmber, size: 22),
                const SizedBox(width: 8),
                const Text(
                  '4H4T 可逆病因現場排查',
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
            const Divider(color: AppColors.surfaceElevated),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _checkedItems.keys.map((item) {
                  final isChecked = _checkedItems[item]!;
                  return CheckboxListTile(
                    value: isChecked,
                    activeColor: AppColors.warningAmber,
                    checkColor: Colors.black,
                    title: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isChecked
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() => _checkedItems[item] = val ?? false);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceElevated,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('完成檢核關閉'),
            ),
          ],
        ),
      ),
    );
  }
}

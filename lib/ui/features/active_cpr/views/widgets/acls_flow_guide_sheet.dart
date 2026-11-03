import 'package:flutter/material.dart';
import 'package:hsinchu_ohca_app/ui/core/app_colors.dart';

class AclsFlowGuideSheet extends StatelessWidget {
  const AclsFlowGuideSheet({super.key});

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
                      color: AppColors.cprGreen.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.account_tree_rounded,
                        color: AppColors.cprGreen, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACLS 到院前急救處置流程指引',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '金山分隊 OHCA 現場決策對照表',
                        style: TextStyle(
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

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // 1. 可電擊心律分支 (Shockable: VF / pVT)
                  _buildBranchCard(
                    title: '⚡ 可電擊心律：VF (心室顫動) / pVT (無脈頻脈)',
                    titleColor: AppColors.urgentRed,
                    borderColor: AppColors.urgentRed.withValues(alpha: 0.4),
                    steps: [
                      '1. 立即執行 去顫電擊 (雙相波 200J)。',
                      '2. 電擊後立即下達「恢復 CPR 按壓 2 分鐘」，不需先量脈搏。',
                      '3. 建立 血管通路 (IV / EZ-IO 骨內針) 與 高級呼吸道 (i-gel / 插管)。',
                      '4. 第 2 次電擊後：給予 Epinephrine 1mg IV/IO (每 3~5 分鐘重複)。',
                      '5. 第 3 次電擊後：給予 抗心律不整藥物 Amiodarone 首劑 300mg (次劑 150mg) 或 Lidocaine 100mg。',
                      '6. 持續排查 4H4T 可逆病因。',
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 2. 不可電擊心律分支 (Non-shockable: Asystole / PEA)
                  _buildBranchCard(
                    title: '🚫 不可電擊心律：Asystole (心搏停止) / PEA (無脈電氣活動)',
                    titleColor: AppColors.warningAmber,
                    borderColor: AppColors.warningAmber.withValues(alpha: 0.4),
                    steps: [
                      '1. 立即恢復高品質 CPR 按壓 2 分鐘，不可電擊。',
                      '2. 儘速給予 Epinephrine 1mg IV/IO (越快越好，每 3~5 分鐘一次)。',
                      '3. 儘早建立 高級呼吸道 (SGA i-gel / ETT) 並接上 ETCO2。',
                      '4. 積極尋找並處置 4H4T（低血容量、缺氧、張力性氣胸、高血鉀等）。',
                      '5. 每 2 分鐘循環評估心律與脈搏。',
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 3. ROSC 自發循環恢復處置
                  _buildBranchCard(
                    title: '🌟 自發循環恢復 (ROSC) 復甦後照護',
                    titleColor: AppColors.roscCyan,
                    borderColor: AppColors.roscCyan.withValues(alpha: 0.4),
                    steps: [
                      '1. 捫及頸動脈博動、ETCO2 突然躍升 (>40 mmHg)。',
                      '2. 立即測量生命徵象 (BP, HR, SpO2, 血糖, 體溫)。',
                      '3. 維持呼吸道暢通，目標 SpO2 92-98%，避免過度換氣 (10次/分)。',
                      '4. 若收縮壓 SBP < 90 mmHg，給予輸液灌流。',
                      '5. 儘速完成 12 導程心電圖 (12-Lead ECG)，評估 STEMI。',
                      '6. 迅速穩定後送往重度級急救責任醫院。',
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 4. 高品質 CPR 核心要點
                  _buildBranchCard(
                    title: '🫀 高品質 CPR 現場五大原則',
                    titleColor: AppColors.cprGreen,
                    borderColor: AppColors.cprGreen.withValues(alpha: 0.4),
                    steps: [
                      '• 按壓速率：100 ~ 120 次/分鐘 (請跟隨 App 110bpm 節拍器)。',
                      '• 按壓深度：成人至少 5 公分，但不超過 6 公分。',
                      '• 胸迴彈：每次按壓後完全回彈，切勿倚靠在胸壁上。',
                      '• 中斷最小化：分析心律與電擊中斷時間控制在 10 秒以內。',
                      '• 避免過度換氣：進階氣道後每 6 秒給予 1 次吹氣 (10次/分)。',
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchCard({
    required String title,
    required Color titleColor,
    required Color borderColor,
    required List<String> steps,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                step,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hsinchu_ohca_app/domain/models/ohca_session.dart';
import 'package:hsinchu_ohca_app/domain/models/rhythm_type.dart';
import 'package:hsinchu_ohca_app/ui/core/app_colors.dart';

class ActionKeypad extends StatelessWidget {
  final OhcaSession session;
  final Function(RhythmType) onRhythmSelect;
  final Function(int joules) onDefibrillate;
  final VoidCallback onEpinephrine;
  final Function(double doseMg) onAmiodarone;
  final Function(double doseMg) onLidocaine;
  final VoidCallback onToggleLucas;
  final VoidCallback onOpenAirwayDialog;
  final VoidCallback onOpenVascularDialog;
  final VoidCallback onOpenEtco2Dialog;
  final VoidCallback onRosc;

  const ActionKeypad({
    super.key,
    required this.session,
    required this.onRhythmSelect,
    required this.onDefibrillate,
    required this.onEpinephrine,
    required this.onAmiodarone,
    required this.onLidocaine,
    required this.onToggleLucas,
    required this.onOpenAirwayDialog,
    required this.onOpenVascularDialog,
    required this.onOpenEtco2Dialog,
    required this.onRosc,
  });

  void _showRhythmBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    '🫀 心律分析波形判定',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  '⚡ 可電擊心律 (Shockable)',
                  style: TextStyle(
                    color: AppColors.urgentRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.urgentRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          onRhythmSelect(RhythmType.vf);
                        },
                        child: const Text('VF 心室顫動',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.urgentRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          onRhythmSelect(RhythmType.pvt);
                        },
                        child: const Text('pVT 無脈心室頻脈',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  '🚫 不可電擊心律 (Non-Shockable)',
                  style: TextStyle(
                    color: AppColors.warningAmber,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceElevated,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                                color: AppColors.warningAmber),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          onRhythmSelect(RhythmType.pea);
                        },
                        child: const Text('PEA 無脈電氣活動',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceElevated,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: AppColors.textMuted),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          onRhythmSelect(RhythmType.asystole);
                        },
                        child: const Text('Asystole 心搏停止',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roscCyan.withOpacity(0.2),
                    foregroundColor: AppColors.roscCyan,
                    side: const BorderSide(color: AppColors.roscCyan),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    onRhythmSelect(RhythmType.rosc);
                  },
                  child: const Text('🌟 ROSC 捫及脈搏 (自發循環恢復)',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAntiarrhythmicDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('💊 抗心律不整藥物選擇',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.shockPurple,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                onAmiodarone(300);
              },
              child: const Text('Amiodarone 第 1 劑 (300 mg)',
                  style: TextStyle(fontSize: 15, color: Colors.white)),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.shockPurple.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                onAmiodarone(150);
              },
              child: const Text('Amiodarone 第 2 劑 (150 mg)',
                  style: TextStyle(fontSize: 15, color: Colors.white)),
            ),
            const Divider(color: AppColors.surfaceElevated, height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceElevated,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                onLidocaine(100);
              },
              child: const Text('Lidocaine (1~1.5 mg/kg, 預設 100mg)',
                  style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 階段一：心律分析與去顫電擊 (到場立即處置) ───
          _buildSectionHeader(
            '① 到場立即判定與去顫',
            Icons.flash_on_rounded,
            AppColors.urgentRed,
          ),
          Row(
            children: [
              // 1. 心律分析判定 (先分析)
              Expanded(
                child: SizedBox(
                  height: 62,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceElevated,
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(
                          color: AppColors.shockPurple, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _showRhythmBottomSheet(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.monitor_heart,
                            size: 26, color: AppColors.shockPurple),
                        const SizedBox(width: 6),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('1. 心律分析判定',
                                style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              session.latestRhythm.displayName,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 2. 執行去顫電擊 (可電擊波形立即放電)
              Expanded(
                child: SizedBox(
                  height: 62,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.urgentRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => onDefibrillate(200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt, size: 28),
                        const SizedBox(width: 6),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('2. 執行電擊(200J)',
                                style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900)),
                            Text('已電擊 ${session.totalShocks} 次',
                                style: const TextStyle(
                                    fontSize: 11.5, color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // ─── 階段二：高級呼吸道與機械按壓 (第 1~2 循環內建立) ───
          _buildSectionHeader(
            '② 進階裝備與氣道支持',
            Icons.health_and_safety_rounded,
            AppColors.cprGreen,
          ),
          Row(
            children: [
              // 3. LUCAS 機械按壓
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: InkWell(
                    onTap: onToggleLucas,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: session.isLucasUsed
                            ? AppColors.warningAmber.withOpacity(0.2)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: session.isLucasUsed
                              ? AppColors.warningAmber
                              : AppColors.surfaceElevated,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.precision_manufacturing,
                            size: 22,
                            color: session.isLucasUsed
                                ? AppColors.warningAmber
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.isLucasUsed ? 'LUCAS 運轉中' : '3. LUCAS 上機',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: session.isLucasUsed
                                      ? AppColors.warningAmber
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                session.isLucasUsed ? '機械按壓中' : '點擊切換上機',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 4. 高級呼吸道 (i-gel / 插管)
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: InkWell(
                    onTap: onOpenAirwayDialog,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: session.airwaySummary != null
                            ? AppColors.cprGreen.withOpacity(0.18)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: session.airwaySummary != null
                              ? AppColors.cprGreen
                              : AppColors.surfaceElevated,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.air,
                            size: 22,
                            color: session.airwaySummary != null
                                ? AppColors.cprGreen
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('4. 高級呼吸道',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary)),
                              Text(
                                session.airwaySummary != null
                                    ? session.airwaySummary!
                                    : 'SGA i-gel / 插管',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: session.airwaySummary != null
                                      ? AppColors.cprGreen
                                      : AppColors.textMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // ─── 階段三：循環給藥與品質監控 (持續急救循環) ───
          _buildSectionHeader(
            '③ 通路給藥與品質監控',
            Icons.medication_liquid_rounded,
            AppColors.drugBlue,
          ),
          // 第一列：5. 血管通路 (IV/IO) + 6. Epinephrine 1mg
          Row(
            children: [
              // 5. 血管通路
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: InkWell(
                    onTap: onOpenVascularDialog,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: session.vascularSummary != null
                            ? AppColors.cprGreen.withOpacity(0.18)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: session.vascularSummary != null
                              ? AppColors.cprGreen
                              : AppColors.surfaceElevated,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.water_drop,
                            size: 20,
                            color: session.vascularSummary != null
                                ? AppColors.cprGreen
                                : AppColors.drugBlue,
                          ),
                          const SizedBox(width: 6),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('5. 血管通路',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary)),
                              Text(
                                session.vascularSummary != null
                                    ? '已建立通路'
                                    : 'IV / EZ-IO 骨針',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: session.vascularSummary != null
                                      ? AppColors.cprGreen
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 6. 給予 Epinephrine 1mg
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.drugBlue,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: onEpinephrine,
                    icon: const Icon(Icons.vaccines, size: 20),
                    label: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('6. Epi 1mg',
                            style: TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.bold)),
                        Text('已給 ${session.totalEpi} 劑 (每4分)',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black87)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 第二列：7. 抗心律不整藥 (Amio/Lido) + 8. ETCO2 監測
          Row(
            children: [
              // 7. 抗心律不整藥 (Amiodarone / Lidocaine)
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.drugBlue),
                      backgroundColor: AppColors.surfaceElevated,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    onPressed: () => _showAntiarrhythmicDialog(context),
                    icon: const Icon(Icons.medication,
                        size: 18, color: AppColors.drugBlue),
                    label: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('7. 抗心律藥',
                            style: TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.bold)),
                        Text(
                          'Amio/Lido (${session.totalAmiodarone + session.totalLidocaine}劑)',
                          style: const TextStyle(
                              fontSize: 10.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 8. ETCO2 數值監測
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: InkWell(
                    onTap: onOpenEtco2Dialog,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.roscCyan.withValues(alpha: 0.8),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.waves,
                              size: 18, color: AppColors.roscCyan),
                          const SizedBox(width: 6),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('8. ETCO2 監測',
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary)),
                              Text(
                                session.latestEtco2 != null
                                    ? '${session.latestEtco2!.toInt()} mmHg'
                                    : '按壓品質 / ROSC',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.roscCyan,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

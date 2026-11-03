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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          // 第一行：⚡ 去顫電擊 與 🫀 心律分析 (核心主按鈕)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 64,
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
                            const Text('去顫電擊 (200J)',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900)),
                            Text('已電擊 ${session.totalShocks} 次',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 64,
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
                            const Text('心律分析判定',
                                style: TextStyle(
                                    fontSize: 15,
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
            ],
          ),

          const SizedBox(height: 10),

          // 第二行：💉 給予 Epi 1mg 與 💊 抗心律不整藥物
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.drugBlue,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onEpinephrine,
                    icon: const Icon(Icons.vaccines, size: 24),
                    label: Text(
                      'Epi 1mg (已給 ${session.totalEpi} 劑)',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.drugBlue),
                      backgroundColor: AppColors.surfaceElevated,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showAntiarrhythmicDialog(context),
                    icon: const Icon(Icons.medication,
                        size: 20, color: AppColors.drugBlue),
                    label: Text(
                      '抗心律藥 (${session.totalAmiodarone + session.totalLidocaine}劑)',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 第三行：新竹市裝備處置快捷面板 (LUCAS | 呼吸道 | 血管通路 | ETCO2)
          Row(
            children: [
              // LUCAS 按鈕
              Expanded(
                child: InkWell(
                  onTap: onToggleLucas,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: session.isLucasUsed
                          ? AppColors.warningAmber.withOpacity(0.2)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: session.isLucasUsed
                            ? AppColors.warningAmber
                            : AppColors.textMuted,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.precision_manufacturing,
                          size: 18,
                          color: session.isLucasUsed
                              ? AppColors.warningAmber
                              : AppColors.textSecondary,
                        ),
                        Text(
                          session.isLucasUsed ? 'LUCAS 運轉中' : 'LUCAS 上機',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: session.isLucasUsed
                                ? AppColors.warningAmber
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 呼吸道按鈕
              Expanded(
                child: InkWell(
                  onTap: onOpenAirwayDialog,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: session.airwaySummary != null
                          ? AppColors.cprGreen.withOpacity(0.15)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: session.airwaySummary != null
                            ? AppColors.cprGreen
                            : AppColors.textMuted,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.air,
                          size: 18,
                          color: session.airwaySummary != null
                              ? AppColors.cprGreen
                              : AppColors.textSecondary,
                        ),
                        Text(
                          session.airwaySummary != null ? '呼吸道已立' : '呼吸道(SGA/管)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: session.airwaySummary != null
                                ? AppColors.cprGreen
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 血管通路按鈕
              Expanded(
                child: InkWell(
                  onTap: onOpenVascularDialog,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: session.vascularSummary != null
                          ? AppColors.cprGreen.withOpacity(0.15)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: session.vascularSummary != null
                            ? AppColors.cprGreen
                            : AppColors.textMuted,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 18,
                          color: session.vascularSummary != null
                              ? AppColors.cprGreen
                              : AppColors.textSecondary,
                        ),
                        Text(
                          session.vascularSummary != null ? '通路已立' : '通路 (IV/IO)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: session.vascularSummary != null
                                ? AppColors.cprGreen
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // ETCO2 按鈕
              Expanded(
                child: InkWell(
                  onTap: onOpenEtco2Dialog,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.roscCyan),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.waves,
                            size: 18, color: AppColors.roscCyan),
                        Text(
                          session.latestEtco2 != null
                              ? '${session.latestEtco2!.toInt()} mmHg'
                              : 'ETCO2 監測',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.roscCyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

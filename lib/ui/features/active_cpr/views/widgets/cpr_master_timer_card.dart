import 'package:flutter/material.dart';
import 'package:hsinchu_ohca_app/ui/core/app_colors.dart';

class CprMasterTimerCard extends StatelessWidget {
  final int totalElapsedSeconds;
  final int cycleSecondsRemaining;
  final int currentCycle;
  final int? epiSecondsRemaining;
  final bool isRunning;
  final bool isPaused;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onNextCycle;

  final bool isMetronomeEnabled;
  final VoidCallback? onToggleMetronome;

  const CprMasterTimerCard({
    super.key,
    required this.totalElapsedSeconds,
    required this.cycleSecondsRemaining,
    required this.currentCycle,
    this.epiSecondsRemaining,
    required this.isRunning,
    required this.isPaused,
    this.isMetronomeEnabled = false,
    this.onToggleMetronome,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onNextCycle,
  });

  String _formatTime(int totalSec) {
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatCycleTime(int sec) {
    if (sec < 0) {
      final overtime = -sec;
      final m = overtime ~/ 60;
      final s = overtime % 60;
      return '+${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return _formatTime(sec);
  }

  Color _getCycleColor() {
    if (cycleSecondsRemaining <= 0) return AppColors.urgentRed;
    if (cycleSecondsRemaining <= 30) return AppColors.warningAmber;
    return AppColors.cprGreen;
  }

  @override
  Widget build(BuildContext context) {
    final cycleColor = _getCycleColor();
    final progress = (120 - cycleSecondsRemaining).clamp(0, 120) / 120.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceElevated, width: 1.5),
      ),
      child: Column(
        children: [
          // 頂部小標題列：總時間與藥物倒數
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 總 CPR 時間
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '總急救時間 ${_formatTime(totalElapsedSeconds)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Epinephrine 倒數膠囊標籤
              Row(
                children: [
                  if (onToggleMetronome != null)
                    GestureDetector(
                      onTap: onToggleMetronome,
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isMetronomeEnabled
                              ? AppColors.cprGreen.withValues(alpha: 0.2)
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isMetronomeEnabled
                                ? AppColors.cprGreen
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.speed_rounded,
                              size: 13,
                              color: isMetronomeEnabled
                                  ? AppColors.cprGreen
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '110 bpm',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isMetronomeEnabled
                                    ? AppColors.cprGreen
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (epiSecondsRemaining != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: epiSecondsRemaining! <= 30
                            ? AppColors.warningAmber.withValues(alpha: 0.2)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: epiSecondsRemaining! <= 30
                              ? AppColors.warningAmber
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.medication,
                              size: 14, color: AppColors.drugBlue),
                          const SizedBox(width: 4),
                          Text(
                            epiSecondsRemaining! > 0
                                ? 'Epi 下劑 ${_formatTime(epiSecondsRemaining!)}'
                                : '⚡ 可給予 Epi',
                            style: TextStyle(
                              color: epiSecondsRemaining! <= 30
                                  ? AppColors.warningAmber
                                  : AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 主倒數大字體與循環輪次
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '第 $currentCycle 循環',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                _formatCycleTime(cycleSecondsRemaining),
                style: TextStyle(
                  color: cycleColor,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),

          if (cycleSecondsRemaining < 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.urgentRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.urgentRed),
              ),
              child: const Text(
                '⚠️ 2分鐘循環已超時，請下達分析心律指令',
                style: TextStyle(
                  color: AppColors.urgentRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // 2分鐘循環進度條
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(cycleColor),
            ),
          ),

          const SizedBox(height: 14),

          // 控制按鈕群 (開始 / 暫停 / 恢復 / 手動下一循環)
          Row(
            children: [
              if (!isRunning)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cprGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: const Text(
                      '指令下達：開始 CPR',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else ...[
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: isPaused ? onResume : onPause,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPaused
                          ? AppColors.cprGreen
                          : AppColors.warningAmber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                    label: Text(
                      isPaused ? '指令：恢復按壓' : '指令：暫停按壓',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: onNextCycle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.textMuted),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.skip_next, size: 18),
                    label: const Text(
                      '指令：換手/下循環',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

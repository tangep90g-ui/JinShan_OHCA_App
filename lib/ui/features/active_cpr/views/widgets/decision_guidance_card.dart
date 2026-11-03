import 'package:flutter/material.dart';
import 'package:hsinchu_ohca_app/domain/models/decision_guidance.dart';
import 'package:hsinchu_ohca_app/ui/core/app_colors.dart';

class DecisionGuidanceCard extends StatelessWidget {
  final DecisionGuidance guidance;
  final VoidCallback onOpen4H4T;

  const DecisionGuidanceCard({
    super.key,
    required this.guidance,
    required this.onOpen4H4T,
  });

  Color _getUrgencyColor() {
    switch (guidance.urgency) {
      case GuidanceUrgency.normal:
        return AppColors.cprGreen;
      case GuidanceUrgency.warning:
        return AppColors.warningAmber;
      case GuidanceUrgency.critical:
        return AppColors.urgentRed;
      case GuidanceUrgency.rosc:
        return AppColors.roscCyan;
    }
  }

  Color _getGlowColor() {
    switch (guidance.urgency) {
      case GuidanceUrgency.normal:
        return AppColors.cprGreenGlow;
      case GuidanceUrgency.warning:
        return AppColors.warningAmberGlow;
      case GuidanceUrgency.critical:
        return AppColors.urgentRedGlow;
      case GuidanceUrgency.rosc:
        return const Color(0x3300E5FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _getUrgencyColor();
    final glowColor = _getGlowColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: urgencyColor, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: urgencyColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assistant_direction,
                        size: 16, color: urgencyColor),
                    const SizedBox(width: 5),
                    Text(
                      'ACLS 下一步指引',
                      style: TextStyle(
                        color: urgencyColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onOpen4H4T,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.checklist_rtl,
                    size: 16, color: AppColors.warningAmber),
                label: const Text(
                  '4H4T 檢核',
                  style: TextStyle(
                    color: AppColors.warningAmber,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            guidance.primaryTitle,
            style: TextStyle(
              color: urgencyColor,
              fontWeight: FontWeight.w900,
              fontSize: 19,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            guidance.primaryDetail,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          if (guidance.secondaryAction.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '💡 提示：${guidance.secondaryAction}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

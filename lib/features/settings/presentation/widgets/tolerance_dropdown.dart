import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/jb_icons.dart';

class ToleranceDropdown extends StatelessWidget {
  final int minutes;

  const ToleranceDropdown({super.key, this.minutes = 15});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x18),
      decoration: BoxDecoration(
        color: c.bgSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.lateTolerance,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.lateToleranceSub,
                  style: TextStyle(
                    color: c.textMute,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.x12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x12, vertical: AppSpacing.x10),
            decoration: BoxDecoration(
              color: c.bgElev,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: c.border, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$minutes',
                      style: AppTypography.mono(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                      ),
                    ),
                    Text(
                      AppStrings.min,
                      style: TextStyle(
                        color: c.textMute,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.x10),
                JbIcon(JbIcon.chevronDown, size: 16, color: c.textMute),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

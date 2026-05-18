import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_icons.dart';

class MonthFilterChip extends StatelessWidget {
  final String monthLabel;
  final String yearLabel;
  final VoidCallback? onTap;

  const MonthFilterChip({
    super.key,
    required this.monthLabel,
    required this.yearLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Material(
      color: c.bgElev,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x12, vertical: AppSpacing.x8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.border, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              JbIcon(JbIcon.calendar, size: 14, color: c.accent),
              const SizedBox(width: AppSpacing.x8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monthLabel,
                    style: TextStyle(
                      color: c.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    yearLabel,
                    style: TextStyle(
                      color: c.textMute,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.x6),
              JbIcon(JbIcon.chevronDown, size: 14, color: c.textMute),
            ],
          ),
        ),
      ),
    );
  }
}

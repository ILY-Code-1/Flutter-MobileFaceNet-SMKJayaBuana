import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/mock_data.dart';

class JbStatusPill extends StatelessWidget {
  final StudentStatus status;
  final String? timeOverride;

  const JbStatusPill({
    super.key,
    required this.status,
    this.timeOverride,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;

    final Color bg;
    final Color fg;
    final String label;
    String? timeText;
    switch (status) {
      case StudentStatus.present:
        bg = c.success.withValues(alpha: 0.14);
        fg = c.success;
        label = AppStrings.statusIn;
        timeText = timeOverride;
        break;
      case StudentStatus.late:
        bg = c.warn.withValues(alpha: 0.14);
        fg = c.warn;
        label = AppStrings.statusLate;
        timeText = timeOverride;
        break;
      case StudentStatus.absent:
        bg = c.danger.withValues(alpha: 0.14);
        fg = c.danger;
        label = AppStrings.statusAbsent;
        timeText = null;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x10, vertical: AppSpacing.x6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          if (timeText != null) ...[
            Text(' · ',
                style: TextStyle(color: fg, fontWeight: FontWeight.w800)),
            Text(
              timeText,
              style: AppTypography.mono(
                  fontSize: 11, fontWeight: FontWeight.w800, color: fg),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_icons.dart';

class ExportFloatingBar extends StatelessWidget {
  final VoidCallback? onExport;
  const ExportFloatingBar({super.key, this.onExport});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Container(
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x18,
        AppSpacing.x12,
        AppSpacing.x10,
        AppSpacing.x12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.exportLabel,
                  style: TextStyle(
                    color: c.onPrimary.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.exportSummary,
                  style: TextStyle(
                    color: c.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.x10),
          Material(
            color: c.accent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: onExport,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x14, vertical: AppSpacing.x10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    JbIcon(JbIcon.download, size: 16, color: c.onAccent),
                    const SizedBox(width: AppSpacing.x6),
                    Text(
                      AppStrings.exportPdf,
                      style: TextStyle(
                        color: c.onAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

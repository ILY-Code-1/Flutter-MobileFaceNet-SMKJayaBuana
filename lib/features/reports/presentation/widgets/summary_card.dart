import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

enum SummaryKind { present, late, absent }

class SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final int percent;
  final SummaryKind kind;

  const SummaryCard({
    super.key,
    required this.label,
    required this.count,
    required this.percent,
    required this.kind,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;

    final Color tint;
    switch (kind) {
      case SummaryKind.present:
        tint = c.success;
        break;
      case SummaryKind.late:
        tint = c.warn;
        break;
      case SummaryKind.absent:
        tint = c.danger;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.x14),
      decoration: BoxDecoration(
        color: c.bgElev,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: c.textMute,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.x8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: c.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: AppSpacing.x8),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    '$percent%',
                    style: TextStyle(
                      color: tint,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
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

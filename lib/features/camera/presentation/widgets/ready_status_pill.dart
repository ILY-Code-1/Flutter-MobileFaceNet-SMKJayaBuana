import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ReadyStatusPill extends StatelessWidget {
  final int checked;
  final int total;

  const ReadyStatusPill({
    super.key,
    this.checked = 26,
    this.total = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x14, vertical: AppSpacing.x10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2540).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.lightSuccess,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.lightSuccess.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.x8),
          const Text(
            AppStrings.ready,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: AppSpacing.x12),
          Text(
            '$checked / $total',
            style: AppTypography.mono(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.lightAccent,
            ),
          ),
          const SizedBox(width: AppSpacing.x6),
          Text(
            'checked\nin today',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

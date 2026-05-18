import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/jb_icons.dart';

class SchedulePickerRow extends StatelessWidget {
  final String clockInTime;
  final String clockOutTime;
  final String clockInLabel;
  final String clockOutLabel;
  final String clockInHint;
  final String clockOutHint;

  const SchedulePickerRow({
    super.key,
    required this.clockInTime,
    required this.clockOutTime,
    required this.clockInLabel,
    required this.clockOutLabel,
    required this.clockInHint,
    required this.clockOutHint,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeCard(
            label: clockInLabel,
            time: clockInTime,
            hint: clockInHint,
          ),
        ),
        const SizedBox(width: AppSpacing.x12),
        Expanded(
          child: _TimeCard(
            label: clockOutLabel,
            time: clockOutTime,
            hint: clockOutHint,
          ),
        ),
      ],
    );
  }
}

class _TimeCard extends StatelessWidget {
  final String label;
  final String time;
  final String hint;

  const _TimeCard({
    required this.label,
    required this.time,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
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
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.x10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: AppTypography.mono(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: c.text,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: JbIcon(JbIcon.chevronDown, size: 16, color: c.textMute),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x6),
          Text(
            hint,
            style: TextStyle(
              color: c.textFaint,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

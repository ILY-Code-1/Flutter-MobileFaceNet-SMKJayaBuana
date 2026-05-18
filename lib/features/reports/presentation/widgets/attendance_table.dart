import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/mock_data.dart';

class AttendanceTable extends StatelessWidget {
  final List<MockReportRow> rows;
  const AttendanceTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;

    return Container(
      decoration: BoxDecoration(
        color: c.bgElev,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border, width: 1.2),
      ),
      child: Column(
        children: [
          _Header(),
          for (int i = 0; i < rows.length; i++) ...[
            if (i != 0) Divider(color: c.border, height: 1, thickness: 1),
            _Row(row: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x14, vertical: AppSpacing.x10),
      decoration: BoxDecoration(
        color: c.bgSubtle,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg - 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              AppStrings.colStudent,
              style: TextStyle(
                color: c.textMute,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),
          _NumHeader(text: AppStrings.colP),
          _NumHeader(text: AppStrings.colL),
          _NumHeader(text: AppStrings.colA),
          const SizedBox(width: AppSpacing.x6),
          SizedBox(
            width: 46,
            child: Text(
              AppStrings.colPct,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: c.textMute,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumHeader extends StatelessWidget {
  final String text;
  const _NumHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return SizedBox(
      width: 28,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: c.textMute,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final MockReportRow row;
  const _Row({required this.row});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x14, vertical: AppSpacing.x12),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              row.name,
              style: TextStyle(
                color: c.text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _NumCell(value: row.present, color: c.success),
          _NumCell(value: row.late, color: c.warn),
          _NumCell(value: row.absent, color: c.danger),
          const SizedBox(width: AppSpacing.x6),
          SizedBox(width: 46, child: _PercentPill(percent: row.percent)),
        ],
      ),
    );
  }
}

class _NumCell extends StatelessWidget {
  final int value;
  final Color color;
  const _NumCell({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final isZero = value == 0;
    return SizedBox(
      width: 28,
      child: Text(
        '$value',
        textAlign: TextAlign.center,
        style: AppTypography.mono(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: isZero ? c.textFaint : color,
        ),
      ),
    );
  }
}

class _PercentPill extends StatelessWidget {
  final int percent;
  const _PercentPill({required this.percent});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final Color tint;
    if (percent >= 95) {
      tint = c.success;
    } else if (percent >= 80) {
      tint = c.warn;
    } else {
      tint = c.danger;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '$percent%',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: tint,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/mock_data.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../widgets/attendance_table.dart';
import '../widgets/export_floating_bar.dart';
import '../widgets/month_filter_chip.dart';
import '../widgets/summary_card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: _ReportsAppBar(),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x22,
                AppSpacing.x14,
                AppSpacing.x22,
                120,
              ),
              children: [
                Text(
                  AppStrings.classNameValue,
                  style: TextStyle(
                    color: c.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.x8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.attendance,
                        style: TextStyle(
                          color: c.text,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const MonthFilterChip(
                      monthLabel: 'June',
                      yearLabel: '2026',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x14),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: AppStrings.present,
                        count: MockData.totalPresent,
                        percent: 94,
                        kind: SummaryKind.present,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x10),
                    Expanded(
                      child: SummaryCard(
                        label: AppStrings.late,
                        count: MockData.totalLate,
                        percent: 4,
                        kind: SummaryKind.late,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x10),
                    Expanded(
                      child: SummaryCard(
                        label: AppStrings.absent,
                        count: MockData.totalAbsent,
                        percent: 2,
                        kind: SummaryKind.absent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x14),
                AttendanceTable(rows: MockData.reportRows),
              ],
            ),
            Positioned(
              left: AppSpacing.x18,
              right: AppSpacing.x18,
              bottom: AppSpacing.x18,
              child: ExportFloatingBar(onExport: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return AppBar(
      backgroundColor: c.bg,
      surfaceTintColor: c.bg,
      elevation: 0,
      centerTitle: true,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.x18),
        child: Material(
          color: c.bgElev,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: c.border, width: 1.2),
          ),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: JbIcon(JbIcon.chevronLeft, size: 18, color: c.text),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        AppStrings.reports,
        style: TextStyle(
          color: c.text,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.x18),
          child: Material(
            color: c.bgElev,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: c.border, width: 1.2),
            ),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: JbIcon(JbIcon.search, size: 18, color: c.text),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

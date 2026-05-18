import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../widgets/grade_picker.dart';
import '../widgets/schedule_picker_row.dart';
import '../widgets/tolerance_dropdown.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Grade _selectedGrade = Grade.xi;

  @override
  Widget build(BuildContext context) {
    final c = context.jb;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: _SettingsAppBar(),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x22,
            AppSpacing.x10,
            AppSpacing.x22,
            AppSpacing.x28,
          ),
          children: [
            _SectionLabel(text: AppStrings.sectionClass),
            const SizedBox(height: AppSpacing.x10),
            Text(
              AppStrings.whichClassQ,
              style: TextStyle(
                color: c.text,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.x14),
            GradePicker(
              selected: _selectedGrade,
              onChanged: (g) => setState(() => _selectedGrade = g),
            ),
            const SizedBox(height: AppSpacing.x22),
            _LabelText(text: AppStrings.className),
            const SizedBox(height: AppSpacing.x8),
            _ClassNameField(),
            const SizedBox(height: AppSpacing.x8),
            Text(
              AppStrings.classNameHint,
              style: TextStyle(
                color: c.textFaint,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.x28),
            _SectionLabel(text: AppStrings.sectionSchedule),
            const SizedBox(height: AppSpacing.x8),
            Text(
              AppStrings.schoolHours,
              style: TextStyle(
                color: c.text,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.x14),
            const SchedulePickerRow(
              clockInLabel: AppStrings.clockIn,
              clockOutLabel: AppStrings.clockOut,
              clockInTime: '07:00',
              clockOutTime: '15:30',
              clockInHint: AppStrings.gateOpens,
              clockOutHint: AppStrings.gateCloses,
            ),
            const SizedBox(height: AppSpacing.x12),
            const ToleranceDropdown(minutes: 15),
            const SizedBox(height: AppSpacing.x28),
            _SectionLabel(text: AppStrings.sectionDevice),
            const SizedBox(height: AppSpacing.x8),
            Text(
              AppStrings.thisTerminal,
              style: TextStyle(
                color: c.text,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.x14),
            _DeviceRowGroup(),
          ],
        ),
      ),
    );
  }
}

class _SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
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
      titleSpacing: 0,
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
        AppStrings.settings,
        style: TextStyle(
          color: c.text,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Text(
      text,
      style: TextStyle(
        color: c.accent,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _LabelText extends StatelessWidget {
  final String text;
  const _LabelText({required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Text(
      text,
      style: TextStyle(
        color: c.textMute,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _ClassNameField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x18, vertical: AppSpacing.x14),
      decoration: BoxDecoration(
        color: c.bgElev,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.classNameValue,
              style: TextStyle(
                color: c.text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x10, vertical: AppSpacing.x6),
            decoration: BoxDecoration(
              color: c.bgSubtle,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              AppStrings.edit,
              style: TextStyle(
                color: c.textMute,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceRowGroup extends StatelessWidget {
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
          _DeviceRow(
            label: AppStrings.deviceName,
            value: AppStrings.deviceNameValue,
          ),
          Divider(color: c.border, height: 1, thickness: 1),
          _DeviceRow(
            label: AppStrings.soundOnScan,
            value: AppStrings.soundOnScanValue,
          ),
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final String label;
  final String value;
  const _DeviceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x18, vertical: AppSpacing.x14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: c.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: c.textMute,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x8),
            JbIcon(JbIcon.chevronRight, size: 16, color: c.textFaint),
          ],
        ),
      ),
    );
  }
}

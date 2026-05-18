import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_icons.dart';

enum Grade { x, xi, xii }

class GradePicker extends StatelessWidget {
  final Grade selected;
  final ValueChanged<Grade> onChanged;

  const GradePicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GradeCard(
            roman: 'X',
            label: AppStrings.gradeTenth,
            sub: AppStrings.gradeTenthSub,
            selected: selected == Grade.x,
            onTap: () => onChanged(Grade.x),
          ),
        ),
        const SizedBox(width: AppSpacing.x12),
        Expanded(
          child: _GradeCard(
            roman: 'XI',
            label: AppStrings.gradeEleventh,
            sub: AppStrings.gradeEleventhSub,
            selected: selected == Grade.xi,
            onTap: () => onChanged(Grade.xi),
          ),
        ),
        const SizedBox(width: AppSpacing.x12),
        Expanded(
          child: _GradeCard(
            roman: 'XII',
            label: AppStrings.gradeTwelfth,
            sub: AppStrings.gradeTwelfthSub,
            selected: selected == Grade.xii,
            onTap: () => onChanged(Grade.xii),
          ),
        ),
      ],
    );
  }
}

class _GradeCard extends StatelessWidget {
  final String roman;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  const _GradeCard({
    required this.roman,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final bg = selected ? c.primary : c.bgElev;
    final fg = selected ? c.onPrimary : c.text;
    final subFg = selected
        ? c.onPrimary.withValues(alpha: 0.65)
        : c.textMute;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.x14, horizontal: AppSpacing.x10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? c.primary : c.border,
              width: 1.2,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  Text(
                    roman,
                    style: TextStyle(
                      color: fg,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(
                      color: subFg,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (selected)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: c.accent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: JbIcon(JbIcon.check,
                        size: 14, color: c.onAccent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

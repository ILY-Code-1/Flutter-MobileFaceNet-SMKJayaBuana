import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// 4-segment password strength meter. [level] 0..4.
class PasswordStrengthBar extends StatelessWidget {
  final int level;

  const PasswordStrengthBar({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final filled = level.clamp(0, 4);
    return Row(
      children: List.generate(4, (i) {
        final isOn = i < filled;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i == 3 ? 0 : AppSpacing.x6),
            height: 4,
            decoration: BoxDecoration(
              color: isOn ? c.accent : c.border,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/mock_data.dart';
import '../../../../core/widgets/jb_avatar.dart';
import '../../../../core/widgets/jb_status_pill.dart';

class StudentListTile extends StatelessWidget {
  final MockStudent student;
  final VoidCallback? onTap;

  const StudentListTile({super.key, required this.student, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4, vertical: AppSpacing.x10),
        child: Row(
          children: [
            JbAvatar(initials: student.initials, hue: student.hue, size: 44),
            const SizedBox(width: AppSpacing.x14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: TextStyle(
                      color: c.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student.nis,
                    style: TextStyle(
                      color: c.textMute,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.x10),
            JbStatusPill(
              status: student.status,
              timeOverride: student.status == StudentStatus.absent
                  ? null
                  : student.lastSeen,
            ),
          ],
        ),
      ),
    );
  }
}

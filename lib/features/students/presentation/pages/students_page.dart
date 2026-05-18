import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/mock_data.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../../../../routing/app_router.dart';
import '../widgets/student_list_tile.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: _StudentsAppBar(),
      floatingActionButton: _EnrollFab(
        onTap: () => Navigator.pushNamed(context, AppRoutes.addStudent),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x22,
                AppSpacing.x14,
                AppSpacing.x22,
                AppSpacing.x8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CLASS ${AppStrings.classNameValue}',
                    style: TextStyle(
                      color: c.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${MockData.totalFacesInClass}',
                        style: TextStyle(
                          color: c.text,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          AppStrings.studentsHeading,
                          style: TextStyle(
                            color: c.text,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          AppStrings.studentsCheckedSub,
                          style: TextStyle(
                            color: c.textMute,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x14),
                  _SearchBar(),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x18,
                  AppSpacing.x4,
                  AppSpacing.x18,
                  100,
                ),
                itemCount: MockData.students.length,
                separatorBuilder: (_, _) =>
                    Divider(color: c.border, height: 1, thickness: 1),
                itemBuilder: (_, i) =>
                    StudentListTile(student: MockData.students[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentsAppBar extends StatelessWidget implements PreferredSizeWidget {
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
        AppStrings.students,
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
                  child:
                      JbIcon(JbIcon.filter, size: 18, color: c.text),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x14, vertical: AppSpacing.x4),
      decoration: BoxDecoration(
        color: c.bgElev,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border, width: 1.2),
      ),
      child: Row(
        children: [
          JbIcon(JbIcon.search, size: 18, color: c.textMute),
          const SizedBox(width: AppSpacing.x10),
          Expanded(
            child: TextField(
              style: TextStyle(
                color: c.text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: AppStrings.searchHint,
                hintStyle: TextStyle(
                  color: c.textFaint,
                  fontWeight: FontWeight.w600,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x8, vertical: AppSpacing.x4),
            decoration: BoxDecoration(
              color: c.bgSubtle,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              '⌘K',
              style: TextStyle(
                color: c.textMute,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnrollFab extends StatelessWidget {
  final VoidCallback onTap;
  const _EnrollFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.x8, bottom: AppSpacing.x8),
      child: Material(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        elevation: 8,
        shadowColor: c.primary.withValues(alpha: 0.35),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x18, vertical: AppSpacing.x14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                JbIcon(JbIcon.plus, size: 18, color: c.onPrimary),
                const SizedBox(width: AppSpacing.x10),
                Text(
                  AppStrings.enrollFace,
                  style: TextStyle(
                    color: c.onPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

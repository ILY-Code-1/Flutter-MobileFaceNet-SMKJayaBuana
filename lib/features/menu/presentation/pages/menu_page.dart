import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/mock_data.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../../../../routing/app_router.dart';
import '../widgets/menu_tile.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x22,
            AppSpacing.x10,
            AppSpacing.x22,
            AppSpacing.x14,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.todayLabel,
                          style: TextStyle(
                            color: c.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x6),
                        RichText(
                          text: TextSpan(
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: c.text,
                              fontSize: 28,
                            ),
                            children: [
                              const TextSpan(text: AppStrings.helloHeadline),
                              TextSpan(
                                text: AppStrings.helloName,
                                style: theme.textTheme.headlineLarge
                                    ?.copyWith(
                                  color: c.text,
                                  fontSize: 28,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        Text(
                          AppStrings.helloPrompt,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: c.textMute,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CloseButton(
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.camera,
                      (r) => false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x22),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    MenuTile(
                      iconAsset: JbIcon.student,
                      title: AppStrings.tileStudents,
                      variant: MenuTileVariant.primary,
                      trailingMeta: TextSpan(
                        children: [
                          TextSpan(
                            text: '${MockData.totalEnrolled} ',
                            style: TextStyle(
                              color: c.accent,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const TextSpan(text: AppStrings.tileStudentsSub),
                        ],
                      ),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.students),
                    ),
                    const SizedBox(height: AppSpacing.x14),
                    MenuTile(
                      iconAsset: JbIcon.report,
                      title: AppStrings.tileReports,
                      trailingMeta: TextSpan(
                        children: [
                          TextSpan(
                            text: '${AppStrings.tileReportsMonth} ',
                            style: TextStyle(
                              color: c.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: AppStrings.tileReportsPct,
                            style: TextStyle(color: c.textMute),
                          ),
                        ],
                      ),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.reports),
                    ),
                    const SizedBox(height: AppSpacing.x14),
                    MenuTile(
                      iconAsset: JbIcon.settings,
                      title: AppStrings.tileSettings,
                      trailingMeta: TextSpan(
                        children: [
                          TextSpan(
                            text: 'XI ',
                            style: TextStyle(
                              color: c.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: '·  ',
                            style: TextStyle(color: c.textMute),
                          ),
                          TextSpan(
                            text: 'A ',
                            style: TextStyle(
                              color: c.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: AppStrings.tileSettingsSub,
                            style: TextStyle(color: c.textMute),
                          ),
                        ],
                      ),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.settings),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x10),
              _SignOutFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _CloseButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Material(
      color: c.bgSubtle,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: JbIcon(JbIcon.close, size: 18, color: c.text)),
        ),
      ),
    );
  }
}

class _SignOutFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.x14, horizontal: AppSpacing.x18),
      decoration: BoxDecoration(
        color: c.bgElev,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: c.border,
          width: 1.2,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          JbIcon(JbIcon.logout, size: 18, color: c.textMute),
          const SizedBox(width: AppSpacing.x8),
          Text(
            AppStrings.signOut,
            style: TextStyle(
              color: c.textMute,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            ' · ${AppStrings.appVersion}',
            style: TextStyle(
              color: c.textFaint,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

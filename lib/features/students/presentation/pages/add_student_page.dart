import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_button.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../../../../core/widgets/jb_text_field.dart';
import '../widgets/face_capture_slot.dart';

class AddStudentPage extends StatelessWidget {
  const AddStudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: _AddStudentAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const _StepProgressBar(currentStep: 2, totalSteps: 3),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x22,
                  AppSpacing.x18,
                  AppSpacing.x22,
                  AppSpacing.x18,
                ),
                children: [
                  Text(
                    AppStrings.stepLabel,
                    style: TextStyle(
                      color: c.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x8),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: c.text,
                        fontSize: 22,
                      ),
                      children: [
                        const TextSpan(text: AppStrings.captureHeadline),
                        TextSpan(
                          text: AppStrings.captureHeadlineEm,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: c.text,
                            fontSize: 22,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const TextSpan(text: AppStrings.captureHeadlineTail),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x10),
                  Text(
                    AppStrings.captureSub,
                    style: TextStyle(
                      color: c.textMute,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x18),
                  Row(
                    children: [
                      Expanded(
                        child: FaceCaptureSlot(
                          label: AppStrings.angleFront,
                          captured: true,
                          hue: 18,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x12),
                      Expanded(
                        child: FaceCaptureSlot(
                          label: AppStrings.angleLeft,
                          captured: true,
                          hue: 75,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x12),
                      Expanded(
                        child: FaceCaptureSlot(
                          label: AppStrings.angleRight,
                          captured: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x22),
                  JbTextField(
                    label: AppStrings.fullName,
                    leadingIcon: const JbIcon(JbIcon.user),
                    controller:
                        TextEditingController(text: AppStrings.fullNameValue),
                  ),
                  const SizedBox(height: AppSpacing.x18),
                  JbTextField(
                    label: AppStrings.nis,
                    controller:
                        TextEditingController(text: AppStrings.nisValue),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x18,
                AppSpacing.x8,
                AppSpacing.x18,
                AppSpacing.x18,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: JbButton.ghost(
                      label: AppStrings.saveDraft,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x12),
                  Expanded(
                    flex: 2,
                    child: JbButton(
                      label: AppStrings.submit,
                      leading: const JbIcon(JbIcon.check, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddStudentAppBar extends StatelessWidget implements PreferredSizeWidget {
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
                child: JbIcon(JbIcon.close, size: 16, color: c.text),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        AppStrings.enrollNewFace,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: c.text,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }
}

class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepProgressBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x22, vertical: AppSpacing.x6),
      child: Row(
        children: List.generate(totalSteps, (i) {
          double fill;
          if (i < currentStep - 1) {
            fill = 1.0;
          } else if (i == currentStep - 1) {
            fill = 0.55;
          } else {
            fill = 0.0;
          }
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 4),
              height: 3,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(99),
              ),
              child: FractionallySizedBox(
                widthFactor: fill,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

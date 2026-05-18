import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_button.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../../../../core/widgets/jb_text_field.dart';
import '../../../../routing/app_router.dart';
import '../widgets/password_strength_bar.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Stack(
          children: [
            _BackgroundOrnaments(color: c.borderStrong.withValues(alpha: 0.35)),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x22,
                AppSpacing.x10,
                AppSpacing.x22,
                AppSpacing.x18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrandRow(),
                  const SizedBox(height: AppSpacing.x22),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StepChip(),
                          const SizedBox(height: AppSpacing.x14),
                          _Headline(theme: theme, c: c),
                          const SizedBox(height: AppSpacing.x10),
                          Text(
                            AppStrings.createAccountSub,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: c.textMute, fontSize: 14),
                          ),
                          const SizedBox(height: AppSpacing.x28),
                          JbTextField(
                            label: AppStrings.labelUsername,
                            hintText: AppStrings.hintUsername,
                            leadingIcon: const JbIcon(JbIcon.user),
                          ),
                          const SizedBox(height: AppSpacing.x18),
                          JbTextField(
                            label: AppStrings.labelPassword,
                            obscureText: _obscurePassword,
                            leadingIcon: const JbIcon(JbIcon.lock),
                            controller: TextEditingController(
                                text: '••••••••••'),
                            trailing: GestureDetector(
                              onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              child: JbIcon(
                                _obscurePassword
                                    ? JbIcon.eye
                                    : JbIcon.eyeOff,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x18),
                          JbTextField(
                            label: AppStrings.labelConfirmPassword,
                            obscureText: _obscureConfirm,
                            leadingIcon: const JbIcon(JbIcon.lock),
                            controller: TextEditingController(
                                text: '••••••••••'),
                            trailing: GestureDetector(
                              onTap: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                              child: JbIcon(
                                _obscureConfirm
                                    ? JbIcon.eyeOff
                                    : JbIcon.eye,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x14),
                          const PasswordStrengthBar(level: 3),
                          const SizedBox(height: AppSpacing.x10),
                          _StrengthCaption(c: c),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x14),
                  JbButton(
                    label: AppStrings.createAccount,
                    leading: const JbIcon(JbIcon.chevronRight, size: 18),
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.camera),
                  ),
                  const SizedBox(height: AppSpacing.x14),
                  Text(
                    AppStrings.terminalAgreement,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: c.textFaint, fontSize: 12),
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

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final theme = Theme.of(context);
    return Row(
      children: [
        const JbLogo(size: 40),
        const SizedBox(width: AppSpacing.x12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.schoolFullName,
              style: TextStyle(
                color: c.accent,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Attendance\nStudio',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: c.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x12, vertical: AppSpacing.x6),
      decoration: BoxDecoration(
        color: c.bgSubtle,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: c.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.x8),
          Text(
            AppStrings.setupStep,
            style: TextStyle(
              color: c.text,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  final ThemeData theme;
  final JbColors c;
  const _Headline({required this.theme, required this.c});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: theme.textTheme.headlineLarge?.copyWith(color: c.text),
        children: [
          TextSpan(text: '${AppStrings.createAccountHeadline}\n'),
          TextSpan(
            text: AppStrings.createAccountHeadlineEm,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: c.text,
              fontStyle: FontStyle.italic,
            ),
          ),
          const TextSpan(text: AppStrings.createAccountHeadlineTail),
        ],
      ),
    );
  }
}

class _StrengthCaption extends StatelessWidget {
  final JbColors c;
  const _StrengthCaption({required this.c});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: AppStrings.strengthStrong,
            style: TextStyle(
              color: c.success,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          TextSpan(
            text: AppStrings.strengthStrongTail,
            style: TextStyle(
              color: c.textMute,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Two faint outline circles in the top-right corner, matching the HTML mocks.
class _BackgroundOrnaments extends StatelessWidget {
  final Color color;
  const _BackgroundOrnaments({required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -60,
      right: -80,
      child: Opacity(
        opacity: 0.6,
        child: Column(
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

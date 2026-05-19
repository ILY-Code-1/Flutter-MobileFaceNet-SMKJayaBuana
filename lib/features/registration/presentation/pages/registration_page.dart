import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/data/seed.dart';
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

enum _Step { account, pin }

class _RegistrationPageState extends State<RegistrationPage> {
  _Step _step = _Step.account;

  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _pin = TextEditingController();
  final _pinConfirm = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _obscurePin = true;
  bool _busy = false;

  String? _accountError;
  String? _pinError;

  @override
  void initState() {
    super.initState();
    _password.addListener(_onChange);
    _confirm.addListener(_onChange);
    _username.addListener(_onChange);
    _pin.addListener(_onChange);
    _pinConfirm.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    _pin.dispose();
    _pinConfirm.dispose();
    super.dispose();
  }

  int _passwordStrength() {
    final p = _password.text;
    if (p.isEmpty) return 0;
    int s = 0;
    if (p.length >= 6) s++;
    if (p.length >= 10) s++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p) || RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s.clamp(0, 4);
  }

  void _goToPin() {
    setState(() {
      _accountError = null;
      if (_username.text.trim().isEmpty) {
        _accountError = 'Username is required.';
        return;
      }
      if (_password.text.length < 6) {
        _accountError = 'Password must be at least 6 characters.';
        return;
      }
      if (_password.text != _confirm.text) {
        _accountError = 'Password and confirmation do not match.';
        return;
      }
      _step = _Step.pin;
    });
  }

  Future<void> _finish() async {
    setState(() => _pinError = null);
    if (_pin.text.length < 4 || _pin.text.length > 8) {
      setState(() => _pinError = 'PIN must be 4–8 digits.');
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(_pin.text)) {
      setState(() => _pinError = 'PIN must contain digits only.');
      return;
    }
    if (_pin.text != _pinConfirm.text) {
      setState(() => _pinError = 'PIN and confirmation do not match.');
      return;
    }

    setState(() => _busy = true);
    try {
      await AppDatabase.instance.createAdmin(
        username: _username.text.trim(),
        password: _password.text,
        pin: _pin.text,
      );
      await DbSeeder.seedIfEmpty();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.camera, (route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pinError = 'Failed to save: $e';
        _busy = false;
      });
    }
  }

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
                      child: _step == _Step.account
                          ? _accountStep(theme, c)
                          : _pinStep(theme, c),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x14),
                  if (_step == _Step.account)
                    JbButton(
                      label: AppStrings.next,
                      leading: const JbIcon(JbIcon.chevronRight, size: 18),
                      onPressed: _busy ? null : _goToPin,
                    )
                  else
                    JbButton(
                      label: AppStrings.createAccount,
                      leading: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const JbIcon(JbIcon.check, size: 18),
                      onPressed: _busy ? null : _finish,
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

  Widget _accountStep(ThemeData theme, JbColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepChip(label: AppStrings.setupStep1),
        const SizedBox(height: AppSpacing.x14),
        _Headline(
          theme: theme,
          c: c,
          before: AppStrings.createAccountHeadline,
          em: AppStrings.createAccountHeadlineEm,
          after: AppStrings.createAccountHeadlineTail,
        ),
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
          controller: _username,
        ),
        const SizedBox(height: AppSpacing.x18),
        JbTextField(
          label: AppStrings.labelPassword,
          obscureText: _obscurePassword,
          leadingIcon: const JbIcon(JbIcon.lock),
          controller: _password,
          trailing: GestureDetector(
            onTap: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            child: JbIcon(
              _obscurePassword ? JbIcon.eye : JbIcon.eyeOff,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x18),
        JbTextField(
          label: AppStrings.labelConfirmPassword,
          obscureText: _obscureConfirm,
          leadingIcon: const JbIcon(JbIcon.lock),
          controller: _confirm,
          trailing: GestureDetector(
            onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
            child: JbIcon(
              _obscureConfirm ? JbIcon.eyeOff : JbIcon.eye,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x14),
        PasswordStrengthBar(level: _passwordStrength()),
        if (_accountError != null) ...[
          const SizedBox(height: AppSpacing.x12),
          Text(
            _accountError!,
            style: TextStyle(
                color: c.danger, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ],
    );
  }

  Widget _pinStep(ThemeData theme, JbColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepChip(label: AppStrings.setupStep2),
        const SizedBox(height: AppSpacing.x14),
        _Headline(
          theme: theme,
          c: c,
          before: AppStrings.pinHeadline,
          em: AppStrings.pinHeadlineEm,
          after: AppStrings.pinHeadlineTail,
        ),
        const SizedBox(height: AppSpacing.x10),
        Text(
          AppStrings.pinSub,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: c.textMute, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.x28),
        JbTextField(
          label: AppStrings.labelPin,
          obscureText: _obscurePin,
          leadingIcon: const JbIcon(JbIcon.lock),
          controller: _pin,
          keyboardType: TextInputType.number,
          trailing: GestureDetector(
            onTap: () => setState(() => _obscurePin = !_obscurePin),
            child: JbIcon(
              _obscurePin ? JbIcon.eye : JbIcon.eyeOff,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x18),
        JbTextField(
          label: AppStrings.labelConfirmPin,
          obscureText: _obscurePin,
          leadingIcon: const JbIcon(JbIcon.lock),
          controller: _pinConfirm,
          keyboardType: TextInputType.number,
        ),
        if (_pinError != null) ...[
          const SizedBox(height: AppSpacing.x12),
          Text(
            _pinError!,
            style: TextStyle(
                color: c.danger, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
        const SizedBox(height: AppSpacing.x18),
        TextButton(
          onPressed: _busy ? null : () => setState(() => _step = _Step.account),
          child: Text(
            '← back to account',
            style: TextStyle(
                color: c.textMute,
                fontWeight: FontWeight.w700,
                fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  final String label;
  const _StepChip({required this.label});

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
            label,
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
  final String before;
  final String em;
  final String after;
  const _Headline(
      {required this.theme,
      required this.c,
      required this.before,
      required this.em,
      required this.after});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: theme.textTheme.headlineLarge?.copyWith(color: c.text),
        children: [
          TextSpan(text: '$before\n'),
          TextSpan(
            text: em,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: c.text,
              fontStyle: FontStyle.italic,
            ),
          ),
          TextSpan(text: after),
        ],
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

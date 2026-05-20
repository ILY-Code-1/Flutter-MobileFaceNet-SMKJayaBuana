import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/data/seed.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/pin_validator.dart';
import '../../../../core/widgets/jb_button.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../../../../core/widgets/jb_pin_dots.dart';
import '../../../../core/widgets/jb_text_field.dart';
import '../../../../core/widgets/shake_widget.dart';
import '../../../../routing/app_router.dart';
import '../../../camera/presentation/widgets/numeric_keypad.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

/// Which PIN the keypad is currently feeding.
enum _PinStage { create, confirm }

class _RegistrationPageState extends State<RegistrationPage> {
  final _username = TextEditingController();

  _PinStage _stage = _PinStage.create;
  String _pin = '';
  String _confirmPin = '';
  PinDotsState _dotsState = PinDotsState.normal;
  String? _error;
  int _shakeTrigger = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _username.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  String get _currentInput =>
      _stage == _PinStage.create ? _pin : _confirmPin;

  void _onDigit(int d) {
    if (_busy) return;
    if (_currentInput.length >= PinValidator.length) return;
    setState(() {
      _error = null;
      _dotsState = PinDotsState.normal;
      if (_stage == _PinStage.create) {
        _pin += '$d';
        if (_pin.length == PinValidator.length) _evaluateCreate();
      } else {
        _confirmPin += '$d';
        if (_confirmPin.length == PinValidator.length) _evaluateConfirm();
      }
    });
  }

  void _onBackspace() {
    if (_busy) return;
    setState(() {
      _error = null;
      _dotsState = PinDotsState.normal;
      if (_stage == _PinStage.create) {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      }
    });
  }

  void _evaluateCreate() {
    final err = PinValidator.validate(_pin);
    if (err != null) {
      _flagError(err, clearStage: _PinStage.create);
      return;
    }
    // valid → flash green, advance to confirm stage
    _dotsState = PinDotsState.success;
    Future.delayed(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      setState(() {
        _stage = _PinStage.confirm;
        _dotsState = PinDotsState.normal;
      });
    });
  }

  void _evaluateConfirm() {
    if (_confirmPin != _pin) {
      _flagError('PIN confirmation does not match.',
          clearStage: _PinStage.confirm);
      return;
    }
    _dotsState = PinDotsState.success;
    Future.delayed(const Duration(milliseconds: 300), _submit);
  }

  void _flagError(String message, {required _PinStage clearStage}) {
    setState(() {
      _error = message;
      _dotsState = PinDotsState.error;
      _shakeTrigger++;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        if (clearStage == _PinStage.create) {
          _pin = '';
        } else {
          _confirmPin = '';
        }
        _dotsState = PinDotsState.normal;
      });
    });
  }

  Future<void> _submit() async {
    if (!mounted || _busy) return;
    if (_username.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter a username first.';
        _stage = _PinStage.create;
        _pin = '';
        _confirmPin = '';
        _dotsState = PinDotsState.normal;
      });
      return;
    }
    setState(() => _busy = true);
    try {
      await AppDatabase.instance.createAdmin(
        username: _username.text.trim(),
        pin: _pin,
      );
      await DbSeeder.seedIfEmpty();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.camera, (route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Failed to save: $e';
        _stage = _PinStage.create;
        _pin = '';
        _confirmPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final theme = Theme.of(context);
    final isConfirm = _stage == _PinStage.confirm;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Stack(
          children: [
            _BackgroundOrnaments(
                color: c.borderStrong.withValues(alpha: 0.35)),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x22,
                AppSpacing.x10,
                AppSpacing.x22,
                AppSpacing.x18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BrandRow(),
                    const SizedBox(height: AppSpacing.x22),
                    const _StepChip(),
                    const SizedBox(height: AppSpacing.x14),
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.headlineLarge
                            ?.copyWith(color: c.text, fontSize: 27),
                        children: [
                          const TextSpan(text: "Let's set up your\n"),
                          TextSpan(
                            text: 'admin',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: c.text,
                              fontSize: 27,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const TextSpan(text: ' account.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x10),
                    Text(
                      'Pick a username and a 6-digit PIN. The PIN unlocks the '
                      'admin menu from the camera screen.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: c.textMute, fontSize: 14),
                    ),
                    const SizedBox(height: AppSpacing.x22),
                    JbTextField(
                      label: AppStrings.labelUsername,
                      hintText: AppStrings.hintUsername,
                      leadingIcon: const JbIcon(JbIcon.user),
                      controller: _username,
                    ),
                    const SizedBox(height: AppSpacing.x22),
                    Text(
                      isConfirm ? 'CONFIRM ADMIN PIN' : 'CREATE ADMIN PIN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: c.textMute,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x6),
                    Text(
                      isConfirm
                          ? 'Re-enter the 6 digits to confirm.'
                          : 'Choose 6 random digits — not 123456 or 654321.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.textFaint,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x18),
                    Center(
                      child: ShakeWidget(
                        shakeTrigger: _shakeTrigger,
                        child: JbPinDots(
                          filled: _currentInput.length,
                          length: PinValidator.length,
                          state: _dotsState,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x12),
                    SizedBox(
                      height: 22,
                      child: Center(
                        child: _error != null
                            ? Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: c.danger,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            : (_dotsState == PinDotsState.success
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: c.success, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        isConfirm
                                            ? 'PIN confirmed'
                                            : 'Looks good',
                                        style: TextStyle(
                                          color: c.success,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink()),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x14),
                    NumericKeypad(
                      onDigit: _onDigit,
                      onBackspace: _onBackspace,
                    ),
                    if (isConfirm) ...[
                      const SizedBox(height: AppSpacing.x12),
                      Center(
                        child: TextButton(
                          onPressed: _busy
                              ? null
                              : () => setState(() {
                                    _stage = _PinStage.create;
                                    _pin = '';
                                    _confirmPin = '';
                                    _error = null;
                                    _dotsState = PinDotsState.normal;
                                  }),
                          child: Text(
                            '↺ Start the PIN over',
                            style: TextStyle(
                              color: c.textMute,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.x14),
                    if (_busy)
                      JbButton(
                        label: 'Creating account…',
                        leading: const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        ),
                        onPressed: null,
                      ),
                    const SizedBox(height: AppSpacing.x10),
                    Text(
                      AppStrings.terminalAgreement,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: c.textFaint, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip();

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
            decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.x8),
          Text(
            'FIRST-TIME SETUP · STEP 1 OF 1',
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

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/pin_validator.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../../../../core/widgets/jb_pin_dots.dart';
import '../../../../core/widgets/shake_widget.dart';
import '../../../../routing/app_router.dart';
import '../widgets/numeric_keypad.dart';

Future<void> showPasswordGateSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) => const PasswordGateSheet(),
  );
}

class PasswordGateSheet extends StatefulWidget {
  const PasswordGateSheet({super.key});

  @override
  State<PasswordGateSheet> createState() => _PasswordGateSheetState();
}

class _PasswordGateSheetState extends State<PasswordGateSheet> {
  String _pin = '';
  PinDotsState _dotsState = PinDotsState.normal;
  bool _error = false;
  int _shakeTrigger = 0;
  bool _busy = false;

  void _onDigit(int d) {
    if (_busy || _pin.length >= PinValidator.length) return;
    setState(() {
      _error = false;
      _dotsState = PinDotsState.normal;
      _pin += '$d';
    });
    if (_pin.length == PinValidator.length) _verify();
  }

  void _onBackspace() {
    if (_busy || _pin.isEmpty) return;
    setState(() {
      _error = false;
      _dotsState = PinDotsState.normal;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verify() async {
    setState(() => _busy = true);
    final ok = await AppDatabase.instance.verifyPin(_pin);
    if (!mounted) return;
    if (ok) {
      setState(() => _dotsState = PinDotsState.success);
      await Future.delayed(const Duration(milliseconds: 280));
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pushNamed(context, AppRoutes.menu);
    } else {
      setState(() {
        _error = true;
        _dotsState = PinDotsState.error;
        _shakeTrigger++;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        _pin = '';
        _dotsState = PinDotsState.normal;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.jb;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: c.bgElev,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x22,
          AppSpacing.x10,
          AppSpacing.x22,
          AppSpacing.x22,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle — the sheet is dismissed by swiping it down.
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: AppSpacing.x22),
            const _LockBadge(),
            const SizedBox(height: AppSpacing.x18),
            Text(
              AppStrings.adminAccessRequired,
              style: TextStyle(
                color: c.text,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.x10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x14),
              child: Text(
                'Enter your 6-digit PIN. Swipe down to cancel.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textMute,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x22),
            ShakeWidget(
              shakeTrigger: _shakeTrigger,
              child: JbPinDots(
                filled: _pin.length,
                length: PinValidator.length,
                state: _dotsState,
              ),
            ),
            const SizedBox(height: AppSpacing.x12),
            SizedBox(
              height: 20,
              child: Center(
                child: _error
                    ? Text(
                        AppStrings.wrongPin,
                        style: TextStyle(
                          color: c.danger,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      )
                    : (_dotsState == PinDotsState.success
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle,
                                  color: c.success, size: 16),
                              const SizedBox(width: 6),
                              Text('Unlocked',
                                  style: TextStyle(
                                    color: c.success,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  )),
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
          ],
        ),
      ),
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: c.bgSubtle,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: JbIcon(JbIcon.lock, size: 30, color: c.text),
        ),
        Positioned(
          right: -4,
          top: -2,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: c.accent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

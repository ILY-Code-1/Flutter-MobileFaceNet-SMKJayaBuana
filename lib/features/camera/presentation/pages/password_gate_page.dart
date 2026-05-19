import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_button.dart';
import '../../../../core/widgets/jb_icons.dart';
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
  static const int maxPinLength = 8;
  const PasswordGateSheet({super.key});

  @override
  State<PasswordGateSheet> createState() => _PasswordGateSheetState();
}

class _PasswordGateSheetState extends State<PasswordGateSheet> {
  String _pin = '';
  String? _error;
  bool _busy = false;

  void _onDigit(int d) {
    if (_pin.length >= PasswordGateSheet.maxPinLength) return;
    setState(() {
      _pin += '$d';
      _error = null;
    });
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  Future<void> _unlock() async {
    if (_pin.isEmpty) return;
    setState(() => _busy = true);
    final ok = await AppDatabase.instance.verifyPin(_pin);
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _error = AppStrings.wrongPin;
        _pin = '';
        _busy = false;
      });
      return;
    }
    Navigator.pop(context);
    Navigator.pushNamed(context, AppRoutes.menu);
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
          AppSpacing.x18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                AppStrings.adminAccessSub,
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
            _DotsRow(filled: _pin.length, max: PasswordGateSheet.maxPinLength),
            const SizedBox(height: AppSpacing.x14),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(
                  color: c.danger,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            const SizedBox(height: AppSpacing.x14),
            NumericKeypad(
              onDigit: _onDigit,
              onBackspace: _onBackspace,
            ),
            const SizedBox(height: AppSpacing.x18),
            Row(
              children: [
                Expanded(
                  child: JbButton.ghost(
                    label: AppStrings.cancel,
                    onPressed: _busy ? null : () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.x12),
                Expanded(
                  flex: 2,
                  child: JbButton(
                    label: AppStrings.unlock,
                    leading: _busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const JbIcon(JbIcon.check, size: 18),
                    onPressed: _busy || _pin.isEmpty ? null : _unlock,
                  ),
                ),
              ],
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

class _DotsRow extends StatelessWidget {
  final int filled;
  final int max;
  const _DotsRow({required this.filled, required this.max});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final shown = filled.clamp(0, max);
    final empties = (6 - shown).clamp(0, 6);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < shown; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x6),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: c.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        for (int i = 0; i < empties; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x6),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.border, width: 1.6),
              ),
            ),
          ),
      ],
    );
  }
}

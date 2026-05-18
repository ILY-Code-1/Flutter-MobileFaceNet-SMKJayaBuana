import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_button.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../../../../routing/app_router.dart';
import '../widgets/numeric_keypad.dart';

/// Shows the password gate as a modal bottom sheet.
/// Routed via [AppRoutes.passwordGate] in [AppRouter.onGenerate].
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
  static const int passwordLength = 6;
  const PasswordGateSheet({super.key});

  @override
  State<PasswordGateSheet> createState() => _PasswordGateSheetState();
}

class _PasswordGateSheetState extends State<PasswordGateSheet> {
  int _filled = 4;

  void _onDigit(int _) {
    if (_filled >= PasswordGateSheet.passwordLength) return;
    setState(() => _filled += 1);
  }

  void _onBackspace() {
    if (_filled == 0) return;
    setState(() => _filled -= 1);
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
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.x14),
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
            _DotsRow(
              filled: _filled,
              length: PasswordGateSheet.passwordLength,
            ),
            const SizedBox(height: AppSpacing.x22),
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.x12),
                Expanded(
                  flex: 2,
                  child: JbButton(
                    label: AppStrings.unlock,
                    leading: const JbIcon(JbIcon.check, size: 18),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.menu);
                    },
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
  final int length;
  const _DotsRow({required this.filled, required this.length});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final isOn = i < filled;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x8),
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: isOn ? c.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: isOn ? null : Border.all(color: c.border, width: 1.6),
            ),
          ),
        );
      }),
    );
  }
}

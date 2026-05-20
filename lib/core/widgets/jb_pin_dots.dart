import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum PinDotsState { normal, error, success }

/// A row of PIN dots: filled / empty, with an optional error (red) or
/// success (green) tint applied to the filled dots.
class JbPinDots extends StatelessWidget {
  final int filled;
  final int length;
  final PinDotsState state;
  final bool onDark;

  const JbPinDots({
    super.key,
    required this.filled,
    required this.length,
    this.state = PinDotsState.normal,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final Color fillColor;
    switch (state) {
      case PinDotsState.error:
        fillColor = c.danger;
        break;
      case PinDotsState.success:
        fillColor = c.success;
        break;
      case PinDotsState.normal:
        fillColor = onDark ? Colors.white : c.primary;
        break;
    }
    final emptyBorder = onDark
        ? Colors.white.withValues(alpha: 0.35)
        : c.border;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final isOn = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.x8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isOn ? fillColor : Colors.transparent,
            shape: BoxShape.circle,
            border: isOn ? null : Border.all(color: emptyBorder, width: 1.8),
          ),
        );
      }),
    );
  }
}

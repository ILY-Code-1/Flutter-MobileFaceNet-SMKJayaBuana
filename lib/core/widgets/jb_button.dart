import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum JbButtonVariant { primary, ghost, gold }

class JbButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final JbButtonVariant variant;
  final Widget? leading;
  final Widget? trailing;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;

  const JbButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = JbButtonVariant.primary,
    this.leading,
    this.trailing,
    this.fullWidth = true,
    this.padding,
  });

  const JbButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.fullWidth = true,
    this.padding,
  }) : variant = JbButtonVariant.ghost;

  const JbButton.gold({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.fullWidth = true,
    this.padding,
  }) : variant = JbButtonVariant.gold;

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final Color bg;
    final Color fg;
    final Color? borderColor;
    switch (variant) {
      case JbButtonVariant.primary:
        bg = c.primary;
        fg = c.onPrimary;
        borderColor = null;
        break;
      case JbButtonVariant.ghost:
        bg = c.bgElev;
        fg = c.text;
        borderColor = c.border;
        break;
      case JbButtonVariant.gold:
        bg = c.accent;
        fg = c.onAccent;
        borderColor = null;
        break;
    }

    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          IconTheme(
            data: IconThemeData(color: fg, size: 18),
            child: leading!,
          ),
          const SizedBox(width: AppSpacing.x8),
        ],
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.x8),
          IconTheme(
            data: IconThemeData(color: fg, size: 18),
            child: trailing!,
          ),
        ],
      ],
    );

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: padding ??
              const EdgeInsets.symmetric(
                  vertical: AppSpacing.x18, horizontal: AppSpacing.x22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1.2)
                : null,
          ),
          child: content,
        ),
      ),
    );
  }
}

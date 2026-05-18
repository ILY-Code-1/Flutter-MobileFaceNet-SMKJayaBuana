import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class JbChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;

  const JbChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leading,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final bg = selected ? c.primary : c.bgSubtle;
    final fg = selected ? c.onPrimary : c.text;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: padding ??
              const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x14, vertical: AppSpacing.x8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                IconTheme(
                  data: IconThemeData(color: fg, size: 14),
                  child: leading!,
                ),
                const SizedBox(width: AppSpacing.x6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class JbCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;
  final BoxBorder? border;

  const JbCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.x18),
    this.color,
    this.borderColor,
    this.radius = AppRadius.lg,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final bg = color ?? c.bgElev;
    final effectiveBorder = border ??
        Border.all(
          color: borderColor ?? c.border,
          width: 1.2,
        );

    final container = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: effectiveBorder,
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return container;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: container,
      ),
    );
  }
}

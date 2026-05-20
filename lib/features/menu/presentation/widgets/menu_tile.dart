import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_icons.dart';

enum MenuTileVariant { primary, ghost }

class MenuTile extends StatelessWidget {
  final String iconAsset;
  final String title;
  final InlineSpan trailingMeta;
  final MenuTileVariant variant;
  final VoidCallback? onTap;

  const MenuTile({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.trailingMeta,
    this.variant = MenuTileVariant.ghost,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final isPrimary = variant == MenuTileVariant.primary;
    final bg = isPrimary ? c.primary : c.bgElev;
    final fg = isPrimary ? c.onPrimary : c.text;
    final chipBg = isPrimary
        ? Colors.white.withValues(alpha: 0.08)
        : c.bgSubtle;
    final iconColor = isPrimary ? c.accent : c.text;
    final chevronColor = isPrimary
        ? c.onPrimary.withValues(alpha: 0.7)
        : c.textMute;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        splashColor: c.primary.withValues(alpha: 0.16),
        highlightColor: c.primary.withValues(alpha: 0.08),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: isPrimary
                ? null
                : Border.all(color: c.border, width: 1.2),
          ),
          padding: const EdgeInsets.all(AppSpacing.x18),
          child: Stack(
            children: [
              if (isPrimary)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: _DotPattern(),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                        ),
                        alignment: Alignment.center,
                        child: JbIcon(iconAsset, size: 22, color: iconColor),
                      ),
                      const SizedBox(width: AppSpacing.x12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: fg,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      JbIcon(JbIcon.chevronRight,
                          size: 18, color: chevronColor),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x14),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: isPrimary
                            ? c.onPrimary.withValues(alpha: 0.75)
                            : c.textMute,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [trailingMeta],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotPattern extends StatelessWidget {
  const _DotPattern();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 60,
      child: CustomPaint(painter: _DotPainter()),
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.15);
    const step = 11.0;
    for (double y = 4; y < size.height; y += step) {
      for (double x = 4; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.2, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPainter oldDelegate) => false;
}

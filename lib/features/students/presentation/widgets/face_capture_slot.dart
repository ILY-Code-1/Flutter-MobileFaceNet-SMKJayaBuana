import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_icons.dart';

class FaceCaptureSlot extends StatelessWidget {
  final String label;
  final bool captured;
  final int hue;
  final VoidCallback? onTap;

  const FaceCaptureSlot({
    super.key,
    required this.label,
    required this.captured,
    this.hue = 18,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;

    return AspectRatio(
      aspectRatio: 0.78,
      child: Material(
        color: captured ? Colors.transparent : c.bgElev,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: c.border, width: 1.2),
              gradient: captured
                  ? LinearGradient(
                      colors: _gradientFromHue(hue),
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                if (captured) const _CapturedOval(),
                if (!captured)
                  Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.bgSubtle,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      alignment: Alignment.center,
                      child: JbIcon(JbIcon.faceScan,
                          size: 20, color: c.textMute),
                    ),
                  ),
                if (captured)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: c.accent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child:
                          JbIcon(JbIcon.check, size: 14, color: c.onAccent),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: captured ? Colors.white : c.textMute,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static List<Color> _gradientFromHue(int hue) {
    final c1 = HSLColor.fromAHSL(1, hue.toDouble() % 360, 0.30, 0.70).toColor();
    final c2 = HSLColor.fromAHSL(1, (hue + 12) % 360, 0.34, 0.45).toColor();
    return [c1, c2];
  }
}

class _CapturedOval extends StatelessWidget {
  const _CapturedOval();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.55,
        heightFactor: 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

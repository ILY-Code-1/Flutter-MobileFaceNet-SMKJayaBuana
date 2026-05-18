import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The central face scan target: 4 gold corner brackets surrounding a dashed
/// oval with a gold horizontal scan line at the centre.
class FaceScanFrame extends StatelessWidget {
  final double size;
  final Color? color;

  const FaceScanFrame({
    super.key,
    this.size = 240,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.jb.accent;
    return SizedBox(
      width: size,
      height: size * 1.05,
      child: CustomPaint(
        painter: _FaceScanFramePainter(color: c),
      ),
    );
  }
}

class _FaceScanFramePainter extends CustomPainter {
  final Color color;
  _FaceScanFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 26.0;
    const cornerR = 8.0;

    // ----- 4 corner brackets -----
    final tl = Path()
      ..moveTo(0, cornerLen)
      ..lineTo(0, cornerR)
      ..arcToPoint(const Offset(cornerR, 0), radius: const Radius.circular(cornerR))
      ..lineTo(cornerLen, 0);
    canvas.drawPath(tl, stroke);

    final tr = Path()
      ..moveTo(size.width - cornerLen, 0)
      ..lineTo(size.width - cornerR, 0)
      ..arcToPoint(Offset(size.width, cornerR), radius: const Radius.circular(cornerR))
      ..lineTo(size.width, cornerLen);
    canvas.drawPath(tr, stroke);

    final bl = Path()
      ..moveTo(0, size.height - cornerLen)
      ..lineTo(0, size.height - cornerR)
      ..arcToPoint(Offset(cornerR, size.height), radius: const Radius.circular(cornerR))
      ..lineTo(cornerLen, size.height);
    canvas.drawPath(bl, stroke);

    final br = Path()
      ..moveTo(size.width - cornerLen, size.height)
      ..lineTo(size.width - cornerR, size.height)
      ..arcToPoint(
        Offset(size.width, size.height - cornerR),
        radius: const Radius.circular(cornerR),
      )
      ..lineTo(size.width, size.height - cornerLen);
    canvas.drawPath(br, stroke);

    // ----- Dashed oval (mute version of accent) -----
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.65,
      height: size.height * 0.72,
    );
    _drawDashedOval(
      canvas,
      ovalRect,
      Paint()
        ..color = color.withValues(alpha: 0.55)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );

    // ----- Centre horizontal scan line with glow -----
    final scanY = size.height / 2;
    final scanWidth = size.width * 0.4;
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, scanY),
      width: scanWidth,
      height: 2,
    );
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0),
          color,
          color.withValues(alpha: 0),
        ],
      ).createShader(scanRect);
    canvas.drawRect(scanRect, scanPaint);

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.45),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(size.width / 2, scanY),
        width: scanWidth,
        height: 18,
      ));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, scanY),
        width: scanWidth,
        height: 18,
      ),
      glow,
    );
  }

  void _drawDashedOval(Canvas canvas, Rect rect, Paint p) {
    const segments = 56;
    const dashGap = 2;
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final rx = rect.width / 2;
    final ry = rect.height / 2;
    for (int i = 0; i < segments; i++) {
      if (i % dashGap == 0) {
        final t1 = (i / segments) * 2 * math.pi;
        final t2 = ((i + 1) / segments) * 2 * math.pi;
        final p1 = Offset(cx + rx * math.cos(t1), cy + ry * math.sin(t1));
        final p2 = Offset(cx + rx * math.cos(t2), cy + ry * math.sin(t2));
        canvas.drawLine(p1, p2, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FaceScanFramePainter old) =>
      old.color != color;
}

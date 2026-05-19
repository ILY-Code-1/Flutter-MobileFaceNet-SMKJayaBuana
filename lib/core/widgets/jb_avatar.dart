import 'package:flutter/material.dart';

class HueGradient {
  static List<Color> fromHue(int hue) {
    final c1 =
        HSLColor.fromAHSL(1.0, hue.toDouble() % 360, 0.42, 0.74).toColor();
    final c2 =
        HSLColor.fromAHSL(1.0, (hue + 30).toDouble() % 360, 0.46, 0.58)
            .toColor();
    return [c1, c2];
  }
}

class JbAvatar extends StatelessWidget {
  final String initials;
  final int hue;
  final double size;
  final double fontSize;
  final bool ringed;

  const JbAvatar({
    super.key,
    required this.initials,
    required this.hue,
    this.size = 44,
    this.fontSize = 14,
    this.ringed = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = HueGradient.fromHue(hue);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: ringed ? Border.all(color: Colors.white, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

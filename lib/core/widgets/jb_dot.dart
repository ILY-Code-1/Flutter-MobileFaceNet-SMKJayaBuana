import 'package:flutter/material.dart';

class JbDot extends StatelessWidget {
  final double size;
  final Color color;

  const JbDot({
    super.key,
    this.size = 8,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

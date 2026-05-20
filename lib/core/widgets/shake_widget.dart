import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Wraps [child] and plays a quick horizontal shake whenever [shakeTrigger]
/// changes value. Used for "wrong PIN" feedback.
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final int shakeTrigger;
  final Duration duration;

  const ShakeWidget({
    super.key,
    required this.child,
    required this.shakeTrigger,
    this.duration = const Duration(milliseconds: 480),
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void didUpdateWidget(covariant ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shakeTrigger != widget.shakeTrigger &&
        widget.shakeTrigger != 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Damped sine: a few oscillations that fade out.
        final t = _controller.value;
        final dx = t == 0
            ? 0.0
            : math.sin(t * math.pi * 6) * 12 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}

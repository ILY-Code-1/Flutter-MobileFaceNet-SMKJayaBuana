import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Wraps a "home" page so the Android back button needs two taps within
/// [window] to actually exit the app. The first tap shows a SnackBar
/// reminding the user; the second tap (within the window) calls
/// SystemNavigator.pop().
class DoubleTapBackToExit extends StatefulWidget {
  final Widget child;
  final Duration window;
  final String? message;

  const DoubleTapBackToExit({
    super.key,
    required this.child,
    this.window = const Duration(seconds: 2),
    this.message,
  });

  @override
  State<DoubleTapBackToExit> createState() => _DoubleTapBackToExitState();
}

class _DoubleTapBackToExitState extends State<DoubleTapBackToExit> {
  DateTime? _lastBackPress;

  void _handlePop(bool didPop, Object? result) {
    if (didPop) return;
    final now = DateTime.now();
    final last = _lastBackPress;
    if (last != null && now.difference(last) <= widget.window) {
      SystemNavigator.pop();
      return;
    }
    _lastBackPress = now;

    final c = context.jb;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          widget.message ?? AppStrings.pressAgainToExit,
          style: TextStyle(color: c.onAccent, fontWeight: FontWeight.w700),
        ),
        backgroundColor: c.bgElev,
        behavior: SnackBarBehavior.floating,
        duration: widget.window,
        margin: const EdgeInsets.all(AppSpacing.x14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePop,
      child: widget.child,
    );
  }
}

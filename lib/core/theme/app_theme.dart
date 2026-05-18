import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const c = JbColors.light;
    final scheme = ColorScheme.light(
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.accent,
      onSecondary: c.onAccent,
      surface: c.bgElev,
      onSurface: c.text,
      error: c.danger,
      onError: c.bg,
    );
    return _build(c, scheme, Brightness.light);
  }

  static ThemeData dark() {
    const c = JbColors.dark;
    final scheme = ColorScheme.dark(
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.accent,
      onSecondary: c.onAccent,
      surface: c.bgElev,
      onSurface: c.text,
      error: c.danger,
      onError: c.bg,
    );
    return _build(c, scheme, Brightness.dark);
  }

  static ThemeData _build(JbColors c, ColorScheme scheme, Brightness b) {
    final textTheme = AppTypography.textTheme(c.text, c.textMute);
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: c.text, size: 22),
      splashFactory: InkRipple.splashFactory,
      dividerTheme: DividerThemeData(
        color: c.border,
        space: 1,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(color: c.text),
        iconTheme: IconThemeData(color: c.text),
      ),
      extensions: <ThemeExtension<dynamic>>[c],
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

// Re-export common tokens for convenience.
typedef Sp = AppSpacing;
typedef R = AppRadius;

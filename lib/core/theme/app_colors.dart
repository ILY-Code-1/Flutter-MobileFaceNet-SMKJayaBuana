import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---------- Light ----------
  static const lightBg = Color(0xFFFBF8F1);
  static const lightBgElev = Color(0xFFFFFFFF);
  static const lightBgSubtle = Color(0xFFF2EDE0);

  static const lightBorder = Color(0xFFE6DFCB);
  static const lightBorderStrong = Color(0xFFD6CDB4);

  static const lightText = Color(0xFF0B1A35);
  static const lightTextMute = Color(0xFF5A6584);
  static const lightTextFaint = Color(0xFF9AA3BD);

  static const lightPrimary = Color(0xFF0F2545);
  static const lightOnPrimary = Color(0xFFFBF8F1);

  static const lightAccent = Color(0xFFC8A431);
  static const lightOnAccent = Color(0xFF0B1A35);

  static const lightSuccess = Color(0xFF1F7A4A);
  static const lightWarn = Color(0xFFB8732C);
  static const lightDanger = Color(0xFFB0344A);

  // ---------- Dark ----------
  static const darkBg = Color(0xFF0A1426);
  static const darkBgElev = Color(0xFF13203B);
  static const darkBgSubtle = Color(0xFF0F1A30);

  static const darkBorder = Color(0xFF1F2E4D);
  static const darkBorderStrong = Color(0xFF2C3E63);

  static const darkText = Color(0xFFF4EFE0);
  static const darkTextMute = Color(0xFF9CA8C4);
  static const darkTextFaint = Color(0xFF6B7794);

  static const darkPrimary = Color(0xFFE8C547);
  static const darkOnPrimary = Color(0xFF0A1426);

  static const darkAccent = Color(0xFFD4AF37);
  static const darkSuccess = Color(0xFF5DD49A);
  static const darkWarn = Color(0xFFE8A35C);
  static const darkDanger = Color(0xFFE87A8E);
}

/// Custom semantic tokens that don't fit into [ColorScheme].
/// Access via `Theme.of(context).extension<JbColors>()!`.
@immutable
class JbColors extends ThemeExtension<JbColors> {
  final Color bg;
  final Color bgElev;
  final Color bgSubtle;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color textMute;
  final Color textFaint;
  final Color primary;
  final Color onPrimary;
  final Color accent;
  final Color onAccent;
  final Color success;
  final Color warn;
  final Color danger;

  const JbColors({
    required this.bg,
    required this.bgElev,
    required this.bgSubtle,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textMute,
    required this.textFaint,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.warn,
    required this.danger,
  });

  static const JbColors light = JbColors(
    bg: AppColors.lightBg,
    bgElev: AppColors.lightBgElev,
    bgSubtle: AppColors.lightBgSubtle,
    border: AppColors.lightBorder,
    borderStrong: AppColors.lightBorderStrong,
    text: AppColors.lightText,
    textMute: AppColors.lightTextMute,
    textFaint: AppColors.lightTextFaint,
    primary: AppColors.lightPrimary,
    onPrimary: AppColors.lightOnPrimary,
    accent: AppColors.lightAccent,
    onAccent: AppColors.lightOnAccent,
    success: AppColors.lightSuccess,
    warn: AppColors.lightWarn,
    danger: AppColors.lightDanger,
  );

  static const JbColors dark = JbColors(
    bg: AppColors.darkBg,
    bgElev: AppColors.darkBgElev,
    bgSubtle: AppColors.darkBgSubtle,
    border: AppColors.darkBorder,
    borderStrong: AppColors.darkBorderStrong,
    text: AppColors.darkText,
    textMute: AppColors.darkTextMute,
    textFaint: AppColors.darkTextFaint,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkOnPrimary,
    accent: AppColors.darkAccent,
    onAccent: AppColors.darkOnPrimary,
    success: AppColors.darkSuccess,
    warn: AppColors.darkWarn,
    danger: AppColors.darkDanger,
  );

  @override
  JbColors copyWith({
    Color? bg,
    Color? bgElev,
    Color? bgSubtle,
    Color? border,
    Color? borderStrong,
    Color? text,
    Color? textMute,
    Color? textFaint,
    Color? primary,
    Color? onPrimary,
    Color? accent,
    Color? onAccent,
    Color? success,
    Color? warn,
    Color? danger,
  }) {
    return JbColors(
      bg: bg ?? this.bg,
      bgElev: bgElev ?? this.bgElev,
      bgSubtle: bgSubtle ?? this.bgSubtle,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      text: text ?? this.text,
      textMute: textMute ?? this.textMute,
      textFaint: textFaint ?? this.textFaint,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      success: success ?? this.success,
      warn: warn ?? this.warn,
      danger: danger ?? this.danger,
    );
  }

  @override
  JbColors lerp(ThemeExtension<JbColors>? other, double t) {
    if (other is! JbColors) return this;
    return JbColors(
      bg: Color.lerp(bg, other.bg, t)!,
      bgElev: Color.lerp(bgElev, other.bgElev, t)!,
      bgSubtle: Color.lerp(bgSubtle, other.bgSubtle, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMute: Color.lerp(textMute, other.textMute, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension JbColorsX on BuildContext {
  JbColors get jb => Theme.of(this).extension<JbColors>()!;
}

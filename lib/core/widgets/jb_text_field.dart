import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class JbTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final Widget? leadingIcon;
  final Widget? trailing;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool enabled;

  const JbTextField({
    super.key,
    this.label,
    this.hintText,
    this.leadingIcon,
    this.trailing,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: c.textMute,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.x8),
        ],
        Container(
          decoration: BoxDecoration(
            color: c.bgElev,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.border, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x14, vertical: AppSpacing.x4),
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                IconTheme(
                  data: IconThemeData(color: c.textMute, size: 18),
                  child: leadingIcon!,
                ),
                const SizedBox(width: AppSpacing.x10),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  enabled: enabled,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: c.textFaint,
                      fontWeight: FontWeight.w600,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.x8),
                IconTheme(
                  data: IconThemeData(color: c.textMute, size: 20),
                  child: trailing!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

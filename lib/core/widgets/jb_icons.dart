import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';

/// Inline SVG icon that respects [color] (via theme tint) and [size].
class JbIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color;

  const JbIcon(this.asset, {super.key, this.size = 22, this.color});

  // Static aliases for the most-used icons (auto-completable).
  static const faceScan = AppAssets.iFaceScan;
  static const menu = AppAssets.iMenu;
  static const report = AppAssets.iReport;
  static const settings = AppAssets.iSettings;
  static const student = AppAssets.iStudent;
  static const clock = AppAssets.iClock;
  static const calendar = AppAssets.iCalendar;
  static const download = AppAssets.iDownload;
  static const plus = AppAssets.iPlus;
  static const search = AppAssets.iSearch;
  static const eye = AppAssets.iEye;
  static const eyeOff = AppAssets.iEyeOff;
  static const check = AppAssets.iCheck;
  static const chevronLeft = AppAssets.iChevronLeft;
  static const chevronRight = AppAssets.iChevronRight;
  static const chevronDown = AppAssets.iChevronDown;
  static const lock = AppAssets.iLock;
  static const user = AppAssets.iUser;
  static const cameraFlip = AppAssets.iCameraFlip;
  static const flash = AppAssets.iFlash;
  static const close = AppAssets.iClose;
  static const sparkle = AppAssets.iSparkle;
  static const filter = AppAssets.iFilter;
  static const logout = AppAssets.iLogout;
  static const bell = AppAssets.iBell;
  static const trash = AppAssets.iTrash;
  static const backspace = AppAssets.iBackspace;
  static const logo = AppAssets.iLogo;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color;
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter:
          tint == null ? null : ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }
}

/// Logo SVG keeps its own colours (do not tint).
class JbLogo extends StatelessWidget {
  final double size;
  const JbLogo({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.iLogo,
      width: size,
      height: size,
    );
  }
}

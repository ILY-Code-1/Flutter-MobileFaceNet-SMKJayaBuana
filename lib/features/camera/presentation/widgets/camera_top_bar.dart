import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/data/app_settings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_icons.dart';

class CameraTopBar extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const CameraTopBar({super.key, this.onMenuTap});

  @override
  State<CameraTopBar> createState() => _CameraTopBarState();
}

class _CameraTopBarState extends State<CameraTopBar> {
  String _subtitle = '';

  @override
  void initState() {
    super.initState();
    _resolveSubtitle();
  }

  Future<void> _resolveSubtitle() async {
    final settings = await SettingsService.instance.load();
    final classes = await AppDatabase.instance.listClasses();
    final names = classes
        .where((c) => settings.activeClassIds.contains(c.id))
        .map((c) => c.name)
        .toList();
    if (!mounted) return;
    setState(() {
      _subtitle = names.isEmpty
          ? 'No class enabled'
          : (names.length <= 2
              ? names.join(' · ')
              : '${names.length} classes');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x18,
        AppSpacing.x10,
        AppSpacing.x14,
        AppSpacing.x10,
      ),
      child: Row(
        children: [
          const JbLogo(size: 32),
          const SizedBox(width: AppSpacing.x10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _MenuButton(onTap: widget.onMenuTap),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _MenuButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: JbIcon(JbIcon.menu, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

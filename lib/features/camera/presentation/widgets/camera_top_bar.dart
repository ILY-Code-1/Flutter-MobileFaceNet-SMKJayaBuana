import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/data/app_settings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_icons.dart';

class CameraTopBar extends StatefulWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onRefreshTap;

  const CameraTopBar({super.key, this.onMenuTap, this.onRefreshTap});

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
          if (widget.onRefreshTap != null) ...[
            _RoundIconButton(
              icon: Icons.refresh,
              onTap: widget.onRefreshTap,
            ),
            const SizedBox(width: AppSpacing.x8),
          ],
          _RoundIconButton(
            onTap: widget.onMenuTap,
            child: const JbIcon(JbIcon.menu, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final VoidCallback? onTap;
  const _RoundIconButton({this.icon, this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: child ??
                Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

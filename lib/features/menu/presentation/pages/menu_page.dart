import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/data/app_settings.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../../../../routing/app_router.dart';
import '../widgets/menu_tile.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  AdminAccount? _admin;
  int _studentCount = 0;
  int _classCount = 0;
  String _activeClassesSummary = 'All classes';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final admin = await AppDatabase.instance.getAdmin();
    final students = await AppDatabase.instance
        .listStudents(includeDrafts: false);
    final classes = await AppDatabase.instance.listClasses();
    final settings = await SettingsService.instance.load();
    final activeNames = classes
        .where((c) => settings.activeClassIds.contains(c.id))
        .map((c) => c.name)
        .toList();
    setState(() {
      _admin = admin;
      _studentCount = students.length;
      _classCount = classes.length;
      _activeClassesSummary = activeNames.isEmpty
          ? 'No class enabled'
          : (activeNames.length <= 2
              ? activeNames.join(' · ')
              : '${activeNames.length} of $_classCount classes');
      _loading = false;
    });
  }

  String _today() {
    final now = DateTime.now();
    final s = DateFormat('EEEE, d MMMM').format(now);
    return s.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x22,
              AppSpacing.x10,
              AppSpacing.x22,
              AppSpacing.x14,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _today(),
                            style: TextStyle(
                              color: c.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x6),
                          RichText(
                            text: TextSpan(
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: c.text,
                                fontSize: 28,
                              ),
                              children: [
                                const TextSpan(text: AppStrings.helloHeadline),
                                TextSpan(
                                  text: _admin?.username ?? 'admin',
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                    color: c.text,
                                    fontSize: 28,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x4),
                          Text(
                            AppStrings.helloPrompt,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: c.textMute,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _CloseButton(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.camera,
                        (r) => false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x22),
                Expanded(
                  child: _loading
                      ? Center(
                          child: CircularProgressIndicator(color: c.accent),
                        )
                      : ListView(
                          padding: EdgeInsets.zero,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            MenuTile(
                              iconAsset: JbIcon.student,
                              title: AppStrings.tileStudents,
                              variant: MenuTileVariant.primary,
                              trailingMeta: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$_studentCount ',
                                    style: TextStyle(
                                      color: c.accent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const TextSpan(
                                      text: AppStrings.tileStudentsSub),
                                ],
                              ),
                              onTap: () async {
                                await Navigator.pushNamed(
                                    context, AppRoutes.students);
                                _load();
                              },
                            ),
                            const SizedBox(height: AppSpacing.x14),
                            MenuTile(
                              iconAsset: JbIcon.report,
                              title: AppStrings.tileReports,
                              trailingMeta: TextSpan(
                                children: [
                                  TextSpan(
                                    text: DateFormat('MMMM yyyy')
                                        .format(DateTime.now()),
                                    style: TextStyle(
                                      color: c.text,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' · view & export PDF',
                                    style: TextStyle(color: c.textMute),
                                  ),
                                ],
                              ),
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.reports),
                            ),
                            const SizedBox(height: AppSpacing.x14),
                            MenuTile(
                              iconAsset: JbIcon.settings,
                              title: AppStrings.tileSettings,
                              trailingMeta: TextSpan(
                                children: [
                                  TextSpan(
                                    text: _activeClassesSummary,
                                    style: TextStyle(
                                      color: c.text,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' · ${AppStrings.tileSettingsSub}',
                                    style: TextStyle(color: c.textMute),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                await Navigator.pushNamed(
                                    context, AppRoutes.settings);
                                _load();
                              },
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: AppSpacing.x10),
                const _Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _CloseButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Material(
      color: c.bgSubtle,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: JbIcon(JbIcon.close, size: 18, color: c.text)),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.x14, horizontal: AppSpacing.x18),
      decoration: BoxDecoration(
        color: c.bgElev,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          JbIcon(JbIcon.chevronLeft, size: 18, color: c.textMute),
          const SizedBox(width: AppSpacing.x8),
          Text(
            AppStrings.backToCamera,
            style: TextStyle(
              color: c.textMute,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            ' · ${AppStrings.appVersion}',
            style: TextStyle(
              color: c.textFaint,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

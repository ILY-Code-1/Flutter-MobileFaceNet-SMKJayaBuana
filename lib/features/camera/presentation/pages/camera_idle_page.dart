import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_settings.dart';
import '../../../../core/services/face_recognition_service.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../../../../routing/app_router.dart';
import '../widgets/camera_top_bar.dart';
import '../widgets/face_scan_frame.dart';

class CameraIdlePage extends StatefulWidget {
  const CameraIdlePage({super.key});

  @override
  State<CameraIdlePage> createState() => _CameraIdlePageState();
}

class _CameraIdlePageState extends State<CameraIdlePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _ready = false;
  bool _initializing = true;
  String? _initError;
  bool _scanning = false;
  AppSettings? _settings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  Future<void> _bootstrap({int attempt = 0}) async {
    _settings = await SettingsService.instance.load();
    // Give the platform a moment to release the previous CameraController
    // when we re-enter this page after navigating away (the camera plugin
    // disposes the surface producer asynchronously).
    if (attempt == 0) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (!mounted) return;
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        setState(() {
          _initializing = false;
          _initError = 'No camera found on this device.';
        });
        return;
      }
      final front = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _ready = true;
        _initializing = false;
        _initError = null;
      });
    } catch (e) {
      if (!mounted) return;
      // Surface producer race on Android: retry once after a longer pause.
      if (attempt < 2) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        return _bootstrap(attempt: attempt + 1);
      }
      setState(() {
        _initializing = false;
        _initError = 'Camera error: $e';
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (state == AppLifecycleState.inactive) {
      if (c != null && c.value.isInitialized) {
        c.dispose();
        _controller = null;
        _ready = false;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_controller == null) {
        _bootstrap();
      }
    }
  }

  Future<void> _retry() async {
    setState(() {
      _initializing = true;
      _initError = null;
      _ready = false;
    });
    await _controller?.dispose();
    _controller = null;
    await _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onScanPressed() async {
    if (!_ready || _scanning || _controller == null) return;
    setState(() => _scanning = true);

    XFile? snap;
    try {
      snap = await _controller!.takePicture();
    } catch (e) {
      if (!mounted) return;
      setState(() => _scanning = false);
      _showError('Failed to capture: $e');
      return;
    }

    if (!mounted) return;

    // Show modal progress while we run the embedding pipeline.
    final completer = Completer<void>();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: _ProcessingDialog(onShown: () {
            if (!completer.isCompleted) completer.complete();
          }),
        );
      },
    );

    await completer.future;

    FaceMatch? match;
    try {
      match = await FaceRecognitionService.instance.identifyFromFile(
        filePath: snap.path,
        classIds: _settings?.activeClassIds.isEmpty == true
            ? null
            : _settings?.activeClassIds,
      );
    } catch (_) {
      match = null;
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // close progress
    if (_settings != null) {
      unawaited(SoundService.instance.playForKey(_settings!.soundOnScan));
    }
    setState(() => _scanning = false);

    if (match == null) {
      _showNotRecognized(snap.path);
      return;
    }

    await Navigator.pushNamed(
      context,
      AppRoutes.recognized,
      arguments: {
        'studentId': match.student.id,
        'similarity': match.similarity,
        'capturedPath': snap.path,
      },
    );
    // re-load settings in case admin updated active classes while away
    _settings = await SettingsService.instance.load();
    try {
      await File(snap.path).delete();
    } catch (_) {}
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade700,
    ));
  }

  Future<void> _showNotRecognized(String filePath) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final c = ctx.jb;
        return AlertDialog(
          backgroundColor: c.bgElev,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: c.danger),
              const SizedBox(width: AppSpacing.x8),
              Expanded(
                child: Text(AppStrings.faceNotRecognized,
                    style: TextStyle(color: c.text)),
              ),
            ],
          ),
          content: Text(
            AppStrings.faceNotRecognizedSub,
            style: TextStyle(color: c.textMute, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('OK',
                  style: TextStyle(
                      color: c.primary, fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
    try {
      await File(filePath).delete();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1426),
        body: Stack(
          fit: StackFit.expand,
          children: [
            _liveCameraOrFallback(),
            // dark vignette over the camera to keep the brand feel
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99000000),
                    Color(0x33000000),
                    Color(0xCC0A1426),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  CameraTopBar(
                    onMenuTap: () =>
                        Navigator.pushNamed(context, AppRoutes.passwordGate),
                  ),
                  const Spacer(),
                  Center(
                    child: _ScanFrameAnimated(scanning: _scanning),
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.x22),
                    child: Text(
                      AppStrings.lookAtCamera,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x8),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.x22),
                    child: Text(
                      AppStrings.keepFaceInside,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x22),
                  _ScanButton(
                    enabled: _ready && !_scanning,
                    scanning: _scanning,
                    onTap: _onScanPressed,
                  ),
                  const SizedBox(height: AppSpacing.x28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _liveCameraOrFallback() {
    if (_initializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_initError != null || _controller == null || !_ready) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _initError ?? 'Camera not available',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.x14),
              TextButton.icon(
                onPressed: _retry,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE8C547),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Tap to retry',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      );
    }
    return ClipRect(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.previewSize?.height ?? 720,
            height: _controller!.value.previewSize?.width ?? 1280,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }
}

class _ScanFrameAnimated extends StatefulWidget {
  final bool scanning;
  const _ScanFrameAnimated({required this.scanning});

  @override
  State<_ScanFrameAnimated> createState() => _ScanFrameAnimatedState();
}

class _ScanFrameAnimatedState extends State<_ScanFrameAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didUpdateWidget(covariant _ScanFrameAnimated old) {
    super.didUpdateWidget(old);
    if (widget.scanning && !_anim.isAnimating) {
      _anim.repeat(reverse: true);
    } else if (!widget.scanning && _anim.isAnimating) {
      _anim.stop();
      _anim.value = 0;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final scale = widget.scanning ? (1.0 + _anim.value * 0.04) : 1.0;
        return Transform.scale(
          scale: scale,
          child: const FaceScanFrame(size: 260),
        );
      },
    );
  }
}

class _ScanButton extends StatelessWidget {
  final bool enabled;
  final bool scanning;
  final VoidCallback onTap;
  const _ScanButton({
    required this.enabled,
    required this.scanning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Center(
      child: Material(
        color: enabled ? c.accent : Colors.white.withValues(alpha: 0.18),
        shape: const StadiumBorder(),
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: 0.6),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x28, vertical: AppSpacing.x18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (scanning)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0B1A35),
                    ),
                  )
                else
                  JbIcon(
                    JbIcon.faceScan,
                    size: 20,
                    color: c.onAccent,
                  ),
                const SizedBox(width: AppSpacing.x12),
                Text(
                  scanning ? AppStrings.scanning : AppStrings.startScan,
                  style: TextStyle(
                    color: c.onAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProcessingDialog extends StatefulWidget {
  final VoidCallback onShown;
  const _ProcessingDialog({required this.onShown});

  @override
  State<_ProcessingDialog> createState() => _ProcessingDialogState();
}

class _ProcessingDialogState extends State<_ProcessingDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onShown());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Dialog(
      backgroundColor: c.bgElev,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: c.accent, strokeWidth: 3),
            const SizedBox(height: AppSpacing.x18),
            Text(
              'Processing face…',
              style: TextStyle(
                color: c.text,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: AppSpacing.x6),
            Text(
              'Detecting · cropping · embedding · matching',
              style: TextStyle(
                color: c.textMute,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

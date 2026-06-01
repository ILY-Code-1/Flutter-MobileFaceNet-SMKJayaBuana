import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_settings.dart';
import '../../../../core/services/face_recognition_service.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/double_tap_back_to_exit.dart';
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
    with WidgetsBindingObserver, RouteAware {
  CameraController? _controller;
  CameraDescription? _camera;
  bool _ready = false;
  bool _initializing = true;
  String? _initError;
  bool _scanning = false;
  AppSettings? _settings;

  // ---- live face detection ----
  late final FaceDetector _liveDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.15,
    ),
  );
  bool _streaming = false;
  bool _detecting = false;
  InputImageRotation _rotation = InputImageRotation.rotation270deg;
  Rect? _faceBox;
  Size? _faceImageSize;
  DateTime _lastFaceSeen = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  // ---- RouteAware: pause/resume when covered by another route ----
  @override
  void didPushNext() {
    _stopStream();
  }

  @override
  void didPopNext() {
    if (_controller == null || !_ready) {
      _retry();
    } else {
      _startStream();
      _refreshSettings();
    }
  }

  Future<void> _refreshSettings() async {
    _settings = await SettingsService.instance.load();
  }

  Future<void> _bootstrap({int attempt = 0}) async {
    _settings = await SettingsService.instance.load();
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
      _camera = front;
      _rotation = InputImageRotationValue.fromRawValue(front.sensorOrientation) ??
          InputImageRotation.rotation270deg;

      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
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
      _startStream();
    } catch (e) {
      if (!mounted) return;
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

  Future<void> _retry() async {
    setState(() {
      _initializing = true;
      _initError = null;
      _ready = false;
      _faceBox = null;
    });
    await _stopStream();
    await _controller?.dispose();
    _controller = null;
    await _bootstrap();
  }

  // ---- image stream / face detection ----
  void _startStream() {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _streaming || _scanning) return;
    _streaming = true;
    c.startImageStream(_onFrame);
  }

  Future<void> _stopStream() async {
    final c = _controller;
    if (c == null || !_streaming) return;
    _streaming = false;
    try {
      await c.stopImageStream();
    } catch (_) {}
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_detecting || !mounted || _scanning) return;
    _detecting = true;
    try {
      final input = _toInputImage(image);
      if (input == null) return;
      final faces = await _liveDetector.processImage(input);
      if (!mounted) return;
      if (faces.isEmpty) {
        // keep the last box briefly to avoid flicker
        if (DateTime.now().difference(_lastFaceSeen) >
            const Duration(milliseconds: 600)) {
          if (_faceBox != null) setState(() => _faceBox = null);
        }
      } else {
        faces.sort(
            (a, b) => b.boundingBox.width.compareTo(a.boundingBox.width));
        _lastFaceSeen = DateTime.now();
        setState(() {
          _faceBox = faces.first.boundingBox;
          _faceImageSize =
              Size(image.width.toDouble(), image.height.toDouble());
        });
      }
    } catch (_) {
      // ignore stream-frame conversion errors
    } finally {
      _detecting = false;
    }
  }

  InputImage? _toInputImage(CameraImage image) {
    if (image.planes.isEmpty) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: _rotation,
        format: Platform.isAndroid
            ? InputImageFormat.nv21
            : InputImageFormat.bgra8888,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _stopStream();
      _controller?.dispose();
      _controller = null;
      _ready = false;
    } else if (state == AppLifecycleState.resumed) {
      if (_controller == null) _bootstrap();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appRouteObserver.unsubscribe(this);
    _stopStream();
    _controller?.dispose();
    _liveDetector.close();
    super.dispose();
  }

  Future<void> _onScanPressed() async {
    if (!_ready || _scanning || _controller == null) return;
    setState(() => _scanning = true);
    await _stopStream();

    XFile? snap;
    try {
      snap = await _controller!.takePicture();
    } catch (e) {
      if (!mounted) return;
      setState(() => _scanning = false);
      _startStream();
      _showError('Failed to capture: $e');
      return;
    }

    if (!mounted) return;

    final completer = Completer<void>();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: _ProcessingDialog(onShown: () {
          if (!completer.isCompleted) completer.complete();
        }),
      ),
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
      await _showNotRecognized(snap.path);
      _startStream();
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
    // didPopNext will restart the stream + refresh settings.
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
    final hasFace = _faceBox != null;
    return DoubleTapBackToExit(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: const Color(0xFF0A1426),
          body: Stack(
          fit: StackFit.expand,
          children: [
            _liveCameraOrFallback(),
            // Light vignette: only mild darkening top & bottom for legibility.
            IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.32, 0.66, 1.0],
                    colors: [
                      Color(0x66000000),
                      Color(0x0D000000),
                      Color(0x1A000000),
                      Color(0xCC0A1426),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  CameraTopBar(
                    onMenuTap: () =>
                        Navigator.pushNamed(context, AppRoutes.passwordGate),
                    onRefreshTap: _retry,
                  ),
                  const Spacer(),
                  if (!hasFace)
                    Center(child: _ScanFrameAnimated(scanning: _scanning)),
                  const Spacer(),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.x22),
                    child: Text(
                      hasFace ? 'Face detected' : AppStrings.lookAtCamera,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                        color: Colors.white.withValues(alpha: 0.7),
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
    final preview = _controller!.value.previewSize;
    final pw = preview?.height ?? 720;
    final ph = preview?.width ?? 1280;
    return ClipRect(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: pw,
            height: ph,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller!),
                if (_faceBox != null && _faceImageSize != null)
                  CustomPaint(
                    painter: _FaceBoxPainter(
                      faceBox: _faceBox!,
                      imageSize: _faceImageSize!,
                      canvasSize: Size(pw, ph),
                      rotation: _rotation,
                      lens: _camera?.lensDirection ??
                          CameraLensDirection.front,
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

/// Animated bracket frame, drawn around a detected face (or centred when
/// idle). Smoothly interpolates between detection frames.
class _FaceBoxPainter extends CustomPainter {
  final Rect faceBox;
  final Size imageSize;
  final Size canvasSize;
  final InputImageRotation rotation;
  final CameraLensDirection lens;

  _FaceBoxPainter({
    required this.faceBox,
    required this.imageSize,
    required this.canvasSize,
    required this.rotation,
    required this.lens,
  });

  double _tx(double x) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return x * canvasSize.width / imageSize.height;
      case InputImageRotation.rotation270deg:
        return canvasSize.width - x * canvasSize.width / imageSize.height;
      case InputImageRotation.rotation0deg:
      case InputImageRotation.rotation180deg:
        final v = x * canvasSize.width / imageSize.width;
        return lens == CameraLensDirection.back
            ? v
            : canvasSize.width - v;
    }
  }

  double _ty(double y) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        return y * canvasSize.height / imageSize.width;
      case InputImageRotation.rotation0deg:
      case InputImageRotation.rotation180deg:
        return y * canvasSize.height / imageSize.height;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final l = _tx(faceBox.left);
    final r = _tx(faceBox.right);
    final t = _ty(faceBox.top);
    final b = _ty(faceBox.bottom);
    final rect = Rect.fromLTRB(
      l < r ? l : r,
      t < b ? t : b,
      l < r ? r : l,
      t < b ? b : t,
    ).inflate(8);

    const accent = Color(0xFF5DD49A);
    final glow = Paint()
      ..color = accent.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final stroke = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rrect =
        RRect.fromRectAndRadius(rect, const Radius.circular(18));
    canvas.drawRRect(rrect, glow);

    // Corner brackets.
    final cl = (rect.width * 0.26).clamp(16.0, 48.0);
    void corner(Offset p, Offset h, Offset v) {
      canvas.drawLine(p, p + h, stroke);
      canvas.drawLine(p, p + v, stroke);
    }

    corner(rect.topLeft, Offset(cl, 0), Offset(0, cl));
    corner(rect.topRight, Offset(-cl, 0), Offset(0, cl));
    corner(rect.bottomLeft, Offset(cl, 0), Offset(0, -cl));
    corner(rect.bottomRight, Offset(-cl, 0), Offset(0, -cl));
  }

  @override
  bool shouldRepaint(covariant _FaceBoxPainter old) =>
      old.faceBox != faceBox || old.canvasSize != canvasSize;
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
                  JbIcon(JbIcon.faceScan, size: 20, color: c.onAccent),
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
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onShown());
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

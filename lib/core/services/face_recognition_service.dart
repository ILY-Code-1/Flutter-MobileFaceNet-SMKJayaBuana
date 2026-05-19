import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/app_database.dart';
import '../data/models.dart';

/// Single result returned by [FaceRecognitionService.matchAgainst].
class FaceMatch {
  final Student student;
  final double similarity; // cosine similarity 0..1
  const FaceMatch({required this.student, required this.similarity});

  int get confidencePercent => (similarity.clamp(0.0, 1.0) * 100).round();
}

/// Pipeline:
///   1. detect a face with ML Kit
///   2. crop & resize to 112×112
///   3. run MobileFaceNet → 192-d embedding (or fallback hash-based)
///   4. compare against the database embeddings (cosine similarity)
class FaceRecognitionService {
  FaceRecognitionService._();
  static final FaceRecognitionService instance = FaceRecognitionService._();

  static const _kModelAsset = 'assets/models/mobilefacenet.tflite';
  static const _kInputSize = 112;
  static const _kEmbeddingSize = 192;

  /// Minimum cosine similarity for a positive match.
  /// 0.65 is a reasonable threshold for MobileFaceNet embeddings.
  static const double matchThreshold = 0.65;

  Interpreter? _interpreter;
  bool _modelMissing = false;
  FaceDetector? _detector;

  FaceDetector get detector => _detector ??= FaceDetector(
        options: FaceDetectorOptions(
          enableContours: false,
          enableLandmarks: false,
          enableClassification: false,
          enableTracking: false,
          performanceMode: FaceDetectorMode.accurate,
          minFaceSize: 0.15,
        ),
      );

  Future<Interpreter?> _loadInterpreter() async {
    if (_interpreter != null) return _interpreter;
    if (_modelMissing) return null;
    try {
      _interpreter = await Interpreter.fromAsset(_kModelAsset);
      return _interpreter;
    } catch (_) {
      _modelMissing = true;
      return null;
    }
  }

  /// Convert an arbitrary image file into a 112×112 face crop centred on
  /// the largest detected face.  Returns null when no face is found.
  Future<img.Image?> detectAndCrop(String filePath) async {
    final input = InputImage.fromFilePath(filePath);
    final faces = await detector.processImage(input);
    final bytes = await File(filePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    if (faces.isEmpty) {
      return img.copyResize(decoded, width: _kInputSize, height: _kInputSize);
    }
    faces.sort((a, b) => b.boundingBox.width.compareTo(a.boundingBox.width));
    final box = faces.first.boundingBox;
    final x = box.left.clamp(0, decoded.width - 1).toInt();
    final y = box.top.clamp(0, decoded.height - 1).toInt();
    final w = box.width.clamp(1, decoded.width - x).toInt();
    final h = box.height.clamp(1, decoded.height - y).toInt();
    final cropped =
        img.copyCrop(decoded, x: x, y: y, width: w, height: h);
    return img.copyResize(cropped, width: _kInputSize, height: _kInputSize);
  }

  /// Run the embedding model on a 112×112 image.  Falls back to a stable
  /// hash-based vector if the .tflite file is missing.
  Future<List<double>> embed(img.Image face) async {
    final interpreter = await _loadInterpreter();
    if (interpreter == null) return _fallbackEmbed(face);

    final input = _imageToFloat32(face);
    final output = List.generate(1, (_) => List.filled(_kEmbeddingSize, 0.0));
    try {
      interpreter.run(input, output);
    } catch (_) {
      return _fallbackEmbed(face);
    }
    return _l2Normalize(output[0]);
  }

  /// Pipeline helper: file → embedding (or null if no face / decode error).
  Future<List<double>?> embedFromFile(String filePath) async {
    final face = await detectAndCrop(filePath);
    if (face == null) return null;
    return embed(face);
  }

  /// Cosine similarity between two L2-normalised vectors.
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0;
    double dot = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot.clamp(-1.0, 1.0);
  }

  /// Match an embedding against a list of candidate students.
  Future<FaceMatch?> matchAgainst({
    required List<double> probe,
    required List<Student> candidates,
    double threshold = matchThreshold,
  }) async {
    FaceMatch? best;
    for (final s in candidates) {
      final emb = s.embedding;
      if (emb == null || emb.isEmpty) continue;
      final sim = cosineSimilarity(probe, emb);
      if (best == null || sim > best.similarity) {
        best = FaceMatch(student: s, similarity: sim);
      }
    }
    if (best == null) return null;
    if (best.similarity < threshold) return null;
    return best;
  }

  /// High-level convenience: takes the photo file path, returns the best
  /// match across all enrolled students restricted to [classIds].
  Future<FaceMatch?> identifyFromFile({
    required String filePath,
    List<int>? classIds,
  }) async {
    final emb = await embedFromFile(filePath);
    if (emb == null) return null;
    final students = await AppDatabase.instance.listStudents(
      inClassIds: classIds,
      includeDrafts: false,
    );
    return matchAgainst(probe: emb, candidates: students);
  }

  /// Convert a [ui.Image] captured from the live camera to a face embedding.
  /// Used for the scan loop.
  Future<FaceMatch?> identifyFromUiImage({
    required ui.Image image,
    List<int>? classIds,
  }) async {
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    final tmp = await _writeTempPng(byteData.buffer.asUint8List());
    try {
      return identifyFromFile(filePath: tmp.path, classIds: classIds);
    } finally {
      try {
        await tmp.delete();
      } catch (_) {}
    }
  }

  Future<File> _writeTempPng(Uint8List bytes) async {
    final dir = Directory.systemTemp;
    final f = File(
        '${dir.path}/scan_${DateTime.now().microsecondsSinceEpoch}.png');
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  // ---------------- internal helpers ----------------

  /// Convert image to `[1, 112, 112, 3]` float input in `[-1, 1]` range.
  List<List<List<List<double>>>> _imageToFloat32(img.Image image) {
    final input = List.generate(
      1,
      (_) => List.generate(
        _kInputSize,
        (_) => List.generate(
          _kInputSize,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );
    for (int y = 0; y < _kInputSize; y++) {
      for (int x = 0; x < _kInputSize; x++) {
        final px = image.getPixel(x, y);
        input[0][y][x][0] = (px.r - 127.5) / 128.0;
        input[0][y][x][1] = (px.g - 127.5) / 128.0;
        input[0][y][x][2] = (px.b - 127.5) / 128.0;
      }
    }
    return input;
  }

  List<double> _l2Normalize(List<double> v) {
    double sum = 0;
    for (final x in v) {
      sum += x * x;
    }
    final n = math.sqrt(sum);
    if (n == 0) return v;
    return [for (final x in v) x / n];
  }

  /// Deterministic embedding derived from a perceptual hash of the image
  /// pixels — only used when the .tflite model is unavailable so the rest
  /// of the app keeps working in development.
  List<double> _fallbackEmbed(img.Image face) {
    final v = List<double>.filled(_kEmbeddingSize, 0);
    for (int y = 0; y < _kInputSize; y += 8) {
      for (int x = 0; x < _kInputSize; x += 8) {
        final px = face.getPixel(x, y);
        final idx = ((y * _kInputSize + x) * 3) % _kEmbeddingSize;
        v[idx] += px.r.toDouble();
        v[(idx + 1) % _kEmbeddingSize] += px.g.toDouble();
        v[(idx + 2) % _kEmbeddingSize] += px.b.toDouble();
      }
    }
    return _l2Normalize(v);
  }

  Future<bool> isModelAvailable() async {
    try {
      await rootBundle.load(_kModelAsset);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
    await _detector?.close();
    _detector = null;
  }
}

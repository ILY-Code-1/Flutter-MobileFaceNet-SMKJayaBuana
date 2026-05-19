# MobileFaceNet Model

This directory must contain the pretrained MobileFaceNet TFLite model file used
to convert a 112×112 face crop into a 192-dimension embedding vector.

## Required file

- `mobilefacenet.tflite` — input shape: `[1, 112, 112, 3]`, output: `[1, 192]`.

## Where to get it

Download from any of the well-known public mirrors, e.g.
<https://github.com/sirius-ai/MobileFaceNet_TF/tree/master/arch> or any other
mirror of the original "MobileFaceNet" paper weights. Place the resulting
`.tflite` file at:

```
assets/models/mobilefacenet.tflite
```

After placing the file, run `flutter pub get` and rebuild the app. The
[FaceRecognitionService](../../lib/core/services/face_recognition_service.dart)
loads it lazily on first use.

## Fallback

If the file is missing, the app falls back to a deterministic
hash-based embedding so the rest of the application still runs end-to-end for
development. The fallback is **not** a real face recogniser — replace the
`.tflite` before shipping.

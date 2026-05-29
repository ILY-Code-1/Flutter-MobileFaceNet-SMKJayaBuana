# Model MobileFaceNet

Direktori ini harus berisi berkas model TFLite MobileFaceNet terlatih yang
dipakai untuk mengubah crop wajah 112×112 menjadi vektor embedding 192 dimensi.

## Berkas yang diperlukan

- `mobilefacenet.tflite` — bentuk input: `[1, 112, 112, 3]`, output: `[1, 192]`.

## Cara memperolehnya

Unduh dari salah satu mirror publik yang umum dikenal, mis.
<https://github.com/sirius-ai/MobileFaceNet_TF/tree/master/arch> atau mirror
lain dari bobot paper "MobileFaceNet" yang asli. Letakkan berkas `.tflite` hasil
unduhan di:

```
assets/models/mobilefacenet.tflite
```

Setelah meletakkan berkas, jalankan `flutter pub get` dan bangun ulang aplikasi.
[FaceRecognitionService](../../lib/core/services/face_recognition_service.dart)
memuatnya secara lazy saat pertama kali digunakan.

## Fallback

Jika berkas tidak ada, aplikasi jatuh ke embedding berbasis hash deterministik
sehingga sisa aplikasi tetap dapat berjalan end-to-end untuk pengembangan.
Fallback ini **bukan** pengenal wajah sungguhan — ganti berkas `.tflite`-nya
sebelum dirilis.

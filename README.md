# Absensi SMK Jaya Buana

Aplikasi absensi siswa berbasis pengenalan wajah (face recognition) yang dibangun
dengan Flutter. Aplikasi ini mengubah satu perangkat Android menjadi terminal
absensi mandiri untuk SMK Jaya Buana: siswa berdiri di depan kamera, aplikasi
mengenali mereka dengan **MobileFaceNet**, dan hasilnya ditulis ke basis data
**SQLite** lokal.

Semuanya berjalan secara lokal — tidak ada backend, tidak ada akun internet,
tidak ada sinkronisasi cloud. Seluruh data tersimpan di direktori dokumen
aplikasi pada perangkat.

> 📘 **Panduan Pengguna (Bahasa Indonesia):**
> [**⬇️ Unduh PDF**](PANDUAN_PENGGUNA.pdf) · atau baca versi
> [Markdown](PANDUAN_PENGGUNA.md).

---

## Daftar isi
1. [Tech stack](#tech-stack)
2. [Struktur proyek](#struktur-proyek)
3. [Setup](#setup)
4. [Alur peluncuran pertama kali](#alur-peluncuran-pertama-kali)
5. [Layar kamera utama](#layar-kamera-utama)
6. [Menu admin](#menu-admin)
   1. [Siswa](#siswa)
   2. [Laporan](#laporan)
   3. [Pengaturan](#pengaturan)
7. [Pipeline pengenalan wajah](#pipeline-pengenalan-wajah)
8. [Logika absensi (aturan status)](#logika-absensi-aturan-status)
9. [Skema basis data](#skema-basis-data)
10. [Data default & seed](#data-default--seed)

---

## Tech stack

- **Flutter / Dart** — UI dan logika aplikasi
- **sqflite** — penyimpanan SQLite (dengan `path_provider` untuk path DB)
- **camera** — pratinjau langsung, pengambilan gambar, dan image stream yang
  dipakai untuk deteksi kotak wajah secara langsung
- **image_picker** — unggah pas-foto saat pendaftaran
- **image** — decode JPEG/PNG, resize ke 112×112 untuk input model
- **google_mlkit_face_detection** — mendeteksi bounding box wajah (baik untuk
  overlay langsung maupun untuk cropping saat pendaftaran / pemindaian)
- **tflite_flutter** — menjalankan model terlatih `mobilefacenet.tflite` untuk
  mengubah wajah yang sudah di-crop menjadi vektor embedding 192 dimensi
- **audioplayers** — suara umpan balik singkat setelah pemindaian
- **device_info_plus** — nama perangkat yang terdeteksi otomatis, dipakai
  sebagai nilai default pengaturan
- **pdf + printing** — membuat dan membagikan laporan absensi PDF multi-halaman
- **share_plus** — membagikan cadangan basis data `.sql` ke WhatsApp pengembang
- **url_launcher** — tautan cadangan chat WhatsApp "Hubungi pengembang"
- **intl** — pemformatan bulan/hari
- **crypto** — hash sha256 untuk PIN admin

## Struktur proyek

```
lib/
├── main.dart                                  # bootstrap, menentukan rute awal
├── routing/app_router.dart                    # named routes + route observer
├── core/
│   ├── constants/                             # string & nama aset seluruh aplikasi
│   ├── theme/                                 # tokens, tema terang/gelap
│   ├── data/
│   │   ├── app_database.dart                  # seluruh CRUD SQLite (skema v3)
│   │   ├── app_settings.dart                  # pengaturan bertipe + service
│   │   ├── models.dart                        # Admin, SchoolClass, Student…
│   │   └── seed.dart                          # data dummy pertama kali
│   ├── services/
│   │   ├── face_recognition_service.dart      # pipeline ML Kit + MobileFaceNet
│   │   ├── sound_service.dart                 # memutar suara umpan balik pindai
│   │   ├── device_info_service.dart           # deteksi otomatis nama perangkat
│   │   ├── database_backup_service.dart       # menulis berkas cadangan .sql
│   │   └── attendance_finalizer_service.dart  # auto-tandai Absen + auto check-out
│   ├── utils/
│   │   ├── time_utils.dart                    # aturan status dari jam masuk/pulang
│   │   └── pin_validator.dart                 # aturan PIN 6 digit
│   └── widgets/                               # atom UI bersama (JbButton,
│                                              # JbPinDots, ShakeWidget…)
├── features/
│   ├── registration/                          # pendaftaran admin satu halaman
│   ├── camera/                                # kamera idle, gerbang PIN,
│   │                                          # layar dikenali, sukses
│   ├── menu/                                  # beranda admin (3 tile)
│   ├── settings/                              # CRUD kelas, jadwal, terminal
│   ├── students/                              # daftar, daftar/edit, embed foto
│   └── reports/                               # filter, rekap, ekspor PDF
assets/
├── icons/        # kumpulan ikon SVG
├── images/       # logo.png (juga ikon launcher Android)
├── models/       # mobilefacenet.tflite diletakkan di sini
└── sounds/       # soft_chime.mp3, beep.mp3, success_ding.mp3
backup_db.sql     # skema yang mudah dibaca (v2) + data dummy untuk referensi
```

## Setup

1. Pasang berkas model **MobileFaceNet**.
   Unduh `mobilefacenet.tflite` (model dengan input `1 × 112 × 112 × 3`, output
   `1 × 192`) dan salin ke:
   ```
   assets/models/mobilefacenet.tflite
   ```
   Lihat [`assets/models/README.md`](assets/models/README.md) untuk detailnya.
   Jika berkas tidak ada, aplikasi tetap berjalan tetapi embedding akan jatuh
   ke hash deterministik — **jangan rilis tanpa model yang asli**.

2. (Opsional) Letakkan tiga berkas audio pendek di `assets/sounds/`:
   `soft_chime.mp3`, `beep.mp3`, `success_ding.mp3`. Berkas yang hilang akan
   diabaikan tanpa efek.

3. Ambil paket dan jalankan di perangkat Android:
   ```bash
   flutter pub get
   flutter run
   ```

`minSdk` Android adalah **24** (diperlukan untuk ML Kit + plugin camera terbaru).
Izin untuk `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE`,
`WRITE_EXTERNAL_STORAGE` ditambah `<queries>` untuk tautan WhatsApp dideklarasikan di
[`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml).

Ikon launcher dihasilkan dari `assets/images/logo.png` melalui
`flutter_launcher_icons` (`dart run flutter_launcher_icons`). Ikon adaptif
menggunakan `adaptive_icon_foreground_inset: 25` sehingga seluruh lambang Jaya
Buana — termasuk wordmark "JAYA BUANA" — tetap berada di dalam zona aman dan
tidak pernah terpotong oleh mask launcher (lingkaran / squircle / persegi
membulat).

## Alur peluncuran pertama kali

Pendaftaran berupa **satu halaman** — tidak ada kata sandi, hanya username dan
PIN 6 digit:

1. Masukkan **username**.
2. **Buat PIN admin** — 6 digit yang dimasukkan melalui keypad di layar.
   Validasi berjalan begitu digit ke-6 masuk:
   - menolak semua digit sama (mis. `111111`)
   - menolak urutan naik / turun yang ketat (mis. `123456`, `654321`)
   - saat ditolak, titik-titik berkedip merah dan **bergetar**, lalu dikosongkan
   - saat berhasil, titik-titik berkedip hijau dan halaman lanjut ke konfirmasi
3. **Konfirmasi PIN** — masukkan ulang 6 digit yang sama. Ketidakcocokan akan
   bergetar dan dikosongkan; kecocokan berkedip hijau dan akun dibuat.

PIN di-hash (sha256) dan disimpan di tabel `admin`. Seeder kemudian berjalan
(kelas + siswa dummy + absensi bulan berjalan) dan aplikasi menuju ke layar
kamera.

**Tidak ada** alur login / logout. Setelah baris admin ada, layar kamera menjadi
layar beranda; gerbang PIN adalah satu-satunya jalan masuk ke area admin.

## Layar kamera utama

- Pratinjau langsung dari **kamera depan** dengan vignette ringan (hanya
  penggelapan tipis di bagian paling atas dan bawah agar teks terbaca).
- **Kotak wajah langsung** — sebuah image stream menjalankan deteksi wajah ML Kit
  secara terus-menerus dan menggambar bracket hijau beranimasi di sekitar wajah
  yang terdeteksi. Saat tidak ada wajah, ditampilkan bingkai panduan idle emas.
- Pil emas **"Start scan"** di bagian bawah mengambil gambar diam dan
  menjalankan pipeline pengenalan di balik dialog *Processing face…*.
- Setelah pencocokan:
  - **Ditemukan** → layar **Recognized**, yang menampilkan foto yang baru
    diambil berbingkai hijau di bagian atas, dan kartu berisi data siswa (foto,
    nama, NIS, kelas, persentase keyakinan, tombol clock-in / clock-out).
    Tertutup otomatis setelah **10 detik**.
  - **Tidak ditemukan** → dialog kesalahan ("Face not recognized · contact admin").
- Tombol **refresh** (kanan atas) menginisialisasi ulang kamera jika gagal
  menyala.
- Tombol **burger** (kanan atas) membuka **gerbang kata sandi**.
- Navigasi tidak pernah membuat ulang halaman kamera — layar menu / dikenali /
  sukses ditumpuk di atas lalu di-*pop* kembali, sehingga kamera tetap berjalan.

## Menu admin

Tiga tile bergaya seragam: **Siswa · Laporan · Pengaturan** (menekan tile
menampilkan ripple biru). Tanggal hari ini dan username admin ada di bagian
atas. Footer berisi dua tombol berdampingan dengan versi aplikasi di tengah
bawahnya:

- **Hubungi pengembang** (kiri) — membuka chat WhatsApp pengembang
  (**+62 851-7822-6071**) yang sudah terisi pesan bantuan.
- **Backup Database** (kanan) — menulis cadangan `.sql` baru dari seluruh basis
  data, lalu membuka share sheet sistem agar admin dapat mengirim berkas itu ke
  pengembang; tombol menampilkan spinner selama cadangan disiapkan.

Tombol tutup mengembalikan ke kamera langsung.

### Siswa

- Filter berdasarkan kelas melalui ikon corong (default = **Semua kelas**).
- Pencarian langsung berdasarkan nama atau NIS.
- Siswa draft diredupkan dan diberi tag `DRAFT`.
- Ikon tempat sampah menghapus siswa (beserta seluruh absensinya).
- Tombol **+ Enroll face** membuka layar pendaftaran.

#### Daftar / edit siswa

- Satu kolom pas-foto. Ketuk untuk memilih dari galeri atau kamera; gambar
  disalin ke folder dokumen aplikasi agar path-nya stabil.
- **Process embed** menjalankan detect → crop → resize → MobileFaceNet →
  L2-normalise dan menyimpan vektor 192-d sebagai `BLOB`. Sebaris status
  mengonfirmasi `Embedding ready` atau `No face detected`.
- Nama, NIS, dan dropdown kelas wajib diisi.
- **Save draft** menulis baris dengan `is_draft = 1` (tidak butuh embedding).
- **Submit** memerlukan embedding yang berhasil.

### Laporan

- Lembar filter: **kelas · tahun · bulan · hari** (tiap tingkat bisa "Any"
  untuk memperluas cakupan — hanya bulan, hanya tahun, atau sepanjang waktu).
- Baris rekap: jumlah HADIR · TERLAMBAT · ABSEN + %.
- Tabel per siswa dengan P / L / A dan persentase kehadiran.
- Menekan sebuah baris membuka dialog detail hari-demi-hari untuk siswa itu.
- Footer biru **EXPORT** berada di bawah tabel yang dapat digulir (tidak
  menutupinya) dan tombol **PDF** menghasilkan laporan bergaya multi-halaman
  sesuai filter aktif: sebuah **halaman ringkasan** (rekap + tabel per siswa)
  diikuti **satu halaman baru per siswa** yang mencantumkan tanggal, jam masuk,
  jam pulang, dan status untuk setiap hari.
- Hanya baris yang **lengkap** (memiliki `check_out_time`) yang diagregasi.

### Pengaturan

- **01 · Kelas** — tiap kelas berupa kartu. Ketuk untuk mengaktifkan/menonaktifkan
  apakah terminal mengenalinya. Edit / hapus tersedia di dalam kartu; kelas yang
  masih dipakai siswa tidak dapat dihapus.
- **02 · Jadwal**
  - `CLOCK-IN` — pemindaian hingga satu jam setelah ini berstatus *hadir*,
    setelahnya *terlambat*.
  - `CLOCK-OUT` — waktu paling awal tombol check-out menjadi aktif.
  - `LAST CHECK-OUT` — batas akhir harian; baris tanpa check-out sampai waktu
    ini tetap tidak lengkap, sehingga siswa terhitung absen pada hari itu.
- **03 · Terminal ini**
  - `Device name` — teks bebas, terisi awal dari nama perangkat asli.
  - `Sound on scan` — *Soft chime · Beep · Success ding · Silent*.

## Pipeline pengenalan wajah

Baik pendaftaran maupun pemindaian menggunakan pipeline yang sama
([`face_recognition_service.dart`](lib/core/services/face_recognition_service.dart)):

1. **Detect** — ML Kit mengembalikan bounding box wajah; yang terbesar dipilih.
2. **Crop & resize** — di-crop ke wajah, di-resize ke `112 × 112`.
3. **Embed** — dinormalisasi ke `[-1, 1]` dan dijalankan melalui
   `mobilefacenet.tflite`, menghasilkan vektor 192-d yang di-L2-normalise.
4. **Match** — untuk pemindaian, vektor probe dibandingkan dengan setiap siswa
   terdaftar pada kelas yang *aktif* menggunakan **cosine similarity**;
   kecocokan terbaik di atas `0.65` yang menang.

Overlay kamera langsung memakai detektor ML Kit terpisah yang lebih ringan
(mode cepat) pada image stream kamera hanya untuk menggambar kotak wajah — ini
tidak melakukan embedding.

## Logika absensi (aturan status)

| Momen | Hasil |
| --- | --- |
| Memindai **sebelum `clockIn + 1j`** | check-in tersimpan, status = **hadir** |
| Memindai **setelah `clockIn + 1j`** | check-in tersimpan, status = **terlambat** |
| Sudah check-in | tombol check-in dinonaktifkan |
| Memindai pada/setelah `clockOut` | tombol check-out aktif |
| **Tidak ada check-in sama sekali** pada hari sekolah | baris **absen** disisipkan oleh auto-finalize → muncul di kolom A |
| **Sudah check-in tetapi tidak check-out** hingga `lastCheckOut` | `check_out_time` diisi otomatis dengan `lastCheckOut`, baris ditandai `auto_checkout = 1`; status tetap **hadir** / **terlambat** |

**"Absen" sekarang berarti siswa tidak datang ke sekolah** (tidak ada catatan
check-in sama sekali). Lupa scan pulang **bukan** absen — itu berarti "saya
masuk tetapi terminal menutup hari saya secara otomatis", ditampilkan dengan
tanda kecil ⚠️ (tanda bintang `*` di PDF) di samping waktu check-out yang diisi
otomatis.

Pergeseran ini diterapkan oleh rutin **auto-finalize**
([`attendance_finalizer_service.dart`](lib/core/services/attendance_finalizer_service.dart)),
yang berjalan secara fire-and-forget saat aplikasi diluncurkan dan lagi (di-await)
setiap kali halaman Laporan dimuat. Rutin ini menelusuri setiap hari kerja yang
lampau dalam jendela pendaftaran, menyisipkan placeholder `absent` untuk siswa
tanpa catatan, dan melakukan auto check-out untuk siswa yang lupa — idempoten
berkat batasan `UNIQUE(student_id, date)` dan penjaga `WHERE check_out_time IS NULL`
pada operasi update.

Rincian lengkap pemetaan waktu-ke-status (dengan timeline visual, bagian
auto-finalize, dan skenario konkret memakai siswa seed nyata) ada di
[`docs/attendance_time_rules.html`](docs/attendance_time_rules.html).

## Skema basis data

DDL lengkap + baris contoh: [`backup_db.sql`](backup_db.sql). Ringkasan (**v3**):

```
admin       (id, username, pin_hash, created_at)          -- tanpa password
classes     (id, name UNIQUE, created_at)
students    (id, name, nis UNIQUE, class_id → classes.id,
             photo_path, embedding BLOB, is_draft, created_at)
attendance  (id, student_id → students.id, date,
             check_in_time, check_out_time, status,
             auto_checkout,
             UNIQUE (student_id, date))
settings    (key PRIMARY KEY, value)

indexes: idx_students_class, idx_attendance_student, idx_attendance_date
```

Embedding adalah byte little-endian mentah dari `Float32List(192)` (768 byte).
Tabel `settings` menyimpan nilai kecil sebagai string, mis.
`active_class_ids = "1,2,5"`, `clock_in_time = "07:00"`.

Basis data berada pada versi **3**. v3 menambahkan kolom `auto_checkout INTEGER
NOT NULL DEFAULT 0` pada `attendance` (dipakai oleh rutin auto-finalize yang
dijelaskan di [Logika absensi](#logika-absensi-aturan-status)). Tangga migrasi
menerapkan `ALTER TABLE` non-destruktif untuk v2 → v3, sehingga data v2 produksi
tetap terjaga. Instalasi pra-v2 (tahap dev) tetap dibangun ulang dari awal.

Dump `.sql` lengkap dari basis data **live** (skema + setiap baris, dengan
embedding `BLOB` yang dienkode hex sebagai `X'…'`) dapat dihasilkan sesuai
permintaan oleh `AppDatabase.exportSqlDump()`. Aksi **Hubungi pengembang**
([Menu admin](#menu-admin)) memakai ini untuk menulis berkas
`backup_smk_jaya_buana_<tanggal>.sql` bertanda waktu sebelum membagikannya —
dump tersebut dapat dijalankan ulang terhadap basis data SQLite kosong untuk
memulihkan instalasi.

## Data default & seed

Seeder ([`lib/core/data/seed.dart`](lib/core/data/seed.dart)) berjalan sekali
setelah pendaftaran:

| | |
| --- | --- |
| PIN Admin | ditetapkan oleh Anda di layar pendaftaran (6 digit acak) |
| Kelas | `X · RPL · A`, `X · TKR · A`, `XI · RPL · A`, `XI · MM · A`, `XII · AKL · B`, `XII · Animation` |
| Siswa | 12 siswa dummy yang tersebar di seluruh kelas |
| Absensi | setiap hari kerja pada bulan berjalan untuk 8 siswa pertama (dengan satu absen berulang dan satu terlambat berulang) |

Untuk melakukan seed ulang, hapus data aplikasi (atau berkas
`smk_jaya_buana.db`) dan daftar lagi.

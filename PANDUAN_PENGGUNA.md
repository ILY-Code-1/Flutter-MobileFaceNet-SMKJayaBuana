# Panduan Pengguna — Absensi SMK Jaya Buana

Panduan ini menjelaskan cara menggunakan aplikasi **Absensi SMK Jaya Buana**
(Jaya Buana · Attendance Studio, versi **v2.0.0**) dari awal hingga laporan
absensi siap dibagikan.

Aplikasi ini mengubah satu perangkat Android menjadi **terminal absensi mandiri**
berbasis pengenalan wajah. Siswa cukup berdiri di depan kamera, aplikasi
mengenali wajahnya, lalu mencatat jam masuk / pulang. Semua data tersimpan
**di dalam perangkat** (tidak ada internet, tidak ada akun online, tidak ada
server). Internet hanya dibutuhkan saat membuka WhatsApp untuk menghubungi
pengembang.

> **Istilah singkat**
> - **Admin / Operator** — petugas yang memegang PIN dan mengelola data.
> - **Terminal** — perangkat Android tempat aplikasi terpasang.
> - **Check-in / Clock-in** — absen masuk (datang ke sekolah).
> - **Check-out / Clock-out** — absen pulang.
> - **Embedding** — "sidik wajah" digital yang dibuat dari foto siswa.

---

## Daftar Isi

1. [Siapa yang menggunakan aplikasi ini](#1-siapa-yang-menggunakan-aplikasi-ini)
2. [Pengaturan pertama kali (membuat akun admin)](#2-pengaturan-pertama-kali-membuat-akun-admin)
3. [Layar kamera (halaman utama)](#3-layar-kamera-halaman-utama)
4. [Cara siswa melakukan absensi](#4-cara-siswa-melakukan-absensi)
5. [Masuk ke menu admin (gerbang PIN)](#5-masuk-ke-menu-admin-gerbang-pin)
6. [Menu admin](#6-menu-admin)
7. [Mengelola siswa (pendaftaran wajah)](#7-mengelola-siswa-pendaftaran-wajah)
8. [Pengaturan (kelas, jadwal, perangkat)](#8-pengaturan-kelas-jadwal-perangkat)
9. [Laporan absensi & ekspor PDF](#9-laporan-absensi--ekspor-pdf)
10. [Aturan status absensi](#10-aturan-status-absensi)
11. [Cadangan data (backup) & hubungi pengembang](#11-cadangan-data-backup--hubungi-pengembang)
12. [Pertanyaan yang sering muncul (FAQ)](#12-pertanyaan-yang-sering-muncul-faq)

---

## 1. Siapa yang menggunakan aplikasi ini

| Peran | Yang dilakukan |
| --- | --- |
| **Siswa** | Berdiri di depan kamera dan menekan tombol untuk absen masuk / pulang. Tidak perlu PIN. |
| **Admin / Operator** | Mendaftarkan wajah siswa, mengatur jadwal & kelas, melihat laporan, dan membuat cadangan data. Membutuhkan PIN. |

Satu perangkat hanya memiliki **satu akun admin**. Tidak ada fitur login/logout
harian — layar kamera selalu terbuka, dan area admin dilindungi oleh PIN.

---

## 2. Pengaturan pertama kali (membuat akun admin)

Saat aplikasi pertama kali dibuka, Anda akan diminta membuat akun admin.
Prosesnya **2 langkah** dan **tidak memakai kata sandi**, hanya username + PIN
6 angka.

**Langkah 1 — Buat username**
1. Masukkan **USERNAME** (contoh: `admin_smk`).
2. Tekan **Next**.

**Langkah 2 — Buat PIN admin**
1. Masukkan **PIN 6 angka** melalui keypad di layar.
2. PIN akan ditolak otomatis jika:
   - semua angka sama (mis. `111111`), atau
   - berurutan naik/turun (mis. `123456` atau `654321`).
   Jika ditolak, titik-titik PIN berkedip merah dan bergetar, lalu dikosongkan.
3. Jika valid, titik berkedip hijau dan lanjut ke konfirmasi.
4. **Masukkan ulang PIN yang sama** untuk konfirmasi. Jika cocok, akun dibuat.

> ⚠️ **Ingat PIN ini baik-baik.** PIN adalah satu-satunya kunci ke menu admin
> (mengelola siswa, jadwal, dan laporan). Tidak ada fitur "lupa PIN" — jika PIN
> hilang, satu-satunya jalan adalah menghapus data aplikasi dan mendaftar ulang
> (lihat [FAQ](#12-pertanyaan-yang-sering-muncul-faq)).

Setelah akun dibuat, aplikasi otomatis mengisi **data contoh** (beberapa kelas,
siswa dummy, dan absensi bulan berjalan) lalu langsung membuka layar kamera.
Data contoh ini boleh Anda hapus dan ganti dengan data sekolah yang sebenarnya.

---

## 3. Layar kamera (halaman utama)

Ini adalah layar yang selalu tampil dan siap dipakai siswa sepanjang hari.

Yang terlihat di layar:
- **Pratinjau kamera depan** dengan panduan posisi wajah.
- Teks **"Look at the camera"** dan **"Tap the gold button below to start the scan"**.
- **Kotak wajah hijau** muncul otomatis mengikuti wajah yang terdeteksi.
- Tombol emas **"Start scan"** di bagian bawah untuk memulai pemindaian.

Tombol di pojok kanan atas:
- 🔄 **Refresh** — menyalakan ulang kamera bila kamera gagal tampil/macet.
- ☰ **Burger (menu)** — membuka **gerbang PIN** untuk masuk ke menu admin.

> Layar kamera dirancang tetap menyala dan tidak dibuat ulang saat berpindah
> halaman, sehingga proses absensi tetap cepat.

---

## 4. Cara siswa melakukan absensi

1. Siswa berdiri menghadap kamera, pastikan wajah berada di dalam panduan dan
   pencahayaan cukup.
2. Tekan tombol **"Start scan"**. Aplikasi memproses wajah (muncul tulisan
   *Processing face…*).
3. **Jika wajah dikenali**, muncul layar **FACE RECOGNIZED** yang menampilkan:
   - foto hasil pindai (berbingkai hijau),
   - persentase keyakinan (mis. *92% CONFIDENCE*),
   - nama, kelas, dan NIS siswa,
   - status hari ini, misalnya:
     - *"Belum check-in hari ini."*
     - *"Sudah check-in pukul 07:05 · belum check-out."*
     - *"Check-in 07:05 · Check-out 15:40"*
4. Pada pertanyaan **"What are you doing right now?"**, siswa memilih:
   - **Clock-in** (*Arriving at school*) — absen masuk.
   - **Clock-out** (*Going home*) — absen pulang.
5. Setelah berhasil, muncul layar **CLOCKED IN / CLOCKED OUT SUCCESSFULLY**,
   lalu otomatis kembali ke kamera.

**Catatan penting:**
- Tombol **Clock-in** nonaktif jika siswa sudah check-in hari ini.
- Tombol **Clock-out** baru aktif setelah melewati jam **CLOCK-OUT** yang
  diatur (default 15:30). Jika ditekan terlalu awal, muncul pesan
  *"Check-out is only open after the configured clock-out time."*
- Jika siswa sudah masuk **dan** pulang hari itu, muncul keterangan
  *"Already checked-in and checked-out today."* dan tidak ada tombol lagi.
- Layar pengenalan **tertutup otomatis dalam 10 detik** (atau ketuk di mana saja
  untuk menutup) bila siswa tidak menekan tombol.

**Jika wajah tidak dikenali**, muncul pesan *"Face not recognized — contact the
admin."* Kemungkinan penyebab: siswa belum didaftarkan, kelasnya tidak aktif di
terminal ini, atau kualitas foto/pencahayaan kurang. Hubungi admin.

---

## 5. Masuk ke menu admin (gerbang PIN)

1. Di layar kamera, tekan tombol **☰ (burger)** di pojok kanan atas.
2. Muncul layar **"Admin access required"**.
3. Masukkan **PIN 6 angka** Anda, lalu tekan **Unlock**.
   - Jika salah, muncul *"Wrong PIN. Try again."*
   - Tekan **Cancel** untuk kembali ke kamera.

---

## 6. Menu admin

Setelah PIN benar, terbuka beranda admin yang menampilkan tanggal hari ini,
sapaan **"Hello, [username]"**, dan **3 menu utama**:

| Menu | Isi |
| --- | --- |
| **Students** | Daftar & pendaftaran wajah siswa. Menampilkan jumlah siswa terdaftar. |
| **Reports** | Laporan absensi & ekspor PDF. Menampilkan bulan & tahun berjalan. |
| **Settings** | Pengaturan kelas, jadwal, dan perangkat. |

Di bagian bawah terdapat dua tombol dan nomor versi aplikasi:
- **Contact developer** — membuka WhatsApp pengembang.
- **Backup Database** — membuat & membagikan cadangan data.

Tekan tombol **✕ (tutup)** di pojok kanan atas untuk kembali ke layar kamera.

---

## 7. Mengelola siswa (pendaftaran wajah)

Buka **Menu admin → Students**.

**Di daftar siswa Anda dapat:**
- **Memfilter** berdasarkan kelas melalui ikon corong (default **All classes**).
- **Mencari** berdasarkan nama atau NIS pada kolom pencarian.
- Melihat siswa berstatus **DRAFT** (ditandai redup) — yaitu siswa yang
  disimpan tanpa wajah terdaftar.
- **Menghapus** siswa lewat ikon tempat sampah (ini juga menghapus seluruh
  catatan absensinya — lakukan dengan hati-hati).
- Menekan **+ Enroll face** untuk menambah siswa baru.

### Mendaftarkan / mengedit siswa

1. **Foto** — tekan kolom foto untuk mengambil dari **galeri atau kamera**.
   Gunakan **pas-foto menghadap depan, pencahayaan baik, tanpa masker, tanpa
   kacamata**.
2. Tekan **Process embed** untuk membuat "sidik wajah" digital. Hasilnya:
   - **Embedding ready** → wajah berhasil dibaca, atau
   - **No face detected — try another photo** → ganti foto yang lebih jelas.
3. Isi data wajib: **FULL NAME**, **NIS / STUDENT ID**, dan **CLASS** (kelas).
4. Pilih cara menyimpan:
   - **Save draft** — menyimpan tanpa wajah/embedding (siswa belum bisa absen,
     bertanda DRAFT). Berguna untuk mengisi data dahulu.
   - **Submit** — menyimpan lengkap; **wajib** sudah ada embedding yang berhasil.

> 💡 Agar bisa dipakai absen, siswa harus: (1) punya embedding yang berhasil,
> dan (2) berada di kelas yang **aktif** di terminal (lihat Pengaturan).

---

## 8. Pengaturan (kelas, jadwal, perangkat)

Buka **Menu admin → Settings**. Terdapat tiga bagian.

### 01 · CLASSES (Kelas)
Menentukan **kelas mana yang dikenali oleh terminal ini**.
- Setiap kelas tampil sebagai kartu. **Ketuk kartu** untuk mengaktifkan /
  menonaktifkan kelas pada terminal ini.
- **Add class** — menambah kelas baru (mis. `XII · AKL · B`, `X · Animation`).
- **Edit / Delete** tersedia di dalam kartu. Kelas yang **masih dipakai siswa
  tidak bisa dihapus**.

> Hanya siswa dari kelas yang **aktif** yang akan dikenali saat memindai wajah.

### 02 · SCHEDULE (Jadwal)
Mengatur jam sekolah yang menentukan status absensi:

| Pengaturan | Arti | Default |
| --- | --- | --- |
| **CLOCK-IN** | Jam masuk. Absen sampai 1 jam setelah jam ini = **hadir**, lewat dari itu = **terlambat**. | `07:00` |
| **CLOCK-OUT** | Jam paling awal tombol absen pulang bisa ditekan. | `15:30` |
| **LAST CHECK-OUT** | Batas akhir harian. Setelah jam ini, sistem merapikan absensi otomatis (lihat [aturan status](#10-aturan-status-absensi)). | `18:00` |

### 03 · THIS TERMINAL (Perangkat ini)
- **Device name** — nama terminal (teks bebas, terisi otomatis dari nama
  perangkat).
- **Sound on scan** — suara saat memindai: **Soft chime · Beep · Success ding ·
  Silent**.

---

## 9. Laporan absensi & ekspor PDF

Buka **Menu admin → Reports**.

**Filter** (di bagian atas): **kelas · tahun · bulan · hari**. Setiap tingkat
bisa diatur ke **"Any"** untuk memperluas cakupan (mis. hanya per bulan, per
tahun, atau sepanjang waktu).

**Yang ditampilkan:**
- **Rekap**: jumlah **PRESENT** (hadir), **LATE** (terlambat), **ABSENT**
  (absen), beserta persentasenya.
- **Tabel per siswa** dengan kolom **P** (hadir), **L** (terlambat),
  **A** (absen), dan **%** kehadiran.
- **Ketuk satu baris siswa** untuk melihat rincian absensi hari demi hari.

**Ekspor PDF:**
- Tekan tombol **PDF** pada bilah **EXPORT** di bagian bawah.
- PDF dibuat sesuai filter yang aktif, berisi:
  - **halaman ringkasan** (rekap + tabel per siswa), lalu
  - **satu halaman per siswa** berisi tanggal, jam masuk, jam pulang, dan status
    setiap hari.
- PDF dapat langsung dibagikan / dicetak.

> Hanya baris yang **lengkap** (sudah ada jam pulang) yang dihitung pada rekap.
> Jam pulang yang diisi otomatis oleh sistem ditandai **⚠️** (tanda bintang `*`
> di PDF).

---

## 10. Aturan status absensi

Aplikasi mengenal tiga status: **HADIR (present)**, **TERLAMBAT (late)**, dan
**ABSEN (absent)**.

| Kejadian | Hasil |
| --- | --- |
| Absen masuk **sebelum** `CLOCK-IN + 1 jam` (mis. sebelum 08:00 bila clock-in 07:00) | Tercatat **HADIR** |
| Absen masuk **setelah** `CLOCK-IN + 1 jam` | Tercatat **TERLAMBAT** |
| Sudah absen masuk | Tombol Clock-in nonaktif |
| Absen pulang **pada / setelah** jam `CLOCK-OUT` | Tombol Clock-out aktif |
| **Tidak absen masuk sama sekali** pada hari sekolah | Tercatat **ABSEN** secara otomatis (muncul di kolom A) |
| **Sudah masuk tetapi lupa absen pulang** sampai `LAST CHECK-OUT` | Jam pulang **diisi otomatis** dengan jam `LAST CHECK-OUT`; status tetap **HADIR / TERLAMBAT**, ditandai **⚠️** |

**Hal penting yang perlu dipahami:**
- **"ABSEN" berarti siswa tidak datang** (tidak ada catatan masuk sama sekali) —
  **bukan** karena lupa absen pulang.
- **Lupa absen pulang bukan absen.** Sistem otomatis mengisi jam pulang dengan
  jam `LAST CHECK-OUT` dan menandainya ⚠️ (artinya: "siswa datang, tetapi
  terminal menutup harinya secara otomatis").
- **Sabtu & Minggu dianggap libur** — tidak dibuat catatan absen.
- Perapian otomatis (auto-finalize) berjalan saat aplikasi dibuka dan setiap
  kali halaman **Reports** dimuat. Jadi laporan akan akurat selama aplikasi
  sesekali dibuka setelah jam `LAST CHECK-OUT`.

---

## 11. Cadangan data (backup) & hubungi pengembang

Karena seluruh data tersimpan **di dalam perangkat**, lakukan cadangan secara
berkala agar data aman bila perangkat rusak/hilang.

**Backup Database** (di footer Menu admin):
1. Tekan **Backup Database** (tombol menampilkan loading sebentar).
2. Aplikasi membuat berkas cadangan `.sql` lalu membuka menu **Bagikan**.
3. Kirim berkas tersebut ke tempat aman (mis. Google Drive, email, atau WhatsApp
   pengembang). Berkas ini dapat dipulihkan kembali ke aplikasi.

**Contact developer** (di footer Menu admin):
- Membuka chat WhatsApp pengembang di **+62 851-7822-6071** dengan pesan bantuan
  yang sudah terisi. Pakai ini bila aplikasi bermasalah atau Anda butuh
  pemulihan data.

---

## 12. Pertanyaan yang sering muncul (FAQ)

**Wajah siswa tidak dikenali. Kenapa?**
Pastikan siswa sudah didaftarkan dengan embedding **ready**, kelasnya **aktif**
di Settings → Classes, serta pencahayaan cukup dan wajah tidak tertutup
masker/kacamata. Bila perlu, daftarkan ulang foto yang lebih jelas.

**Siswa lupa absen pulang. Apakah jadi absen?**
Tidak. Statusnya tetap **HADIR / TERLAMBAT**, dan jam pulang diisi otomatis pada
jam `LAST CHECK-OUT`, ditandai ⚠️. Lihat [aturan status](#10-aturan-status-absensi).

**Tombol Clock-out tidak bisa ditekan.**
Tombol pulang baru aktif setelah melewati jam `CLOCK-OUT` (default 15:30).
Ubah di Settings → Schedule bila perlu.

**Saya lupa PIN admin.**
Tidak ada fitur "lupa PIN". Solusi terakhir: hapus data aplikasi (atau
uninstall lalu pasang ulang), kemudian daftar admin lagi — **namun semua data
akan hilang**, jadi pastikan sudah ada **backup**. Hubungi pengembang lebih
dahulu bila ragu.

**Bagaimana mengganti data contoh (dummy) dengan data sekolah?**
Hapus siswa & kelas contoh melalui menu Students dan Settings, lalu daftarkan
data sekolah yang sebenarnya.

**Apakah butuh internet?**
Tidak untuk absensi sehari-hari. Internet hanya diperlukan saat membuka WhatsApp
(Contact developer) atau saat membagikan berkas backup.

**Bagaimana mengubah jam sekolah / kelas?**
Melalui **Menu admin → Settings**. Lihat [bagian Pengaturan](#8-pengaturan-kelas-jadwal-perangkat).

---

*Dokumen ini dibuat berdasarkan aplikasi versi **v2.0.0**. Tampilan tombol/teks
tertentu di aplikasi masih berbahasa Inggris (mis. "Start scan", "Clock-in",
"Submit") dan disebutkan apa adanya pada panduan ini agar mudah dicocokkan di
layar.*

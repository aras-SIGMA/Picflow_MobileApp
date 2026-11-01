# Notulen Sprint 7: End-to-End Polish, Performance Audit & Release Hardening

- **Target Branch**: `feature/e2e-polish`
- **Tujuan**: Melakukan audit performa menyeluruh, audit keamanan jaringan (*network security config & cleartext hardening*), verifikasi penanganan kegagalan jaringan dan USB reverse diagnostic tips, pengujian perangkat fisik Android, serta persiapan rilis MVP v1.0 PicFlow Mobile.
- **Status**: Selesai diimplementasikan (Pending review & commit dari pengguna).

---

## 1. Rincian Perubahan & Peningkatan

### 1.1 Network Security & Cleartext Hardening
- **`android/app/src/main/res/xml/network_security_config.xml`**:
  - Konfigurasi XML resmi untuk keamanan jaringan Android.
  - `<base-config cleartextTrafficPermitted="false">`: Mewajibkan enkripsi HTTPS pada seluruh komunikasi domain eksternal produksi (Cloudinary CDN, Supabase DB/Auth).
  - `<domain-config cleartextTrafficPermitted="true">`: Mengisolasi izin HTTP cleartext hanya untuk domain lokal pengujian USB (`localhost`, `127.0.0.1`, `10.0.2.2`).
  - `<debug-overrides>`: Mendukung sertifikat debug saat aplikasi berjalan pada mode pengembangan.
- **`android/app/src/main/AndroidManifest.xml`**:
  - Menghapus flag global `android:usesCleartextTraffic="true"`.
  - Menetapkan atribut `android:networkSecurityConfig="@xml/network_security_config"` untuk menegakkan kebijakan keamanan jaringan di level sistem operasi Android.
- **`android/app/src/debug/AndroidManifest.xml`**:
  - Menetapkan `android:usesCleartextTraffic="true"` terisolasi khusus varian build `debug`, menjaga build `release` tetap terlindungi.

### 1.2 Penanganan Kegagalan Jaringan & Diagnostik USB
- **`NetworkConnectionException` (`lib/services/api_exception.dart`)**:
  - Menghasilkan pesan diagnostik informatif (*"Tidak dapat terhubung ke server backend PicFlow. Pastikan server backend berjalan di port 8000 dan jalankan 'adb reverse tcp:8000 tcp:8000' pada terminal jika menggunakan HP fisik via USB"*).
- **Komponen Error Recovery di Antarmuka**:
  - `FeedScreen`: Tampilan error dengan tombol coba lagi (*Retry*) saat koneksi terputus.
  - `ProfileScreen`: Banner error interaktif saat sinkronisasi portofolio gagal.
  - `PhotoDetailScreen`: Layar status error dengan instruksi pemulihan.
  - `UploadPhotoScreen`: Error banner yang dapat ditutup (*dismissable*) dengan deskripsi galat yang jelas.

### 1.3 Audit Performa & Manajemen Memori Bitmap
- **Optimalisasi Cache Bitmap Memori (`CachedNetworkImage`)**:
  - Kartu Feed (`PhotoCard`): Dibatasi `memCacheWidth: 1080` untuk mencegah rendering bitmap resolusi raksasa yang membebani GPU.
  - Grid Portofolio Profil (`ProfileScreen`): Dibatasi `memCacheWidth: 600` sesuai lebar kolom grid 2 kolom.
  - Panggung High-Res Detail (`PhotoDetailScreen`): Dibatasi `memCacheWidth: 2048` untuk mempertahankan ketajaman saat zoom hingga 4x tanpa kebocoran memori (*OOM prevention*).
- **Scrolling 60 FPS**:
  - Memanfaatkan `ListView.separated` dan `SliverGrid.builder` dengan rendering lazy pada viewport aktif.

### 1.4 Pengujian Otomatis (`test/widget_test.dart`)
- Menambahkan pengujian khusus untuk memastikan `NetworkConnectionException` memuat instruksi perintah `adb reverse tcp:8000 tcp:8000`.
- Total 12 pengujian unit dan widget mencakup seluruh alur MVP v1.0.

---

## 2. Hasil Verifikasi Kualitas
- **`flutter analyze`**: 0 issue / No issues found.
- **`flutter test`**: 12/12 unit & widget tests passed.
- **Status Git**: Seluruh berkas berstatus *unstaged* menunggu review pengguna sebelum commit bertahap.

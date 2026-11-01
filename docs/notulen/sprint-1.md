# Notulen Sprint 1: Core Setup, Theme & Services Layer

- **Target Branch**: `feature/core-setup-theme`
- **Tujuan**: Membangun fondasi arsitektur, instalasi dependensi, konfigurasi native Android, implementasi sistem desain visual Warm Editorial, dan lapisan jaringan HTTP ringan.
- **Status**: Selesai & Terverifikasi (Dimerge ke `develop`).

---

## 1. Rincian Perubahan

### 1.1 Dependensi Proyek (`pubspec.yaml`)
Menambahkan pustaka utama:
- `flutter_riverpod: ^2.6.1` — State management terstandarisasi.
- `http: ^1.2.2` — Klien HTTP performan dan ringan.
- `flutter_secure_storage: ^9.2.2` — Penyimpanan token JWT terenkripsi via Android Keystore.
- `cached_network_image: ^3.4.1` — Caching gambar dan efisiensi memori.
- `image_picker: ^1.1.2` — Pengambil foto kamera dan galeri HP.
- `google_fonts: ^6.2.1` — Tipografi Plus Jakarta Sans dan JetBrains Mono.
- `intl: ^0.19.0` — Format tanggal dan metadata pemotretan EXIF.

### 1.2 Konfigurasi Native Android (`android/app/src/main/AndroidManifest.xml`)
- Izin akses ditambahkan:
  - `android.permission.INTERNET`
  - `android.permission.CAMERA`
  - `android.permission.READ_MEDIA_IMAGES`
  - `android.permission.READ_EXTERNAL_STORAGE` (`maxSdkVersion="32"`)
- Menambahkan `android:usesCleartextTraffic="true"` pada tag `<application>` untuk mengizinkan komunikasi HTTP ke backend lokal laptop (`http://localhost:8000`).

### 1.3 Token Desain & Tema (`lib/utils/`)
- **`app_colors.dart`**: Implementasi palet *Modern Fluid Editorial* dari `docs/design.md`:
  - Kanvas Warm Cream (`#FFFDF6`)
  - Kartu Elevated (`#F8F3E8`)
  - Border Halus (`#E8DEC9`)
  - Teks Stone (`#1C1917`, `#57534E`, `#8F887C`)
  - Royal Blue PicFlow (`#2563EB`)
  - Spektrum sRGB (`#EF4444`, `#10B981`, `#3B82F6`)
- **`app_typography.dart`**: Skala tipografi (Display 28px, Heading 22px, Subheading 18px, Body 14px, Monospace EXIF 11px).
- **`app_theme.dart`**: Konfigurasi `ThemeData` Material 3 (Scaffold, CardThemeData, ElevatedButton, OutlinedButton, InputDecoration, Divider).
- **`constants.dart`**: Endpoint REST API (`/auth`, `/categories`, `/photos`, `/users`) dan helper `resolveImageUrl()` untuk konversi URL gambar statis.

### 1.4 Lapisan Layanan & Storage (`lib/services/`)
- **`storage_service.dart`**: Wrapper `FlutterSecureStorage` dengan opsi `encryptedSharedPreferences: true` untuk menyimpan, membaca, dan menghapus JWT token.
- **`api_exception.dart`**: Model exception standar dengan deteksi otomatis kegagalan jaringan yang memunculkan panduan eksekusi `adb reverse tcp:8000 tcp:8000`.
- **`api_service.dart`**: Klien HTTP mandiri dengan penyisipan otomatis header `Authorization: Bearer <token>`, `Content-Type: application/json`, batas timeout request, dan dukungan multipart upload.

---

## 2. Keputusan Arsitektur
- **Struktur Folder**: Mengadopsi arsitektur **Layer-First (Opsi A)**: `models`, `screens`, `widgets`, `providers`, `services`, `utils`, dan `main.dart` agar lebih mudah dipelajari, datar, dan modular.
- Dokumen pendukung (`docs/PRD.md` dan `docs/SCHEDULE.md`) telah disinkronkan dengan arsitektur Opsi A.

---

## 3. Hasil Verifikasi Kualitas
- **`flutter analyze`**: 0 issues found.
- **`flutter test`**: All tests passed.
- **Commit**: `4f7d8f9 feat(core): setup dependencies, design tokens, theme, and http client services`.

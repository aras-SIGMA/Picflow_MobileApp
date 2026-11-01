<div align="center">

# PicFlow Mobile

### *The High-Resolution Photography Showcase & Optical Curation Platform*

[![Flutter Version](https://img.shields.io/badge/Flutter-3.13+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.1+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Flutter%20Riverpod%202.6-blueviolet)](https://riverpod.dev)
[![Backend](https://img.shields.io/badge/Backend-Express%20%7C%20Supabase%20%7C%20Cloudinary-339933?logo=node.js&logoColor=white)](https://nodejs.org)
[![Security](https://img.shields.io/badge/Security-Android%20Network%20Hardened-success)](https://developer.android.com/training/articles/security-config)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<br/>

**PicFlow Mobile** adalah aplikasi Android native berbasis Flutter yang dirancang khusus untuk fotografer dan kurator visual. Mengusung konsep desain **Warm Editorial Canvas** dengan aksen optik sRGB terkalibrasi, PicFlow memungkinkan fotografer mempublikasikan karya resolusi tinggi, mempertahankan spesifikasi optik perangkat (*EXIF hardware extraction*), dan mengelola portofolio profesional secara mulus.

</div>

---

## Fitur Utama (MVP v1.0)

| Fitur | Deskripsi | Layar / Modul |
|---|---|---|
| **Autentikasi & Keamanan Sesi** | Pendaftaran dan masuk akun fotografer dengan persistensi token JWT terenkripsi pada **Android Keystore** (`flutter_secure_storage`). Dilengkapi gerbang autentikasi dinamis (*AuthGate*). | `LoginScreen`, `RegisterScreen` |
| **Eksplorasi Feed & Filter Genre** | Kurasi linimasa foto dinamis dengan tab *Explore* & *Following*, filter horizontal genre fotografi (Street, Landscape, Portrait, dll.), apresiasi instan (*optimistic like*), dan pull-to-refresh. | `FeedScreen`, `PhotoCard` |
| **Panggung High-Res & Panel EXIF** | Penampil karya sinematik dengan gestur interaktif *pinch-to-zoom* (1x hingga 4x), geser (*pan*), reset zoom, serta panel teknis optik kamera (Camera Body, Lens, Aperture, Shutter, ISO, Focal Length) dengan fallback cerdas `N/A`. | `PhotoDetailScreen`, `ExifMetadataPanel` |
| **Studio Kurasi & Unggah Foto** | Pemilihan foto dari Kamera bawaan atau Galeri (`image_picker`) hingga batas resolusi 3840 px, input judul, kategori, serta narasi foto. Pengunggahan multipart otomatis memicu ekstraksi EXIF server-side. | `UploadPhotoScreen` |
| **Profil Kreator & Portofolio CRUD** | Portofolio 2 kolom dengan counter agregat total karya & total apresiasi likes, modal edit metadata judul & deskripsi (`PUT`), dialog hapus foto destruktif (`DELETE`), dan teardown sesi (Logout aman). | `ProfileScreen`, `EditPhotoSheet` |
| **Network Security Hardening** | Kebijakan `network_security_config.xml` mewajibkan HTTPS untuk seluruh traffic luar (Cloudinary & Supabase) dan mengisolasi HTTP cleartext khusus untuk pengujian lokal via USB reverse tunnel. | Android Manifest & Security XML |

---

## Filosofi Desain & Token Desain

PicFlow Mobile mengacu pada filosofi **Warm Editorial Canvas** yang memadukan keanggunan majalah cetak fotografi klasik dengan modernitas antarmuka aplikasi seluler:

- **Canvas & Surfaces**:
  - `AppColors.canvas`: `#FFFDF6` (Cream Canvas Hangat)
  - `AppColors.surfaceElevated`: `#F8F3E8` (Kartu & Panel)
  - `AppColors.surfaceSubtle`: `#F5EFE6` (Input Background)
  - `AppColors.surfaceBorder`: `#E8DEC9` (Border Kontur Halus)
- **Tipografi**:
  - **Display, Heading & Body**: *Plus Jakarta Sans* (Elegan, proporsional, dan nyaman dibaca).
  - **Data Teknis Optik & Badge**: *JetBrains Mono* (Presisi numerik untuk parameter bukaan lensa, kecepatan rana, dan ISO).
- **Gamut Accents**:
  - Biru Editorial (`#2563EB`), Hijau sRGB Terkalibrasi (`#10B981`), Amber Peringatan (`#F59E0B`), dan Merah Destruktif (`#EF4444`).

---

## Arsitektur Proyek (Layer-First)

Aplikasi dibangun menggunakan struktur modular **Layer-First** berbasis **Flutter Riverpod**:

```text
lib/
├── models/                     # Entitas data model & deserializer JSON
│   ├── category_model.dart     # Model genre fotografi
│   ├── photo_model.dart        # Model karya foto, EXIF optik, & kepemilikan
│   └── user_model.dart         # Model profil fotografer & session
├── providers/                  # State management berbasis Riverpod
│   ├── auth_provider.dart      # Session lifecycle, Keystore storage, & status login
│   ├── categories_provider.dart# FutureProvider genre fotografi
│   ├── feed_provider.dart      # Linimasa feed, tab filter, & optimistic likes
│   ├── photo_detail_provider.dart # Family provider detail foto & sinkronisasi
│   ├── profile_provider.dart   # Portofolio personal, update metadata, & delete foto
│   └── upload_provider.dart    # State studio kurasi & transmisi multipart
├── screens/                    # Halaman antarmuka pengguna
│   ├── auth/                   # LoginScreen & RegisterScreen
│   ├── feed/                   # FeedScreen & CategoryPillList
│   ├── main_navigation_shell.dart # Shell navigasi 3-tab utama
│   ├── photo_detail/           # PhotoDetailScreen (InteractiveViewer Stage)
│   ├── profile/                # ProfileScreen (2-Column Portfolio Grid)
│   └── upload/                 # UploadPhotoScreen (Studio Kurasi)
├── services/                   # Network abstraction & native storage
│   ├── api_exception.dart      # Model exception & USB tunnel diagnostic tips
│   ├── api_service.dart        # Klien HTTP kustom (GET, POST, PUT, DELETE, Multipart)
│   ├── auth_service.dart       # Integrasi endpoint /api/auth
│   ├── photo_service.dart      # Integrasi endpoint /api/photos & /api/categories
│   └── storage_service.dart    # Pembungkus FlutterSecureStorage
├── utils/                      # Design system tokens & konstanta
│   ├── app_colors.dart         # Palet warna editorial & gamut sRGB
│   ├── app_theme.dart          # Tema global Material 3
│   ├── app_typography.dart     # Skala tipografi Plus Jakarta Sans & JetBrains Mono
│   └── constants.dart          # Endpoint API & resolver URL gambar
└── widgets/                    # Komponen antarmuka modular & reusable
    ├── custom_button.dart      # Tombol aksi primer, sekunder, & outline
    ├── custom_text_field.dart  # Form input berstandar editorial
    ├── edit_photo_sheet.dart   # Modal pembaruan judul, genre, & narasi karya
    ├── exif_metadata_panel.dart# Container spesifikasi teknis kamera EXIF
    └── photo_card.dart         # Kartu karya feed dengan indikator optik ringkas
```

---

## Kebutuhan Sistem & Konfigurasi Backend

Aplikasi PicFlow Mobile berkomunikasi dengan backend PicFlow Express:

1. **Backend Repository**:
   - Backend berjalan di `http://localhost:8000`.
   - Pastikan server backend Express telah berjalan:
     ```bash
     cd "C:\Personal Project\picflow\backend"
     npm run dev
     ```
2. **Koneksi HP Android Fisik via USB**:
   - Hubungkan HP Android ke PC dengan mode **USB Debugging** aktif.
   - Buat jembatan port forwarding agar HP dapat mengakses server lokal:
     ```bash
     adb reverse tcp:8000 tcp:8000
     ```
   - Catatan: Jika terjadi kendala jaringan, aplikasi otomatis menampilkan panduan diagnostik untuk memastikan port bridge aktif.

---

## Panduan Memulai

### 1. Kloning Repositori
```bash
git clone https://github.com/aras-SIGMA/Picflow_MobileApp.git
cd Picflow_MobileApp
```

### 2. Pindah ke Branch `develop`
```bash
git checkout develop
```

### 3. Pasang Dependensi
```bash
flutter pub get
```

### 4. Jalankan Analisis Kode & Pengujian
```bash
flutter analyze
flutter test
```

### 5. Jalankan Aplikasi pada HP Fisik / Emulator
```bash
# Pastikan port bridge telah aktif untuk HP fisik
adb reverse tcp:8000 tcp:8000

# Jalankan aplikasi
flutter run
```

---

## Pengujian & Jaminan Kualitas

Aplikasi dilengkapi suite pengujian otomatis komprehensif pada berkas `test/widget_test.dart`:

- **Auth Gate Test**: Verifikasi routing otomatis ke layar Login saat sesi kosong.
- **Navigation Shell Test**: Pengujian keberadaan ketiga tab navigasi (Feed, Upload, Profile).
- **Feed Card & Optical Chips**: Verifikasi rendering thumbnail, nama kreator, dan badge optik bukaan lensa.
- **EXIF Metadata Panel**: Pengujian ekstraksi lengkap Make, Model, Lens, Aperture, Shutter, ISO, dan penanganan fallback `N/A`.
- **Interactive Viewer Stage**: Verifikasi hero viewer dan instruksi gestur zoom hingga 4x.
- **Studio Kurasi & Modal Picker**: Pengujian form judul, genre dropdown, dan sheet pemilihan Kamera vs Galeri.
- **Robust Deserialization**: Validasi parsing tipe data UUID Supabase dan ISO berformat numerik `int`.
- **USB Diagnostic Exception**: Validasi pesan diagnostik `adb reverse tcp:8000 tcp:8000` pada kegagalan jaringan.
- **Profile & Portfolio Grid**: Verifikasi statistik akumulasi karya & likes, opsi edit metadata, dan dialog hapus permanen.

---

## Roadmap Pengembangan (Sprint Milestones)

- [x] **Sprint 1: Core Setup, Design Tokens & Network Layer** (`feature/core-setup-theme`)
- [x] **Sprint 2: Creator Authentication & Session Persistence** (`feature/auth`)
- [x] **Sprint 3: Main Navigation Shell & Feed Discovery** (`feature/feed-discovery`)
- [x] **Sprint 4: High-Res Photo Detail & EXIF Technical Panel** (`feature/photo-detail-exif`)
- [x] **Sprint 5: Photo Upload & Curation Studio** (`feature/photo-upload`)
- [x] **Sprint 6: Creator Profile & Personal Portfolio CRUD** (`feature/user-profile-crud`)
- [x] **Sprint 7: End-to-End Polish, Performance Audit & Hardening** (`feature/e2e-polish`)

---

## Lisensi

Proyek ini dirilis di bawah lisensi [MIT License](LICENSE). Seluruh kode bebas dipelajari, dikembangkan, dan dimodifikasi sesuai ketentuan lisensi terbuka.

<div align="center">
  <sub>Built for passionate photographers by the PicFlow Engineering Team.</sub>
</div>

# Product Requirements Document (PRD) — PicFlow Mobile (Android)

> **Document Version**: 1.0.0  
> **Target Platform**: Android (Flutter Native)  
> **Status**: Approved for MVP Implementation  
> **Author**: PicFlow Mobile Engineering  
> **Base Workspace**: `Picflow_Mobile`  

---

## 1. Executive Summary

### 1.1 Problem Statement
Fotografer mobile kesulitan menemukan platform showcase karya yang mempertahankan resolusi gambar tinggi, menampilkan metadata optik kamera (EXIF) secara transparan, serta memungkinkan kurasi portofolio langsung dari perangkat genggam tanpa penurunan kualitas visual atau manipulasi kompresi agresif.

### 1.2 Proposed Solution
PicFlow Mobile menghadirkan aplikasi native Android berbasis Flutter dengan tema *Editorial Warm Canvas* yang terhubung langsung ke backend PicFlow Express REST API via jaringan lokal dan kabel USB debugging (`adb reverse`). Aplikasi berfokus pada siklus hidup CRUD karya fotografi, ekstraksi otomatis parameter optik kamera, dan manajemen profil kreator.

### 1.3 Success Criteria (KPIs)
- **App Launch Time**: Cold start hingga frame pertama Feed $\le 1.5$ detik pada perangkat Android kelas menengah (*Snapdragon 680 / Helio G99* atau setara).
- **Feed Scroll Performance**: Menjaga 60 fps stabil dengan tingkat *jank* (dropped frames) $< 2\%$ saat rendering daftar foto bermedia resolusi tinggi.
- **Upload Success Rate**: $\ge 99\%$ keberhasilan upload foto multipart beserta ekstraksi parameter optik EXIF oleh backend.
- **Network Response Latency**: Response parsing $\le 200$ ms melalui tunneling USB `adb reverse tcp:8000 tcp:8000`.

---

## 2. User Experience & Functionality

### 2.1 User Personas
1. **Fotografer Lapangan (Mobile Creator)**: Mengambil gambar dengan kamera HP atau mentransfer foto dari kamera profesional (Sony, Canon, Fujifilm, Leica), lalu mengunggah ke PicFlow lengkap dengan genre dan cerita di balik karya.
2. **Kurator & Penikmat Fotografi**: Menjelajahi karya-karya terbaik komunitas, menyaring feed berdasarkan genre/kategori, dan mempelajari pengaturan teknis kamera (aperture, shutter speed, ISO, lensa) dari setiap foto.

### 2.2 User Stories & Acceptance Criteria (Scope MVP v1.0)

#### US-01: Autentikasi Kreator & Manajemen Sesi
- **Story**: *Sebagai fotografer, saya ingin mendaftar dan masuk ke akun PicFlow agar dapat mengelola portofolio karya saya secara aman.*
- **Acceptance Criteria**:
  - Form Register memvalidasi email, username, dan kata sandi ($\ge 6$ karakter).
  - Form Login mengirim kredensial ke `POST /api/auth/login` dan menerima token JWT.
  - Token JWT disimpan secara terenkripsi menggunakan `flutter_secure_storage`.
  - Sesi otomatis diverifikasi saat pembukaan aplikasi via `GET /api/auth/me`. Jika token tidak valid, aplikasi mengarahkan ke layar Login.
  - Aksi Logout menghapus token dari storage dan mereset state autentikasi ke status unauthenticated.

#### US-02: Feed & Eksplorasi Karya (Read)
- **Story**: *Sebagai kurator visual, saya ingin menelusuri feed foto dengan filter genre agar dapat menemukan inspirasi visual yang relevan.*
- **Acceptance Criteria**:
  - Menampilkan daftar foto terbaru dari endpoint `GET /api/photos?feed=recent`.
  - Filter horizontal pill kategori diambil dinamis dari `GET /api/categories`.
  - Mendukung gestur *pull-to-refresh* dan indikator loading yang mulus (*skeleton loading* / spinner bernuansa editorial).
  - Kartu foto menampilkan: avatar & nama kreator, gambar yang di-cache (`cached_network_image`), judul, serta badge metadata ringkas (kamera & aperture).

#### US-03: Detail Foto & Metadata Optik EXIF (Read)
- **Story**: *Sebagai fotografer, saya ingin membuka detail karya dengan data EXIF lengkap agar dapat mempelajari teknik pemotretan foto tersebut.*
- **Acceptance Criteria**:
  - Hero image dengan dukungan pinch-to-zoom atau fullscreen view.
  - Panel metadata EXIF menampilkan:
    - Camera Make & Model (e.g. *SONY ILCE-7M4*)
    - Lens Info (e.g. *FE 24-70mm F2.8 GM II*)
    - Focal Length (e.g. *35mm*)
    - Aperture (e.g. *f/2.8*)
    - Shutter Speed (e.g. *1/500s*)
    - ISO (e.g. *ISO 100*)
    - Timestamp pemotretan (*taken_at*).
  - Jika salah satu nilai EXIF tidak tersedia pada gambar, field menampilkan badge `N/A` tanpa merusak layout.

#### US-04: Unggah & Kurasi Karya Foto (Create)
- **Story**: *Sebagai kreator, saya ingin mengunggah foto baru dari galeri atau kamera HP langsung ke PicFlow.*
- **Acceptance Criteria**:
  - Pemilihan media menggunakan `image_picker` (sumber Kamera atau Galeri).
  - Form kurasi memuat: Judul foto (wajib), Kategori foto (dropdown wajib), Deskripsi/Cerita (opsional).
  - Mengirim payload multipart form-data `image`, `title`, `id_category`, dan `description` ke `POST /api/photos`.
  - Menampilkan indikator progres unggahan.
  - Setelah berhasil, mengembalikan pengguna ke feed/profil dan memperbarui daftar karya secara instan.

#### US-05: Pengelolaan Karya Pribadi (Update & Delete)
- **Story**: *Sebagai pemilik karya, saya ingin mengedit metadata atau menghapus foto yang telah diunggah.*
- **Acceptance Criteria**:
  - Tombol aksi Edit dan Delete hanya tampil untuk karya milik pengguna yang sedang terautentikasi (`photo.id_user == currentUser.id`).
  - Hapus foto meminta konfirmasi melalui dialog modal sebelum mengeksekusi `DELETE /api/photos/:id`.
  - Edit foto memungkinkan pembaruan judul dan deskripsi melalui `PUT /api/photos/:id`.

#### US-06: Profil & Portofolio Kreator (Read & Profile Management)
- **Story**: *Sebagai fotografer, saya ingin melihat halaman profil portofolio yang menampilkan seluruh karya yang pernah saya unggah.*
- **Acceptance Criteria**:
  - Header profil memuat avatar pengguna, nama pengguna, bio, dan total karya.
  - Portofolio foto disusun dalam tata letak grid 2-kolom yang rapi.
  - Mengetuk item grid langsung membuka halaman Detail Foto.

### 2.3 Non-Goals (Scope Protection untuk Rilis Berikutnya)
- **v1.1**: Form submit dan rating interaktif 4-Pilar Kritik (*Composition, Lighting, Color, Concept*).
- **v1.1**: Realtime SSE event listener stream (`/api/realtime/stream`).
- **v1.1**: Tab analitik dashboard mendalam (grafik views, likes, ulasan berkala).
- **v2.0**: Penyimpanan offline cache berbasis database lokal (Hive / Isar / SQLite).
- **v2.0**: Integrasi Push Notification (Firebase Cloud Messaging).
- **v2.0**: In-app photo editor (crop, rotate, filter tone sRGB sebelum upload).

---

## 3. AI System Requirements
*Tidak ada dependensi sistem AI pada fase MVP v1.0 (N/A).*

---

## 4. Technical Specifications

### 4.1 Architecture Overview
Aplikasi menggunakan arsitektur **Layer-First (Sederhana & Mudah Dikelola)** dengan **Flutter Riverpod** sebagai state management:

```
lib/
├── models/          # user_model.dart, photo_model.dart, category_model.dart
├── screens/         # login_screen.dart, feed_screen.dart, detail_screen.dart, upload_screen.dart, profile_screen.dart
├── widgets/         # photo_card.dart, exif_panel.dart, custom_button.dart, custom_text_field.dart
├── providers/       # auth_provider.dart, feed_provider.dart, photo_detail_provider.dart, upload_provider.dart
├── services/        # api_service.dart (http wrapper), api_exception.dart, storage_service.dart (secure storage)
├── utils/           # app_colors.dart, app_typography.dart, app_theme.dart, constants.dart
└── main.dart
```

### 4.2 Integration Points
- **Backend Environment**: Express.js REST API (`http://localhost:8000/api`).
- **Device Port Forwarding**: `adb reverse tcp:8000 tcp:8000` via USB bridge.
- **REST Endpoints MVP**:
  | Metode | Endpoint | Fungsi | Auth |
  | --- | --- | --- | --- |
  | `POST` | `/api/auth/register` | Registrasi akun baru | Tidak |
  | `POST` | `/api/auth/login` | Login & generate JWT | Tidak |
  | `GET` | `/api/auth/me` | Validasi sesi & profil aktif | Bearer |
  | `GET` | `/api/categories` | Daftar genre fotografi | Tidak |
  | `GET` | `/api/photos` | Feed foto umum / filter kategori | Opsional |
  | `GET` | `/api/photos/:id` | Detail foto + EXIF | Opsional |
  | `POST` | `/api/photos` | Upload foto multipart form-data | Bearer |
  | `PUT` | `/api/photos/:id` | Update metadata karya | Bearer |
  | `DELETE` | `/api/photos/:id` | Hapus karya | Bearer |

### 4.3 Design System & Visual Tokens
Mengadopsi identitas visual resmi PicFlow (*Modern Fluid Editorial*):
- **Canvas / Background**: `#FFFDF6` (warm cream editorial)
- **Elevated Surface / Card**: `#F8F3E8`
- **Subtle Surface**: `#F5EFE6`
- **Border / Outline**: `#E8DEC9`
- **Typography Ink**: `#1C1917` (stone-900 sharp text)
- **Muted Text**: `#57534E` (stone-600)
- **Accent Primary**: `#2563EB` (royal blue)
- **sRGB Highlights**: Merah (`#EF4444`), Hijau (`#10B981`), Biru (`#3B82F6`)
- **Card Corners**: Rounded `16dp` dengan border halus `1dp` solid `#E8DEC9`.

### 4.4 Security & Privacy
- Kredensial JWT disimpan di Android Keystore via `flutter_secure_storage`.
- Konfigurasi `android:usesCleartextTraffic="true"` diaktifkan pada `AndroidManifest.xml` (khusus mode debug) untuk mengizinkan komunikasi HTTP lokal ke server laptop via `localhost:8000`.
- Izin Android: `CAMERA`, `READ_EXTERNAL_STORAGE` / `READ_MEDIA_IMAGES`.

---

## 5. Risks & Roadmap

### 5.1 Phased Rollout
- **Phase 1 (MVP v1.0)**: Arsitektur inti, tema visual editorial, autentikasi, feed jelajah, detail foto & panel EXIF, upload karya, manajemen portofolio (CRUD dasar).
- **Phase 2 (v1.1)**: Interaksi sosial lanjutan (toggle like dengan optimistic UI, komentar berulir), modul penilaian kritik 4-pilar komprehensif, dan dasbor analitik kreator.
- **Phase 3 (v2.0)**: Realtime listener SSE, offline sync, in-app cropping, push notifications.

### 5.2 Technical Risks & Mitigation
1. **Risiko Koneksi USB HP ke Laptop**: Port 8000 tidak terhubung jika developer lupa menjalankan `adb reverse`.  
   *Mitigasi*: Buat exception handler di `ApiService` dengan pesan human-readable: *"Gagal terhubung ke backend. Pastikan server aktif dan jalankan 'adb reverse tcp:8000 tcp:8000'"*.
2. **Risiko Memori Gambar Besar (OOM)**: Kamera HP modern menghasilkan foto 10-50MB.  
   *Mitigasi*: Manfaatkan URL transformasi Cloudinary (`thumbnail_url` dan `medium_url`) untuk feed; batasi decoding resolusi pada widget image.

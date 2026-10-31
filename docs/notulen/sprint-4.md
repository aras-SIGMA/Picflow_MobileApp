# Notulen Sprint 4: High-Res Photo Detail & EXIF Technical Panel

- **Target Branch**: `feature/photo-detail-exif`
- **Tujuan**: Mengimplementasikan penampil foto beresolusi tinggi dengan dukungan gestur zoom interaktif (*InteractiveViewer*), panel spesifikasi optik kamera EXIF komprehensif, dan sinkronisasi navigasi dari kartu feed.
- **Status**: Selesai diimplementasikan (Pending review & commit dari pengguna).

---

## 1. Rincian Perubahan

### 1.1 Pembaruan Data Model (`lib/models/photo_model.dart`)
- **Properti Baru**:
  - `isOwner`: Flag kepemilikan karya foto (`true` jika pengguna yang login adalah pengunggah foto).
  - Helper `formattedTakenAt`: Memformat timestamp ISO pemotretan asli menjadi format tanggal ramah manusia (contoh: *12 Mar 2024, 14:30*).
  - Getter `hasAnyExif`: Mendeteksi apakah karya foto memiliki metadata kamera EXIF.

### 1.2 Layanan Jaringan (`lib/services/photo_service.dart`)
- **`getPhotoDetail(photoId)`**:
  - Memanggil endpoint `GET /api/photos/:id` dengan menyertakan header token JWT.
  - Memetakan payload respons ke objek `PhotoModel` tunggal beserta atribut kepemilikan `is_owner`.

### 1.3 State Management (`lib/providers/photo_detail_provider.dart`)
- **`photoDetailProvider`**: StateNotifierProvider berbasis `family` (`.autoDispose`) dengan argumen `photoId`.
- **`PhotoDetailNotifier`**:
  - `fetchDetail()`: Memuat detail data foto dan EXIF dari API backend.
  - `toggleLike()`: Menerapkan pembaruan instan (*Optimistic UI*) di halaman detail dan menyinkronkan state like ke `feedProvider` jika foto tersebut ada di dalam daftar feed.

### 1.4 Komponen Antarmuka (`lib/widgets/exif_metadata_panel.dart`)
- **`ExifMetadataPanel`**:
  - Container spesifikasi teknis kamera berstandar editorial Warm Surface (`#F8F3E8`).
  - Parameter yang diekstrak dan ditampilkan:
    1. **Camera Body**: Merk dan model kamera (e.g., *Sony ILCE-7M4*).
    2. **Lens Model**: Model optik lensa (e.g., *FE 24-70mm F2.8 GM II*).
    3. **Aperture**: Diafragma bukaan lensa (e.g., *f/2.8*).
    4. **Shutter**: Kecepatan rana (e.g., *1/1000s*).
    5. **Sensitivity**: Sensitivitas sensor ISO (e.g., *ISO 100*).
    6. **Focal Length**: Jarak fokal lensa (e.g., *35mm*).
    7. **Resolution**: Dimensi piksel gambar asli (e.g., *4000 × 3000 px*).
    8. **Captured At**: Waktu asli pemotretan dari EXIF.
  - **Graceful Fallback**: Setiap nilai parameter yang tidak tersedia otomatis ditampilkan dengan badge `N/A` monospace tanpa merusak tata letak.

### 1.5 Layar Antarmuka (`lib/screens/photo_detail/photo_detail_screen.dart`)
- **Interactive Viewer Stage**:
  - Panggung foto hitam sinematik dengan komponen `InteractiveViewer` bawaan Flutter.
  - Mendukung gestur *pinch-to-zoom* (perbesaran 1x hingga 4x) dan geser (*pan*).
  - Tombol aksi reset zoom (`Matrix4.identity()`) dan indikator instruksi gestur zoom.
- **Creator Header & Story**:
  - Avatar lingkaran fotografer, nama pengguna, badge genre kategori, dan narasi cerita di balik karya (*story behind the shot*).
- **Social Interaction Bar**:
  - Tombol like optimistik (ikon hati merah + counter), jumlah komentar, dan badge "Your Photo" jika pengguna adalah pemilik foto.
  - Tombol aksi salin/bagikan metadata ke clipboard (`ClipboardData`).
- **Integrasi Navigasi (`lib/screens/feed/feed_screen.dart`)**:
  - Menghubungkan gestur ketuk kartu feed dan tombol "View EXIF" untuk membuka `PhotoDetailScreen` dengan transisi mulus memanfaatkan `initialPhoto`.

---

## 2. Hasil Verifikasi Kualitas
- **`flutter analyze`**: 0 issues found (No issues found).
- **`flutter test`**: All tests passed (4 unit/widget tests passed).
- **Format Dart**: Seluruh berkas telah diformat via `dart format`.
- **Status Git**: Seluruh berkas berstatus *unstaged* menunggu review pengguna.

# Notulen Sprint 3: Main Navigation Shell & Feed Discovery

- **Target Branch**: `feature/feed-discovery`
- **Tujuan**: Mengimplementasikan shell navigasi bawah (bottom navigation), layar feed jelajah foto dengan filter kategori horizontal dinamis, kartu karya fotografi dengan metadata optik EXIF, dan interaksi suka (like) optimistik.
- **Status**: Selesai diimplementasikan (Pending review & commit dari pengguna).

---

## 1. Rincian Perubahan

### 1.1 Data Models (`lib/models/`)
- **`CategoryModel`** (`lib/models/category_model.dart`):
  - Memetakan genre fotografi dari endpoint `GET /api/categories`.
  - Atribut: `idCategory`, `name`, `slug`, `createdAt`.
- **`PhotoModel` & `PhotoCreator`** (`lib/models/photo_model.dart`):
  - Memetakan karya foto lengkap dari endpoint `GET /api/photos`.
  - Atribut gambar: `imageUrl`, `thumbnailUrl`, `mediumUrl`, `highResUrl`.
  - Atribut optik EXIF: `cameraMake`, `cameraModel`, `lens`, `focalLength`, `aperture`, `shutterSpeed`, `iso`, `takenAt`.
  - Helper `cameraBadgeText`: Merangkum spesifikasi kamera dan eksposur dalam format ringkas (contoh: *SONY ILCE-7M4 • f/2.8 • 1/500s*).
  - Atribut sosial: `likesCount`, `commentsCount`, `isLiked`.
  - `copyWith()`: Mendukung pembaruan state lokal optimistik.

### 1.2 Layanan Jaringan (`lib/services/photo_service.dart`)
- **`getCategories()`**: Memanggil `GET /api/categories` untuk daftar genre.
- **`getPhotos({feed, categoryId, userId})`**: Memanggil `GET /api/photos` dengan parameter query feed (`explore` / `following`) dan kategori genre.
- **`toggleLike(photoId)`**: Memanggil `POST /api/photos/:id/like` dengan token JWT terenkripsi.

### 1.3 State Management (`lib/providers/`)
- **`categories_provider.dart`**: `FutureProvider<List<CategoryModel>>` untuk mengambil kategori genre secara ter-cache.
- **`feed_provider.dart`**:
  - `FeedState`: Menyimpan daftar foto, status loading, status pull-to-refresh, error message, kategori aktif, dan feed tab (`explore` / `following`).
  - `FeedNotifier`:
    - `fetchFeed()`: Memuat foto sesuai filter aktif.
    - `selectCategory()`: Mengubah genre dan memuat ulang feed.
    - `setFeedTab()`: Beralih antara feed "Explore" dan "Following".
    - `toggleLike()`: Pembaruan **Optimistic UI** (ikon dan counter like langsung berubah dalam $\le 50$ ms di UI, disinkronisasi ke API, dan di-revert jika gagal).

### 1.4 Komponen Antarmuka (`lib/widgets/`)
- **`CategoryPillList`** (`lib/widgets/category_pill_list.dart`): Bar kapsul genre yang dapat di-scroll horizontal, diawali pill "All Genres", dengan efek warna aktif `AppColors.primary` (Royal Blue).
- **`PhotoCard`** (`lib/widgets/photo_card.dart`):
  - Header profil kreator (avatar bulat, nama pengguna, waktu relatif pemotretan/unggah).
  - Media visual: `CachedNetworkImage` dengan aspect ratio responsif, decoding limit RAM (`memCacheWidth: 1080`), dan placeholder loading.
  - EXIF Parameter Strip: Pita metadata optik kamera di bawah foto.
  - Footer aksi: Judul karya, tombol interaktif Like (ikon hati merah + counter), jumlah komentar, dan tombol "View EXIF".

### 1.5 Layar Aplikasi (`lib/screens/` & `lib/main.dart`)
- **`FeedScreen`** (`lib/screens/feed/feed_screen.dart`):
  - App bar dengan logo PicFlow sRGB dan tab selector (Explore / Following).
  - `RefreshIndicator` untuk gestur pull-to-refresh.
  - Penanganan state lengkap: loading spinner bernuansa editorial, pesan error koneksi dengan tombol coba lagi, dan empty state.
- **`MainNavigationShell`** (`lib/screens/main_navigation_shell.dart`):
  - `BottomNavigationBar` dengan 3 tab: Feed (`FeedScreen`), Upload (Placeholder studio kurasi untuk Sprint 5), dan Profile (`HomeScreen`).
- **`AuthGate`** (`lib/main.dart`):
  - Mengarahkan akun yang terautentikasi ke `MainNavigationShell`.

---

## 2. Hasil Verifikasi Kualitas
- **`flutter analyze`**: 0 issues found (No issues found).
- **`flutter test`**: All tests passed (2 unit/widget tests passed).
- **Format Dart**: `dart format` dijalankan pada seluruh berkas.
- **Status Git**: Seluruh berkas berstatus *unstaged* menunggu review pengguna.

# Notulen Sprint 5: Photo Upload & Curation Studio

- **Target Branch**: `feature/photo-upload`
- **Tujuan**: Mengimplementasikan antarmuka Studio Kurasi dan alur unggah foto (US-04) dengan pemilihan berkas gambar dari kamera/galeri, pengisian metadata kurasi (judul, kategori genre, deskripsi/cerita), unggahan multipart ke backend Express, dan penyegaran otomatis feed.
- **Status**: Selesai diimplementasikan (Pending review & commit dari pengguna).

---

## 1. Rincian Perubahan

### 1.1 Layanan Jaringan & Model Data (`lib/services/photo_service.dart` & `lib/models/photo_model.dart`)
- **Metode Baru `uploadPhoto`**:
  - Mengirim permintaan multipart (`POST /api/photos`) menggunakan `ApiService.multipart`.
  - Berkas foto dikirim menggunakan field name `'image'` via `http.MultipartFile.fromPath`.
  - Form fields: `'title'`, `'id_category'`, dan `'description'` (opsional).
  - Backend Express otomatis mengekstrak metadata EXIF dan menghasilkan respons ter-serialize `PhotoModel`.
- **Perbaikan Robust Deserialization (`PhotoModel`)**:
  - Mengubah tipe `idPhoto` menjadi `dynamic` untuk menampung format UUID asli dari database Supabase (`row.id`).
  - Mengganti type casting kaku `as String?` pada field metadata EXIF (`iso`, `camera_make`, dll.) menjadi `?.toString()`, mencegah crash `TypeError` saat backend mengirim nilai `iso` dalam format numerik `int` (misal `50`).

### 1.2 State Management (`lib/providers/upload_provider.dart`)
- **`UploadState`**:
  - Menyimpan status pemilihan gambar (`selectedImage`), kategori genre (`selectedCategoryId`), indikator loading (`isUploading`), pesan error (`errorMessage`), status keberhasilan (`isSuccess`), dan model foto hasil unggahan (`uploadedPhoto`).
- **`UploadNotifier` (`StateNotifierProvider.autoDispose`)**:
  - `pickImage(ImageSource source)`: Mengambil gambar beresolusi tinggi via `image_picker` (maksimal 3840×3840 px, kualitas 95%) dari kamera bawaan atau galeri berkas.
  - `setImage(File? file)`: Menetapkan atau mereset berkas foto terpilih secara langsung.
  - `clearImage()`: Menghapus foto yang sedang dipilih dari memori formulir.
  - `setCategory(int? categoryId)`: Menetapkan genre fotografi terpilih.
  - `clearError()`: Mereset banner pesan error.
  - `upload({required String title, String? description})`: Melakukan validasi klien (foto wajib dipilih, judul minimal 1 karakter, kategori wajib ditentukan), mengeksekusi request unggah, dan mengembalikan status boolean.
  - `reset()`: Mengembalikan formulir ke kondisi awal.

### 1.3 Layar Studio Kurasi (`lib/screens/upload/upload_photo_screen.dart`)
- **Picker Frame & Image Preview**:
  - Area unggah dengan container border halus saat belum ada gambar terpilih.
  - Bottom sheet dialog modern untuk memilih sumber: **Kamera** (`ImageSource.camera`) atau **Galeri** (`ImageSource.gallery`).
  - Pratinjau gambar terpilih dengan batas ketinggian adaptif, tombol "Ganti Foto" mengambang, nama berkas, dan tombol hapus di AppBar.
- **Formulir Kurasi**:
  - Input judul karya wajib (`TextFormField`) dengan validasi form.
  - Dropdown kategori genre fotografi terhubung langsung ke `categoriesProvider` dengan penanganan status loading dan error.
  - Input narasi dan cerita di balik foto (*multiline text*) untuk fotografer mendeskripsikan proses pemotretan.
  - Card tip informatif: Menjelaskan bahwa metadata optik teknis kamera (EXIF) diekstrak otomatis oleh server dari berkas asli tanpa perlu diinput manual.
- **Tombol Publikasi & Feedback**:
  - Tombol submit dengan indikator progress berputar dan teks "Mengunggah & Mengekstrak EXIF...".
  - Banner error interaktif dengan tombol tutup (*dismissable*).
  - SnackBar hijau sukses saat unggahan berhasil dan pemicu callback `onUploadSuccess`.

### 1.4 Integrasi Shell Navigasi (`lib/screens/main_navigation_shell.dart`)
- Mengganti `_UploadPlaceholderScreen` dengan `UploadPhotoScreen`.
- Saat foto berhasil diunggah:
  - Feed otomatis diperbarui di latar belakang via `ref.read(feedProvider.notifier).fetchFeed(isRefresh: true)`.
  - Tab navigasi otomatis beralih kembali ke tab **Feed** (`_currentIndex = 0`).

### 1.5 Pengujian Antarmuka (`test/widget_test.dart`)
- Menambahkan 3 skenario pengujian widget untuk alur unggah:
  1. Render studio kurasi (judul, kategori, picker trigger, tombol publikasi, dan tip EXIF).
  2. Pembukaan bottom sheet pemilihan sumber foto (Kamera vs Galeri).
  3. Validasi form saat menekan publikasikan tanpa judul atau gambar.

---

## 2. Hasil Verifikasi Kualitas
- **`flutter analyze`**: 0 issue / No issues found.
- **`flutter test`**: 8 unit/widget tests passed (termasuk regression test deserialisasi integer ISO & UUID).
- **Status Git**: Seluruh berkas berstatus *unstaged* menunggu review pengguna sebelum commit bertahap.

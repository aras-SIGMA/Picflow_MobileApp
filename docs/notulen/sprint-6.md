# Notulen Sprint 6: Creator Profile & Personal Portfolio Management

- **Target Branch**: `feature/user-profile-crud`
- **Tujuan**: Mengimplementasikan antarmuka Profil Kreator & Portofolio Karya Pribadi lengkap dengan siklus CRUD: melihat portofolio dalam 2-column grid, mengedit metadata karya (US-05), menghapus foto karya dengan konfirmasi destruktif (US-06), serta session teardown (logout terproteksi).
- **Status**: Selesai diimplementasikan (Pending review & commit dari pengguna).

---

## 1. Rincian Perubahan

### 1.1 Layanan Jaringan (`lib/services/photo_service.dart`)
- **`getUserPhotos()`**:
  - Mengambil seluruh daftar karya foto milik pengguna terautentikasi melalui `GET /api/photos?feed=my` dengan header token Bearer.
- **`updatePhoto({required dynamic photoId, required String title, required int categoryId, String? description})`**:
  - Memperbarui metadata foto melalui `PUT /api/photos/:id` via `apiService.put`.
  - Mengirim payload JSON terstruktur `{ 'title': title, 'id_category': categoryId, 'description': description }`.
- **`deletePhoto(dynamic photoId)`**:
  - Menghapus karya foto melalui `DELETE /api/photos/:id` via `apiService.delete`.

### 1.2 State Management (`lib/providers/profile_provider.dart`)
- **`ProfileState`**:
  - Menyimpan daftar karya pribadi (`userPhotos`), status loading pemuatan awal (`isLoading`), status loading aksi mutasi (`isActionLoading`), serta pesan error dan feedback sukses.
  - Getter teragregasi: `totalPhotos` (panjang list karya) dan `totalLikes` (akumulasi jumlah likes pada karya pengguna).
- **`ProfileNotifier` (`StateNotifierProvider`)**:
  - `fetchUserPhotos()`: Memuat portofolio foto kreator saat inisialisasi atau pull-to-refresh.
  - `updatePhoto(...)`: Memperbarui data foto di server, memutasi list foto lokal secara instan (*in-place update*), dan menyegarkan `feedProvider` agar sinkron.
  - `deletePhoto(photoId)`: Mengeksekusi penghapusan di server, memfilter foto dari state lokal secara seketika (*instant removal*), dan menyegarkan `feedProvider`.

### 1.3 Komponen Modal Edit Metadata (`lib/widgets/edit_photo_sheet.dart`)
- Modal Bottom Sheet terisolasi dan reusable untuk pembaruan metadata karya:
  - Input judul karya wajib (`TextFormField`) dengan validasi minimal 1 karakter.
  - Dropdown kategori genre fotografi terhubung langsung ke `categoriesProvider`.
  - Input deskripsi / narasi cerita di balik lensa (*multiline text*).
  - Tombol aksi simpan dengan indikator loading berputar.

### 1.4 Layar Profil & Portofolio (`lib/screens/profile/profile_screen.dart`)
- Menggantikan placeholder `HomeScreen` di tab ke-3 navigasi utama (`MainNavigationShell`).
- **Creator Header Card**:
  - Avatar lingkaran fotografer dengan gambar profil jaringan ter-cache atau ikon fallback.
  - Nama pengguna, email, dan badge peran (`PHOTOGRAPHER` / `ADMIN CURATOR`).
  - Bar statistik agregat: **Total Karya** dan **Total Likes**.
- **2-Column Portfolio Grid**:
  - Tampilan grid 2 kolom dengan kartu foto proporsional (`childAspectRatio: 0.72`).
  - Pratinjau gambar via `CachedNetworkImage` dengan badge likes mengambang di atas foto.
  - Menu aksi mengambang (`PopupMenuButton`) pada setiap kartu untuk memilih **Edit Metadata** atau **Hapus Foto**.
  - Ketuk kartu membuka `PhotoDetailScreen` (hero image + data optik EXIF lengkap).
- **Empty State**:
  - Tampilan bersahabat saat kreator belum memiliki karya foto dengan tombol CTA *"Unggah Karya Pertama"* yang langsung memindahkan tab aktif ke Studio Kurasi (tab index 1).
- **Session Teardown (Logout)**:
  - Tombol logout di AppBar dengan dialog konfirmasi (`AlertDialog`).
  - Memanggil `authProvider.notifier.logout()`, menghapus token di secure storage, dan kembali ke `LoginScreen`.

### 1.5 Integrasi Shell & Layar Detail Foto
- **`lib/screens/main_navigation_shell.dart`**: Menghubungkan `ProfileScreen` dengan callback `onNavigateToUpload` untuk perpindahan antar-tab mulus.
- **`lib/screens/upload/upload_photo_screen.dart`**: Memanggil `profileProvider.notifier.fetchUserPhotos()` saat unggah sukses agar portofolio profil selalu mutakhir.
- **`lib/screens/photo_detail/photo_detail_screen.dart`**:
  - Menyesuaikan tipe `photoId` menjadi `dynamic` agar kompatibel dengan UUID database Supabase.
  - Menambahkan menu opsi Edit Metadata (`EditPhotoSheet`) dan Hapus Foto (dengan konfirmasi destruktif) pada AppBar jika pengguna adalah pemilik foto (`photo.isOwner == true`).

### 1.6 Pengujian Antarmuka (`test/widget_test.dart`)
- Menambahkan 3 skenario pengujian widget untuk alur Profil & CRUD:
  1. Render profil kreator, badge peran, bio, statistik total foto, dan kartu portofolio grid.
  2. Dialog konfirmasi keluar (logout) saat menekan ikon logout AppBar.
  3. Render formulir edit metadata karya (`EditPhotoSheet`) lengkap dengan judul, dropdown kategori, dan narasi cerita.

---

## 2. Hasil Verifikasi Kualitas
- **`flutter analyze`**: 0 issue / No issues found.
- **`flutter test`**: 11 unit & widget tests passed.
- **Status Git**: Seluruh berkas berstatus *unstaged* menunggu review pengguna sebelum commit bertahap.

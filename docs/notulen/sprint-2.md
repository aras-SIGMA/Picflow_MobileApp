# Notulen Sprint 2: Creator Authentication & Session Management

- **Target Branch**: `feature/auth`
- **Tujuan**: Mengimplementasikan alur registrasi, login kreator, persistensi sesi JWT, auto-login saat peluncuran aplikasi, dan routing antarmuka autentikasi.
- **Status**: Selesai diimplementasikan (Pending review & commit dari pengguna).

---

## 1. Rincian Perubahan

### 1.1 Data Model (`lib/models/user_model.dart`)
- **`UserModel`**:
  - Properti: `idUser`, `username`, `email`, `role`, `fullName`, `bio`, `profilePictureUrl`, `createdAt`.
  - Getter `isAdmin` untuk mendeteksi hak kurator admin.
  - Serialization: `fromJson`, `toJson`, dan `copyWith`.
- **`AuthResponse`**:
  - Memetakan payload respons login/register (`token`, `refresh_token`, dan `user`).

### 1.2 Service Autentikasi (`lib/services/auth_service.dart`)
- Mengonsumsi endpoint Express backend:
  - `login()`: Mengirim kredensial ke `POST /auth/login`, otomatis menyimpan token ke `StorageService` (Keystore).
  - `register()`: Mengirim data ke `POST /auth/register`, otomatis menyimpan token jika backend langsung mengembalikan sesi.
  - `getMe()`: Mengambil profil kreator dari `GET /auth/me` dengan autentikasi Bearer token.
  - `logout()`: Menghapus token dari Keystore.

### 1.3 State Management (`lib/providers/auth_provider.dart`)
- **`AuthState`**: Memiliki enum status (`initial`, `loading`, `authenticated`, `unauthenticated`, `error`).
- **`AuthNotifier`**:
  - `checkAuthStatus()`: Otomatis dipanggil saat aplikasi terbuka. Membaca token dari Keystore dan memverifikasi ke backend. Jika token kedaluwarsa (401), otomatis membersihkan storage dan mengembalikan ke state `unauthenticated`.
  - `login()` & `register()`: Mengatur state loading, memproses payload, dan mengupdate state `authenticated`.
  - `logout()`: Menghapus sesi dan mereset status aplikasi.

### 1.4 Komponen Antarmuka Reusable (`lib/widgets/`)
- **`CustomTextField`**: Text input bergaya editorial dengan validasi form, prefix icon, dan tombol toggle visibilitas password (ikon mata).
- **`CustomButton`**: Tombol tindakan utama (primary dan outline) dengan indikator `CircularProgressIndicator` saat proses loading.
- **`ErrorBanner`**: Banner pesan error bernuansa merah lembut untuk menampilkan validasi input dari backend.

### 1.5 Layar Aplikasi (`lib/screens/` & `lib/main.dart`)
- **`LoginScreen`** (`lib/screens/auth/login_screen.dart`): Form login dengan tombol **"Quick Demo Account"** (`guest@picflow.studio`) untuk mempercepat pengujian.
- **`RegisterScreen`** (`lib/screens/auth/register_screen.dart`): Form pendaftaran akun baru dengan validasi username ($\ge 3$ huruf/angka) dan password ($\ge 6$ karakter).
- **`HomeScreen`** (`lib/screens/home/home_screen.dart`): Layar profil kreator terautentikasi (avatar, username, email, badge status role, konfirmasi sesi aktif, dan tombol Logout).
- **`AuthGate`** (`lib/main.dart`): Entry point dinamis yang mengarahkan pengguna secara otomatis ke `SplashScreen`, `HomeScreen`, atau `LoginScreen` berdasarkan status autentikasi.

---

## 2. Catatan Teknis & Troubleshooting USB Debugging
- **Masalah**: Muncul pesan `"tidak dapat terhubung ke server backend picflow..."` saat pengujian di HP Android fisik via USB.
- **Penyebab**: Perangkat Android menganggap `localhost` adalah sistem Android itu sendiri, bukan PC/laptop pengembang. Port forwarding bridge belum terpasang.
- **Solusi**: Dijalankan perintah `adb reverse tcp:8000 tcp:8000`. Port 8000 di HP fisik kini terhubung langsung ke port 8000 server Express di laptop.

---

## 3. Hasil Verifikasi Kualitas
- **`flutter analyze`**: 0 issues found.
- **`flutter test`**: All tests passed (Unit/Widget test AuthGate login berhasil).
- **Status Git**: Seluruh file masih berstatus *unstaged* menunggu persetujuan review pengguna.

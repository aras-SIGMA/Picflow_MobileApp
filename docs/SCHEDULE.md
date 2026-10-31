# Development Schedule — PicFlow Mobile (MVP v1.0)

> **Document Version**: 1.0.0  
> **Status**: Approved  
> **Target Platform**: Android (Flutter Native)  
> **State Management**: Flutter Riverpod  
> **Networking**: `package:http` (Lightweight Custom API Client)  

---

## 1. Development Principles & Git Workflow

- **Branch Strategy**:
  - `main`: Production-ready release branch.
  - `develop`: Primary integration branch during development.
  - `feature/<feature-name>`: Isolated branches branched off `develop` for every individual milestone.
- **Commit Format**: Conventional Commits (`feat(...)`, `docs(...)`, `fix(...)`, `chore(...)`, `refactor(...)`).
- **Review Gate**: Every feature is verified via `flutter analyze` and tested against the backend via USB reverse proxy (`adb reverse tcp:8000 tcp:8000`) before merging back to `develop`.

---

## 2. Sprint Milestones Breakdown

### Sprint 1: Core Setup, Design Tokens & Network Layer
- **Target Branch**: `feature/core-setup-theme`
- **Estimated Scope**: Foundation
- **Deliverables**:
  1. Add core dependencies to `pubspec.yaml`:
     - `flutter_riverpod: ^2.6.1`
     - `http: ^1.2.2`
     - `flutter_secure_storage: ^9.2.2`
     - `cached_network_image: ^3.4.1`
     - `image_picker: ^1.1.2`
     - `google_fonts: ^6.2.1`
     - `intl: ^0.19.0`
  2. Android configuration:
     - Add `INTERNET`, `CAMERA`, and image read permissions to `AndroidManifest.xml`.
     - Enable `android:usesCleartextTraffic="true"` for debug HTTP access to local backend.
  3. Design Tokens & Theme implementation:
     - `AppColors` (Canvas `#FFFDF6`, Elevated Card `#F8F3E8`, Border `#E8DEC9`, Primary Blue `#2563EB`, Stone Inks, sRGB highlights).
     - `AppTypography` using GoogleFonts (Plus Jakarta Sans / Inter).
     - `AppTheme` configuring theme data, input decorations, and button styles.
  4. Lightweight Network Layer (`ApiClient`):
     - Wrapper around `http.Client`.
     - Automated headers: `Content-Type: application/json` and `Authorization: Bearer <token>`.
     - Custom `ApiException` with friendly network error messages for local `adb reverse` troubleshooting.
  5. `TokenStorage`:
     - Secure token persistence using `FlutterSecureStorage`.
- **Verification**: `flutter analyze` passes with 0 issues; placeholder app boots with warm cream canvas theme.

---

### Sprint 2: Creator Authentication & Session Management (US-01)
- **Target Branch**: `feature/auth`
- **Estimated Scope**: Core Security & Session
- **Deliverables**:
  1. Data Models:
     - `UserModel` (`id_user`, `username`, `email`, `role`, `avatar_url`, `bio`).
     - `AuthResponse` (`token`, user info).
  2. Repositories:
     - `AuthRepository`: `login(email, password)`, `register(username, email, password)`, `getMe()`.
  3. Riverpod State:
     - `AuthState` & `AuthNotifier`: Handing `initial`, `loading`, `authenticated(user)`, `unauthenticated`, and `error`.
  4. Presentation Screens:
     - `LoginScreen`: Form validation, password visibility toggle, error banners.
     - `RegisterScreen`: Username, email, password validation ($\ge 6$ characters).
     - `AuthGate`: Initial routing gate inspecting persisted token on boot.
- **Verification**: User can register an account, log in, store token in Keystore, and stay logged in across app restarts.

---

### Sprint 3: Main Navigation Shell & Feed Discovery (US-02)
- **Target Branch**: `feature/feed-discovery`
- **Estimated Scope**: Core Read Interaction
- **Deliverables**:
  1. Navigation Shell:
     - `MainNavigationShell` with bottom navigation bar (Feed, Upload, Profile).
  2. Data Models:
     - `PhotoModel` (id, title, description, image_url, thumbnail_url, high_res_url, camera EXIF fields, creator object).
     - `CategoryModel` (id, name).
  3. Repositories:
     - `PhotoRepository.getPhotos({category_id, feed})`.
     - `CategoryRepository.getCategories()`.
  4. Riverpod State:
     - `FeedNotifier`: Active category filter, pull-to-refresh handling, photo list caching.
  5. Presentation Widgets:
     - `FeedScreen`: Pull-to-refresh list view.
     - `CategoryPillList`: Horizontally scrollable category pills.
     - `PhotoCard`: Creator header, cached photo thumbnail, title, and quick camera/aperture chips.
- **Verification**: Feed displays real photos served by backend API; category filter refreshes feed correctly.

---

### Sprint 4: High-Res Photo Detail & EXIF Technical Panel (US-03)
- **Target Branch**: `feature/photo-detail-exif`
- **Estimated Scope**: Detail & Optical Metadata
- **Deliverables**:
  1. Riverpod State:
     - `PhotoDetailNotifier`: Fetching individual photo details by ID.
  2. Presentation Screen:
     - `PhotoDetailScreen`: High-resolution hero image with interactive zoom support.
  3. Optical Metadata Panel:
     - `ExifMetadataPanel`: Displays camera make & model, lens, focal length, aperture, shutter speed, ISO, and shooting timestamp.
     - Fallback handling: Graceful `N/A` chips for missing EXIF fields.
- **Verification**: Tapping any feed card opens full-screen photo detail with complete EXIF specifications.

---

### Sprint 5: Photo Upload & Curation Studio (US-04)
- **Target Branch**: `feature/photo-upload`
- **Estimated Scope**: Core Create Interaction
- **Deliverables**:
  1. Image Selection:
     - Bottom sheet dialog offering Camera vs Gallery source via `image_picker`.
  2. Riverpod State:
     - `UploadNotifier`: Selected file preview, category selection, upload loading state.
  3. Presentation Screen:
     - `UploadPhotoScreen`: Selected image frame, Title input (required), Category dropdown (required), Description input (optional).
  4. Multipart Request:
     - `ApiClient.uploadPhoto()` executing multipart form upload to `POST /api/photos`.
  5. Completion Flow:
     - Success feedback, automatic feed invalidation/refresh, and navigation back to Feed.
- **Verification**: Capturing/picking an image and uploading it succeeds, and the new photo appears in the feed.

---

### Sprint 6: Creator Profile & Personal Portfolio Management (US-05 & US-06)
- **Target Branch**: `feature/user-profile-crud`
- **Estimated Scope**: Core Update & Delete Interaction
- **Deliverables**:
  1. Profile & Portfolio:
     - `ProfileScreen`: Creator avatar, username, total uploaded photos counter.
     - 2-column grid layout displaying only photos belonging to the logged-in creator.
  2. Edit Metadata (Update):
     - Edit modal / screen to update title and description via `PUT /api/photos/:id`.
  3. Delete Photo (Delete):
     - Confirmation modal before executing `DELETE /api/photos/:id`.
     - Instant removal of photo from state and grid upon successful deletion.
  4. Session Teardown:
     - Logout button clearing token storage and resetting to `LoginScreen`.
- **Verification**: Complete CRUD lifecycle verified; creator can create, view, edit, and delete their own photos.

---

### Sprint 7: End-to-End Polish, Performance Audit & USB Device Verification
- **Target Branch**: `feature/e2e-polish`
- **Estimated Scope**: Quality Assurance & Delivery
- **Deliverables**:
  1. End-to-End manual testing on physical Android device connected via USB (`adb reverse tcp:8000 tcp:8000`).
  2. Network connection failure handler with diagnostic tip (*"Pastikan server aktif dan jalankan 'adb reverse tcp:8000 tcp:8000'"*).
  3. Performance and memory check: Smooth 60 fps scrolling without image memory leaks.
  4. Run `flutter analyze` across entire project (0 warnings, 0 errors).
  5. Merge `feature/e2e-polish` into `develop`.
- **Verification**: Fully functional, polished MVP Android build ready for testing and demo.

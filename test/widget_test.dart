import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picflow_mobile/main.dart';
import 'package:picflow_mobile/models/category_model.dart';
import 'package:picflow_mobile/models/photo_model.dart';
import 'package:picflow_mobile/models/user_model.dart';
import 'package:picflow_mobile/providers/auth_provider.dart';
import 'package:picflow_mobile/providers/categories_provider.dart';
import 'package:picflow_mobile/providers/feed_provider.dart';
import 'package:picflow_mobile/providers/profile_provider.dart';
import 'package:picflow_mobile/screens/photo_detail/photo_detail_screen.dart';
import 'package:picflow_mobile/screens/profile/profile_screen.dart';
import 'package:picflow_mobile/screens/upload/upload_photo_screen.dart';
import 'package:picflow_mobile/services/api_exception.dart';
import 'package:picflow_mobile/widgets/edit_photo_sheet.dart';
import 'package:picflow_mobile/widgets/exif_metadata_panel.dart';

void main() {
  testWidgets('PicFlow auth gate renders login screen when unauthenticated', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            (ref) => FakeAuthNotifier(
              const AuthState(status: AuthStatus.unauthenticated),
            ),
          ),
        ],
        child: const PicFlowApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify presence of brand title and login elements
    expect(find.text('Pic'), findsOneWidget);
    expect(find.text('Flow'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets(
    'PicFlow renders MainNavigationShell with Feed when authenticated',
    (WidgetTester tester) async {
      const mockUser = UserModel(
        idUser: 'u1',
        username: 'testcreator',
        email: 'test@picflow.studio',
        role: 'user',
      );

      const mockPhoto = PhotoModel(
        idPhoto: 1,
        idUser: 'u1',
        title: 'Neon Tokyo',
        description: 'Night street photography',
        imageUrl: 'https://example.com/photo.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        mediumUrl: 'https://example.com/med.jpg',
        highResUrl: 'https://example.com/high.jpg',
        cameraModel: 'SONY A7M4',
        aperture: 'f/1.8',
        likesCount: 12,
        commentsCount: 3,
        isLiked: false,
        creator: PhotoCreator(idUser: 'u1', username: 'testcreator'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              (ref) => FakeAuthNotifier(
                const AuthState(
                  status: AuthStatus.authenticated,
                  user: mockUser,
                ),
              ),
            ),
            categoriesProvider.overrideWith(
              (ref) async => [
                const CategoryModel(idCategory: 1, name: 'Street'),
                const CategoryModel(idCategory: 2, name: 'Portrait'),
              ],
            ),
            feedProvider.overrideWith(
              (ref) => FakeFeedNotifier(const FeedState(photos: [mockPhoto])),
            ),
          ],
          child: const PicFlowApp(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify presence of navigation items
      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify feed item rendered
      expect(find.text('Neon Tokyo'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);
    },
  );

  testWidgets(
    'ExifMetadataPanel renders optical fields and handles N/A fallback',
    (WidgetTester tester) async {
      const fullPhoto = PhotoModel(
        idPhoto: 99,
        idUser: 'u1',
        title: 'Alpine Summit',
        imageUrl: 'https://example.com/alpine.jpg',
        thumbnailUrl: 'https://example.com/alpine.jpg',
        mediumUrl: 'https://example.com/alpine.jpg',
        highResUrl: 'https://example.com/alpine.jpg',
        cameraMake: 'Sony',
        cameraModel: 'ILCE-7M4',
        lens: 'FE 24-70mm F2.8 GM II',
        focalLength: '35mm',
        aperture: 'f/2.8',
        shutterSpeed: '1/1000s',
        iso: '100',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ExifMetadataPanel(photo: fullPhoto),
            ),
          ),
        ),
      );

      expect(find.text('Optical Specifications'), findsOneWidget);
      expect(find.text('Sony ILCE-7M4'), findsOneWidget);
      expect(find.text('FE 24-70mm F2.8 GM II'), findsOneWidget);
      expect(find.text('f/2.8'), findsOneWidget);
      expect(find.text('1/1000s'), findsOneWidget);
      expect(find.text('ISO 100'), findsOneWidget);
      expect(find.text('35mm'), findsOneWidget);
    },
  );

  testWidgets('PhotoDetailScreen renders photo info and action buttons', (
    WidgetTester tester,
  ) async {
    const testPhoto = PhotoModel(
      idPhoto: 42,
      idUser: 'u9',
      title: 'Candid Street',
      description: 'Captured in morning light with Leica M11.',
      imageUrl: 'https://example.com/candid.jpg',
      thumbnailUrl: 'https://example.com/candid.jpg',
      mediumUrl: 'https://example.com/candid.jpg',
      highResUrl: 'https://example.com/candid.jpg',
      cameraModel: 'Leica M11',
      aperture: 'f/1.4',
      shutterSpeed: '1/250s',
      likesCount: 8,
      commentsCount: 2,
      isLiked: true,
      creator: PhotoCreator(idUser: 'u9', username: 'leicacreator'),
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PhotoDetailScreen(photoId: 42, initialPhoto: testPhoto),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Candid Street'), findsAtLeastNWidgets(1));
    expect(
      find.text('Captured in morning light with Leica M11.'),
      findsOneWidget,
    );
    expect(find.text('leicacreator'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Pinch to zoom (up to 4x)'), findsOneWidget);
  });

  testWidgets(
    'UploadPhotoScreen renders curation studio form and picker trigger',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesProvider.overrideWith(
              (ref) async => [
                const CategoryModel(idCategory: 1, name: 'Landscape'),
              ],
            ),
          ],
          child: const MaterialApp(home: UploadPhotoScreen()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Studio Kurasi'), findsOneWidget);
      expect(find.text('Sentuh untuk Memilih Foto'), findsOneWidget);
      expect(find.text('Judul Karya *'), findsOneWidget);
      expect(find.text('Kategori Fotografi *'), findsOneWidget);
      expect(find.text('Publikasikan Karya'), findsOneWidget);
      expect(find.text('Ekstraksi Otomatis EXIF'), findsOneWidget);
    },
  );

  testWidgets(
    'UploadPhotoScreen shows camera and gallery modal when tapping picker container',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesProvider.overrideWith(
              (ref) async => [
                const CategoryModel(idCategory: 1, name: 'Landscape'),
              ],
            ),
          ],
          child: const MaterialApp(home: UploadPhotoScreen()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Sentuh untuk Memilih Foto'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Sumber Foto'), findsOneWidget);
      expect(find.text('Ambil Foto dari Kamera'), findsOneWidget);
      expect(find.text('Pilih dari Galeri'), findsOneWidget);
    },
  );

  testWidgets('UploadPhotoScreen validates empty title and missing image', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriesProvider.overrideWith(
            (ref) async => [
              const CategoryModel(idCategory: 1, name: 'Landscape'),
            ],
          ),
        ],
        child: const MaterialApp(home: UploadPhotoScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Attempt to submit without filling title or picking image
    final submitButton = find.text('Publikasikan Karya');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Form validation for title should trigger
    expect(find.text('Judul foto wajib diisi'), findsOneWidget);
  });

  test('PhotoModel.fromJson parses integer ISO and UUID idPhoto safely', () {
    final payload = {
      'id_photo': '8195b0c5-ba9d-4ddd-89c3-a4c512b69c30',
      'id_user': '578f0b0d-9bda-4448-83ca-5883df8b5ebf',
      'title': 'UI di sore hari',
      'image_url': 'https://res.cloudinary.com/test.jpg',
      'iso': 50,
      'camera_make': 'TECNO',
      'camera_model': 'TECNO CN5',
    };

    final photo = PhotoModel.fromJson(payload);
    expect(photo.idPhoto, '8195b0c5-ba9d-4ddd-89c3-a4c512b69c30');
    expect(photo.iso, '50');
    expect(photo.cameraMake, 'TECNO');
  });

  test(
    'NetworkConnectionException provides clear adb reverse diagnostic advice',
    () {
      final ex = NetworkConnectionException('Connection refused');
      expect(ex.message, contains('adb reverse tcp:8000 tcp:8000'));
      expect(ex.statusCode, 0);
    },
  );

  testWidgets(
    'ProfileScreen renders creator info, aggregate counters, and portfolio grid',
    (WidgetTester tester) async {
      const mockUser = UserModel(
        idUser: 'creator-99',
        username: 'lensmaster',
        email: 'lens@picflow.studio',
        role: 'user',
        bio: 'Landscape and street enthusiast.',
      );

      const mockPhoto = PhotoModel(
        idPhoto: 'p1',
        idUser: 'creator-99',
        title: 'Morning Misty Mountain',
        categoryName: 'Landscape',
        imageUrl: 'https://example.com/mist.jpg',
        thumbnailUrl: 'https://example.com/mist.jpg',
        mediumUrl: 'https://example.com/mist.jpg',
        highResUrl: 'https://example.com/mist.jpg',
        likesCount: 15,
        isOwner: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              (ref) => FakeAuthNotifier(
                const AuthState(
                  status: AuthStatus.authenticated,
                  user: mockUser,
                ),
              ),
            ),
            profileProvider.overrideWith(
              (ref) => FakeProfileNotifier(
                const ProfileState(userPhotos: [mockPhoto]),
              ),
            ),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Profil & Portofolio'), findsOneWidget);
      expect(find.text('lensmaster'), findsOneWidget);
      expect(find.text('PHOTOGRAPHER'), findsOneWidget);
      expect(find.text('Landscape and street enthusiast.'), findsOneWidget);
      expect(find.text('Karya Portofolio'), findsOneWidget);
      expect(find.text('1 Foto'), findsOneWidget);
      expect(find.text('Morning Misty Mountain'), findsOneWidget);
    },
  );

  testWidgets('ProfileScreen shows logout confirmation dialog', (
    WidgetTester tester,
  ) async {
    const mockUser = UserModel(
      idUser: 'creator-99',
      username: 'lensmaster',
      email: 'lens@picflow.studio',
      role: 'user',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            (ref) => FakeAuthNotifier(
              const AuthState(status: AuthStatus.authenticated, user: mockUser),
            ),
          ),
          profileProvider.overrideWith(
            (ref) => FakeProfileNotifier(const ProfileState()),
          ),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap logout icon in AppBar
    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Keluar'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
  });

  testWidgets(
    'EditPhotoSheet renders metadata edit form with title, category, and story',
    (WidgetTester tester) async {
      const mockPhoto = PhotoModel(
        idPhoto: 'p1',
        idUser: 'u1',
        title: 'Original Title',
        description: 'Original Story',
        idCategory: 1,
        categoryName: 'Landscape',
        imageUrl: 'https://example.com/p1.jpg',
        thumbnailUrl: 'https://example.com/p1.jpg',
        mediumUrl: 'https://example.com/p1.jpg',
        highResUrl: 'https://example.com/p1.jpg',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesProvider.overrideWith(
              (ref) async => [
                const CategoryModel(idCategory: 1, name: 'Landscape'),
                const CategoryModel(idCategory: 2, name: 'Street'),
              ],
            ),
            profileProvider.overrideWith(
              (ref) => FakeProfileNotifier(const ProfileState()),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: EditPhotoSheet(photo: mockPhoto)),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Edit Metadata Karya'), findsOneWidget);
      expect(find.text('Judul Karya *'), findsOneWidget);
      expect(find.text('Original Title'), findsOneWidget);
      expect(find.text('Kategori Fotografi *'), findsOneWidget);
      expect(find.text('Deskripsi & Cerita'), findsOneWidget);
      expect(find.text('Original Story'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
    },
  );
}

class FakeProfileNotifier extends StateNotifier<ProfileState>
    implements ProfileNotifier {
  FakeProfileNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> fetchUserPhotos() async {}

  @override
  Future<bool> updatePhoto({
    required dynamic photoId,
    required String title,
    required int categoryId,
    String? description,
  }) async => true;

  @override
  Future<bool> deletePhoto(dynamic photoId) async => true;

  @override
  void clearMessages() {}
}

class FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  FakeAuthNotifier(super.state);

  @override
  Future<void> checkAuthStatus() async {}

  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> logout() async {}
}

class FakeFeedNotifier extends StateNotifier<FeedState>
    implements FeedNotifier {
  FakeFeedNotifier(super.state);

  @override
  Future<void> fetchFeed({bool isRefresh = false}) async {}

  @override
  void selectCategory(dynamic categoryId) {}

  @override
  void setFeedTab(String tab) {}

  @override
  Future<void> toggleLike(dynamic photoId) async {}
}

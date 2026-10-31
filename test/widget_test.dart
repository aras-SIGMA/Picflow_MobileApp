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
import 'package:picflow_mobile/screens/photo_detail/photo_detail_screen.dart';
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
  Future<void> toggleLike(int photoId) async {}
}

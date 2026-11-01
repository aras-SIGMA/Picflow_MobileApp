import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/photo_model.dart';
import '../services/api_exception.dart';
import '../services/photo_service.dart';
import 'feed_provider.dart';

class ProfileState {
  final List<PhotoModel> userPhotos;
  final bool isLoading;
  final bool isActionLoading;
  final String? errorMessage;
  final String? actionSuccessMessage;

  const ProfileState({
    this.userPhotos = const [],
    this.isLoading = false,
    this.isActionLoading = false,
    this.errorMessage,
    this.actionSuccessMessage,
  });

  int get totalPhotos => userPhotos.length;

  int get totalLikes =>
      userPhotos.fold<int>(0, (sum, photo) => sum + photo.likesCount);

  ProfileState copyWith({
    List<PhotoModel>? userPhotos,
    bool? isLoading,
    bool? isActionLoading,
    String? errorMessage,
    String? actionSuccessMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      userPhotos: userPhotos ?? this.userPhotos,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionSuccessMessage: clearSuccess
          ? null
          : (actionSuccessMessage ?? this.actionSuccessMessage),
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  final photoService = ref.watch(photoServiceProvider);
  return ProfileNotifier(photoService: photoService, ref: ref);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final PhotoService photoService;
  final Ref ref;

  ProfileNotifier({required this.photoService, required this.ref})
    : super(const ProfileState()) {
    fetchUserPhotos();
  }

  Future<void> fetchUserPhotos() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final photos = await photoService.getUserPhotos();
      state = state.copyWith(
        userPhotos: photos,
        isLoading: false,
        clearError: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat portofolio Anda. Silakan coba lagi.',
      );
    }
  }

  Future<bool> updatePhoto({
    required dynamic photoId,
    required String title,
    required int categoryId,
    String? description,
  }) async {
    state = state.copyWith(
      isActionLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final updatedPhoto = await photoService.updatePhoto(
        photoId: photoId,
        title: title,
        categoryId: categoryId,
        description: description,
      );

      final updatedList = state.userPhotos.map((p) {
        if (p.idPhoto.toString() == photoId.toString()) {
          return updatedPhoto;
        }
        return p;
      }).toList();

      state = state.copyWith(
        userPhotos: updatedList,
        isActionLoading: false,
        actionSuccessMessage: 'Karya foto berhasil diperbarui!',
      );

      // Refresh feed in background so title/category stay synchronized
      ref.read(feedProvider.notifier).fetchFeed(isRefresh: true);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Gagal memperbarui karya foto. Silakan coba lagi.',
      );
      return false;
    }
  }

  Future<bool> deletePhoto(dynamic photoId) async {
    state = state.copyWith(
      isActionLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await photoService.deletePhoto(photoId);

      final filteredList = state.userPhotos
          .where((p) => p.idPhoto.toString() != photoId.toString())
          .toList();

      state = state.copyWith(
        userPhotos: filteredList,
        isActionLoading: false,
        actionSuccessMessage: 'Karya foto berhasil dihapus.',
      );

      // Refresh feed in background to remove the deleted photo
      ref.read(feedProvider.notifier).fetchFeed(isRefresh: true);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Gagal menghapus karya foto. Silakan coba lagi.',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

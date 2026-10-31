import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/photo_model.dart';
import '../services/api_exception.dart';
import '../services/photo_service.dart';
import 'feed_provider.dart';

class PhotoDetailState {
  final PhotoModel? photo;
  final bool isLoading;
  final String? errorMessage;

  const PhotoDetailState({
    this.photo,
    this.isLoading = false,
    this.errorMessage,
  });

  PhotoDetailState copyWith({
    PhotoModel? photo,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PhotoDetailState(
      photo: photo ?? this.photo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final photoDetailProvider = StateNotifierProvider.family
    .autoDispose<PhotoDetailNotifier, PhotoDetailState, int>((ref, photoId) {
      final photoService = ref.watch(photoServiceProvider);
      return PhotoDetailNotifier(
        photoService: photoService,
        photoId: photoId,
        ref: ref,
      );
    });

class PhotoDetailNotifier extends StateNotifier<PhotoDetailState> {
  final PhotoService photoService;
  final int photoId;
  final Ref ref;

  PhotoDetailNotifier({
    required this.photoService,
    required this.photoId,
    required this.ref,
  }) : super(const PhotoDetailState()) {
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final photo = await photoService.getPhotoDetail(photoId);
      state = state.copyWith(photo: photo, isLoading: false, clearError: true);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat detail foto. Silakan coba lagi.',
      );
    }
  }

  Future<void> toggleLike() async {
    final currentPhoto = state.photo;
    if (currentPhoto == null) return;

    final originalIsLiked = currentPhoto.isLiked;
    final originalCount = currentPhoto.likesCount;

    final optimisticIsLiked = !originalIsLiked;
    final optimisticCount = optimisticIsLiked
        ? originalCount + 1
        : (originalCount > 0 ? originalCount - 1 : 0);

    // Optimistic local update
    state = state.copyWith(
      photo: currentPhoto.copyWith(
        isLiked: optimisticIsLiked,
        likesCount: optimisticCount,
      ),
    );

    // Also update feed provider if photo exists there
    ref.read(feedProvider.notifier).toggleLike(photoId);

    try {
      final res = await photoService.toggleLike(photoId);
      final actualIsLiked = res['is_liked'] as bool? ?? optimisticIsLiked;
      final actualCount = res['likes_count'] as int? ?? optimisticCount;

      if (state.photo != null) {
        state = state.copyWith(
          photo: state.photo!.copyWith(
            isLiked: actualIsLiked,
            likesCount: actualCount,
          ),
        );
      }
    } catch (_) {
      // Revert if error
      if (state.photo != null) {
        state = state.copyWith(
          photo: state.photo!.copyWith(
            isLiked: originalIsLiked,
            likesCount: originalCount,
          ),
        );
      }
    }
  }
}

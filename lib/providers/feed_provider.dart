import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/photo_model.dart';
import '../services/api_exception.dart';
import '../services/photo_service.dart';

class FeedState {
  final List<PhotoModel> photos;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final dynamic selectedCategoryId;
  final String feedTab; // 'explore' or 'following'

  const FeedState({
    this.photos = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.selectedCategoryId = 'all',
    this.feedTab = 'explore',
  });

  FeedState copyWith({
    List<PhotoModel>? photos,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    dynamic selectedCategoryId,
    String? feedTab,
    bool clearError = false,
  }) {
    return FeedState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      feedTab: feedTab ?? this.feedTab,
    );
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final photoService = ref.watch(photoServiceProvider);
  return FeedNotifier(photoService);
});

class FeedNotifier extends StateNotifier<FeedState> {
  final PhotoService _photoService;

  FeedNotifier(this._photoService) : super(const FeedState()) {
    fetchFeed();
  }

  Future<void> fetchFeed({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, clearError: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final photos = await _photoService.getPhotos(
        feed: state.feedTab,
        categoryId: state.selectedCategoryId == 'all'
            ? null
            : state.selectedCategoryId,
      );

      state = state.copyWith(
        photos: photos,
        isLoading: false,
        isRefreshing: false,
        clearError: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: 'Gagal memuat karya foto. Silakan coba lagi.',
      );
    }
  }

  void selectCategory(dynamic categoryId) {
    if (state.selectedCategoryId == categoryId) return;
    state = state.copyWith(selectedCategoryId: categoryId);
    fetchFeed();
  }

  void setFeedTab(String tab) {
    if (state.feedTab == tab) return;
    state = state.copyWith(feedTab: tab);
    fetchFeed();
  }

  Future<void> toggleLike(dynamic photoId) async {
    // 1. Optimistic local state update
    final index = state.photos.indexWhere(
      (p) => p.idPhoto.toString() == photoId.toString(),
    );
    if (index == -1) return;

    final targetPhoto = state.photos[index];
    final originalIsLiked = targetPhoto.isLiked;
    final originalCount = targetPhoto.likesCount;

    final optimisticIsLiked = !originalIsLiked;
    final optimisticCount = optimisticIsLiked
        ? originalCount + 1
        : (originalCount > 0 ? originalCount - 1 : 0);

    final updatedPhotos = List<PhotoModel>.from(state.photos);
    updatedPhotos[index] = targetPhoto.copyWith(
      isLiked: optimisticIsLiked,
      likesCount: optimisticCount,
    );
    state = state.copyWith(photos: updatedPhotos);

    // 2. Call backend API
    try {
      final res = await _photoService.toggleLike(photoId);
      final actualIsLiked = res['is_liked'] as bool? ?? optimisticIsLiked;
      final actualCount = res['likes_count'] as int? ?? optimisticCount;

      final verifiedPhotos = List<PhotoModel>.from(state.photos);
      final verifiedIndex = verifiedPhotos.indexWhere(
        (p) => p.idPhoto.toString() == photoId.toString(),
      );
      if (verifiedIndex != -1) {
        verifiedPhotos[verifiedIndex] = verifiedPhotos[verifiedIndex].copyWith(
          isLiked: actualIsLiked,
          likesCount: actualCount,
        );
        state = state.copyWith(photos: verifiedPhotos);
      }
    } catch (_) {
      // Revert on error
      final revertedPhotos = List<PhotoModel>.from(state.photos);
      final revertIndex = revertedPhotos.indexWhere(
        (p) => p.idPhoto.toString() == photoId.toString(),
      );
      if (revertIndex != -1) {
        revertedPhotos[revertIndex] = targetPhoto.copyWith(
          isLiked: originalIsLiked,
          likesCount: originalCount,
        );
        state = state.copyWith(photos: revertedPhotos);
      }
    }
  }
}

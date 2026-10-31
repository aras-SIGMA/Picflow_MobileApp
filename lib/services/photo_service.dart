import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../models/photo_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

final photoServiceProvider = Provider<PhotoService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PhotoService(apiService: apiService);
});

class PhotoService {
  final ApiService apiService;

  PhotoService({required this.apiService});

  /// Fetch all available photographic genre categories
  Future<List<CategoryModel>> getCategories() async {
    final response = await apiService.get(AppConstants.categories, auth: false);

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList
        .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Fetch feed photos with optional feed filter ('explore', 'trending', 'following') and category ID.
  Future<List<PhotoModel>> getPhotos({
    String feed = 'explore',
    dynamic categoryId,
    String? userId,
  }) async {
    final queryParams = <String, dynamic>{'feed': feed};

    if (categoryId != null &&
        categoryId != 'all' &&
        categoryId.toString().isNotEmpty) {
      queryParams['category_id'] = categoryId;
    }

    if (userId != null && userId.isNotEmpty) {
      queryParams['user_id'] = userId;
    }

    final response = await apiService.get(
      AppConstants.photos,
      queryParameters: queryParams,
      auth: true,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList
        .map((item) => PhotoModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Toggle like status on a photo.
  Future<Map<String, dynamic>> toggleLike(dynamic photoId) async {
    final response = await apiService.post(
      AppConstants.photoLike(photoId),
      auth: true,
    );
    return response['data'] as Map<String, dynamic>? ?? {};
  }
}

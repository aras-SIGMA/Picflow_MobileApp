import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../services/photo_service.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final photoService = ref.watch(photoServiceProvider);
  return await photoService.getCategories();
});

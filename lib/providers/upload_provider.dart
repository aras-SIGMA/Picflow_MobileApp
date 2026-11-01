import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/photo_model.dart';
import '../services/api_exception.dart';
import '../services/photo_service.dart';

class UploadState {
  final File? selectedImage;
  final int? selectedCategoryId;
  final bool isUploading;
  final String? errorMessage;
  final bool isSuccess;
  final PhotoModel? uploadedPhoto;

  const UploadState({
    this.selectedImage,
    this.selectedCategoryId,
    this.isUploading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.uploadedPhoto,
  });

  UploadState copyWith({
    File? selectedImage,
    bool clearImage = false,
    int? selectedCategoryId,
    bool clearCategory = false,
    bool? isUploading,
    String? errorMessage,
    bool clearError = false,
    bool? isSuccess,
    PhotoModel? uploadedPhoto,
    bool clearUploadedPhoto = false,
  }) {
    return UploadState(
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      isUploading: isUploading ?? this.isUploading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      uploadedPhoto: clearUploadedPhoto
          ? null
          : (uploadedPhoto ?? this.uploadedPhoto),
    );
  }
}

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

final uploadProvider =
    StateNotifierProvider.autoDispose<UploadNotifier, UploadState>((ref) {
      final photoService = ref.watch(photoServiceProvider);
      final imagePicker = ref.watch(imagePickerProvider);
      return UploadNotifier(
        photoService: photoService,
        imagePicker: imagePicker,
      );
    });

class UploadNotifier extends StateNotifier<UploadState> {
  final PhotoService photoService;
  final ImagePicker _imagePicker;

  UploadNotifier({required this.photoService, ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker(),
      super(const UploadState());

  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 3840,
        maxHeight: 3840,
        imageQuality: 95,
      );

      if (picked != null) {
        state = state.copyWith(
          selectedImage: File(picked.path),
          clearError: true,
          isSuccess: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Gagal mengambil gambar: ${e.toString()}',
      );
    }
  }

  void setImage(File? file) {
    if (file == null) {
      state = state.copyWith(clearImage: true);
    } else {
      state = state.copyWith(selectedImage: file, clearError: true);
    }
  }

  void clearImage() {
    state = state.copyWith(clearImage: true);
  }

  void setCategory(int? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId, clearError: true);
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  Future<bool> upload({required String title, String? description}) async {
    final trimmedTitle = title.trim();

    if (state.selectedImage == null) {
      state = state.copyWith(errorMessage: 'Pilih foto terlebih dahulu');
      return false;
    }

    if (trimmedTitle.isEmpty) {
      state = state.copyWith(errorMessage: 'Judul foto wajib diisi');
      return false;
    }

    if (state.selectedCategoryId == null) {
      state = state.copyWith(errorMessage: 'Kategori foto wajib dipilih');
      return false;
    }

    state = state.copyWith(
      isUploading: true,
      clearError: true,
      isSuccess: false,
    );

    try {
      final photo = await photoService.uploadPhoto(
        imageFile: state.selectedImage!,
        title: trimmedTitle,
        categoryId: state.selectedCategoryId!,
        description: description?.trim(),
      );

      state = state.copyWith(
        isUploading: false,
        isSuccess: true,
        uploadedPhoto: photo,
        clearImage: true,
        clearCategory: true,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isUploading: false, errorMessage: e.toString());
      return false;
    } catch (e, stackTrace) {
      debugPrint('Upload error: $e\n$stackTrace');
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Terjadi kesalahan saat mengunggah foto: $e',
      );
      return false;
    }
  }

  void reset() {
    state = const UploadState();
  }
}

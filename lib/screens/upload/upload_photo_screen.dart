import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/category_model.dart';
import '../../providers/categories_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/upload_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_typography.dart';

class UploadPhotoScreen extends ConsumerStatefulWidget {
  final VoidCallback? onUploadSuccess;

  const UploadPhotoScreen({super.key, this.onUploadSuccess});

  @override
  ConsumerState<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends ConsumerState<UploadPhotoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pilih Sumber Foto', style: AppTypography.heading),
                const SizedBox(height: 8),
                Text(
                  'Gunakan foto asli untuk mempertahankan metadata teknis kamera (EXIF).',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    'Ambil Foto dari Kamera',
                    style: AppTypography.subheading,
                  ),
                  subtitle: Text(
                    'Buka kamera bawaan perangkat',
                    style: AppTypography.caption,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ref
                        .read(uploadProvider.notifier)
                        .pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    'Pilih dari Galeri',
                    style: AppTypography.subheading,
                  ),
                  subtitle: Text(
                    'Pilih karya resolusi tinggi dari penyimpanan',
                    style: AppTypography.caption,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ref
                        .read(uploadProvider.notifier)
                        .pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(uploadProvider.notifier)
        .upload(
          title: _titleController.text,
          description: _descriptionController.text,
        );

    if (success && mounted) {
      _titleController.clear();
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto berhasil dipublikasikan ke PicFlow!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      // Invalidate & refresh feed and profile portfolio so the new photo shows up immediately
      ref.read(feedProvider.notifier).fetchFeed(isRefresh: true);
      ref.read(profileProvider.notifier).fetchUserPhotos();

      // Trigger navigation callback if provided
      widget.onUploadSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Studio Kurasi', style: AppTypography.subheading),
        actions: [
          if (uploadState.selectedImage != null && !uploadState.isUploading)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              tooltip: 'Hapus Foto',
              onPressed: () {
                ref.read(uploadProvider.notifier).clearImage();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Picker Container
                _buildImagePicker(uploadState.selectedImage),
                const SizedBox(height: 24),

                // Error Banner if present
                if (uploadState.errorMessage != null) ...[
                  _buildErrorBanner(uploadState.errorMessage!),
                  const SizedBox(height: 20),
                ],

                // Title Input
                Text('Judul Karya *', style: AppTypography.subheading),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  enabled: !uploadState.isUploading,
                  decoration: const InputDecoration(
                    hintText: 'Misal: Golden Hour di Savana Bromo',
                    prefixIcon: Icon(Icons.title, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul foto wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category Dropdown
                Text('Kategori Fotografi *', style: AppTypography.subheading),
                const SizedBox(height: 8),
                _buildCategoryDropdown(
                  categoriesAsync,
                  uploadState.selectedCategoryId,
                  uploadState.isUploading,
                ),
                const SizedBox(height: 20),

                // Description Input
                Text(
                  'Deskripsi & Cerita di Balik Lensa',
                  style: AppTypography.subheading,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !uploadState.isUploading,
                  maxLines: 4,
                  minLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Ceritakan konsep pemotretan, lokasi, atau momen berharga saat menekan shutter...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),

                // EXIF Notice Tip
                _buildExifNotice(),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: uploadState.isUploading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: uploadState.isUploading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Mengunggah & Mengekstrak EXIF...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined),
                            SizedBox(width: 8),
                            Text('Publikasikan Karya'),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(File? selectedImage) {
    if (selectedImage == null) {
      return GestureDetector(
        onTap: _showImagePickerModal,
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.surfaceBorder,
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceElevated,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sentuh untuk Memilih Foto',
                style: AppTypography.subheading,
              ),
              const SizedBox(height: 6),
              Text(
                'Mendukung JPG, JPEG, PNG (Maks 10MB)',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Image.file(
                  selectedImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: AppColors.surfaceSubtle,
                      child: Center(
                        child: Text(
                          'Gagal menampilkan preview',
                          style: AppTypography.caption,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _showImagePickerModal,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ganti Foto',
                              style: AppTypography.metadata.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedImage.path.split(Platform.pathSeparator).last,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(
    AsyncValue<List<CategoryModel>> categoriesAsync,
    int? selectedCategoryId,
    bool isUploading,
  ) {
    return categoriesAsync.when(
      data: (categories) {
        return DropdownButtonFormField<int>(
          key: const ValueKey('category_dropdown'),
          initialValue: selectedCategoryId,
          hint: const Text('Pilih genre fotografi'),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.category_outlined, size: 20),
          ),
          items: categories.map((cat) {
            return DropdownMenuItem<int>(
              value: cat.idCategory,
              child: Text(cat.name),
            );
          }).toList(),
          onChanged: isUploading
              ? null
              : (val) {
                  ref.read(uploadProvider.notifier).setCategory(val);
                },
          validator: (value) {
            if (value == null) {
              return 'Kategori foto wajib dipilih';
            }
            return null;
          },
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text('Memuat kategori...', style: AppTypography.caption),
          ],
        ),
      ),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.danger),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 20, color: AppColors.danger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Gagal memuat kategori genre',
                style: AppTypography.caption.copyWith(color: AppColors.danger),
              ),
            ),
            TextButton(
              onPressed: () => ref.refresh(categoriesProvider),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.danger,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(color: AppColors.danger),
            ),
          ),
          InkWell(
            onTap: () {
              ref.read(uploadProvider.notifier).clearError();
            },
            child: const Icon(Icons.close, size: 18, color: AppColors.danger),
          ),
        ],
      ),
    );
  }

  Widget _buildExifNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ekstraksi Otomatis EXIF',
                  style: AppTypography.subheading.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sistem akan otomatis mengekstrak metadata kamera (Make, Model, Lensa, Aperture, Shutter, ISO) langsung dari file foto tanpa perlu diinput manual.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

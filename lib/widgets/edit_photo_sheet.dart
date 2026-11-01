import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/photo_model.dart';
import '../providers/categories_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';

class EditPhotoSheet extends ConsumerStatefulWidget {
  final PhotoModel photo;
  final VoidCallback? onSaved;

  const EditPhotoSheet({super.key, required this.photo, this.onSaved});

  static Future<void> show(
    BuildContext context, {
    required PhotoModel photo,
    VoidCallback? onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => EditPhotoSheet(photo: photo, onSaved: onSaved),
    );
  }

  @override
  ConsumerState<EditPhotoSheet> createState() => _EditPhotoSheetState();
}

class _EditPhotoSheetState extends ConsumerState<EditPhotoSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.photo.title);
    _descriptionController = TextEditingController(
      text: widget.photo.description ?? '',
    );
    _selectedCategoryId = widget.photo.idCategory;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final success = await ref
        .read(profileProvider.notifier)
        .updatePhoto(
          photoId: widget.photo.idPhoto,
          title: _titleController.text,
          categoryId: _selectedCategoryId!,
          description: _descriptionController.text,
        );

    if (success && mounted) {
      navigator.pop();
      widget.onSaved?.call();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Metadata karya berhasil diperbarui!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final profileState = ref.watch(profileProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text('Edit Metadata Karya', style: AppTypography.heading),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title Input
                Text('Judul Karya *', style: AppTypography.subheading),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Judul foto',
                    prefixIcon: Icon(Icons.title, size: 20),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Judul foto wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                Text('Kategori Fotografi *', style: AppTypography.subheading),
                const SizedBox(height: 8),
                categoriesAsync.when(
                  data: (categories) {
                    final validCategory = categories.any(
                      (c) => c.idCategory == _selectedCategoryId,
                    );
                    if (!validCategory && categories.isNotEmpty) {
                      _selectedCategoryId = categories.first.idCategory;
                    }

                    return DropdownButtonFormField<int>(
                      initialValue: _selectedCategoryId,
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
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                        });
                      },
                      validator: (val) {
                        if (val == null) return 'Kategori wajib dipilih';
                        return null;
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, st) => Text(
                    'Gagal memuat kategori',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description Input
                Text('Deskripsi & Cerita', style: AppTypography.subheading),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Ceritakan narasi di balik lensa...',
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                ElevatedButton(
                  onPressed: profileState.isActionLoading ? null : _handleSave,
                  child: profileState.isActionLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan Perubahan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/photo_model.dart';
import '../../providers/photo_detail_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_typography.dart';
import '../../utils/constants.dart';
import '../../widgets/exif_metadata_panel.dart';

class PhotoDetailScreen extends ConsumerStatefulWidget {
  final int photoId;
  final PhotoModel? initialPhoto;

  const PhotoDetailScreen({
    super.key,
    required this.photoId,
    this.initialPhoto,
  });

  @override
  ConsumerState<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends ConsumerState<PhotoDetailScreen> {
  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  void _copyShareDetails(PhotoModel photo) {
    final text =
        '${photo.title} by @${photo.creator?.username ?? "Creator"}\n'
        'Gear: ${photo.cameraBadgeText}\n'
        'View on PicFlow: ${AppConstants.fileBaseUrl}/photos/${photo.idPhoto}';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Metadata foto disalin ke clipboard!',
          style: AppTypography.caption.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(photoDetailProvider(widget.photoId));
    final photo = detailState.photo ?? widget.initialPhoto;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          photo?.title ?? 'Karya Fotografi',
          style: AppTypography.subheading.copyWith(fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (photo != null)
            IconButton(
              icon: const Icon(Icons.share_outlined, size: 20),
              tooltip: 'Bagikan Metadata',
              onPressed: () => _copyShareDetails(photo),
            ),
        ],
      ),
      body: SafeArea(child: _buildBody(context, detailState, photo)),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PhotoDetailState state,
    PhotoModel? photo,
  ) {
    if (state.isLoading && photo == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat detail sRGB & data optik...',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (state.errorMessage != null && photo == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.danger,
              ),
              const SizedBox(height: 12),
              Text('Gagal Memuat Foto', style: AppTypography.heading),
              const SizedBox(height: 6),
              Text(
                state.errorMessage!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(photoDetailProvider(widget.photoId).notifier)
                      .fetchDetail();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (photo == null) {
      return const Center(child: Text('Foto tidak ditemukan'));
    }

    final targetImageUrl = AppConstants.resolveImageUrl(
      photo.highResUrl.isNotEmpty
          ? photo.highResUrl
          : (photo.mediumUrl.isNotEmpty ? photo.mediumUrl : photo.imageUrl),
    );

    final avatarUrl = AppConstants.resolveImageUrl(photo.creator?.avatarUrl);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. High-Resolution Interactive Viewer Stage
          Stack(
            children: [
              Container(
                width: double.infinity,
                color: Colors.black,
                child: AspectRatio(
                  aspectRatio:
                      (photo.width != null &&
                          photo.height != null &&
                          photo.height! > 0)
                      ? (photo.width! / photo.height!).clamp(0.6, 2.0)
                      : 4 / 3,
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    minScale: 1.0,
                    maxScale: 4.0,
                    clipBehavior: Clip.hardEdge,
                    child: CachedNetworkImage(
                      imageUrl: targetImageUrl,
                      fit: BoxFit.contain,
                      memCacheWidth: 2048,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white54,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Floating Controls & Zoom Indicators
              Positioned(
                bottom: 12,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(160),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.pinch_outlined,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pinch to zoom (up to 4x)',
                        style: AppTypography.metadata.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 12,
                child: IconButton(
                  icon: const Icon(
                    Icons.center_focus_strong_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  tooltip: 'Reset Zoom',
                  onPressed: _resetZoom,
                ),
              ),
            ],
          ),

          // 2. Creator Info Strip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surfaceBorder,
                      width: 1.5,
                    ),
                    image: avatarUrl.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(avatarUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: avatarUrl.isEmpty
                      ? const Icon(
                          Icons.person_outline_rounded,
                          size: 24,
                          color: AppColors.textMuted,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo.creator?.username ?? 'Creator',
                        style: AppTypography.subheading.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        photo.formattedTakenAt != 'N/A'
                            ? 'Taken: ${photo.formattedTakenAt}'
                            : 'Published on PicFlow',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textFaint,
                        ),
                      ),
                    ],
                  ),
                ),
                if (photo.categoryName != null &&
                    photo.categoryName!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: AppColors.surfaceBorder,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      photo.categoryName!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 3. Social Interaction Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder, width: 1),
              ),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      ref
                          .read(photoDetailProvider(widget.photoId).notifier)
                          .toggleLike();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            photo.isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 22,
                            color: photo.isLiked
                                ? AppColors.danger
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            photo.likesCount.toString(),
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: photo.isLiked
                                  ? AppColors.danger
                                  : AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        photo.commentsCount.toString(),
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (photo.isOwner)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFBFDBFE),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Your Photo',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 4. Title & Story Behind Shot
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.title,
                  style: AppTypography.heading.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                if (photo.description != null &&
                    photo.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    photo.description!,
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textMuted,
                      height: 1.55,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 5. Technical EXIF Optical Specification Panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ExifMetadataPanel(photo: photo),
          ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }
}

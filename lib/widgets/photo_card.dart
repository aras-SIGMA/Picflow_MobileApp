import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/photo_model.dart';
import '../providers/feed_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';
import '../utils/constants.dart';

class PhotoCard extends ConsumerWidget {
  final PhotoModel photo;
  final VoidCallback? onTap;

  const PhotoCard({super.key, required this.photo, this.onTap});

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Recent';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (_) {
      return 'Recent';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageTargetUrl = AppConstants.resolveImageUrl(
      photo.mediumUrl.isNotEmpty
          ? photo.mediumUrl
          : (photo.thumbnailUrl.isNotEmpty
                ? photo.thumbnailUrl
                : photo.imageUrl),
    );

    final avatarUrl = AppConstants.resolveImageUrl(photo.creator?.avatarUrl);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Creator Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surfaceBorder,
                      width: 1,
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
                          size: 18,
                          color: AppColors.textMuted,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo.creator?.username ?? 'Creator',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatDate(photo.createdAt),
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
                      horizontal: 10,
                      vertical: 4,
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
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Photo Visual Media
          GestureDetector(
            onTap: onTap,
            child: AspectRatio(
              aspectRatio:
                  (photo.width != null &&
                      photo.height != null &&
                      photo.height! > 0)
                  ? (photo.width! / photo.height!).clamp(0.75, 1.8)
                  : 4 / 3,
              child: Container(
                color: AppColors.imagePlaceholder,
                child: CachedNetworkImage(
                  imageUrl: imageTargetUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 1080,
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary.withAlpha(150),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textFaint,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // EXIF Optical Metadata Pill Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.surfaceSubtle,
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceBorder, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    photo.cameraBadgeText,
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.textMain,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Content & Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.title,
                  style: AppTypography.subheading.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (photo.description != null &&
                    photo.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    photo.description!,
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),

                // Social Engagement Row
                Row(
                  children: [
                    // Like button
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        ref
                            .read(feedProvider.notifier)
                            .toggleLike(photo.idPhoto);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              photo.isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 20,
                              color: photo.isLiked
                                  ? AppColors.danger
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              photo.likesCount.toString(),
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: photo.isLiked
                                    ? AppColors.danger
                                    : AppColors.textMain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Comments count
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            photo.commentsCount.toString(),
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Detail arrow
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'View EXIF',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

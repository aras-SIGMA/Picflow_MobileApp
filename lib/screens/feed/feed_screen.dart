import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/feed_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_typography.dart';
import '../../widgets/category_pill_list.dart';
import '../../widgets/photo_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pic',
              style: AppTypography.heading.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  AppColors.danger,
                  AppColors.success,
                  AppColors.primary,
                ],
              ).createShader(bounds),
              child: Text(
                'Flow',
                style: AppTypography.heading.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FeedTabButton(
                  title: 'Explore',
                  isActive: feedState.feedTab == 'explore',
                  onTap: () {
                    ref.read(feedProvider.notifier).setFeedTab('explore');
                  },
                ),
                const SizedBox(width: 8),
                _FeedTabButton(
                  title: 'Following',
                  isActive: feedState.feedTab == 'following',
                  onTap: () {
                    ref.read(feedProvider.notifier).setFeedTab('following');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const CategoryPillList(),
            const SizedBox(height: 12),
            Expanded(child: _buildFeedContent(context, ref, feedState)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedContent(
    BuildContext context,
    WidgetRef ref,
    FeedState state,
  ) {
    if (state.isLoading && state.photos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Loading sRGB curated works...',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (state.errorMessage != null && state.photos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: AppColors.textFaint,
              ),
              const SizedBox(height: 12),
              Text(
                'Gagal Menghubungkan ke Feed',
                style: AppTypography.subheading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
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
                  ref.read(feedProvider.notifier).fetchFeed();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.photos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: AppColors.textFaint,
              ),
              const SizedBox(height: 12),
              Text('Belum Ada Foto', style: AppTypography.subheading),
              const SizedBox(height: 6),
              Text(
                state.feedTab == 'following'
                    ? 'Ikuti fotografer favorit Anda untuk melihat karya mereka di sini.'
                    : 'Belum ada karya foto untuk kategori ini.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceElevated,
      onRefresh: () =>
          ref.read(feedProvider.notifier).fetchFeed(isRefresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.photos.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final photo = state.photos[index];
          return PhotoCard(
            photo: photo,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Detail Foto "${photo.title}" siap di Sprint 4.',
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FeedTabButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _FeedTabButton({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surfaceElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isActive ? AppColors.surfaceBorder : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_typography.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Profile Showcase Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surfaceBorder,
                            width: 1.5,
                          ),
                          image:
                              user?.profilePictureUrl != null &&
                                  user!.profilePictureUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(
                                    AppConstants.resolveImageUrl(
                                      user.profilePictureUrl,
                                    ),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            user?.profilePictureUrl == null ||
                                user!.profilePictureUrl!.isEmpty
                            ? const Icon(
                                Icons.person_outline_rounded,
                                size: 36,
                                color: AppColors.textMuted,
                              )
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user?.username ?? 'Creator',
                        style: AppTypography.heading,
                      ),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '', style: AppTypography.caption),
                      const SizedBox(height: 10),

                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user?.isAdmin == true
                              ? const Color(0xFFFEF3C7)
                              : AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: user?.isAdmin == true
                                ? const Color(0xFFFCD34D)
                                : AppColors.surfaceBorder,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          user?.isAdmin == true
                              ? 'ADMIN CURATOR'
                              : 'PHOTOGRAPHER',
                          style: AppTypography.metadata.copyWith(
                            color: user?.isAdmin == true
                                ? const Color(0xFF92400E)
                                : AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          user.bio!,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyRegular.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sprint 2 Success Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Authentication Active',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF065F46),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Session persisted securely via Android Keystore. Ready for Sprint 3 (Feed & Discovery).',
                            style: AppTypography.caption.copyWith(
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Sign Out',
                variant: ButtonVariant.outline,
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/categories_provider.dart';
import '../providers/feed_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';

class CategoryPillList extends ConsumerWidget {
  const CategoryPillList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategoryId = ref.watch(
      feedProvider.select((s) => s.selectedCategoryId),
    );

    return SizedBox(
      height: 40,
      child: categoriesAsync.when(
        data: (categories) {
          final allPills = [
            _PillItem(id: 'all', label: 'All Genres'),
            ...categories.map(
              (c) => _PillItem(id: c.idCategory, label: c.name),
            ),
          ];

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: allPills.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final pill = allPills[index];
              final isSelected =
                  selectedCategoryId.toString() == pill.id.toString();

              return GestureDetector(
                onTap: () {
                  ref.read(feedProvider.notifier).selectCategory(pill.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceBorder,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      pill.label,
                      style: AppTypography.caption.copyWith(
                        color: isSelected ? Colors.white : AppColors.textMain,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) => Container(
            width: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
        ),
        error: (error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}

class _PillItem {
  final dynamic id;
  final String label;

  const _PillItem({required this.id, required this.label});
}

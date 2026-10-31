import 'package:flutter/material.dart';

import '../models/photo_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';

class ExifMetadataPanel extends StatelessWidget {
  final PhotoModel photo;

  const ExifMetadataPanel({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    final cameraParts = [
      photo.cameraMake,
      photo.cameraModel,
    ].where((s) => s != null && s.trim().isNotEmpty).join(' ');
    final cameraValue = cameraParts.isEmpty ? 'N/A' : cameraParts;

    final lensValue = (photo.lens != null && photo.lens!.trim().isNotEmpty)
        ? photo.lens!
        : 'N/A';

    final focalValue =
        (photo.focalLength != null && photo.focalLength!.trim().isNotEmpty)
        ? photo.focalLength!
        : 'N/A';

    final apertureValue =
        (photo.aperture != null && photo.aperture!.trim().isNotEmpty)
        ? photo.aperture!
        : 'N/A';

    final shutterValue =
        (photo.shutterSpeed != null && photo.shutterSpeed!.trim().isNotEmpty)
        ? photo.shutterSpeed!
        : 'N/A';

    final isoValue = (photo.iso != null && photo.iso!.trim().isNotEmpty)
        ? (photo.iso!.toUpperCase().startsWith('ISO')
              ? photo.iso!
              : 'ISO ${photo.iso}')
        : 'N/A';

    final dimensionsValue = (photo.width != null && photo.height != null)
        ? '${photo.width} × ${photo.height} px'
        : 'N/A';

    final timestampValue = photo.formattedTakenAt;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
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
                  ),
                  child: const Icon(
                    Icons.camera_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Optical Specifications',
                        style: AppTypography.subheading.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Automatic EXIF hardware extraction',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textFaint,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.surfaceBorder,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'sRGB',
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 14),

            // Metadata Grid Rows
            _buildExifRow(
              icon: Icons.camera_alt_outlined,
              label: 'Camera Body',
              value: cameraValue,
            ),
            const SizedBox(height: 12),
            _buildExifRow(
              icon: Icons.filter_center_focus_outlined,
              label: 'Lens Model',
              value: lensValue,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildExifCompactItem(
                    icon: Icons.album_outlined,
                    label: 'Aperture',
                    value: apertureValue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildExifCompactItem(
                    icon: Icons.shutter_speed_outlined,
                    label: 'Shutter',
                    value: shutterValue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildExifCompactItem(
                    icon: Icons.iso_outlined,
                    label: 'Sensitivity',
                    value: isoValue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildExifCompactItem(
                    icon: Icons.straighten_outlined,
                    label: 'Focal Length',
                    value: focalValue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildExifCompactItem(
                    icon: Icons.aspect_ratio_outlined,
                    label: 'Resolution',
                    value: dimensionsValue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildExifCompactItem(
                    icon: Icons.access_time_outlined,
                    label: 'Captured At',
                    value: timestampValue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExifRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isNA = value == 'N/A';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: AppTypography.metadata.copyWith(
                color: isNA ? AppColors.textFaint : AppColors.textMain,
                fontWeight: isNA ? FontWeight.w400 : FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExifCompactItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isNA = value == 'N/A';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.metadata.copyWith(
              color: isNA ? AppColors.textFaint : AppColors.textMain,
              fontWeight: isNA ? FontWeight.w400 : FontWeight.w700,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

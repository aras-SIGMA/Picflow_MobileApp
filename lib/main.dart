import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/app_colors.dart';
import 'utils/app_theme.dart';
import 'utils/app_typography.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PicFlowApp()));
}

class PicFlowApp extends StatelessWidget {
  const PicFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PicFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const BootScreen(),
    );
  }
}

class BootScreen extends StatelessWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pic',
              style: AppTypography.heading.copyWith(fontWeight: FontWeight.w800),
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
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
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'sRGB Standard & Craft',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Curated Photography Community',
                        textAlign: TextAlign.center,
                        style: AppTypography.subheading,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Showcase high-resolution photographs, inspect optical camera EXIF metadata, and engage in constructive critique.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyRegular.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

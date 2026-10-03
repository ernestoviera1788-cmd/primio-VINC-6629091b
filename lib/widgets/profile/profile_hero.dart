import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/profile_photo.dart';

class ProfileHero extends StatelessWidget {
  final String name;
  final String? photo;
  final int photoCount;
  final int maxPhotos;
  final VoidCallback onPreview;
  final VoidCallback onPhotos;

  const ProfileHero({
    super.key,
    required this.name,
    required this.photo,
    required this.photoCount,
    required this.maxPhotos,
    required this.onPreview,
    required this.onPhotos,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final appColors = theme.extension<AppColorsExtension>()!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          children: [
            InkWell(
              customBorder: const CircleBorder(),
              onTap: onPhotos,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingXs),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [colors.primary, appColors.spark]),
                ),
                child: ClipOval(
                  child: ProfilePhoto(
                    source: photo,
                    width: AppTheme.avatarLg,
                    height: AppTheme.avatarLg,
                    cacheWidth: 300,
                    semanticLabel: 'Tu foto principal',
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              name.isEmpty ? 'Tu perfil' : name,
              style: text.headlineSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              '$photoCount de $maxPhotos fotos',
              style: text.bodyMedium?.copyWith(color: appColors.subtleText),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPreview,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Ver cómo me ven los demás'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

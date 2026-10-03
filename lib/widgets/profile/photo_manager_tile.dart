import 'package:flutter/material.dart';

import '../../models/my_photo.dart';
import '../../theme/theme.dart';
import '../common/profile_photo.dart';

class PhotoManagerTile extends StatelessWidget {
  final MyPhoto photo;
  final int index;
  final bool busy;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onSetPrimary;
  final VoidCallback onDelete;

  const PhotoManagerTile({
    super.key,
    required this.photo,
    required this.index,
    required this.busy,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onSetPrimary,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = theme.extension<AppColorsExtension>()!;
    final (statusLabel, statusColor) = switch (photo.state) {
      PhotoStatus.approved => ('Aprobada', colors.tertiary),
      PhotoStatus.pending => ('Pendiente de aprobación', appColors.subtleText),
      PhotoStatus.rejected => ('Rechazada', colors.error),
      PhotoStatus.other => (photo.status.isEmpty ? 'Sin estado' : photo.status, appColors.subtleText),
    };
    final canBePrimary = photo.state == PhotoStatus.approved && !photo.isPrimary && !busy;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingSm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: ProfilePhoto(
                source: photo.url,
                width: AppTheme.avatarLg,
                height: AppTheme.avatarLg,
                cacheWidth: 300,
                semanticLabel: photo.altText ?? 'Foto ${index + 1}',
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(photo.isPrimary ? 'Foto ${index + 1} · Principal' : 'Foto ${index + 1}', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppTheme.spacingXxs),
                  Text(statusLabel, style: theme.textTheme.bodySmall?.copyWith(color: statusColor)),
                  Wrap(
                    children: [
                      IconButton(tooltip: 'Mover antes', onPressed: busy ? null : onMoveUp, icon: const Icon(Icons.arrow_upward_rounded)),
                      IconButton(tooltip: 'Mover después', onPressed: busy ? null : onMoveDown, icon: const Icon(Icons.arrow_downward_rounded)),
                      IconButton(
                        tooltip: photo.state == PhotoStatus.approved ? 'Usar como principal' : 'Solo una foto aprobada puede ser la principal',
                        onPressed: canBePrimary ? onSetPrimary : null,
                        icon: Icon(photo.isPrimary ? Icons.star_rounded : Icons.star_outline_rounded),
                      ),
                      IconButton(tooltip: 'Eliminar foto', onPressed: busy ? null : onDelete, icon: const Icon(Icons.delete_outline_rounded)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

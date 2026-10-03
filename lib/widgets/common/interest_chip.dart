import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class InterestChip extends StatelessWidget {
  final String label;
  final bool highlighted;
  final bool onPhoto;

  const InterestChip({super.key, required this.label, this.highlighted = false, this.onPhoto = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = theme.extension<AppColorsExtension>()!;

    final Color bg;
    final Color fg;
    if (onPhoto) {
      bg = appColors.onPhoto.withValues(alpha: AppTheme.opacityChipOnPhoto);
      fg = appColors.onPhoto;
    } else if (highlighted) {
      bg = colors.primaryContainer;
      fg = colors.onPrimaryContainer;
    } else {
      bg = colors.surfaceContainerHigh;
      fg = colors.onSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd - 4, vertical: AppTheme.spacingXs + 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (highlighted || onPhoto) ...[
            Icon(Icons.auto_awesome_rounded, size: AppTheme.iconSm - 2, color: fg),
            const SizedBox(width: AppTheme.spacingXs),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

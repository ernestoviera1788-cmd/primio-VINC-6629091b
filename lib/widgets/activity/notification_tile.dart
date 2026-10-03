import 'package:flutter/material.dart';

import '../../models/app_notification.dart';
import '../../theme/theme.dart';
import '../common/time_format.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationTile({super.key, required this.notification, required this.onTap});

  IconData get _icon {
    final t = notification.type.toUpperCase();
    if (t.contains('MATCH')) return Icons.all_inclusive_rounded;
    if (t.contains('MESSAGE')) return Icons.chat_bubble_outline_rounded;
    if (t.contains('SUPER')) return Icons.auto_awesome_rounded;
    if (t.contains('LIKE')) return Icons.favorite_outline_rounded;
    if (t.contains('SAFETY') || t.contains('SECURITY')) return Icons.shield_outlined;
    return Icons.notifications_none_rounded;
  }

  (Color, Color) _tone(ColorScheme c) {
    final t = notification.type.toUpperCase();
    if (t.contains('MATCH')) return (c.primaryContainer, c.onPrimaryContainer);
    if (t.contains('MESSAGE')) return (c.secondaryContainer, c.onSecondaryContainer);
    if (t.contains('LIKE')) return (c.tertiaryContainer, c.onTertiaryContainer);
    return (c.surfaceContainerHighest, c.onSurface);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final appColors = theme.extension<AppColorsExtension>()!;
    final n = notification;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppTheme.thumbnailSize,
                height: AppTheme.thumbnailSize,
                decoration: BoxDecoration(color: _tone(colors).$1, shape: BoxShape.circle),
                child: Icon(_icon, color: _tone(colors).$2),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title.isEmpty ? 'Aviso' : n.title,
                      style: n.isRead ? text.titleSmall : text.titleSmall?.copyWith(color: colors.primary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (n.body.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spacingXxs),
                      Text(n.body, style: text.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: AppTheme.spacingXxs),
                    Text(relativeTime(n.createdAt), style: text.labelSmall?.copyWith(color: appColors.subtleText)),
                  ],
                ),
              ),
              if (!n.isRead)
                Padding(
                  padding: const EdgeInsets.only(left: AppTheme.spacingSm, top: AppTheme.spacingXs),
                  child: Icon(Icons.circle, size: AppTheme.spacingSm, color: colors.primary, semanticLabel: 'Sin leer'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

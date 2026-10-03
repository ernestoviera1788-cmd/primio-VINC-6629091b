import 'package:flutter/material.dart';

import '../../models/match_item.dart';
import '../../theme/theme.dart';
import 'profile_photo.dart';
import 'time_format.dart';

/// A match row. With [showPreview] it reads as a conversation (last message).
class MatchTile extends StatelessWidget {
  final MatchItem match;
  final bool showPreview;
  final VoidCallback onOpen;
  final VoidCallback onUnmatch;

  const MatchTile({
    super.key,
    required this.match,
    required this.onOpen,
    required this.onUnmatch,
    this.showPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final appColors = theme.extension<AppColorsExtension>()!;
    final p = match.user;
    final last = match.lastMessage;
    final subtitle = showPreview
        ? (last == null ? 'Nuevo vínculo · rompe el hielo' : '${last.mine ? 'Tú: ' : ''}${last.body}')
        : (last == null
            ? 'Vínculo del ${shortDate(match.createdAt)} · aún no hablan'
            : 'Conversación activa · ${relativeTime(last.createdAt)}');

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppTheme.spacingMd, AppTheme.spacingSm, AppTheme.spacingXs, AppTheme.spacingSm),
          child: Row(
            children: [
              ClipOval(
                child: ProfilePhoto(
                  source: p.photos.isEmpty ? null : p.photos.first,
                  width: AppTheme.thumbnailSize,
                  height: AppTheme.thumbnailSize,
                  cacheWidth: 200,
                  semanticLabel: 'Foto de ${p.name}',
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${p.name}, ${p.age}', style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: AppTheme.spacingXxs),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: (last != null && !last.mine)
                          ? text.bodyMedium?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w700)
                          : text.bodyMedium?.copyWith(color: appColors.subtleText),
                    ),
                  ],
                ),
              ),
              if (showPreview) ...[
                const SizedBox(width: AppTheme.spacingSm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(relativeTime(match.lastActivity), style: text.labelSmall?.copyWith(color: appColors.subtleText)),
                    if (last != null && !last.mine) ...[
                      const SizedBox(height: AppTheme.spacingXs),
                      Icon(Icons.circle, size: AppTheme.spacingSm + AppTheme.spacingXxs, color: colors.primary, semanticLabel: 'Por responder'),
                    ],
                  ],
                ),
              ],
              PopupMenuButton<String>(
                tooltip: 'Opciones',
                onSelected: (v) => v == 'chat' ? onOpen() : onUnmatch(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'chat', child: Text('Enviar mensaje')),
                  PopupMenuItem(value: 'unmatch', child: Text('Deshacer vínculo')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/match_item.dart';
import '../../theme/theme.dart';
import '../common/profile_photo.dart';
import '../common/time_format.dart';

/// A match in the grid. The dot means their last message is waiting for you.
class MatchAvatar extends StatelessWidget {
  final MatchItem match;
  final VoidCallback onOpen;
  final VoidCallback onUnmatch;

  const MatchAvatar({super.key, required this.match, required this.onOpen, required this.onUnmatch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final appColors = theme.extension<AppColorsExtension>()!;
    final last = match.lastMessage;
    final theyWrote = last != null && !last.mine;
    final isNew = last == null;
    final highlight = theyWrote || isNew;
    final status = theyWrote ? 'Te escribió' : (isNew ? 'Nuevo' : relativeTime(match.lastActivity));
    final p = match.user;

    return Semantics(
      button: true,
      label: '${p.name}. $status',
      hint: 'Mantén pulsado para deshacer el vínculo',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        onTap: onOpen,
        onLongPress: onUnmatch,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXs),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingXs),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: highlight ? LinearGradient(colors: [colors.primary, appColors.spark]) : null,
                      color: highlight ? null : colors.outlineVariant,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingXxs),
                      decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
                      child: ClipOval(
                        child: ProfilePhoto(
                          source: p.photos.isEmpty ? null : p.photos.first,
                          width: AppTheme.matchAvatar,
                          height: AppTheme.matchAvatar,
                          cacheWidth: 240,
                          semanticLabel: 'Foto de ${p.name}',
                        ),
                      ),
                    ),
                  ),
                  if (theyWrote)
                    Positioned(
                      top: AppTheme.spacingXs,
                      right: AppTheme.spacingXs,
                      child: Container(
                        width: AppTheme.unreadDot,
                        height: AppTheme.unreadDot,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.surface, width: AppTheme.borderThick),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.titleSmall),
              Text(
                status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelMedium?.copyWith(color: theyWrote ? colors.primary : appColors.subtleText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

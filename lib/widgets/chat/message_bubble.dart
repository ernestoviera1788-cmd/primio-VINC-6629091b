import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/chat_message.dart';
import '../../theme/theme.dart';
import '../common/time_format.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final mine = message.mine;
    final fg = mine ? colors.onPrimary : colors.onSurface;
    final readAt = message.readAt;
    final status = readAt != null ? 'Leído a las ${clockTime(readAt)}' : 'Enviado';

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constraints) => ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.78),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingXxs + 1),
            padding: const EdgeInsets.fromLTRB(AppTheme.spacingMd, AppTheme.spacingSm + 2, AppTheme.spacingMd, AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: mine ? colors.primary : colors.surfaceContainerHigh,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppTheme.radiusLarge),
                topRight: const Radius.circular(AppTheme.radiusLarge),
                bottomLeft: Radius.circular(mine ? AppTheme.radiusLarge : AppTheme.spacingXs),
                bottomRight: Radius.circular(mine ? AppTheme.spacingXs : AppTheme.radiusLarge),
              ),
            ),
            child: Column(
              crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(message.body, style: text.bodyLarge?.copyWith(color: fg)),
                const SizedBox(height: AppTheme.spacingXxs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(clockTime(message.createdAt), style: text.labelSmall?.copyWith(color: fg)),
                    if (mine) ...[
                      const SizedBox(width: AppTheme.spacingXs),
                      Tooltip(
                        message: status,
                        child: Icon(
                          readAt != null ? Icons.done_all_rounded : Icons.done_rounded,
                          size: AppTheme.iconSm,
                          color: fg,
                          semanticLabel: status,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 180.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../providers/matches_provider.dart';
import '../providers/notifications_provider.dart';
import '../theme/responsive_layout.dart';
import '../theme/theme.dart';
import '../widgets/chat/chat_composer.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/common/profile_photo.dart';
import '../widgets/common/skeleton.dart';
import '../widgets/common/state_view.dart';
import 'match_actions.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _syncedAfterLoad = false;

  @override
  void initState() {
    super.initState();
    // Clear the Messages tab dot once the user views the conversation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationsProvider>().markConversationRead(widget.conversationId);
      }
    });
  }

  /// After messages load, the backend has marked notifications as read
  /// (listmessages does this server-side). Re-sync local state so the dot
  /// clears even if the earlier mark-read raced with the message fetch.
  void _syncAfterMessagesLoaded(bool isLoading) {
    if (!isLoading && !_syncedAfterLoad && mounted) {
      _syncedAfterLoad = true;
      // Small delay to let the backend's listmessages commit first.
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) context.read<NotificationsProvider>().load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationId = widget.conversationId;
    final chat = context.watch<ChatProvider>();
    _syncAfterMessagesLoaded(chat.isLoading);
    final match = context.watch<MatchesProvider>().byConversation(conversationId);
    final name = match?.user.name ?? 'Chat';
    final messages = chat.messages;
    final padding = ResponsiveLayout.getPadding(context);

    final Widget list;
    if (chat.isLoading) {
      list = const SkeletonList(semanticLabel: 'Cargando mensajes', itemCount: 4);
    } else if (chat.error != null && messages.isEmpty) {
      list = StateView(icon: Icons.cloud_off_rounded, title: 'No pudimos cargar el chat', message: chat.error!, primaryLabel: 'Reintentar', onPrimary: chat.refresh);
    } else if (messages.isEmpty) {
      list = StateView(
        icon: Icons.waving_hand_outlined,
        image: 'assets/images/empty_messages.png',
        title: 'Rompe el hielo',
        message: 'Escribe el primer mensaje a $name. Algo sobre su perfil suele ser un buen comienzo.',
      );
    } else {
      list = ListView.builder(
        reverse: true,
        padding: padding.copyWith(top: AppTheme.spacingSm, bottom: AppTheme.spacingSm),
        itemCount: messages.length,
        itemBuilder: (_, i) => MessageBubble(message: messages[messages.length - 1 - i]),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ClipOval(
              child: ProfilePhoto(
                source: (match == null || match.user.photos.isEmpty) ? null : match.user.photos.first,
                width: AppTheme.iconXl,
                height: AppTheme.iconXl,
                cacheWidth: 120,
                semanticLabel: 'Foto de $name',
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Flexible(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          if (match != null)
            PopupMenuButton<String>(
              tooltip: 'Opciones',
              onSelected: (_) async {
                if (await confirmAndUnmatch(context, match) && context.mounted) context.pop();
              },
              itemBuilder: (_) => const [PopupMenuItem(value: 'unmatch', child: Text('Deshacer vínculo'))],
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveLayout.constrain(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (chat.error != null && messages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  child: InfoBanner(icon: Icons.sync_problem_rounded, message: 'No se pudo actualizar el chat. ${chat.error}'),
                ),
              Expanded(child: list),
              ChatComposer(
                sending: chat.isSending,
                maxLength: 2000,
                onSend: chat.send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

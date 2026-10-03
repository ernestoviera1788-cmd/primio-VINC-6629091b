import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/matches_provider.dart';
import '../theme/responsive_layout.dart';
import '../theme/theme.dart';
import '../widgets/common/match_tile.dart';
import '../widgets/common/sign_in_required_view.dart';
import '../widgets/common/skeleton.dart';
import '../widgets/common/state_view.dart';
import '../widgets/common/tab_page.dart';
import 'match_actions.dart';

/// Conversations are derived from matches (each match owns one).
class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<MatchesProvider>();
    final items = m.byActivity;
    final padding = ResponsiveLayout.getPadding(context);

    final Widget body;
    if (m.needsSignIn) {
      body = SignInRequiredView(
        message: 'Tus conversaciones privadas aparecen aquí cuando tienes una cuenta.',
        onSignIn: () => context.read<AuthProvider>().leaveGuestMode(),
      );
    } else if (m.isLoading && items.isEmpty) {
      body = const SkeletonList(semanticLabel: 'Cargando conversaciones');
    } else if (m.error != null && items.isEmpty) {
      body = StateView(icon: Icons.cloud_off_rounded, title: 'No pudimos cargar tus mensajes', message: m.error!, primaryLabel: 'Reintentar', onPrimary: m.load);
    } else if (items.isEmpty) {
      body = StateView(
        icon: Icons.chat_bubble_outline_rounded,
        image: 'assets/images/empty_messages.png',
        title: 'Sin conversaciones todavía',
        message: 'Cuando tengas un vínculo podrás escribirle desde aquí.',
        primaryLabel: 'Ir a Descubrir',
        onPrimary: () => context.go('/discover'),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: m.load,
        child: ListView.separated(
          padding: padding.copyWith(top: 0),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacingSm),
          itemBuilder: (context, i) {
            final match = items[i];
            return MatchTile(
              match: match,
              showPreview: true,
              onOpen: () => openChat(context, match.conversationId),
              onUnmatch: () => confirmAndUnmatch(context, match),
            );
          },
        ),
      );
    }

    return TabPage(title: 'Mensajes', subtitle: 'Conversaciones privadas con tus vínculos.', body: body);
  }
}

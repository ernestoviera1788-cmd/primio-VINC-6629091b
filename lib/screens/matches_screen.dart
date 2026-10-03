import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/matches_provider.dart';
import '../theme/responsive_layout.dart';
import '../theme/theme.dart';
import '../widgets/common/sign_in_required_view.dart';
import '../widgets/common/skeleton.dart';
import '../widgets/common/state_view.dart';
import '../widgets/common/tab_page.dart';
import '../widgets/matches/match_avatar.dart';
import 'match_actions.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<MatchesProvider>();
    final padding = ResponsiveLayout.getPadding(context);
    final items = m.byActivity;

    final Widget body;
    if (m.needsSignIn) {
      body = SignInRequiredView(
        message: 'Tus vínculos aparecen aquí cuando tienes una cuenta.',
        onSignIn: () => context.read<AuthProvider>().leaveGuestMode(),
      );
    } else if (m.isLoading && items.isEmpty) {
      body = const SkeletonList(semanticLabel: 'Cargando tus vínculos');
    } else if (m.error != null && items.isEmpty) {
      body = StateView(icon: Icons.cloud_off_rounded, title: 'No pudimos cargar tus vínculos', message: m.error!, primaryLabel: 'Reintentar', onPrimary: m.load);
    } else if (items.isEmpty) {
      body = StateView(
        icon: Icons.all_inclusive_rounded,
        image: 'assets/images/empty_matches.png',
        title: 'Aún no tienes vínculos',
        message: 'Cuando alguien que te gusta también te elija, aparecerá aquí.',
        primaryLabel: 'Ir a Descubrir',
        onPrimary: () => context.go('/discover'),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: m.load,
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding.copyWith(top: 0),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: AppTheme.matchCellWidth,
            mainAxisExtent: AppTheme.matchCellHeight,
            crossAxisSpacing: AppTheme.spacingSm,
            mainAxisSpacing: AppTheme.spacingMd,
          ),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final match = items[i];
            return MatchAvatar(
              match: match,
              onOpen: () => openChat(context, match.conversationId),
              onUnmatch: () => confirmAndUnmatch(context, match),
            );
          },
        ),
      );
    }

    return TabPage(
      title: 'Vínculos',
      subtitle: 'Toca para escribir · mantén pulsado para deshacer.',
      body: body,
    );
  }
}

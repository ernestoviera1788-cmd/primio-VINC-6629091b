import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../providers/discovery/discovery_provider.dart';
import '../providers/matches_provider.dart';
import '../providers/me_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/ambient_background.dart';
import '../widgets/common/sign_in_required_view.dart';
import '../widgets/common/state_view.dart';
import '../widgets/discover/action_dock.dart';
import '../widgets/discover/card_deck.dart';
import '../widgets/discover/discover_header.dart';
import '../widgets/discover/discover_skeleton.dart';
import '../widgets/discover/filters_sheet.dart';
import '../widgets/discover/match_dialog.dart';
import 'match_actions.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  void _handleEvents(BuildContext context, DiscoveryProvider provider) {
    if (provider.pendingMatch == null && provider.notice == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final notice = provider.takeNotice();
      final match = provider.takeMatch();
      if (notice != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(notice)));
      }
      if (match != null) {
        HapticFeedback.heavyImpact();
        context.read<MatchesProvider>().load();
        final me = context.read<MeProvider>().publicPreview;
        showGeneralDialog<void>(
          context: context,
          barrierColor: Theme.of(context).extension<AppColorsExtension>()!.photoScrim,
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (dialogContext, _, _) => MatchDialog(
            candidate: match.candidate,
            myPhoto: (me == null || me.photos.isEmpty) ? null : me.photos.first,
            onKeepGoing: () => Navigator.of(dialogContext).pop(),
            onMessage: () {
              Navigator.of(dialogContext).pop();
              final id = match.conversationId;
              if (id != null) {
                openChat(context, id);
              } else {
                context.go('/matches');
              }
            },
          ),
        );
      }
    });
  }

  Future<void> _openFilters(BuildContext context) async {
    final me = context.read<MeProvider>();
    final profile = me.profile;
    if (profile == null) {
      context.push('/profile/edit');
      return;
    }
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FiltersSheet(profile: profile, onApply: me.save),
    );
    if (applied == true && context.mounted) {
      context.read<DiscoveryProvider>().loadInitial();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filtros guardados. Buscando de nuevo…')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscoveryProvider>();
    _handleEvents(context, provider);
    final queue = provider.queue;
    final hasCards = queue.isNotEmpty;

    final Widget content;
    if (provider.needsSignIn) {
      content = SignInRequiredView(
        message: 'Para descubrir personas reales necesitas una cuenta. En modo invitado no se muestran perfiles.',
        onSignIn: () => context.read<AuthProvider>().leaveGuestMode(),
      );
    } else if (!hasCards && provider.isLoading) {
      content = const DiscoverSkeleton();
    } else if (!hasCards && provider.error != null) {
      content = StateView(
        icon: Icons.cloud_off_rounded,
        title: 'Se nos cruzó un cable',
        message: provider.error!,
        primaryLabel: 'Reintentar',
        onPrimary: provider.loadInitial,
      );
    } else if (!hasCards) {
      content = StateView(
        icon: Icons.travel_explore_rounded,
        image: 'assets/images/empty_discover.png',
        title: 'Has visto a todos por ahora',
        message: 'Amplía la edad, la distancia o lo que buscas para conocer a más personas.',
        primaryLabel: 'Ajustar filtros',
        onPrimary: () => _openFilters(context),
        secondaryLabel: 'Buscar de nuevo',
        onSecondary: provider.loadInitial,
      );
    } else {
      content = CardDeck(
        candidates: queue.take(2).toList(),
        intentLabelOf: (_) => '',
        onSwipe: (d) => provider.decide(d),
        onOpen: (c) => context.push('/discover/profile/${c.profile.id}'),
      );
    }

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).appBarTheme.systemOverlayStyle!,
        child: AmbientBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppTheme.maxCardWidth),
                child: Column(
                  children: [
                    DiscoverHeader(onFilters: () => _openFilters(context)),
                    Expanded(child: content),
                    if (!provider.needsSignIn)
                      ActionDock(
                        onPass: hasCards ? () => provider.decide(SwipeDecision.pass) : null,
                        onSpark: hasCards ? () => provider.decide(SwipeDecision.spark) : null,
                        onLike: hasCards ? () => provider.decide(SwipeDecision.like) : null,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

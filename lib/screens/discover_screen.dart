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
import '../widgets/common/gradient_button.dart';
import '../widgets/common/sign_in_required_view.dart';
import '../widgets/common/state_view.dart';
import '../widgets/discover/action_dock.dart';
import '../widgets/discover/card_deck.dart';
import '../widgets/discover/discover_skeleton.dart';
import '../widgets/discover/filters_sheet.dart';
import '../widgets/discover/match_dialog.dart';
import 'match_actions.dart';

/// Descubrir con la portada nocturna: foto a pantalla completa, cabecera
/// VINCÓ con lema, nota manuscrita y tarjeta de estado vacío como el diseño.
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
    // Ensure the profile is loaded before deciding (it loads async at startup).
    if (me.profile == null) {
      await me.load();
    }
    final profile = me.profile;
    if (profile == null) {
      if (context.mounted) context.push('/profile/edit');
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

  Widget _buildBody(BuildContext context, DiscoveryProvider provider, List<DiscoveryCandidate> queue) {
    final hasCards = queue.isNotEmpty;
    if (provider.needsSignIn) {
      return Expanded(
        child: SignInRequiredView(
          message: 'Para descubrir personas reales necesitas una cuenta. En modo invitado no se muestran perfiles.',
          onSignIn: () => context.read<AuthProvider>().leaveGuestMode(),
        ),
      );
    }
    if (!hasCards && provider.isLoading) {
      return const Expanded(child: DiscoverSkeleton());
    }
    if (!hasCards && provider.error != null) {
      return Expanded(
        child: StateView(
          icon: Icons.cloud_off_rounded,
          title: 'Se nos cruzó un cable',
          message: provider.error!,
          primaryLabel: 'Reintentar',
          onPrimary: provider.loadInitial,
        ),
      );
    }
    if (!hasCards) {
      return Expanded(
        child: Stack(
          children: [
            const Positioned(
              right: AppTheme.spacingXl,
              top: AppTheme.spacingMd,
              child: _HandwrittenNote(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 120),
                child: _EmptyDiscoverCard(
                  onAdjustFilters: () => _openFilters(context),
                  onRetry: provider.loadInitial,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Expanded(
      child: CardDeck(
        candidates: queue.take(2).toList(),
        intentLabelOf: (_) => '',
        onSwipe: (d) => provider.decide(d),
        onOpen: (c) => context.push('/discover/profile/${c.profile.id}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscoveryProvider>();
    _handleEvents(context, provider);
    final queue = provider.queue;
    final hasCards = queue.isNotEmpty;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).appBarTheme.systemOverlayStyle!,
        child: Stack(
          children: [
            // Portada nocturna a pantalla completa.
            Positioned.fill(
              child: Image.asset(
                'assets/images/discover_night.jpg',
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
            ),
            // Degradados oscuros arriba y abajo para legibilidad.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.78),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppTheme.maxCardWidth),
                  child: Column(
                    children: [
                      _DiscoverHeroHeader(onFilters: () => _openFilters(context)),
                      _buildBody(context, provider, queue),
                      if (hasCards && !provider.needsSignIn)
                        ActionDock(
                          onPass: () => provider.decide(SwipeDecision.pass),
                          onSpark: () => provider.decide(SwipeDecision.spark),
                          onLike: () => provider.decide(SwipeDecision.like),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cabecera de la portada: logo VINCÓ centrado con lema y botón circular
/// de filtros arriba a la derecha.
class _DiscoverHeroHeader extends StatelessWidget {
  final VoidCallback onFilters;

  const _DiscoverHeroHeader({required this.onFilters});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = theme.extension<AppColorsExtension>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        AppTheme.spacingXs,
        AppTheme.spacingMd,
        AppTheme.spacingSm,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Rings(size: 30, primary: colors.primary, secondary: colors.secondary),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    'VINCÓ',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colors.onSurface,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                'CONEXIONES QUE SUMAN\nA TU VIDA',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: appColors.subtleText,
                  letterSpacing: 4,
                  height: 1.7,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: onFilters,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.35),
                ),
                child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

/// Los dos anillos entrelazados del logo VINCÓ.
class _Rings extends StatelessWidget {
  final double size;
  final Color primary;
  final Color secondary;

  const _Rings({required this.size, required this.primary, required this.secondary});

  @override
  Widget build(BuildContext context) {
    Widget ring(Color color) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
        );

    return SizedBox(
      width: size * 1.6,
      height: size,
      child: Stack(
        children: [
          ring(primary),
          Positioned(left: size * 0.6, child: ring(secondary)),
        ],
      ),
    );
  }
}

/// Nota manuscrita sobre el fondo: "Buenas personas en todas partes ♡".
class _HandwrittenNote extends StatelessWidget {
  const _HandwrittenNote();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.1,
      child: const Text(
        'Buenas\npersonas\nen todas\npartes ♡',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
          fontSize: 26,
          height: 1.3,
          color: Colors.white,
          shadows: [
            Shadow(color: Color(0x80000000), blurRadius: 10, offset: Offset(0, 2)),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de estado vacío: "Has visto a todos por ahora".
class _EmptyDiscoverCard extends StatelessWidget {
  final VoidCallback onAdjustFilters;
  final VoidCallback onRetry;

  const _EmptyDiscoverCard({required this.onAdjustFilters, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = theme.extension<AppColorsExtension>()!;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppTheme.spacingLg,
        0,
        AppTheme.spacingLg,
        AppTheme.spacingLg,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingLg,
        AppTheme.spacingXl,
        AppTheme.spacingLg,
        AppTheme.spacingLg,
      ),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Has visto a todos por ahora',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Amplía la edad, la distancia o lo que buscas para conocer a más personas.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: appColors.subtleText),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          GradientButton(
            label: 'Ajustar filtros',
            icon: Icons.tune_rounded,
            onPressed: onAdjustFilters,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Center(
            child: SizedBox(
              width: 250,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Buscar de nuevo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  side: BorderSide(
                    color: colors.primary.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  minimumSize: const Size(0, AppTheme.buttonHeight),
                  shape: const StadiumBorder(),
                  textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _EmptyPerk(icon: Icons.groups_outlined, label: 'Nuevas\nperspectivas'),
              _EmptyPerk(icon: Icons.favorite_border_rounded, label: 'Conversaciones\nreales'),
              _EmptyPerk(icon: Icons.auto_awesome_outlined, label: 'Historias\nextraordinarias'),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyPerk extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmptyPerk({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: appColors.subtleText),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: appColors.subtleText,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

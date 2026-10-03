import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../providers/discovery/discovery_provider.dart';
import '../theme/responsive_layout.dart';
import '../theme/theme.dart';
import '../widgets/common/profile_photo.dart';
import '../widgets/common/round_action_button.dart';
import '../widgets/common/state_view.dart';
import '../widgets/profile/profile_facts.dart';

class FullProfileScreen extends StatelessWidget {
  final String profileId;

  const FullProfileScreen({super.key, required this.profileId});

  void _act(BuildContext context, SwipeDecision d) {
    final provider = context.read<DiscoveryProvider>();
    context.pop();
    provider.decide(d, profileId: profileId);
  }

  @override
  Widget build(BuildContext context) {
    final candidate = context.watch<DiscoveryProvider>().byId(profileId);
    if (candidate == null) {
      return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: StateView(
            icon: Icons.person_off_outlined,
            title: 'Perfil no disponible',
            message: 'Este perfil ya no está en tu lista de descubrimiento.',
            primaryLabel: 'Volver',
            onPrimary: () => context.pop(),
          ),
        ),
      );
    }
    final p = candidate.profile;
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final name = p.name;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                expandedHeight: MediaQuery.sizeOf(context).height * AppTheme.galleryHeightFactor,
                leading: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingXs),
                  child: IconButton.filledTonal(
                    tooltip: 'Volver',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: PageView.builder(
                    itemCount: p.photos.isEmpty ? 1 : p.photos.length,
                    itemBuilder: (context, i) => ProfilePhoto(
                      source: p.photos.isEmpty ? null : p.photos[i],
                      cacheWidth: 1100,
                      semanticLabel: 'Foto ${i + 1} de $name',
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ResponsiveLayout.constrain(
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacingLg,
                      AppTheme.spacingLg,
                      AppTheme.spacingLg,
                      AppTheme.actionLarge + AppTheme.spacingXxl * 2,
                    ),
                    child: ProfileFacts(
                      candidate: candidate,
                      intentLabel: p.intention ?? '',
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppTheme.spacingMd,
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundActionButton(icon: Icons.close_rounded, tooltip: 'Pasar', color: appColors.pass, onPressed: () => _act(context, SwipeDecision.pass)),
                  const SizedBox(width: AppTheme.spacingLg),
                  RoundActionButton(icon: Icons.auto_awesome_rounded, tooltip: 'Enviar Chispa', color: appColors.spark, size: AppTheme.actionSmall, onPressed: () => _act(context, SwipeDecision.spark)),
                  const SizedBox(width: AppTheme.spacingLg),
                  RoundActionButton(icon: Icons.favorite_rounded, tooltip: 'Me gusta', color: appColors.like, onPressed: () => _act(context, SwipeDecision.like)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

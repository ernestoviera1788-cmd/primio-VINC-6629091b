import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../providers/me_provider.dart';
import '../theme/responsive_layout.dart';
import '../theme/theme.dart';
import '../widgets/common/profile_photo.dart';
import '../widgets/common/state_view.dart';
import '../widgets/profile/profile_facts.dart';

class MyPublicProfileScreen extends StatelessWidget {
  const MyPublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<MeProvider>();
    final preview = me.publicPreview;

    final Widget body;
    if (preview == null && me.isLoading) {
      body = const LoadingView(message: 'Cargando tu perfil…');
    } else if (preview == null) {
      body = StateView(
        icon: Icons.cloud_off_rounded,
        title: 'No pudimos cargar tu perfil',
        message: me.error ?? 'Inténtalo de nuevo.',
        primaryLabel: 'Reintentar',
        onPrimary: me.load,
      );
    } else {
      body = ListView(
        padding: ResponsiveLayout.getPadding(context),
        children: [
          const InfoBanner(
            icon: Icons.visibility_outlined,
            message: 'Así te ven los demás. Solo se muestran tus fotos aprobadas; tu email y teléfono nunca aparecen.',
          ),
          const SizedBox(height: AppTheme.spacingLg),
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              child: PageView.builder(
                itemCount: preview.photos.isEmpty ? 1 : preview.photos.length,
                itemBuilder: (_, i) => ProfilePhoto(
                  source: preview.photos.isEmpty ? null : preview.photos[i],
                  cacheWidth: 1100,
                  semanticLabel: 'Tu foto ${i + 1}',
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ProfileFacts(
            candidate: DiscoveryCandidate(
              profile: preview,
              compatibility: 0,
              sharedInterests: const [],
              distanceLabel: [preview.city, preview.state].whereType<String>().join(', '),
            ),
            intentLabel: preview.intention ?? '',
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil público')),
      body: SafeArea(top: false, child: ResponsiveLayout.constrain(body)),
    );
  }
}

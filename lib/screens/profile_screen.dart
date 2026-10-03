import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/me_provider.dart';
import '../theme/responsive_layout.dart';
import '../theme/theme.dart';
import '../widgets/common/menu_tile.dart';
import '../widgets/common/state_view.dart';
import '../widgets/common/tab_page.dart';
import '../widgets/profile/account_card.dart';
import '../widgets/profile/profile_hero.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = context.watch<MeProvider>();
    final padding = ResponsiveLayout.getPadding(context);

    return TabPage(
      title: 'Perfil',
      subtitle: 'Tu identidad, tus fotos y tus ajustes.',
      body: ListView(
        padding: padding.copyWith(top: 0),
        children: [
          if (!me.needsSignIn && me.profile != null) ...[
            ProfileHero(
              name: me.profile!.firstName,
              photo: (me.publicPreview?.photos.isEmpty ?? true) ? null : me.publicPreview!.photos.first,
              photoCount: me.photos.length,
              maxPhotos: me.maxPhotos,
              onPreview: () => context.push('/profile/public'),
              onPhotos: () => context.push('/profile/photos'),
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],
          AccountCard(
            user: auth.user,
            busy: auth.busy,
            onLogout: auth.logout,
            onSignIn: auth.leaveGuestMode,
          ),
          if (!me.needsSignIn) ...[
            if (me.error != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              InfoBanner(icon: Icons.error_outline_rounded, message: 'No pudimos cargar tu perfil. ${me.error}'),
              TextButton(onPressed: me.load, child: const Text('Reintentar')),
            ],
            const SizedBox(height: AppTheme.spacingMd),
            MenuTile(
              icon: Icons.photo_library_outlined,
              title: 'Fotos',
              description: '${me.photos.length} de ${me.maxPhotos} · sube, ordena y elige la principal.',
              onTap: () => context.push('/profile/photos'),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            MenuTile(
              icon: Icons.edit_outlined,
              title: 'Sobre mí y preferencias',
              description: 'Tus datos, biografía, edad, distancia y a quién quieres conocer.',
              onTap: () => context.push('/profile/edit'),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            MenuTile(
              icon: Icons.settings_outlined,
              title: 'Ajustes',
              description: 'Cerrar sesión y eliminar tu cuenta.',
              onTap: () => context.push('/profile/settings'),
            ),
          ],
        ],
      ),
    );
  }
}

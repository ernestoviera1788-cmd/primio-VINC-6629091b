import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../theme/theme.dart';

class AccountCard extends StatelessWidget {
  final AppUser? user;
  final bool busy;
  final VoidCallback onLogout;
  final VoidCallback onSignIn;

  const AccountCard({
    super.key,
    required this.user,
    required this.busy,
    required this.onLogout,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final appColors = theme.extension<AppColorsExtension>()!;
    final u = user;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: AppTheme.thumbnailSize / 2,
                  backgroundColor: colors.primaryContainer,
                  child: u == null
                      ? Icon(Icons.person_outline_rounded, color: colors.onPrimaryContainer)
                      : Text(
                          u.firstName.isEmpty ? '?' : u.firstName.characters.first.toUpperCase(),
                          style: text.titleLarge?.copyWith(color: colors.onPrimaryContainer),
                        ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u == null ? 'Modo invitado' : u.firstName,
                        style: text.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        u == null ? 'Nada se guarda en el servidor.' : u.email,
                        style: text.bodyMedium?.copyWith(color: appColors.subtleText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (u != null) ...[
              const SizedBox(height: AppTheme.spacingSm),
              Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: AppTheme.iconSm, color: appColors.subtleText),
                  const SizedBox(width: AppTheme.spacingXs),
                  Expanded(
                    child: Text(
                      u.emailVerified
                          ? 'Email verificado · solo tú ves tu email y teléfono'
                          : 'Email sin verificar · la verificación llegará al conectar un proveedor de email',
                      style: text.bodySmall?.copyWith(color: appColors.subtleText),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppTheme.spacingMd),
            if (u == null)
              FilledButton(onPressed: onSignIn, child: const Text('Crear cuenta o entrar'))
            else
              OutlinedButton.icon(
                onPressed: busy ? null : onLogout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
              ),
          ],
        ),
      ),
    );
  }
}

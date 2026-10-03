import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/responsive_layout.dart';
import '../theme/theme.dart';
import '../widgets/common/state_view.dart';
import '../widgets/profile/delete_account_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _delete(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(context: context, builder: (_) => const DeleteAccountDialog());
    if (ok != true) return;
    final error = await auth.deleteAccount();
    if (error != null) messenger.showSnackBar(SnackBar(content: Text('No se eliminó la cuenta. $error')));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: SafeArea(
        top: false,
        child: ResponsiveLayout.constrain(
          ListView(
            padding: ResponsiveLayout.getPadding(context),
            children: [
              const InfoBanner(
                icon: Icons.lock_outline_rounded,
                message: 'Tu email y tu teléfono son privados: nunca aparecen en tu perfil público.',
              ),
              const SizedBox(height: AppTheme.spacingXl),
              Text('Sesión', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppTheme.spacingSm),
              OutlinedButton.icon(
                onPressed: auth.busy ? null : auth.logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              Text('Zona sensible', style: theme.textTheme.titleLarge?.copyWith(color: colors.error)),
              const SizedBox(height: AppTheme.spacingSm),
              Text('Eliminar tu cuenta borra tus datos de VINCÓ de forma permanente.', style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppTheme.spacingMd),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: colors.error, side: BorderSide(color: colors.error)),
                onPressed: auth.busy ? null : () => _delete(context),
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Eliminar cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/me_provider.dart';
import '../theme/responsive_layout.dart';
import '../widgets/common/state_view.dart';
import '../widgets/profile/edit_profile_form.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<MeProvider>();
    final profile = me.profile;

    final Widget body;
    if (profile == null && me.isLoading) {
      body = const LoadingView(message: 'Cargando tu perfil…');
    } else if (profile == null) {
      body = StateView(
        icon: Icons.cloud_off_rounded,
        title: 'No pudimos cargar tu perfil',
        message: me.error ?? 'Inicia sesión para editar tu perfil.',
        primaryLabel: 'Reintentar',
        onPrimary: me.load,
      );
    } else {
      body = SingleChildScrollView(
        padding: ResponsiveLayout.getPadding(context),
        child: EditProfileForm(
          initial: profile,
          saving: me.isSaving,
          onSubmit: (updated) async {
            final messenger = ScaffoldMessenger.of(context);
            final error = await me.save(updated);
            if (error == null && context.mounted) {
              messenger.showSnackBar(const SnackBar(content: Text('Perfil guardado.')));
              context.pop();
            }
            return error;
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(top: false, child: ResponsiveLayout.constrain(body)),
    );
  }
}

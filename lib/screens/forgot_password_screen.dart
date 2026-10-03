import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/theme.dart';
import '../widgets/auth/auth_scaffold.dart';
import '../widgets/auth/reset_password_form.dart';
import '../widgets/common/state_view.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String? _error;

  Future<bool> _requestCode(String identifier) async {
    final error = await context.read<AuthProvider>().requestPasswordReset(identifier);
    if (!mounted) return false;
    setState(() => _error = error);
    return error == null;
  }

  Future<void> _complete(String identifier, String code, String newPassword) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<AuthProvider>().completePasswordReset(identifier, code, newPassword);
    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    messenger.showSnackBar(const SnackBar(content: Text('Contraseña actualizada. Ya puedes entrar.')));
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthProvider>().busy;
    return AuthScaffold(
      title: 'Recupera tu acceso',
      subtitle: 'Te pediremos un código y una contraseña nueva.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const InfoBanner(
            icon: Icons.mark_email_unread_outlined,
            message: 'Por ahora el servidor genera el código pero aún no lo envía por email ni SMS. '
                'Llegará cuando se conecte un proveedor de envío.',
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ResetPasswordForm(busy: busy, error: _error, onRequestCode: _requestCode, onComplete: _complete),
        ],
      ),
    );
  }
}

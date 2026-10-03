import 'package:flutter/material.dart';

import 'state_view.dart';

class SignInRequiredView extends StatelessWidget {
  final String message;
  final VoidCallback onSignIn;

  const SignInRequiredView({super.key, required this.message, required this.onSignIn});

  @override
  Widget build(BuildContext context) => StateView(
        icon: Icons.lock_outline_rounded,
        title: 'Inicia sesión',
        message: message,
        primaryLabel: 'Crear cuenta o entrar',
        onPrimary: onSignIn,
      );
}

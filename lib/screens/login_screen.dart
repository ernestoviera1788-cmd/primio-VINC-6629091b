import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth/auth_scaffold.dart';
import '../widgets/auth/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _error;

  Future<void> _login(String identifier, String password) async {
    final error = await context.read<AuthProvider>().login(identifier, password);
    if (mounted) setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthProvider>().busy;
    return AuthScaffold(
      title: 'Hola de nuevo',
      subtitle: 'Entra con tu email o teléfono y tu contraseña.',
      child: LoginForm(
        busy: busy,
        error: _error,
        onSubmit: _login,
        onForgotPassword: () => context.push('/forgot-password'),
        onSignup: () => context.pushReplacement('/signup'),
      ),
    );
  }
}

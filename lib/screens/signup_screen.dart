import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth/auth_scaffold.dart';
import '../widgets/auth/signup_form.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String? _error;

  Future<void> _register(SignupData data) async {
    final error = await context.read<AuthProvider>().register(data);
    if (mounted) setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthProvider>().busy;
    return AuthScaffold(
      title: 'Crea tu cuenta',
      subtitle: 'Tu email y teléfono son privados. Solo mostramos lo que tú decidas.',
      child: SignupForm(busy: busy, error: _error, onSubmit: _register),
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'auth_error_banner.dart';
import 'password_field.dart';
import 'submit_button.dart';

class LoginForm extends StatefulWidget {
  final bool busy;
  final String? error;
  final void Function(String identifier, String password) onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onSignup;

  const LoginForm({
    super.key,
    required this.busy,
    required this.error,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onSignup,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(_identifier.text.trim(), _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.error != null) ...[
              AuthErrorBanner(message: widget.error!),
              const SizedBox(height: AppTheme.spacingMd),
            ],
            TextFormField(
              controller: _identifier,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email, AutofillHints.telephoneNumber],
              decoration: const InputDecoration(
                labelText: 'Email o teléfono',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe tu email o teléfono' : null,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            PasswordField(
              controller: _password,
              validator: (v) => (v == null || v.isEmpty) ? 'Escribe tu contraseña' : null,
              onSubmitted: (_) => _submit(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onForgotPassword,
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            SubmitButton(label: 'Entrar', busy: widget.busy, onPressed: _submit),
            const SizedBox(height: AppTheme.spacingSm),
            TextButton(onPressed: widget.onSignup, child: const Text('¿Aún no tienes cuenta? Créala')),
          ],
        ),
      ),
    );
  }
}

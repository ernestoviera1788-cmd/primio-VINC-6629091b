import 'package:flutter/material.dart';

import '../../models/auth_validators.dart';
import '../../theme/theme.dart';
import 'auth_error_banner.dart';
import 'password_field.dart';
import 'submit_button.dart';

class ResetPasswordForm extends StatefulWidget {
  final bool busy;
  final String? error;

  /// Returns true when the server accepted the request.
  final Future<bool> Function(String identifier) onRequestCode;
  final void Function(String identifier, String code, String newPassword) onComplete;

  const ResetPasswordForm({
    super.key,
    required this.busy,
    required this.error,
    required this.onRequestCode,
    required this.onComplete,
  });

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _codeRequested = false;

  @override
  void dispose() {
    _identifier.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final id = _identifier.text.trim();
    if (!_codeRequested) {
      final ok = await widget.onRequestCode(id);
      if (ok && mounted) setState(() => _codeRequested = true);
    } else {
      widget.onComplete(id, _code.text.trim(), _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
            enabled: !_codeRequested,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email o teléfono de tu cuenta',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
            validator: (v) => AuthValidators.required(v, 'Escribe tu email o teléfono'),
          ),
          if (_codeRequested) ...[
            const SizedBox(height: AppTheme.spacingMd),
            TextFormField(
              controller: _code,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              decoration: const InputDecoration(labelText: 'Código de recuperación', prefixIcon: Icon(Icons.pin_outlined)),
              validator: (v) => AuthValidators.required(v, 'Escribe el código'),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            PasswordField(
              controller: _password,
              label: 'Nueva contraseña',
              isNew: true,
              helperText: 'Entre 10 y 100 caracteres',
              validator: AuthValidators.password,
            ),
          ],
          const SizedBox(height: AppTheme.spacingLg),
          SubmitButton(
            label: _codeRequested ? 'Cambiar contraseña' : 'Solicitar código',
            busy: widget.busy,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

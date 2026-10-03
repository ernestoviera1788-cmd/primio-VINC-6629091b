import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/auth_validators.dart';
import '../../theme/theme.dart';
import 'auth_error_banner.dart';
import 'birth_date_field.dart';
import 'password_field.dart';
import 'submit_button.dart';

class SignupForm extends StatefulWidget {
  final bool busy;
  final String? error;
  final ValueChanged<SignupData> onSubmit;

  const SignupForm({super.key, required this.busy, required this.error, required this.onSubmit});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _country = TextEditingController(text: 'US');
  DateTime? _birthDate;
  String _gender = genderOptions.first;
  bool _acceptedTerms = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _city, _state, _country]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    setState(() => _showTermsError = !_acceptedTerms);
    if (!valid || !_acceptedTerms) return;
    widget.onSubmit(SignupData(
      email: _email.text.trim(),
      password: _password.text,
      firstName: _name.text.trim(),
      birthDate: AuthValidators.apiDate(_birthDate!),
      gender: _gender,
      city: _city.text.trim(),
      state: _state.text.trim(),
      country: _country.text.trim().toUpperCase(),
      phone: _phone.text.trim(),
    ));
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {FormFieldValidator<String>? validator, TextInputType? type, List<String>? autofill, String? helper}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        autofillHints: autofill,
        textInputAction: TextInputAction.next,
        validator: validator,
        decoration: InputDecoration(labelText: label, helperText: helper, prefixIcon: Icon(icon)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            _field(_name, 'Nombre', Icons.person_outline_rounded,
                autofill: const [AutofillHints.givenName],
                validator: (v) => AuthValidators.required(v, 'Escribe tu nombre')),
            _field(_email, 'Email', Icons.alternate_email_rounded,
                type: TextInputType.emailAddress,
                autofill: const [AutofillHints.email],
                validator: AuthValidators.email,
                helper: 'Privado. Nunca se muestra en tu perfil.'),
            _field(_phone, 'Teléfono (opcional)', Icons.phone_outlined,
                type: TextInputType.phone,
                autofill: const [AutofillHints.telephoneNumber],
                validator: AuthValidators.optionalPhone,
                helper: 'Privado. Formato internacional, ej. +15125550199'),
            PasswordField(
              controller: _password,
              isNew: true,
              helperText: 'Entre 10 y 100 caracteres',
              validator: AuthValidators.password,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            BirthDateField(value: _birthDate, onChanged: (d) => setState(() => _birthDate = d)),
            const SizedBox(height: AppTheme.spacingMd),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: const InputDecoration(labelText: 'Género', prefixIcon: Icon(Icons.diversity_3_outlined)),
              items: [for (final g in genderOptions) DropdownMenuItem(value: g, child: Text(g))],
              onChanged: (g) => setState(() => _gender = g ?? _gender),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _field(_city, 'Ciudad', Icons.location_city_outlined,
                autofill: const [AutofillHints.addressCity],
                validator: (v) => AuthValidators.required(v, 'Escribe tu ciudad'),
                helper: 'Solo se usa para mostrar distancias aproximadas.'),
            _field(_state, 'Estado o provincia (opcional)', Icons.map_outlined,
                autofill: const [AutofillHints.addressState]),
            _field(_country, 'País (código, ej. US, MX, ES)', Icons.public_rounded,
                autofill: const [AutofillHints.countryCode],
                validator: (v) => (v == null || v.trim().length != 2) ? 'Usa el código de 2 letras' : null),
            CheckboxListTile(
              value: _acceptedTerms,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (v) => setState(() {
                _acceptedTerms = v ?? false;
                if (_acceptedTerms) _showTermsError = false;
              }),
              title: Text('Acepto los términos de uso y la política de privacidad', style: theme.textTheme.bodyMedium),
              subtitle: _showTermsError
                  ? Text('Necesitas aceptarlos para crear tu cuenta',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error))
                  : null,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            SubmitButton(label: 'Crear cuenta', busy: widget.busy, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}

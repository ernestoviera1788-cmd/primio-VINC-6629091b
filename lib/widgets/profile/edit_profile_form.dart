import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/my_profile.dart';
import '../../theme/theme.dart';
import 'preferences_fields.dart';

class EditProfileForm extends StatefulWidget {
  final MyProfile initial;
  final bool saving;

  /// Returns an error message, or null when saved.
  final Future<String?> Function(MyProfile profile) onSubmit;

  const EditProfileForm({super.key, required this.initial, required this.saving, required this.onSubmit});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial.firstName);
  late final _bio = TextEditingController(text: widget.initial.bio);
  late final _city = TextEditingController(text: widget.initial.city);
  late final _state = TextEditingController(text: widget.initial.state);
  late final _country = TextEditingController(text: widget.initial.country);
  late final _occupation = TextEditingController(text: widget.initial.occupation);
  late final _education = TextEditingController(text: widget.initial.education);
  late final _hobbies = TextEditingController(text: widget.initial.hobbies);
  late final _lifestyle = TextEditingController(text: widget.initial.lifestyle);
  late String _gender = widget.initial.gender;
  late String _intention = widget.initial.intention;
  late String _preferred = widget.initial.preferredGender;
  late RangeValues _ages = RangeValues(
    widget.initial.ageMin.clamp(18, 99).toDouble(),
    widget.initial.ageMax.clamp(widget.initial.ageMin.clamp(18, 99), 99).toDouble(),
  );
  late double _distance = widget.initial.distanceMax.clamp(1, 500).toDouble();
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _bio, _city, _state, _country, _occupation, _education, _hobbies, _lifestyle]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await widget.onSubmit(MyProfile(
      firstName: _name.text.trim(),
      bio: _bio.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      country: _country.text.trim(),
      gender: _gender,
      intention: _intention,
      occupation: _occupation.text.trim(),
      education: _education.text.trim(),
      hobbies: _hobbies.text.trim(),
      lifestyle: _lifestyle.text.trim(),
      preferredGender: _preferred,
      ageMin: _ages.start.round(),
      ageMax: _ages.end.round(),
      distanceMax: _distance.round(),
      birthDate: widget.initial.birthDate,
    ));
    if (mounted) setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const gap = SizedBox(height: AppTheme.spacingMd);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sobre ti', style: theme.textTheme.titleLarge),
          gap,
          TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre'), textCapitalization: TextCapitalization.words, validator: _required),
          gap,
          TextFormField(controller: _bio, decoration: const InputDecoration(labelText: 'Biografía (opcional)'), minLines: 3, maxLines: 6, textCapitalization: TextCapitalization.sentences),
          gap,
          DropdownButtonFormField<String>(
            initialValue: _gender.isEmpty ? null : _gender,
            decoration: const InputDecoration(labelText: 'Género'),
            items: [for (final o in optionsWith(genderOptions, _gender)) DropdownMenuItem(value: o, child: Text(o))],
            onChanged: (v) => setState(() => _gender = v ?? _gender),
            validator: (v) => v == null ? 'Elige una opción' : null,
          ),
          gap,
          TextFormField(controller: _city, decoration: const InputDecoration(labelText: 'Ciudad'), validator: _required),
          gap,
          TextFormField(controller: _state, decoration: const InputDecoration(labelText: 'Estado o provincia')),
          gap,
          TextFormField(controller: _country, decoration: const InputDecoration(labelText: 'País (código, p. ej. US)'), validator: _required),
          gap,
          TextFormField(controller: _occupation, decoration: const InputDecoration(labelText: 'Profesión (opcional)')),
          gap,
          TextFormField(controller: _education, decoration: const InputDecoration(labelText: 'Educación (opcional)')),
          gap,
          TextFormField(controller: _hobbies, decoration: const InputDecoration(labelText: 'Hobbies (opcional)', helperText: 'Separados por comas')),
          gap,
          TextFormField(controller: _lifestyle, decoration: const InputDecoration(labelText: 'Estilo de vida (opcional)')),
          const SizedBox(height: AppTheme.spacingXl),
          Text('Lo que buscas', style: theme.textTheme.titleLarge),
          gap,
          PreferencesFields(
            intention: _intention,
            preferredGender: _preferred,
            ages: _ages,
            distance: _distance,
            onIntention: (v) => setState(() => _intention = v),
            onPreferredGender: (v) => setState(() => _preferred = v),
            onAges: (v) => setState(() => _ages = v),
            onDistance: (v) => setState(() => _distance = v),
          ),
          if (_error != null) ...[
            gap,
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(color: colors.errorContainer, borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
              child: Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: colors.onErrorContainer)),
            ),
          ],
          const SizedBox(height: AppTheme.spacingLg),
          FilledButton(
            onPressed: widget.saving ? null : _submit,
            child: widget.saving
                ? const SizedBox(width: AppTheme.iconSm, height: AppTheme.iconSm, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/auth_validators.dart';
import '../../theme/theme.dart';

class BirthDateField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  const BirthDateField({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: value,
      validator: AuthValidators.birthDate,
      builder: (field) => InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: field.value ?? DateTime(now.year - 25, now.month, now.day),
            firstDate: DateTime(now.year - 100),
            lastDate: now,
            helpText: 'Fecha de nacimiento',
            initialEntryMode: DatePickerEntryMode.calendarOnly,
          );
          if (picked != null) {
            field.didChange(picked);
            onChanged(picked);
          }
        },
        child: InputDecorator(
          isEmpty: field.value == null,
          decoration: InputDecoration(
            labelText: 'Fecha de nacimiento',
            helperText: 'Debes tener 18 años o más. No se muestra en tu perfil, solo tu edad.',
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.cake_outlined),
            errorText: field.errorText,
          ),
          child: Text(field.value == null ? '' : AuthValidators.displayDate(field.value!)),
        ),
      ),
    );
  }
}

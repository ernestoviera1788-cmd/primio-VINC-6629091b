import 'package:flutter/material.dart';

import '../../models/my_profile.dart';
import '../../theme/theme.dart';

class PreferencesFields extends StatelessWidget {
  final String intention;
  final String preferredGender;
  final RangeValues ages;
  final double distance;
  final ValueChanged<String> onIntention;
  final ValueChanged<String> onPreferredGender;
  final ValueChanged<RangeValues> onAges;
  final ValueChanged<double> onDistance;

  const PreferencesFields({
    super.key,
    required this.intention,
    required this.preferredGender,
    required this.ages,
    required this.distance,
    required this.onIntention,
    required this.onPreferredGender,
    required this.onAges,
    required this.onDistance,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: intention.isEmpty ? null : intention,
          decoration: const InputDecoration(labelText: 'Qué buscas'),
          items: [for (final o in optionsWith(intentionOptions, intention)) DropdownMenuItem(value: o, child: Text(o))],
          onChanged: (v) {
            if (v != null) onIntention(v);
          },
          validator: (v) => v == null ? 'Elige qué buscas' : null,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        DropdownButtonFormField<String>(
          initialValue: preferredGender.isEmpty ? null : preferredGender,
          decoration: const InputDecoration(labelText: 'Quiero conocer a'),
          items: [
            for (final o in optionsWith(preferredGenderOptions, preferredGender)) DropdownMenuItem(value: o, child: Text(o)),
          ],
          onChanged: (v) {
            if (v != null) onPreferredGender(v);
          },
          validator: (v) => v == null ? 'Elige a quién quieres conocer' : null,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Text('Edad: ${ages.start.round()} – ${ages.end.round()} años', style: text.titleSmall),
        RangeSlider(
          values: ages,
          min: 18,
          max: 99,
          divisions: 81,
          labels: RangeLabels('${ages.start.round()}', '${ages.end.round()}'),
          onChanged: onAges,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text('Distancia máxima: ${distance.round()} mi', style: text.titleSmall),
        Slider(
          value: distance,
          min: 1,
          max: 500,
          divisions: 499,
          label: '${distance.round()} mi',
          onChanged: onDistance,
        ),
      ],
    );
  }
}

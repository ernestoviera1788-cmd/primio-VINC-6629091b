import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/my_profile.dart';
import '../../theme/theme.dart';

/// Edits the discovery preferences stored in the profile (updateprofile).
class FiltersSheet extends StatefulWidget {
  final MyProfile profile;
  final Future<String?> Function(MyProfile) onApply;

  const FiltersSheet({super.key, required this.profile, required this.onApply});

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  late RangeValues _ages = RangeValues(
    widget.profile.ageMin.clamp(18, 99).toDouble(),
    widget.profile.ageMax.clamp(18, 99).toDouble(),
  );
  late double _distance = widget.profile.distanceMax.clamp(1, 500).toDouble();
  late String _intention = widget.profile.intention;
  bool _saving = false;
  String? _error;

  Future<void> _apply() async {
    final p = widget.profile;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await widget.onApply(MyProfile(
      firstName: p.firstName,
      bio: p.bio,
      city: p.city,
      state: p.state,
      country: p.country,
      gender: p.gender,
      intention: _intention,
      occupation: p.occupation,
      education: p.education,
      hobbies: p.hobbies,
      lifestyle: p.lifestyle,
      preferredGender: p.preferredGender,
      ageMin: _ages.start.round(),
      ageMax: _ages.end.round(),
      distanceMax: _distance.round(),
      birthDate: p.birthDate,
    ));
    if (!mounted) return;
    if (error == null) {
      HapticFeedback.lightImpact();
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final colors = theme.colorScheme;
    final appColors = theme.extension<AppColorsExtension>()!;

    Widget label(String title, String value) => Row(
          children: [
            Expanded(child: Text(title, style: text.titleMedium)),
            Text(value, style: text.titleMedium?.copyWith(color: colors.primary)),
          ],
        );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingLg,
        0,
        AppTheme.spacingLg,
        AppTheme.spacingLg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Filtros', style: text.headlineSmall),
          const SizedBox(height: AppTheme.spacingXs),
          Text('Ajusta a quién te mostramos en Descubrir.', style: text.bodyMedium?.copyWith(color: appColors.subtleText)),
          const SizedBox(height: AppTheme.spacingLg),
          label('Edad', '${_ages.start.round()} – ${_ages.end.round()}'),
          RangeSlider(
            values: _ages,
            min: 18,
            max: 99,
            divisions: 81,
            labels: RangeLabels('${_ages.start.round()}', '${_ages.end.round()}'),
            onChanged: _saving ? null : (v) => setState(() => _ages = v),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          label('Distancia máxima', '${_distance.round()} mi'),
          Slider(
            value: _distance,
            min: 1,
            max: 500,
            divisions: 499,
            label: '${_distance.round()} mi',
            onChanged: _saving ? null : (v) => setState(() => _distance = v),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text('Qué buscas', style: text.titleMedium),
          const SizedBox(height: AppTheme.spacingSm),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: [
              for (final o in optionsWith(intentionOptions, _intention))
                ChoiceChip(
                  label: Text(o),
                  selected: o == _intention,
                  onSelected: _saving ? null : (_) => setState(() => _intention = o),
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Text(_error!, style: text.bodyMedium?.copyWith(color: colors.error)),
          ],
          const SizedBox(height: AppTheme.spacingLg),
          FilledButton(
            onPressed: _saving ? null : _apply,
            child: _saving
                ? SizedBox.square(
                    dimension: AppTheme.iconMd,
                    child: CircularProgressIndicator(strokeWidth: AppTheme.borderThick, color: colors.onPrimary),
                  )
                : const Text('Aplicar filtros'),
          ),
        ],
      ),
    );
  }
}

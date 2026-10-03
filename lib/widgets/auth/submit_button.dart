import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class SubmitButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback onPressed;

  const SubmitButton({super.key, required this.label, required this.busy, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? Semantics(
              label: 'Cargando',
              child: const SizedBox.square(
                dimension: AppTheme.iconMd,
                child: CircularProgressIndicator(strokeWidth: AppTheme.borderThick),
              ),
            )
          : Text(label),
    );
  }
}

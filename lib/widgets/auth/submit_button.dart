import 'package:flutter/material.dart';

import '../common/gradient_button.dart';

class SubmitButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback onPressed;

  const SubmitButton({super.key, required this.label, required this.busy, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GradientButton(label: label, onPressed: onPressed, busy: busy);
  }
}

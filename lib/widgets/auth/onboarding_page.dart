import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String body;

  const OnboardingPage({super.key, required this.image, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Column(
        children: [
          Expanded(child: Image.asset(image, fit: BoxFit.contain, excludeFromSemantics: true)),
          const SizedBox(height: AppTheme.spacingLg),
          Text(title, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            body,
            style: theme.textTheme.bodyLarge?.copyWith(color: appColors.subtleText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

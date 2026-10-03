import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/responsive_layout.dart';
import '../../theme/theme.dart';
import 'ambient_background.dart';

/// Layout shared by the main tabs: warm background, title, subtitle and a body.
class TabPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget body;

  const TabPage({super.key, required this.title, required this.subtitle, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final padding = ResponsiveLayout.getPadding(context);

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: theme.appBarTheme.systemOverlayStyle!,
        child: AmbientBackground(
          child: SafeArea(
            child: ResponsiveLayout.constrain(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: padding.copyWith(top: AppTheme.spacingLg, bottom: AppTheme.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.headlineLarge),
                        const SizedBox(height: AppTheme.spacingXs),
                        Text(subtitle, style: theme.textTheme.bodyLarge?.copyWith(color: appColors.subtleText)),
                      ],
                    ),
                  ),
                  Expanded(child: body),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

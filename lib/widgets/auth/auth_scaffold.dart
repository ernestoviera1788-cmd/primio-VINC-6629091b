import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../theme/responsive_layout.dart';
import '../../theme/theme.dart';
import '../common/ambient_background.dart';
import '../common/vinco_wordmark.dart';

class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const AuthScaffold({super.key, required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: AnnotatedRegion(
        value: theme.appBarTheme.systemOverlayStyle!,
        child: AmbientBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: ResponsiveLayout.getPadding(context).copyWith(bottom: AppTheme.spacingXl),
              child: ResponsiveLayout.constrain(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Volver',
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => context.canPop() ? context.pop() : context.go('/welcome'),
                        ),
                        const Spacer(),
                        const VincoWordmark(compact: true),
                        const SizedBox(width: AppTheme.spacingMd),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    Text(title, style: theme.textTheme.headlineLarge),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(subtitle, style: theme.textTheme.bodyLarge?.copyWith(color: appColors.subtleText)),
                    const SizedBox(height: AppTheme.spacingLg),
                    child,
                  ],
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.04),
                maxWidth: AppTheme.maxCardWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

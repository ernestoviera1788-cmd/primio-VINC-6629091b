import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AmbientBackground extends StatelessWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = theme.extension<AppColorsExtension>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.9, -1.0),
          radius: 1.3,
          colors: [appColors.glowA, colors.surface],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(1.0, 1.1),
            radius: 1.1,
            colors: [appColors.glowB, appColors.glowB.withValues(alpha: AppTheme.opacityNone)],
          ),
        ),
        child: child,
      ),
    );
  }
}

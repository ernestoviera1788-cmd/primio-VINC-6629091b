import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/round_action_button.dart';

/// Pass ("otro día"), Spark and Like (the interlocking-rings vínculo).
class ActionDock extends StatelessWidget {
  final VoidCallback? onPass;
  final VoidCallback? onSpark;
  final VoidCallback? onLike;

  const ActionDock({super.key, this.onPass, this.onSpark, this.onLike});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.spacingMd, AppTheme.spacingSm, AppTheme.spacingMd, AppTheme.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoundActionButton(icon: Icons.waving_hand_rounded, tooltip: 'Otro día', color: appColors.pass, onPressed: onPass),
          const SizedBox(width: AppTheme.spacingLg),
          RoundActionButton(
            icon: Icons.flare_rounded,
            tooltip: 'Enviar Chispa',
            color: appColors.spark,
            size: AppTheme.actionSmall,
            onPressed: onSpark,
          ),
          const SizedBox(width: AppTheme.spacingLg),
          RoundActionButton(
            icon: Icons.all_inclusive_rounded,
            tooltip: 'Me gusta',
            color: theme.colorScheme.primary,
            iconColor: theme.colorScheme.onPrimary,
            filled: true,
            size: AppTheme.actionHero,
            onPressed: onLike,
          ),
        ],
      ),
    );
  }
}

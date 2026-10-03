import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Original VINCÓ mark: two overlapping rings, a quiet symbol of a bond.
class VincoWordmark extends StatelessWidget {
  final bool compact;

  const VincoWordmark({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const ring = AppTheme.logoRing;

    final mark = SizedBox(
      width: ring * 1.6,
      height: ring,
      child: Stack(
        children: [
          _Ring(color: colors.primary),
          Positioned(left: ring * 0.6, child: _Ring(color: colors.secondary)),
        ],
      ),
    );

    return Semantics(
      label: 'VINCÓ',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          if (!compact) ...[
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'VINCÓ',
              style: theme.textTheme.headlineSmall?.copyWith(color: colors.primary, letterSpacing: 2),
            ),
          ],
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final Color color;

  const _Ring({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTheme.logoRing,
      height: AppTheme.logoRing,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: AppTheme.borderStamp),
      ),
    );
  }
}

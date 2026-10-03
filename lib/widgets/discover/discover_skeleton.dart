import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/skeleton.dart';

class DiscoverSkeleton extends StatelessWidget {
  const DiscoverSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Buscando personas afines',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
        child: SkeletonShimmer(
          child: Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            ),
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            alignment: Alignment.bottomLeft,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(widthFactor: 0.55, child: SkeletonBox(height: AppTheme.iconLg)),
                SizedBox(height: AppTheme.spacingSm),
                FractionallySizedBox(widthFactor: 0.4, child: SkeletonBox(height: AppTheme.skeletonLine)),
                SizedBox(height: AppTheme.spacingSm),
                FractionallySizedBox(widthFactor: 0.8, child: SkeletonBox(height: AppTheme.skeletonLine)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

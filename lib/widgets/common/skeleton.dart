import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../theme/theme.dart';

/// A placeholder block in the shape of the content that is loading.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final bool circle;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = AppTheme.radiusSmall,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

/// Moving highlight over skeleton blocks.
class SkeletonShimmer extends StatelessWidget {
  final Widget child;

  const SkeletonShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Theme.of(context).colorScheme.surface,
      colorOpacity: AppTheme.opacityHint,
      duration: const Duration(milliseconds: 1600),
      child: child,
    );
  }
}

/// Rows of avatar + two text lines, used while lists load.
class SkeletonList extends StatelessWidget {
  final String semanticLabel;
  final int itemCount;

  const SkeletonList({super.key, required this.semanticLabel, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: SkeletonShimmer(
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          itemCount: itemCount,
          separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacingMd),
          itemBuilder: (_, i) => Row(
            children: [
              const SkeletonBox(height: AppTheme.thumbnailSize, width: AppTheme.thumbnailSize, circle: true),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: i.isEven ? 0.5 : 0.4,
                      child: const SkeletonBox(height: AppTheme.skeletonLine),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    FractionallySizedBox(
                      widthFactor: i.isEven ? 0.85 : 0.7,
                      child: const SkeletonBox(height: AppTheme.skeletonLine),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

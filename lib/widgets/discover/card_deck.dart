import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/profile.dart';
import '../../theme/theme.dart';
import 'swipe_card.dart';

class CardDeck extends StatelessWidget {
  final List<DiscoveryCandidate> candidates;
  final String Function(RelationshipIntent) intentLabelOf;
  final ValueChanged<SwipeDecision> onSwipe;
  final ValueChanged<DiscoveryCandidate> onOpen;

  const CardDeck({
    super.key,
    required this.candidates,
    required this.intentLabelOf,
    required this.onSwipe,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final top = candidates.first;
    final next = candidates.length > 1 ? candidates[1] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
      child: Stack(
        children: [
          if (next != null)
            Positioned.fill(
              child: Transform.scale(
                scale: 0.94,
                alignment: Alignment.bottomCenter,
                child: SwipeCard(
                  key: ValueKey('back-${next.profile.id}'),
                  candidate: next,
                  intentLabel: intentLabelOf(next.profile.intent),
                  isInteractive: false,
                ),
              ),
            ),
          Positioned.fill(
            child: SwipeCard(
              key: ValueKey('top-${top.profile.id}'),
              candidate: top,
              intentLabel: intentLabelOf(top.profile.intent),
              onSwipe: onSwipe,
              onOpenProfile: () => onOpen(top),
            )
                .animate(key: ValueKey('anim-${top.profile.id}'))
                .fadeIn(duration: 260.ms)
                .scaleXY(begin: 0.96, end: 1, curve: Curves.easeOutCubic),
          ),
        ],
      ),
    );
  }
}

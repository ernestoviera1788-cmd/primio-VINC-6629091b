import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/profile.dart';
import '../../theme/theme.dart';
import '../common/profile_photo.dart';

/// Full-screen celebration: both photos slide in as rings that interlock,
/// the VINCÓ knot pops between them and golden sparks burst outwards.
class MatchDialog extends StatelessWidget {
  final DiscoveryCandidate candidate;
  final String? myPhoto;
  final VoidCallback onMessage;
  final VoidCallback onKeepGoing;

  const MatchDialog({
    super.key,
    required this.candidate,
    this.myPhoto,
    required this.onMessage,
    required this.onKeepGoing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final appColors = theme.extension<AppColorsExtension>()!;
    final p = candidate.profile;
    final reduce = MediaQuery.disableAnimationsOf(context);
    Duration d(int ms) => reduce ? Duration.zero : Duration(milliseconds: ms);

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppTheme.maxCardWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: AppTheme.avatarLg * 1.8,
                    height: AppTheme.avatarLg * 1.4,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        for (var i = 0; i < 12; i++)
                          _Spark(index: i, color: i.isEven ? appColors.spark : colors.primary, delay: d(500 + i * 30), reduce: reduce),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _Ring(photo: myPhoto, border: colors.primary, label: 'Tu foto')
                              .animate()
                              .fadeIn(duration: d(250))
                              .slideX(begin: -0.7, end: 0, duration: d(600), curve: Curves.easeOutBack),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _Ring(
                            photo: p.photos.isEmpty ? null : p.photos.first,
                            border: appColors.spark,
                            label: 'Foto de ${p.name}',
                          ).animate().fadeIn(duration: d(250)).slideX(begin: 0.7, end: 0, duration: d(600), curve: Curves.easeOutBack),
                        ),
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingSm),
                          decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                          child: Icon(Icons.all_inclusive_rounded, color: colors.onPrimary, size: AppTheme.iconLg),
                        ).animate(delay: d(520)).scale(begin: Offset.zero, end: const Offset(1, 1), duration: d(700), curve: Curves.elasticOut),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  Text(
                    'Vínculo encendido',
                    textAlign: TextAlign.center,
                    style: text.displaySmall?.copyWith(color: appColors.onPhoto),
                  ).animate(delay: d(400)).fadeIn(duration: d(400)).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'A ti y a ${p.name} les gustó lo que vieron. El primer mensaje marca el ritmo.',
                    textAlign: TextAlign.center,
                    style: text.bodyLarge?.copyWith(color: appColors.onPhoto),
                  ).animate(delay: d(550)).fadeIn(duration: d(400)),
                  const SizedBox(height: AppTheme.spacingXl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onMessage,
                      icon: const Icon(Icons.chat_bubble_rounded),
                      label: const Text('Enviar mensaje'),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: appColors.onPhoto,
                        side: BorderSide(color: appColors.onPhoto),
                      ),
                      onPressed: onKeepGoing,
                      child: const Text('Seguir descubriendo'),
                    ),
                  ),
                ],
              ).animate(delay: d(650)).custom(duration: Duration.zero, builder: (_, _, child) => child),
            ),
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final String? photo;
  final Color border;
  final String label;

  const _Ring({required this.photo, required this.border, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXs),
      decoration: BoxDecoration(color: border, shape: BoxShape.circle),
      child: ClipOval(
        child: ProfilePhoto(
          source: photo,
          width: AppTheme.avatarLg,
          height: AppTheme.avatarLg,
          cacheWidth: 300,
          semanticLabel: label,
        ),
      ),
    );
  }
}

class _Spark extends StatelessWidget {
  final int index;
  final Color color;
  final Duration delay;
  final bool reduce;

  const _Spark({required this.index, required this.color, required this.delay, required this.reduce});

  @override
  Widget build(BuildContext context) {
    if (reduce) return const SizedBox.shrink();
    final angle = index * 2 * math.pi / 12;
    final r = AppTheme.avatarLg * 0.85;
    return Container(
      width: AppTheme.sparkDot,
      height: AppTheme.sparkDot,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    )
        .animate(delay: delay)
        .fadeIn(duration: 150.ms)
        .move(begin: Offset.zero, end: Offset(math.cos(angle) * r, math.sin(angle) * r), duration: 700.ms, curve: Curves.easeOutCubic)
        .then()
        .fadeOut(duration: 400.ms);
  }
}

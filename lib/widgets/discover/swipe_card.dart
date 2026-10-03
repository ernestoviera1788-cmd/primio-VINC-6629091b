import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/profile.dart';
import '../../theme/theme.dart';
import '../common/profile_photo.dart';

/// Swipe right = like, left = pass, up = spark. Tap the sides to change
/// photo, tap the centre to open the full profile.
class SwipeCard extends StatefulWidget {
  final DiscoveryCandidate candidate;
  final String intentLabel;
  final bool isInteractive;
  final ValueChanged<SwipeDecision>? onSwipe;
  final VoidCallback? onOpenProfile;

  const SwipeCard({
    super.key,
    required this.candidate,
    required this.intentLabel,
    this.isInteractive = true,
    this.onSwipe,
    this.onOpenProfile,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  static const double _threshold = 110;
  Offset _drag = Offset.zero;
  bool _dragging = false;
  int _photo = 0;

  void _onPanEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond;
    SwipeDecision? decision;
    if (_drag.dx > _threshold || v.dx > 900) {
      decision = SwipeDecision.like;
    } else if (_drag.dx < -_threshold || v.dx < -900) {
      decision = SwipeDecision.pass;
    } else if (_drag.dy < -_threshold * 1.2) {
      decision = SwipeDecision.spark;
    }
    setState(() {
      _dragging = false;
      _drag = Offset.zero;
    });
    if (decision != null) {
      HapticFeedback.mediumImpact();
      widget.onSwipe?.call(decision);
    }
  }

  void _onTapUp(TapUpDetails d, double width) {
    final count = widget.candidate.profile.photos.length;
    final x = d.localPosition.dx;
    if (count > 1 && x < width * 0.3) {
      HapticFeedback.selectionClick();
      setState(() => _photo = (_photo - 1 + count) % count);
    } else if (count > 1 && x > width * 0.7) {
      HapticFeedback.selectionClick();
      setState(() => _photo = (_photo + 1) % count);
    } else {
      widget.onOpenProfile?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final appColors = theme.extension<AppColorsExtension>()!;
    final p = widget.candidate.profile;
    final intent = p.intention ?? widget.intentLabel;
    final place = [widget.candidate.distanceLabel, intent].where((s) => s.isNotEmpty).join('  ·  ');
    final likeT = (_drag.dx / _threshold).clamp(0.0, 1.0);
    final passT = (-_drag.dx / _threshold).clamp(0.0, 1.0);
    final sparkT = ((-_drag.dy / _threshold).clamp(0.0, 1.0) * (1 - (likeT > passT ? likeT : passT))).toDouble();
    final instant = _dragging || MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onPanUpdate: widget.isInteractive
            ? (d) => setState(() {
                  _dragging = true;
                  _drag += d.delta;
                })
            : null,
        onPanEnd: widget.isInteractive ? _onPanEnd : null,
        onTapUp: widget.isInteractive ? (d) => _onTapUp(d, constraints.maxWidth) : null,
        child: AnimatedContainer(
          duration: instant ? Duration.zero : const Duration(milliseconds: 320),
          curve: Curves.easeOutBack,
          transformAlignment: Alignment.center,
          transform: Matrix4.translationValues(_drag.dx, _drag.dy, 0)..rotateZ(_drag.dx / 900),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: AppTheme.opacityShadow),
                blurRadius: AppTheme.shadowBlur,
                offset: const Offset(0, AppTheme.shadowOffset),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ProfilePhoto(
                  source: p.photos.isEmpty ? null : p.photos[_photo.clamp(0, p.photos.length - 1)],
                  semanticLabel: 'Foto de ${p.name}',
                ),
                if (p.photos.length > 1)
                  Positioned(
                    top: AppTheme.spacingSm,
                    left: AppTheme.spacingMd,
                    right: AppTheme.spacingMd,
                    child: Row(
                      children: [
                        for (var i = 0; i < p.photos.length; i++)
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: AppTheme.indicatorHeight,
                              margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXxs),
                              decoration: BoxDecoration(
                                color: appColors.onPhoto.withValues(alpha: i == _photo ? 1 : AppTheme.opacityBorderSoft),
                                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                Positioned(
                  top: AppTheme.spacingXl,
                  left: AppTheme.spacingLg,
                  child: _Stamp(label: 'VÍNCULO', icon: Icons.all_inclusive_rounded, color: appColors.like, t: likeT, angle: -0.2),
                ),
                Positioned(
                  top: AppTheme.spacingXl,
                  right: AppTheme.spacingLg,
                  child: _Stamp(label: 'OTRO DÍA', icon: Icons.waving_hand_rounded, color: appColors.pass, t: passT, angle: 0.2),
                ),
                Align(
                  alignment: const Alignment(0, 0.1),
                  child: _Stamp(label: 'CHISPA', icon: Icons.flare_rounded, color: appColors.spark, t: sparkT, angle: 0),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.4, 1],
                        colors: [
                          appColors.photoScrim.withValues(alpha: AppTheme.opacityNone),
                          appColors.photoScrim.withValues(alpha: AppTheme.opacityScrimMid),
                          appColors.photoScrim,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingXxl * 2, AppTheme.spacingSm, AppTheme.spacingLg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.age > 0 ? '${p.name}, ${p.age}' : p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.headlineMedium?.copyWith(color: appColors.onPhoto),
                                ),
                                if (place.isNotEmpty) ...[
                                  const SizedBox(height: AppTheme.spacingXs),
                                  Row(
                                    children: [
                                      Icon(Icons.place_outlined, size: AppTheme.iconSm, color: appColors.onPhoto),
                                      const SizedBox(width: AppTheme.spacingXs),
                                      Flexible(
                                        child: Text(
                                          place,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: text.bodyMedium?.copyWith(color: appColors.onPhoto),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (p.bio.isNotEmpty) ...[
                                  const SizedBox(height: AppTheme.spacingSm),
                                  Text(
                                    p.bio,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.bodyLarge?.copyWith(color: appColors.onPhoto),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Ver perfil completo',
                            color: appColors.onPhoto,
                            onPressed: widget.onOpenProfile,
                            icon: const Icon(Icons.info_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stamp extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double t;
  final double angle;

  const _Stamp({required this.label, required this.icon, required this.color, required this.t, required this.angle});

  @override
  Widget build(BuildContext context) {
    if (t <= 0) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    return Opacity(
      opacity: t,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
          decoration: BoxDecoration(
            color: appColors.photoScrim,
            border: Border.all(color: color, width: AppTheme.borderStamp),
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: appColors.onPhoto, size: AppTheme.iconMd),
              const SizedBox(width: AppTheme.spacingSm),
              Text(label, style: theme.textTheme.titleMedium?.copyWith(color: appColors.onPhoto, letterSpacing: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}

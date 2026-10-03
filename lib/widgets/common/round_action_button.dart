import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/theme.dart';

class RoundActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final double size;
  final bool filled;
  final Color? iconColor;
  final VoidCallback? onPressed;

  const RoundActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.color,
    this.size = AppTheme.actionLarge,
    this.filled = false,
    this.iconColor,
    this.onPressed,
  });

  @override
  State<RoundActionButton> createState() => _RoundActionButtonState();
}

class _RoundActionButtonState extends State<RoundActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = widget.onPressed != null;
    final base = widget.filled ? (widget.iconColor ?? colors.onPrimary) : widget.color;
    final fg = enabled ? base : base.withValues(alpha: AppTheme.opacityDisabled);
    final bg = widget.filled
        ? (enabled ? widget.color : widget.color.withValues(alpha: AppTheme.opacityDisabled))
        : colors.surfaceContainerLowest;

    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: widget.tooltip,
        child: AnimatedScale(
          scale: _pressed ? 0.86 : 1,
          duration: Duration(milliseconds: _pressed ? 100 : 420),
          curve: _pressed ? Curves.easeOut : Curves.elasticOut,
          child: Material(
            color: bg,
            elevation: AppTheme.elevationAction,
            shadowColor: colors.shadow,
            shape: CircleBorder(
              side: widget.filled
                  ? BorderSide.none
                  : BorderSide(color: fg.withValues(alpha: AppTheme.opacityBorderSoft), width: AppTheme.borderThick),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onHighlightChanged: (v) => setState(() => _pressed = v),
              onTap: enabled
                  ? () {
                      HapticFeedback.mediumImpact();
                      widget.onPressed!();
                    }
                  : null,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Icon(widget.icon, color: fg, size: widget.size * 0.44),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

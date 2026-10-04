import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Primary call-to-action: violet → pink gradient pill, 52px tall,
/// white semibold label. The noir signature button.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null && !busy;
    final content = busy
        ? const SizedBox.square(
            dimension: AppTheme.iconMd,
            child: CircularProgressIndicator(strokeWidth: AppTheme.borderThick, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: AppTheme.spacingSm),
              ],
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        height: AppTheme.buttonHeight,
        decoration: BoxDecoration(
          gradient: enabled ? AppTheme.primaryGradient : null,
          color: enabled ? null : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          boxShadow: enabled
              ? const [
                  BoxShadow(
                    color: Color(0x59EC4899),
                    blurRadius: 22,
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

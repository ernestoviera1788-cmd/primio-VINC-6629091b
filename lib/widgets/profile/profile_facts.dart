import 'package:flutter/material.dart';

import '../../models/profile.dart';
import '../../theme/theme.dart';
import '../common/interest_chip.dart';

class ProfileFacts extends StatelessWidget {
  final DiscoveryCandidate candidate;
  final String intentLabel;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;

  const ProfileFacts({
    super.key,
    required this.candidate,
    required this.intentLabel,
    this.onReport,
    this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final appColors = theme.extension<AppColorsExtension>()!;
    final p = candidate.profile;
    final shared = candidate.sharedInterests.toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(child: Text('${p.name}, ${p.age}', style: text.headlineLarge, maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (p.isVerified) ...[
              const SizedBox(width: AppTheme.spacingSm),
              Icon(Icons.verified_rounded, color: appColors.verified, semanticLabel: 'Perfil verificado'),
            ],
          ],
        ),
        Text(
          [if (p.pronouns != null) p.pronouns!, candidate.distanceLabel].where((s) => s.isNotEmpty).join('  ·  '),
          style: text.bodyLarge?.copyWith(color: appColors.subtleText),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        if (candidate.compatibility > 0) ...[
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
            child: Row(
              children: [
                Text('${candidate.compatibility}%', style: text.headlineLarge?.copyWith(color: colors.onPrimaryContainer)),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Text(
                    'de afinidad · ${shared.length} intereses en común',
                    style: text.bodyMedium?.copyWith(color: colors.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
        ],
        if (p.bio.isNotEmpty) ...[
          Text('Sobre mí', style: text.titleMedium),
          const SizedBox(height: AppTheme.spacingSm),
          Text(p.bio, style: text.bodyLarge),
          const SizedBox(height: AppTheme.spacingLg),
        ],
        if (intentLabel.isNotEmpty) _FactRow(icon: Icons.favorite_outline_rounded, label: 'Busca', value: intentLabel),
        if (p.job != null) _FactRow(icon: Icons.work_outline_rounded, label: 'Profesión', value: p.job!),
        if (p.education != null) _FactRow(icon: Icons.school_outlined, label: 'Educación', value: p.education!),
        if (p.hobbies != null) _FactRow(icon: Icons.palette_outlined, label: 'Hobbies', value: p.hobbies!),
        if (p.lifestyle != null) _FactRow(icon: Icons.spa_outlined, label: 'Estilo de vida', value: p.lifestyle!),
        if (p.heightCm != null) _FactRow(icon: Icons.height_rounded, label: 'Altura', value: '${p.heightCm} cm'),
        if (p.languages.isNotEmpty) _FactRow(icon: Icons.translate_rounded, label: 'Idiomas', value: p.languages.join(', ')),
        const SizedBox(height: AppTheme.spacingLg),
        if (p.interests.isNotEmpty) ...[
          Text('Intereses', style: text.titleMedium),
          const SizedBox(height: AppTheme.spacingSm),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: [for (final i in p.interests) InterestChip(label: i, highlighted: shared.contains(i))],
          ),
          const SizedBox(height: AppTheme.spacingLg),
        ],
        if (onReport != null || onBlock != null)
          Wrap(
            spacing: AppTheme.spacingSm,
            children: [
              if (onReport != null)
                TextButton.icon(onPressed: onReport, icon: const Icon(Icons.flag_outlined), label: Text('Reportar a ${p.name}')),
              if (onBlock != null)
                TextButton.icon(onPressed: onBlock, icon: const Icon(Icons.block_rounded), label: const Text('Bloquear')),
            ],
          ),
      ],
    );
  }
}

class _FactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FactRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      child: Row(
        children: [
          Icon(icon, size: AppTheme.iconMd, color: theme.colorScheme.primary),
          const SizedBox(width: AppTheme.spacingMd),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: appColors.subtleText)),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Text(value, textAlign: TextAlign.end, style: theme.textTheme.bodyLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

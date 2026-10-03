import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/vinco_wordmark.dart';

class DiscoverHeader extends StatelessWidget {
  final VoidCallback onFilters;

  const DiscoverHeader({super.key, required this.onFilters});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingSm, AppTheme.spacingMd, AppTheme.spacingXs),
      child: Row(
        children: [
          const VincoWordmark(),
          const Spacer(),
          IconButton.filledTonal(
            tooltip: 'Filtros',
            onPressed: onFilters,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
    );
  }
}

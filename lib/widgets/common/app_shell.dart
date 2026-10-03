import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/responsive_layout.dart';
import '../../theme/theme.dart';
import 'vinco_wordmark.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  static const _items = [
    (Icons.explore_outlined, Icons.explore_rounded, 'Descubrir'),
    (Icons.favorite_border_rounded, Icons.favorite_rounded, 'Actividad'),
    (Icons.all_inclusive_rounded, Icons.all_inclusive_rounded, 'Vínculos'),
    (Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Mensajes'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
  ];

  void _go(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isMobileLayout(context)) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _go,
          destinations: [
            for (final item in _items)
              NavigationDestination(icon: Icon(item.$1), selectedIcon: Icon(item.$2), label: item.$3),
          ],
        ),
      );
    }
    final extended = ResponsiveLayout.isDesktopLayout(context);
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            right: false,
            child: NavigationRail(
              extended: extended,
              labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _go,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
                child: VincoWordmark(compact: !extended),
              ),
              destinations: [
                for (final item in _items)
                  NavigationRailDestination(icon: Icon(item.$1), selectedIcon: Icon(item.$2), label: Text(item.$3)),
              ],
            ),
          ),
          const VerticalDivider(width: AppTheme.borderDefault, thickness: AppTheme.borderDefault),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/notifications_provider.dart';
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

  /// Index of the tab that shows the notification badge.
  static const _activityIndex = 1;

  /// Index of the tab that shows a dot for unread messages.
  static const _messagesIndex = 3;

  void _go(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  Widget _tabIcon(BuildContext context, int index, IconData icon, int unread, int msgUnread) {
    final themed = Icon(icon);
    if (index == _messagesIndex && msgUnread > 0) {
      return Badge(
        smallSize: 10,
        backgroundColor: const Color(0xFFEC4899),
        child: themed,
      );
    }
    if (index != _activityIndex || unread <= 0) return themed;
    return Badge(
      label: Text(unread > 99 ? '99+' : '$unread'),
      child: themed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationsProvider>().activityUnreadCount;
    final msgUnread = context.watch<NotificationsProvider>().messageUnreadCount;
    if (ResponsiveLayout.isMobileLayout(context)) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _go,
          destinations: [
            for (int i = 0; i < _items.length; i++)
              NavigationDestination(
                icon: _tabIcon(context, i, _items[i].$1, unread, msgUnread),
                selectedIcon: _tabIcon(context, i, _items[i].$2, unread, msgUnread),
                label: _items[i].$3,
              ),
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
                for (int i = 0; i < _items.length; i++)
                  NavigationRailDestination(
                    icon: _tabIcon(context, i, _items[i].$1, unread, msgUnread),
                    selectedIcon: _tabIcon(context, i, _items[i].$2, unread, msgUnread),
                    label: Text(_items[i].$3),
                  ),
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

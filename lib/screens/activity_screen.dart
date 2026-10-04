import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_notification.dart';
import '../providers/auth_provider.dart';
import '../providers/notifications_provider.dart';
import '../theme/responsive_layout.dart';
import '../theme/theme.dart';
import '../widgets/activity/notification_tile.dart';
import '../widgets/common/sign_in_required_view.dart';
import '../widgets/common/skeleton.dart';
import '../widgets/common/state_view.dart';
import '../widgets/common/tab_page.dart';
import '../widgets/common/time_format.dart';
import 'match_actions.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  Future<void> _open(BuildContext context, AppNotification n) async {
    final messenger = ScaffoldMessenger.of(context);
    final conversationId = n.conversationId;
    if (conversationId != null) openChat(context, conversationId);
    final error = await context.read<NotificationsProvider>().markRead(n);
    if (error != null) messenger.showSnackBar(SnackBar(content: Text(error)));
  }

  static String _dayLabel(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final day = DateUtils.dateOnly(date.toLocal());
    final diff = today.difference(day).inDays;
    if (diff <= 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    return shortDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<NotificationsProvider>();
    final padding = ResponsiveLayout.getPadding(context);
    final text = Theme.of(context).textTheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    final Widget body;
    if (n.needsSignIn) {
      body = SignInRequiredView(
        message: 'Aquí verás tus vínculos, mensajes y avisos cuando tengas una cuenta.',
        onSignIn: () => context.read<AuthProvider>().leaveGuestMode(),
      );
    } else if (n.isLoading && n.activityItems.isEmpty) {
      body = const SkeletonList(semanticLabel: 'Cargando tu actividad');
    } else if (n.error != null && n.activityItems.isEmpty) {
      body = StateView(icon: Icons.cloud_off_rounded, title: 'No pudimos cargar tu actividad', message: n.error!, primaryLabel: 'Reintentar', onPrimary: n.load);
    } else if (n.activityItems.isEmpty) {
      body = StateView(
        icon: Icons.notifications_none_rounded,
        image: 'assets/images/empty_activity.png',
        title: 'Todo tranquilo por aquí',
        message: 'Cuando tengas un vínculo o un like, lo verás en esta lista.',
        primaryLabel: 'Actualizar',
        onPrimary: n.load,
      );
    } else {
      final entries = <Object>[];
      String? lastDay;
      for (final item in n.activityItems) {
        final day = _dayLabel(item.createdAt);
        if (day != lastDay) {
          entries.add(day);
          lastDay = day;
        }
        entries.add(item);
      }
      body = RefreshIndicator(
        onRefresh: n.load,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding.copyWith(top: 0),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e = entries[i];
            if (e is String) {
              return Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : AppTheme.spacingMd, bottom: AppTheme.spacingSm),
                child: Text(e, style: text.titleSmall?.copyWith(color: appColors.subtleText)),
              );
            }
            final item = e as AppNotification;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: NotificationTile(notification: item, onTap: () => _open(context, item)),
            );
          },
        ),
      );
    }

    return TabPage(
      title: 'Actividad',
      subtitle: n.activityUnreadCount > 0 ? '${n.activityUnreadCount} sin leer' : 'Vínculos y likes.',
      body: body,
    );
  }
}

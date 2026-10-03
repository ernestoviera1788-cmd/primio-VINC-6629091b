import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider({required NotificationService service}) : _service = service;

  final NotificationService _service;
  List<AppNotification> _items = const [];
  int _unread = 0;
  bool _loading = false;
  bool _disposed = false;
  String? _error;

  List<AppNotification> get items => _items;
  int get unreadCount => _unread;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get needsSignIn => !_service.hasSession;

  Future<void> load() async {
    if (needsSignIn) return;
    _loading = true;
    _error = null;
    _notify();
    try {
      final page = await _service.load();
      _items = page.items;
      _unread = page.unreadCount;
    } catch (e) {
      _error = AuthService.messageFor(e);
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<String?> markRead(AppNotification n) async {
    if (n.isRead) return null;
    try {
      await _service.markRead(n.id);
      _items = [for (final x in _items) x.id == n.id ? x.markedRead() : x];
      if (_unread > 0) _unread--;
      _notify();
      return null;
    } catch (e) {
      return AuthService.messageFor(e);
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

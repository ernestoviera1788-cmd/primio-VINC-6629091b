import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../services/auth_service.dart';
import '../services/local_notifications.dart';
import '../services/notification_service.dart';

class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider({required NotificationService service}) : _service = service;

  final NotificationService _service;
  List<AppNotification> _items = const [];
  int _unread = 0;
  bool _loading = false;
  bool _disposed = false;
  String? _error;

  Timer? _pollTimer;
  final Set<String> _seenIds = {};

  /// Local toggles (no server-side read action; defaults all on).
  bool likesEnabled = true;
  bool matchesEnabled = true;
  bool messagesEnabled = true;

  List<AppNotification> get items => _items;

  /// Items shown in the Activity tab: message notifications are excluded —
  /// those live in the Messages tab (and still trigger push notifications).
  List<AppNotification> get activityItems =>
      _items.where((n) => n.type != 'message').toList();

  int get unreadCount => _unread;

  /// Unread count for the Activity tab (excludes messages).
  int get activityUnreadCount =>
      _items.where((n) => n.type != 'message' && !n.isRead).length;

  /// Unread message count for the Messages tab dot.
  int get messageUnreadCount =>
      _items.where((n) => n.type == 'message' && !n.isRead).length;
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
      _seenIds.addAll(page.items.map((n) => n.id));
    } catch (e) {
      _error = AuthService.messageFor(e);
    } finally {
      _loading = false;
      _notify();
    }
  }

  /// Starts the 30s background poll for new notifications.
  void startPolling() {
    stopPolling();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _poll());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _poll() async {
    if (needsSignIn || _disposed) return;
    try {
      final page = await _service.load();
      final fresh = <AppNotification>[];
      for (final n in page.items) {
        if (n.readAt == null && !_seenIds.contains(n.id) && _typeEnabled(n.type)) {
          fresh.add(n);
        }
      }
      _seenIds.addAll(page.items.map((n) => n.id));
      _items = page.items;
      _unread = page.unreadCount;
      _notify();
      for (final n in fresh) {
        await LocalNotifications.show(
          id: n.id.hashCode,
          title: n.title,
          body: n.body,
          payload: jsonEncode({'type': n.type, 'conversationId': n.conversationId}),
        );
      }
    } catch (_) {
      // Polling is best-effort: keep the last known state on failure.
    }
  }

  bool _typeEnabled(String type) {
    switch (type) {
      case 'like':
        return likesEnabled;
      case 'match':
        return matchesEnabled;
      case 'message':
        return messagesEnabled;
      default:
        return true;
    }
  }

  Future<String?> updateNotificationSettings({
    required bool likes,
    required bool matches,
    required bool messages,
  }) async {
    try {
      await _service.updateSettings(likes: likes, matches: matches, messages: messages);
      likesEnabled = likes;
      matchesEnabled = matches;
      messagesEnabled = messages;
      _notify();
      return null;
    } catch (e) {
      return AuthService.messageFor(e);
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

  /// Marks all unread message notifications for a conversation as read
  /// (called when the user opens the chat, so the Messages tab dot clears).
  /// Updates local state immediately (dot disappears at once), persists to
  /// the backend, then re-syncs to guarantee DB/app/UI are consistent.
  Future<void> markConversationRead(String conversationId) async {
    // 0. Fetch fresh state first: the notification may not be local yet.
    try {
      final page = await _service.load();
      _items = page.items;
      _unread = page.unreadCount;
      _seenIds.addAll(page.items.map((n) => n.id));
    } catch (_) {
      // Fall through with the local list on failure.
    }
    // 1. Optimistic local update: clear the dot immediately.
    final localTargets = _items
        .where((n) => n.type == 'message' && !n.isRead && n.conversationId == conversationId)
        .toList();
    if (localTargets.isNotEmpty) {
      final ids = localTargets.map((n) => n.id).toSet();
      _items = [for (final x in _items) ids.contains(x.id) ? x.markedRead() : x];
      _unread = _items.where((n) => !n.isRead).length;
      _notify();
    }
    // 2. Persist each to the backend (individual markRead calls).
    for (final n in localTargets) {
      try {
        await _service.markRead(n.id);
      } catch (_) {
        // Best-effort: the final re-sync below will reconcile.
      }
    }
    // 3. Re-sync with the server to guarantee consistency; the dot must
    //    not reappear for already-read messages (server is source of truth).
    try {
      final page = await _service.load();
      _items = page.items;
      _unread = page.unreadCount;
      _seenIds.addAll(page.items.map((n) => n.id));
      _notify();
    } catch (_) {
      // Keep the optimistic local state on failure.
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    _disposed = true;
    super.dispose();
  }
}

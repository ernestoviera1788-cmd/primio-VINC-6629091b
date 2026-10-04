import '../models/app_notification.dart';
import 'api_client.dart';
import 'profile_parser.dart';

class NotificationPage {
  final List<AppNotification> items;
  final int unreadCount;

  const NotificationPage(this.items, this.unreadCount);
}

class NotificationRepository {
  final ApiClient _api;
  final String? Function() _token;

  NotificationRepository({ApiClient? api, required String? Function() tokenProvider})
      : _api = api ?? ApiClient(),
        _token = tokenProvider;

  bool get hasSession => _token() != null;

  Future<NotificationPage> list({int limit = 50, int offset = 0}) async {
    final data = await _api.sendAuthed('listnotifications', _token(), {'limit': limit, 'offset': offset});
    if (data is! Map || data['notifications'] is! List) {
      throw ApiException('BAD_RESPONSE', 'listnotifications: $data');
    }
    final items = [
      for (final n in data['notifications'] as List)
        if (n is Map)
          AppNotification(
            id: '${n['id']}',
            type: '${n['type'] ?? ''}',
            title: '${n['title'] ?? ''}',
            body: '${n['body'] ?? ''}',
            data: n['data'] is Map ? Map<String, dynamic>.from(n['data'] as Map) : const {},
            readAt: ProfileParser.dateOrNull(n['readAt']),
            createdAt: ProfileParser.date(n['createdAt']),
          ),
    ];
    final unread = data['unreadCount'] is num
        ? (data['unreadCount'] as num).toInt()
        : items.where((n) => !n.isRead).length;
    return NotificationPage(items, unread);
  }

  Future<void> markRead(String notificationId) async {
    await _api.sendAuthed('marknotificationread', _token(), {'notificationId': notificationId});
  }

  /// Persists the user's notification toggles on the server.
  Future<void> updateSettings({
    required bool likes,
    required bool matches,
    required bool messages,
  }) async {
    await _api.sendAuthed('updatenotificationsettings', _token(), {
      'likes': likes,
      'matches': matches,
      'messages': messages,
      'security': true,
      'marketing': false,
    });
  }
}
